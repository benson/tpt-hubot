Conversation = require 'hubot-conversation'

QUERY_CATEGORIES = ['GMV', 'Users', 'Products']
api_url = "http://tpt-api-hack.awesome-labs.com/"

validDate = (date) ->
  if Object.prototype.toString.call(date) == "[object Date]"
    return true unless isNaN(date.getTime())
  return false

datepicker = (dialog, success) ->
  dialog.addChoice(/(.*)/i, (msg) ->
    date = new Date(msg.match[1])
    if validDate(date)
      success(date)
    else
      msg.send "That date doesn't seem to be valid. Try formatting it like this: ```MM/DD/YYYY```"
      datepicker(dialog, success)
  )

humanReadableDate = (date) ->
  date.toUTCString()[0..15]

removeDuplicates = (ar) ->
  if ar.length == 0
    return []
  res = {}
  res[ar[key]] = ar[key] for key in [0..ar.length-1]
  value for key, value of res


querypicker = (dialog, name, queries) ->
    to_send = "_Available #{name} queries:_ ```"
    for query, i in queries
      to_send = to_send + "\n [#{i}] #{query.name}"
      to_send = to_send + "\n\t #{query.description}"
    msg.send to_send + "```"

    dialog.addChoice(/(\d{1,3})/i, (msg2) ->
      selected_query = queries[msg2.match[1]]
      msg.send "_You chose *#{selected_query.name}*. Your query is running..._:wall:"
      url = api_url + "api/queries/#{selected_query._id}"
      results_url = api_url + "queries/#{selected_query._id}"
      robot.http(url)
        .header('Content-Type', 'application/json')
        .post() (err, res, body) ->
          if err
            msg.send "Error: #{err}"
            return
          msg.send "_Query is done running! Check out the results here:_ \n ```" + results_url + "```"
    )
  )

# ================================================================
module.exports = (robot) ->
  switchboard = new Conversation(robot)

  robot.respond /.*data.*request/i, (msg) ->
    dialog = switchboard.startDialog(msg)

    robot.http(api_url + "api/queries")
      .get() (err, res, body) ->
        if err
          msg.send "Error: #{err}"
          return
        queries = JSON.parse(body)

        msg.reply "I have a lot of stored data queries. How would you like to browse?"
        msg.reply "``` [1] Category \n[2] Most Recent \n[3] Popular ```"

        dialog.addChoice(/category|1/i, (msg2) ->
          gmv_queries = (query for query in queries when query.category is "GMV")
          user_queries = (query for query in queries when query.category is "Users")
          product_queries = (query for query in queries when query.category is "Products")

          msg.reply "Which category are you interested in?"
          for request, i in QUERY_CATGORIES
            to_send = to_send + "\n [#{i+1}] #{request}"
          msg.send "```" + to_send + '```'

          # ================ GMV queries ===================
          dialog.addChoice(/GMV|1/i, (msg2) ->
            querypicker(dialog, "GMV", gmv_queries)
            # to_send = "_Available GMV queries:_ ```"
            # for query, i in gmv_queries
              # to_send = to_send + "\n [#{i}] #{query.name}"
              # to_send = to_send + "\n\t #{query.description}"
            # msg.send to_send + "```"

            # dialog.addChoice(/(\d{1,3})/i, (msg2) ->
              # selected_query = gmv_queries[msg2.match[1]]
              # msg.send "_You chose *#{selected_query.name}*. Your query is running..._:wall:"
              # url = api_url + "api/queries/#{selected_query._id}"
              # results_url = api_url + "queries/#{selected_query._id}"
              # robot.http(url)
                # .header('Content-Type', 'application/json')
                # .post() (err, res, body) ->
                  # if err
                    # msg.send "Error: #{err}"
                    # return
                  # msg.send "_Query is done running! Check out the results here:_ \n ```" + results_url + "```"
            # )
          )

          # ================ User queries ===================
          dialog.addChoice(/user|2/i, (msg2) ->
            to_send = "_Available 'users' queries:_ ```"
            for query, i in user_queries
              to_send = to_send + "\n [#{i}] #{query.name}"
              to_send = to_send + "\n\t #{query.description}"
            msg.send to_send + "```"

            dialog.addChoice(/(\d{1,3})/i, (msg2) ->
              selected_query = user_queries[msg2.match[1]]
              msg.send "_You chose *#{selected_query.name}*. Your query is running..._:wall:"
              url = api_url + "api/queries/#{selected_query._id}"
              results_url = api_url + "queries/#{selected_query._id}"
              robot.http(url)
                .header('Content-Type', 'application/json')
                .post() (err, res, body) ->
                  if err
                    msg.send "Error: #{err}"
                    return
                  msg.send "_Query is done running! Check out the results here:_ \n ```" + results_url + "```"
            )
          )

          # ================ Product queries ===================
          dialog.addChoice(/product|2/i, (msg2) ->
            to_send = "_Available 'products' queries:_ ```"
            for query, i in product_queries
              to_send = to_send + "\n [#{i}] #{query.name}"
              to_send = to_send + "\n\t #{query.description}"
            msg.send to_send + "```"

            dialog.addChoice(/(\d{1,3})/i, (msg2) ->
              selected_query = product_queries[msg2.match[1]]
              msg.send "_You chose *#{selected_query.name}*. Your query is running..._:wall:"
              url = api_url + "api/queries/#{selected_query._id}"
              results_url = api_url + "queries/#{selected_query._id}"
              robot.http(url)
                .header('Content-Type', 'application/json')
                .post() (err, res, body) ->
                  if err
                    msg.send "Error: #{err}"
                    return
                  msg.send "_Query is done running! Check out the results here:_ \n ```" + results_url + "```"
            )
          )
        )

        dialog.addChoice(/most recent|2/i, (msg2) ->
          # recent stuff here
        )

        dialog.addChoice(/popular|3/i, (msg2) ->
          # popular? stuff here
        )

        # TODO: change this to be actual category, not name
        # categories = removeDuplicates((query.name for query in queries))

  robot.respond /.*queries.*/i, (msg) ->
    dialog = switchboard.startDialog(msg)

    robot.http(api_url + "api/queries")
      .get() (err, res, body) ->
        if err
          msg.send "Error: #{err}"
          return
        data = JSON.parse(body)
        to_send = "_Available queries:_ ```"
        for query, i in data
          to_send = to_send + "\n [#{i}] #{query.name}"
          to_send = to_send + "\n\t #{query.description}"
        msg.send to_send + "```"

        dialog.addChoice(/(\d{1,3})/i, (msg2) ->
          selection = msg2.match[1]
          msg.send "_You chose *#{data[selection].name}*. Your query is running..._:wall:"
          url = api_url + "api/queries/#{data[selection]._id}"
          results_url = api_url + "queries/#{data[selection]._id}"
          robot.http(url)
            .header('Content-Type', 'application/json')
            .post() (err, res, body) ->
              if err
                msg.send "Error: #{err}"
                return
              msg.send "_Query is done running! Check out the results here:_ \n ```" + results_url + "```"
              # data = JSON.parse(body)
              # to_send = ""
              # for item in data
                # to_send = to_send + "\n ```#{JSON.stringify(item)}```"
              # msg.send "```" + to_send + "```"
        )

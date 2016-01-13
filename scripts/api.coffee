Conversation = require 'hubot-conversation'

# api_url = "http://tpt-api-hack.awesome-labs.com"
api_url = "http://localhost:3000"

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


querypicker = (dialog, name, queries, msg, robot) ->
  to_send = "_Available #{name} queries:_ ```"
  for query, i in queries
    to_send = to_send + "\n [#{i+1}] #{query.name}"
    to_send = to_send + "\n\t #{query.description}"
  msg.send to_send + "```"

  dialog.addChoice(/(\d{1,3})/i, (msg2) ->
    selected_query = queries[msg2.match[1]-1]
    msg.send "_You chose *#{selected_query.name}*. Your query is running..._:wall:"
    url = api_url + "/api/queries/#{selected_query.id}"
    results_url = api_url + "/queries/#{selected_query.id}"
    robot.http(url)
      .header('Authorization', 'token 40fc7d904b7bcb1a7940a93d19f4193ccf997367e809f7847ced8474d9bb1028091cc1f2b0edad6279b5ff7c44dd408dde6b5c701a3ffcb148bcd78e64c076b6')
      .post() (err, res, body) ->
        if err
          msg.send "Error: #{err}"
          return
        msg.send "_Query is done running! Check out the results here:_ \n ```" + results_url + "```"
  )

# ================================================================
module.exports = (robot) ->
  switchboard = new Conversation(robot)

  robot.respond /.*data.*request/i, (msg) ->
    dialog = switchboard.startDialog(msg)

    robot.http(api_url + "/api/queries")
      .header('Authorization', 'token 40fc7d904b7bcb1a7940a93d19f4193ccf997367e809f7847ced8474d9bb1028091cc1f2b0edad6279b5ff7c44dd408dde6b5c701a3ffcb148bcd78e64c076b6')
      .get() (err, res, body) ->
        if err
          msg.send "Error: #{err}"
          return
        queries = JSON.parse(body)

        msg.send "```How would you like to browse queries?\n[1] Category \n[2] Most Recent \n[3] User ```"

# ================ FILTER BY CATEGORY =========================
        dialog.addChoice(/category|1/i, (msg2) ->
          gmv_queries     = queries.filter (query) -> query.category is "gmv"
          user_queries    = queries.filter (query) -> query.category is "users"
          product_queries = queries.filter (query) -> query.category is "products"

          to_send = "Which category are you interested in?"
          for request, i in ['GMV', 'Users', 'Products']
            to_send = to_send + "\n [#{i+1}] #{request}"
          msg.send "```" + to_send + '```'

          # ================ GMV queries ===================
          dialog.addChoice(/GMV|1/i, (msg2) ->
            querypicker(dialog, "GMV", gmv_queries, msg, robot)
          )

          # ================ User queries ===================
          dialog.addChoice(/user|2/i, (msg2) ->
            querypicker(dialog, "user", user_queries, msg, robot)
          )

          # ================ Product queries ===================
          dialog.addChoice(/product|3/i, (msg2) ->
            querypicker(dialog, "product", product_queries, msg, robot)
          )
        )

# =============== FILTER BY MOST RECENT ======================
        dialog.addChoice(/most recent|2/i, (msg2) ->
          most_recent = queries.sort (a, b) ->
            a.created_at > b.created_at
          querypicker(dialog, "most recent", most_recent, msg, robot)
        )

# =============== FILTER BY USER ============================
        dialog.addChoice(/by user|3/i, (msg2) ->
          # user stuff here
          users = removeDuplicates(query.author.username for query in queries)
          console.log users
          to_send = "Which user?"
          for user, i in users
            to_send = to_send + "\n [#{i+1}] #{user}"
          msg.send "```" + to_send + '```'
          dialog.addChoice(/\d{1,3}/i, (msg3) ->

          )

          querypicker(dialog, "most recent", most_recent, msg, robot)
        )

  # robot.respond /.*queries.*/i, (msg) ->
    # dialog = switchboard.startDialog(msg)

    # robot.http(api_url + "api/queries")
      # .header('Authorization', 'token 40fc7d904b7bcb1a7940a93d19f4193ccf997367e809f7847ced8474d9bb1028091cc1f2b0edad6279b5ff7c44dd408dde6b5c701a3ffcb148bcd78e64c076b6')
      # .get() (err, res, body) ->
        # if err
          # msg.send "Error: #{err}"
          # return
        # data = JSON.parse(body)
        # to_send = "_Available queries:_ ```"
        # for query, i in data
          # to_send = to_send + "\n [#{i}] #{query.name}"
          # to_send = to_send + "\n\t #{query.description}"
        # msg.send to_send + "```"

        # dialog.addChoice(/(\d{1,3})/i, (msg2) ->
          # selection = msg2.match[1]
          # msg.send "_You chose *#{data[selection].name}*. Your query is running..._:wall:"
          # url = api_url + "api/queries/#{data[selection].id}"
          # results_url = api_url + "queries/#{data[selection].id}"
          # robot.http(url)
            # .header('Authorization', 'token 40fc7d904b7bcb1a7940a93d19f4193ccf997367e809f7847ced8474d9bb1028091cc1f2b0edad6279b5ff7c44dd408dde6b5c701a3ffcb148bcd78e64c076b6')
            # .post() (err, res, body) ->
              # if err
                # msg.send "Error: #{err}"
                # return
              # msg.send "_Query is done running! Check out the results here:_ \n ```" + results_url + "```"
              # # data = JSON.parse(body)
              # # to_send = ""
              # # for item in data
                # # to_send = to_send + "\n ```#{JSON.stringify(item)}```"
              # # msg.send "```" + to_send + "```"
        # )

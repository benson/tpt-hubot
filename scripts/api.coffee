Conversation = require 'hubot-conversation'

# api_url = "http://tpt-api-hack.awesome-labs.com"
api_url = "http://localhost:3000"
token = "40fc7d904b7bcb1a7940a93d19f4193ccf997367e809f7847ced8474d9bb1028091cc1f2b0edad6279b5ff7c44dd408dde6b5c701a3ffcb148bcd78e64c076b6"

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

# paramsetter = (params, success, msg) ->
  # dialog.addChoice(/(.*)/i, (msg2) ->
    # date = new Date(msg2.match[1])
    # if validDate(date)
      # success(date)
    # else
      # msg.send "That date doesn't seem to be valid. Try formatting it like this: ```MM/DD/YYYY```"
      # datepicker(dialog, success)
  # )


humanReadableDate = (date) ->
  "#{date.getMonth()+1}/#{date.getDate()}/#{date.getFullYear()} #{date.toLocaleTimeString()[..-7]} #{date.toLocaleTimeString()[-2..]}"

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
    unless selected_query
      msg.send "_That wasn't an option._"
      return
    msg.send "_You chose *#{selected_query.name}*_"
    url = api_url + "/api/queries/#{selected_query.id}"
    results_url = api_url + "/queries/#{selected_query.id}"
    robot.http(url)
      .header('Authorization', "token #{token}")
      .get() (err, res, body) ->
        if err
          msg.send "Error: #{err}"
          return
        results = JSON.parse(body)
        if results.executions.count > 0
          msg.send "_This query has been run before. Here are the most recent past runs:_"
          to_send = ""
          for execution in results.executions.recent[...5]
            to_send = to_send + "[#{humanReadableDate(new Date(execution.finished))}] - #{api_url}/queries/#{selected_query.id}/executions/#{execution.id}\n"
          msg.send "```" + to_send + "```"
          msg.send "```If none of those are recent enough, you can: \n[1] Run the query again\n[2] Leave me alone```"
          dialog.addChoice(/(\d{1})/i, (msg3) ->
            if msg3.match[1] is "1"
              runQuery(dialog, msg, robot, url, results.parameters)
            else
              msg.send "_Then why bother me in the first place?_ :timeforthat:"
          )
        else
          runQuery(dialog, msg, robot, url, results.parameters)
  )

runQuery = (dialog, msg, robot, url, params) ->
  if params.length
    msg.send "_This query has some params you need to set (and I can't do that yet) so try doing it through the web:_"
    msg.send url.replace("/api", "")
    # user_params = {}
    # for param in params
  else
    msg.send "_Running query..._ :wall"
    robot.http(url)
      .header('Authorization', "token #{token}")
      .post() (err, res, body) ->
        if err
          msg.send "Error: #{err}"
          return
        # TODO: uncomment this stuff when the endpoint returns this data
        # response = JSON.parse(body)
        # execution = response[0].executions.recent[0]
        # msg.send "_Query is done running! Check out the results here:_ \n ```#{api_url}/queries/#{selected_query.id}/executions/#{execution.id}\n"
        msg.send "This will be a link to the results page!!!!!!!"


# ================================================================
module.exports = (robot) ->
  switchboard = new Conversation(robot)

  robot.respond /.*data.*|.*queries.*|.*query.*/i, (msg) ->
    dialog = switchboard.startDialog(msg)

    robot.http(api_url + "/api/queries")
      .header('Authorization', "token #{token}")
      .get() (err, res, body) ->
        if err
          msg.send "Error: #{err}"
          return
        queries = JSON.parse(body)

        msg.send "```How would you like to browse queries?\n[1] Category \n[2] Most Recent \n[3] User ```"

        dialog.addChoice(/category|1/i, (msg2) ->
          gmv_queries     = queries.filter (query) -> query.category is "gmv"
          user_queries    = queries.filter (query) -> query.category is "users"
          product_queries = queries.filter (query) -> query.category is "products"

          to_send = "Which category are you interested in?"
          for request, i in ['GMV', 'Users', 'Products']
            to_send = to_send + "\n [#{i+1}] #{request}"
          msg.send "```" + to_send + '```'

          dialog.addChoice(/GMV|1/i, (msg2) ->
            querypicker(dialog, "GMV", gmv_queries, msg, robot)
          )
          dialog.addChoice(/user|2/i, (msg2) ->
            querypicker(dialog, "user", user_queries, msg, robot)
          )
          dialog.addChoice(/product|3/i, (msg2) ->
            querypicker(dialog, "product", product_queries, msg, robot)
          )
        )

        dialog.addChoice(/most recent|2/i, (msg2) ->
          most_recent = queries.sort (a, b) ->
            a.created < b.created
          querypicker(dialog, "most recent", most_recent, msg, robot)
        )

        dialog.addChoice(/by user|3/i, (msg2) ->
          # user stuff here
          users = removeDuplicates(query.author.username for query in queries)
          to_send = "Which user?"
          for user, i in users
            to_send = to_send + "\n [#{i+1}] #{user}"
          msg.send "```" + to_send + '```'
          dialog.addChoice(/\d{1,3}/i, (msg3) ->
            user = users[i-1]
            unless user
              msg.send "That wasn't one of the options."
              return
            user_queries = queries.filter (query) -> query.author.username is user
            querypicker(dialog, "'made by #{user}'", user_queries, msg, robot)
          )
        )

Conversation = require 'hubot-conversation'

data_requests = ['GMV', 'Users', 'Products']
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

module.exports = (robot) ->
  switchboard = new Conversation(robot)


  robot.respond /.*data.*request/i, (msg) ->
    dialog = switchboard.startDialog(msg)

    msg.reply "I can help with a lot of data requests. Which of these do you want?"
    to_send = "```"
    for request, i in data_requests
      to_send = to_send + "\n [#{i+1}] #{request}"
    msg.send to_send + '```'

    dialog.addChoice(/GMV|1/i, (msg2) ->
      msg.send "I can tell you the GMV by \n```[1] Year \n[2] Month \n[3] Week \n[4] Day```"
      dialog.addChoice(/1/i, (msg3) ->
        msg.send "Which year would you like the GMV for?"
        dialog.addChoice(/(\d{4})/i, (msg4) ->
          year = msg4.match[1]
          msg.send "The GMV for #{year} is ```_____```"
        )
      )
      dialog.addChoice(/2/i, (msg3) ->
        msg.send "Which month would you like the GMV for?"
        datepicker(dialog, (date) =>
          # get data using that date here
          month = date.getMonth()
          msg.send "The GMV for #{humanReadableDate(date)} is ```_____```"
        )
      )
      dialog.addChoice(/3/i, (msg3) ->
        msg.send "Which week would you like the GMV for?"
        dialog.addChoice(/(\d{4})/i, (msg4) ->
          year = msg4.match[1]
          msg.send "The GMV for #{year} is ```_____```"
        )
      )
      dialog.addChoice(/4/i, (msg3) ->
        msg.send "Which day would you like the GMV for?"
        datepicker(dialog, (date) =>
          # get data using that date here
          msg.send "The GMV for #{humanReadableDate(date)} is ```_____```"
        )
      )
    )

    dialog.addChoice(/user|2/i, (msg2) ->
      msg.reply "Users - great choice!"
    )

    dialog.addChoice(/product|3/i, (msg2) ->
      msg.reply "Products - great choice!"
    )

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

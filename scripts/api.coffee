Conversation = require 'hubot-conversation'
data_requests = ['GMV', 'Users', 'Products']

validDate = (date) ->
  console.log "in validDate"
  if Object.prototype.toString.call(date) == "[object Date]"
    console.log "first if"
    if isNaN(date.getTime())
      console.log "NaN"
      return false
    else
      console.log "it's a number boys"
      return true
  return false

datepicker = (dialog, success) ->
  dialog.addChoice(/(.*)/i, (msg) ->
    date = new Date(msg.match[1])
    console.log validDate(date)
    if validDate(date)
      success(date)
    else
      msg.send "That date doesn't seem to be valid. Try formatting it like this: ```MM/DD/YYYY```"
      datepicker(dialog, success)
  )

module.exports = (robot) ->
  switchboard = new Conversation(robot)

  robot.respond /.*data.*request/i, (msg) ->
    dialog = switchboard.startDialog(msg)

    msg.reply "I can help with a lot of data requests. Which of these do you want?"
    to_send = "```"
    for request, i in data_requests
      to_send = to_send + "\n #{request}"
    msg.send to_send + '```'

    dialog.addChoice(/GMV/i, (msg2) ->
      msg.reply "GMV - good choice!"
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
        dialog.addChoice(/(\d{4})/i, (msg4) ->
          year = msg4.match[1]
          msg.send "The GMV for #{year} is ```_____```"
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
          msg.send "The GMV for #{date} is ```_____```"
        )
      )
    )

    dialog.addChoice(/user/i, (msg2) ->
      msg.reply "Users - great choice!"
    )

    dialog.addChoice(/product/i, (msg2) ->
      msg.reply "Products - great choice!"
    )

    # robot.http("http://jsonplaceholder.typicode.com/posts/1")
      # .get() (err, res, body) ->
        # if err
          # msg.send "oh shit dat error"
          # return
        # msg.send "Got back #{body}"

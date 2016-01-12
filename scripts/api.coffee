Conversation = require 'hubot-conversation'
# data_requests = ['GMV', 'Users', 'Products']

module.exports = (robot) ->
  switchboard = new Conversation(robot)

  robot.respond /data.*request/i, (msg) ->
    console.log "got into here"
    dialog = switchboard.startDialog(msg)

    to_send = "I can help with a lot of data requests. Which of these do you want?"
    for request, i in data_requests
      to_send = to_send + "\n #{request}"
    msg.reply to_send

    dialog.addChoice(/GMV/i, (msg2) ->
      msg.reply "GMV - good choice!"
    )

    dialog.addChoice(/users/i, (msg2) ->
      msg.reply "Users - great choice!"
    )

    # robot.http("http://jsonplaceholder.typicode.com/posts/1")
      # .get() (err, res, body) ->
        # if err
          # msg.send "oh shit dat error"
          # return
        # msg.send "Got back #{body}"

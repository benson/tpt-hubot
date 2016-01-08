# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->
  botname = process.env.HUBOT_SLACK_BOTNAME
  plusplus_re = /([a-z0-9_\-\.]+)\+{2,}/ig
  minusminus_re = /([a-z0-9_\-\.]+)\-{2,}/ig
  plusplus_minusminus_re = /([a-z0-9_\-\.]+)[\+\-]{2,}/ig

  robot.hear plusplus_minusminus_re, (msg) ->
     sending_user = msg.message.user.name
     res = ''
     while (match = plusplus_re.exec(msg.message))
         user = match[1].replace(/\-+$/g, '')
         if user != sending_user
            count = (robot.brain.get(user) or 0) + 1
            robot.brain.set user, count
            res += "#{user}++ [nice! now at #{count}]\n"
     while (match = minusminus_re.exec(msg.message))
         user = match[1].replace(/\-+$/g, '')
         count = (robot.brain.get(user) or 0) - 1
         robot.brain.set user, count
         res += "#{user}-- [ouch! now at #{count}]\n"
     msg.send res.replace(/\s+$/g, '')

  robot.hear /!loc (.*)/i, (msg) ->
    user = msg.message.user.name
    today = new Date()
    location = msg.match[1] + " as of " + today.toLocaleTimeString + " on " + today.toDateString()

    robot.brain.set (user + "_loc"), location
    msg.send user + " is at " + location

  robot.hear /!whereis (.*)/i, (msg) ->
    user = msg.match[1]

    location = robot.brain.get (user + "_loc")
    msg.send user + " is at " + location

  robot.hear /karma.*leaderboard/i, (msg) ->
     users = robot.brain.data._private
     tuples = []
     for username, score of users
        tuples.push([username, score])

     if tuples.length == 0
        msg.send "No one has any karma yet!"
        return

     tuples.sort (a, b) ->
        if a[1] > b[1]
           return -1
        else if a[1] < b[1]
           return 1
        else
           return 0

     str = ''
     limit = 5
     for i in [0...Math.min(limit, tuples.length)]
        username = tuples[i][0]
        points = tuples[i][1]
        point_label = if points == 1 then "point" else "points"
        newline = if i < Math.min(limit, tuples.length) - 1 then '\n' else ''
        str += "[#{i+1}] #{username}: #{points} " + point_label + newline
     msg.send(str)

  robot.respond /api shit/i, (msg) ->
    robot.http("http://jsonplaceholder.typicode.com/posts/1")
        .get() (err, res, body) ->
          if err
            msg.send "oh shit dat error"
            return
          msg.send "Got back #{body}"

  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'

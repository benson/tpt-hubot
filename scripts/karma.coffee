module.exports = (robot) ->
  plusplus_re = /([a-z0-9_\-\.]+)\+{2,}/ig
  minusminus_re = /([a-z0-9_\-\.]+)\-{2,}/ig
  plusplus_minusminus_re = /([a-z0-9_\-\.]+)[\+\-]{2,}/ig

  # increment and decrement karma
  robot.hear plusplus_minusminus_re, (msg) ->
    unless karma_hash = robot.brain.get "karma_hash"
      robot.brain.set("karma_hash", {})
      karma_hash = robot.brain.get "karma_hash"

    sending_user = msg.message.user.name
    res = ''
    while (match = plusplus_re.exec(msg.message))
      user = match[1].replace(/\-+$/g, '')
      if user != sending_user
        count = (karma_hash[user] or 0) + 1
        karma_hash[user] = count
        res += "#{user}++ [nice! now at #{count}]\n"
    while (match = minusminus_re.exec(msg.message))
      user = match[1].replace(/\-+$/g, '')
      count = (karma_hash[user] or 0) - 1
      karma_hash[user] = count
      res += "#{user}-- [ouch! now at #{count}]\n"
    msg.send res.replace(/\s+$/g, '')

  # print karma leaderboard
  robot.hear /karma.*leaderboard/i, (msg) ->
    karma_hash = robot.brain.get "karma_hash"
    tuples = []
    for username, score of karma_hash
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

    str = '```'
    limit = 5
    for i in [0...Math.min(limit, tuples.length)]
      username = tuples[i][0]
      points = tuples[i][1]
      point_label = if points == 1 then "point" else "points"
      newline = if i < Math.min(limit, tuples.length) - 1 then '\n' else ''
      str += "[#{i+1}] #{username}: #{points} " + point_label + newline
    msg.send(str+'```')

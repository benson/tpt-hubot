module.exports = (robot) ->
  # allow users to set their location
  robot.hear /!loc (.*)/i, (msg) ->
    user = msg.message.user.name
    today = new Date()
    location = msg.match[1] + " as of " + today.toLocaleTimeString()[0..4] + ", " + today.toDateString()[0..9]

    robot.brain.set (user + "_loc"), location
    msg.send user + " is at " + location

  # allow users to query the location of other users
  robot.hear /!whereis (.*)/i, (msg) ->
    user = msg.match[1]

    location = robot.brain.get (user + "_loc")
    if location
      msg.send user + " last said they were at " + location
    else
      msg.send user + " hasn't said where they are yet."

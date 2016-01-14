module.exports = (robot) ->
  robot.respond /help/i, (msg) ->
    msg.send '_Here is everything I can do:_'
    msg.send "`@tpt-robot queries/query/data` \n>Display the query browse tool"
    msg.send "`some_user++` \n>Give karma to `some_user`"
    msg.send "`some_user--` \n>Subtract karma from `some_user`"
    msg.send "`!loc some_location` \n>Sets your current location to `some_location`"
    msg.send "`!whereis some_user` \n>Tells you the last known location of `some_user`"

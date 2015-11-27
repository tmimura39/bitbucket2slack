# Description:
#   bitbucket to Slack
#
# Configuration:
#   MUST: (Enviroment Variable)
#     HUBOT_SLACK_TOKEN
#   OPTION:
#   (Enviroment Variable)
#     HUBOT_BITBUCKET2SLACK_DESTINATION
#     HUBOT_BITBUCKET2SLACK_GOOD_COLOR
#     HUBOT_BITBUCKET2SLACK_WARNING_COLOR
#     HUBOT_BITBUCKET2SLACK_DANGER_COLOR
#     HUBOT_BITBUCKET2SLACK_INFOMATION_COLOR
#   (GET params)
#     http:.../bitbucket2slack?destination=example_user
#     http:.../bitbucket2slack?good_color=000000
#     http:.../bitbucket2slack?warning_color=ff0000&danger_color=ff00ff
#     ...etc
#
#     - The color is not included "#"
#     - GET params is priority than Enviroment Variable
#
# Author:
#   t_mimura

querystring = require('querystring')

module.exports = (robot) ->

  config =
    destination: process.env.HUBOT_BITBUCKET2SLACK_DESTINATION
    good_color: process.env.HUBOT_BITBUCKET2SLACK_GOOD_COLOR || "good"
    warning_color: process.env.HUBOT_BITBUCKET2SLACK_WARNING_COLOR || "warning"
    danger_color: process.env.HUBOT_BITBUCKET2SLACK_DANGER_COLOR || "danger"
    information_color: process.env.HUBOT_BITBUCKET2SLACK_INFOMATION_COLOR || "439FE0"

  robot.router.post "/bitbucket2slack", (req, res) ->
    query = querystring.parse(req._parsedUrl.query)
    { destination } = query
    { destination } = config unless destination?
    { body } = req
    event_type = req.get 'X-Event-Key'

    try

      notifications = title = title_link = ""
      [event, action] = event_type.split(":")
      color = query.information_color || config.information_color
      fields = []

      switch event_type
#       when "pullrequest:created", "pullrequest:updated"
        when "pullrequest:fulfilled", "pullrequest:approved"
          action = "merged" if action == "fulfilled"
          color = query.good_color || config.good_color
        when "pullrequest:rejected", "pullrequest:unapproved"
          color = query.danger_color || config.danger_color
        when "pullrequest:comment_created", "pullrequest:comment_updated", "pullrequest:comment_deleted"
          color = query.warning_color || config.warning_color

        when "issue:created", "issue:updated"
          if body.changes?.status?.old?
            fields.push(
              title: "ChangeStatus"
              value: "[#{body.changes.status.old.toUpperCase()}] => [#{body.changes.status.new.toUpperCase()}]"
            )
          else
            fields.push(
              title: "Content"
              value: body.issue.content.raw
            )
#       when "issue:comment_created"

        when "repo:push"
          title = body.repository.full_name
          title_link = body.repository.links.html.href
          event = "repository"
        when "repo:fork"
          title = body.fork.full_name
          title_link = body.fork.links.html.href
          event = "repository"

      if body.pullrequest?
        title = body.pullrequest.title
        title_link = body.pullrequest.links.html.href
        reviewers = body.pullrequest.reviewers.map (r) -> " #{r.username}"
        notifications = [body.pullrequest.author.username].concat(reviewers)
        unless body.comment?.content?
          fields.push(
            title: "Description"
            value: body.pullrequest.description
          )
        unless body.pullrequest.reason == ""
          fields.push(
            title: "reason"
            value: body.pullrequest.reason
          )

      else if body.issue?
        title = "[#{body.issue.state.toUpperCase()}] #{body.issue.title}"
        title_link = body.issue.links.html.href

      if body.comment?.content?.raw? && body.comment.content.raw != ""
        fields.push(
            title: "Comment"
            value: body.comment.content.raw
        )

      if title != ""
        msg =
          channel: destination
          username: body.repository.full_name
          icon_url: "https://raw.githubusercontent.com/mito5525/bitbucket2slack/master/icon/bitbucket.png"
          content:
            text: "#{action.toUpperCase()}: #{event} by #{body.actor.username}"
            fallback: "#{action.toUpperCase()}: #{event} by #{body.actor.username}"
            color: color
            title: title
            title_link: title_link
            fields: fields

        msg.content.pretext = "To: #{notifications}" unless notifications == ""

        robot.emit 'slack-attachment', msg
        res.end "OK"
      else
        robot.messageRoom destination, "[#{body.repository.full_name}]\nThere was something movement\n"
        res.end "OK"

    catch error
      robot.messageRoom destination, "error:" + error
      robot.send
      res.end "Error"

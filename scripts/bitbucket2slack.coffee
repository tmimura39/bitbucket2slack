# Description:
#   bitbucket to Slack
#
# Configuration:
#   HUBOT_SLACK_TOKEN
#
# Author:
#   t_mimura

module.exports = (robot) ->
  robot.router.post "/bitbucket2slack/:room", (req, res) ->
    { room } = req.params
    { body } = req
    event_type = req.get 'X-Event-Key'

    try

      msg =
        message:
          room: room

      notifications = title = title_link = ""
      [event, action] = event_type.split(":")
      color = "#439FE0"
      fields = []

      switch event_type
#       when "pullrequest:created", "pullrequest:updated"
        when "pullrequest:fulfilled", "pullrequest:approved"
          action = "merged" if action == "fulfilled"
          color = "good"
        when "pullrequest:rejected", "pullrequest:unapproved" then color = "danger"
        when "pullrequest:comment_created", "pullrequest:comment_updated", "pullrequest:comment_deleted" then color = "warning"

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
          title = " #{body.repository.full_name}"
          title_link = body.repository.links.html.href
          event = "repository"
        when "repo:fork"
          title = body.fork.full_name
          title_link = body.fork.links.html.href
          event = "repository"

      if body.pullrequest?
        title = body.pullrequest.title
        title_link = body.pullrequest.links.html.href
        reviewers = body.pullrequest.reviewers.map (r) -> " #{r.display_name}"
        notifications = "#{body.pullrequest.author.display_name},#{reviewers}"
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
        msg.content =
          text: "#{action.toUpperCase()}: #{event} by #{body.actor.display_name}"
          fallback: "#{action.toUpperCase()}: #{event} by #{body.actor.display_name}"
          color: color
          author_name: body.repository.full_name
          author_icon: "https://bitbucket-assetroot.s3.amazonaws.com/c/photos/2015/Sep/09/1315830652-8-bitbucket-avatar.png"
          title: title
          title_link: title_link
          fields: fields

        msg.content.pretext = "To: #{notifications}" unless notifications == ""

        robot.emit 'slack-attachment', msg
        res.end "OK"
      else
        robot.messageRoom room, "[#{body.repository.full_name}]\nThere was something movement\n"
        res.end "OK"

    catch error
      robot.messageRoom room, "error:" + error
      robot.send
      res.end "Error"

# Description:
#   bitbucket to Slack
#
# Configuration:
#  HUBOT_SLACK_TOKEN
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

      switch event_type
        when "pullrequest:created", "pullrequest:updated","pullrequest:fulfilled", "pullrequest:approved", "pullrequest:rejected", "pullrequest:unapproved"
          type = if event_type == "pullrequest:fulfilled" then "MERGED" else event_type.split(":")[1].toUpperCase()
          color = if type in ["CREATED", "UPDATED"] then "#439FE0" else if type in ["MERGED", "APPROVED"] then "good" else "danger"
          reviewers = body.pullrequest.reviewers.map (r)->r.display_name
          content =
            pretext: "To: #{body.pullrequest.author.display_name}, #{reviewers}"
            text: "#{type}: PullRequest by #{body.actor.display_name}"
            fallback: "#{type}: PullRequestComment by #{body.actor.display_name}"
            color: color
            author_name: body.repository.full_name
            author_icon: "https://bitbucket-assetroot.s3.amazonaws.com/c/photos/2015/Sep/09/1315830652-8-bitbucket-avatar.png"
            title: body.pullrequest.title
            title_link: body.pullrequest.links.html.href
            fields: [
              {
                title: "Description"
                value: body.pullrequest.description
              }
            ]

        when "pullrequest:comment_created", "pullrequest:comment_updated", "pullrequest:comment_deleted"
          type = event_type.split("_")[1].toUpperCase()
          content =
            pretext: "To: #{body.pullrequest.author.display_name}"
            text: "#{type}: PullRequestComment by #{body.actor.display_name}"
            fallback: "#{type}: PullRequestComment by #{body.actor.display_name}"
            color: "warning"
            author_name: body.repository.full_name
            author_icon: "https://bitbucket-assetroot.s3.amazonaws.com/c/photos/2015/Sep/09/1315830652-8-bitbucket-avatar.png"
            title: body.pullrequest.title
            title_link: body.pullrequest.links.html.href
            fields: [
              {
                title: "Comment"
                value: body.comment.content.raw
              }
            ]

        when "issue:created"
          type = event_type.split(":")[1].toUpperCase()
          content =
            text: "#{type}: Issue by #{body.actor.display_name}"
            fallback: "#{type}: Issue by #{body.actor.display_name}"
            color: "#439FE0"
            author_name: body.repository.full_name
            author_icon: "https://bitbucket-assetroot.s3.amazonaws.com/c/photos/2015/Sep/09/1315830652-8-bitbucket-avatar.png"
            title: " [#{body.issue.state}] #{body.issue.title}"
            title_link: body.issue.links.html.href
            fields: [
              {
                title: "Content"
                value: body.issue.content.raw
              }
            ]

        when "issue:updated"
          type = event_type.split(":")[1].toUpperCase()
          if body.changes.status?.old?
            fields = [
              {
                title: "Comment"
                value: body.comment.content.raw
              },
              {
                title: "ChangeStatus"
                value: "#{body.changes.status.old} => #{body.changes.status.new}"
              }
            ]
          else
            fields = [
              {
                title: "Content"
                value: body.issue.content.raw
              }
            ]

          content =
            text: "#{type}: Issue by #{body.actor.display_name}"
            fallback: "#{type}: Issue by #{body.actor.display_name}"
            color: "#439FE0"
            author_name: body.repository.full_name
            author_icon: "https://bitbucket-assetroot.s3.amazonaws.com/c/photos/2015/Sep/09/1315830652-8-bitbucket-avatar.png"
            title: " [#{body.issue.state}] #{body.issue.title}"
            title_link: body.issue.links.html.href
            fields: fields

        when "issue:comment_created"
          type = event_type.split("_")[1].toUpperCase()
          content =
            text: "#{type}: IssueComment by #{body.actor.display_name}"
            fallback: "#{type}: IssueComment by #{body.actor.display_name}"
            color: "#439FE0"
            author_name: body.repository.full_name
            author_icon: "https://bitbucket-assetroot.s3.amazonaws.com/c/photos/2015/Sep/09/1315830652-8-bitbucket-avatar.png"
            title: " [#{body.issue.state}] #{body.issue.title}"
            title_link: body.issue.links.html.href
            fields: [
              {
                title: "Comment"
                value: body.comment.content.raw
              }
            ]

        when "repo:push"
          content =
            text: "Pushed: Repository by #{body.actor.display_name}"
            fallback: "Pushed: Repository by #{body.actor.display_name}"
            color: "#439FE0"
            author_name: body.repository.full_name
            author_icon: "https://bitbucket-assetroot.s3.amazonaws.com/c/photos/2015/Sep/09/1315830652-8-bitbucket-avatar.png"
            title: body.repository.full_name
            title_link: body.repository.links.html.href

        when "repo:fork"
          content =
            text: "Fork: Repository by #{body.actor.display_name}"
            fallback: "Fork: Repository by #{body.actor.display_name}"
            color: "#439FE0"
            author_name: body.repository.full_name
            author_icon: "https://bitbucket-assetroot.s3.amazonaws.com/c/photos/2015/Sep/09/1315830652-8-bitbucket-avatar.png"
            title: "#{body.fork.full_name}"
            title_link: body.fork.links.html.href

      if content?
        msg.content = content
        robot.emit 'slack-attachment', msg
        res.end "OK"
      else
        robot.messageRoom room, "[#{body.repository.full_name}]\nThere was something movement\n"
        res.end "OK"

    catch error
      robot.messageRoom room, "error:" + error
      robot.send
      res.end "Error"

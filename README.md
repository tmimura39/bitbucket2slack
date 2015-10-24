# Bitbucket Notification To Slack

This Hubot script supports all movements of Bitbucket!!

## Supporting
- Repository Events
    + Push
    + Fork
- Pullrequest Ebents
    + Created
    + Updated
    + Approved
    + Approval Removed
    + Merged
    + Declined
    + Comment Created
    + ~~Comment Updated~~ (Not working by Bitbucket...?)
    + Comment Deleted
- Issue Event
    + Created
    + Updated
    + Comment Created

## Installation

In your hubot directory, run:

`npm install bitbucket2slack --save`

To enable a script, add the following to the external-scripts.json

```json
["bitbucket2slack"]
```

## Configuration

### Bitbucket Add webhook

`https://bitbucket.org/{owner_name}/{repository_name}/admin/addon/admin/bitbucket-webhooks/bb-webhooks-repo-admin`

- Set following URL

`{hubot_url}/bitbucket2slack/{Channel_name}`  
(exampleURL: `http:example.com:8080/bitbucket2slack/bb-notification-channel`)

### Set enviroment variable HUBOT_SLACK_TOKEN

`export HUBOT_SLACK_TOKEN = {your_slack_API_token}`
# Bitbucket Notification To Slack

This Hubot script supports all movements of Bitbucket!!

## Supporting
- Repository Events
    + Push
    + Fork
- Pullrequest Events
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

`{hubot_url}/bitbucket2slack`  
(exampleURL: `http:example.com:8080/bitbucket2slack`)

### Set enviroment variable HUBOT_SLACK_TOKEN

`export HUBOT_SLACK_TOKEN = {your_slack_API_token}`

### Two ways to configure the notification destination

- Get params(**priority**)  
`http:example.com:8080/bitbucket2slack?destination=random`

- Enviroment variable  
`export HUBOT_BITBUCKET2SLACK_DESTINATION=j_michael`

destination is {CHANNELS or PRIVATE_GROUP or DM(user_name)}

### Option to change the slack attachments colors

- Get params(**priority**)  
`http:example.com:8080/bitbucket2slack?good_color=000000`  
`http:example.com:8080/bitbucket2slack?warning_color=ff0000&danger_color=f0f`  
...etc

- Enviroment variable  
`export HUBOT_BITBUCKET2SLACK_GOOD_COLOR = "000"`  
`export HUBOT_BITBUCKET2SLACK_INFOMATION_COLOR = "ffff00"`

The color is **not included** "#"

Before using this workflow, you need to configure it with your Pinboard account by running `:configurepinunread` followed by your api token and your preferred action.

![](https://i.imgur.com/zjaHg9t.png)

You can get the API token of you Pinboard account by visiting https://pinboard.in/settings/password.

Your preferred action may be one of `delete`, `archive`, or `keep`. `delete` will remove the bookmark from your account, after you act (open or copy the link) on it; `archive` will mark the bookmark as read; `keep` will leave it untouched.

An example configuration would be: `:configurepinunread username:HSJWJK2HHSKI14QPDOIK delete`

When you’re all set, call `pun`, and your unread bookmarks will be displayed. Press ↩ on one to open it in your default browser or ⌘+↩ to copy the link to your clipboard; the action you picked while configuring will take place in the background.

![](http://imgur.com/0wfAKMD.png)

You may also type something after `pun` (don’t add a space, just type), to filter the bookmarks.

![](http://imgur.com/12fBicE.png)

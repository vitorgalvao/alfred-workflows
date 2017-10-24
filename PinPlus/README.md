Add to and view your Pinboard bookmarks.

`pa` opens Pinboard’s “add bookmark” page in your frontmost browser. You can submit bookmarks with ↵ or dismiss the window with ⎋.

![](https://i.imgur.com/2RUKdcA.png)

Configure the `Hotkey Trigger` to add your current browser tab as an unread bookmark.

`pin` and `pun` are similar. The former shows all your bookmarks (type to filter), while the latter shows only the unread ones.

![](https://i.imgur.com/hrxtJ54.png)

In each case:

+ ↵ opens the bookmark in your default web browser.
+ ⇧↵ opens the bookmark in Pinboard’s website, so you can edit it at will.
+ ⌥↵ copies the bookmark’s URL to your clipboard.
+ ⌘↵ downloads the video on the page, if any. It requires [DownVid](https://github.com/vitorgalvao/alfred-workflows/tree/master/DownVid) and will automatically add to [WatchList](https://github.com/vitorgalvao/alfred-workflows/tree/master/WatchList) if available)
+ `fn` shows the bookmark’s description.
+ ⌃ shows the bookmark’s tags.

Unread bookmarks suffer an extra event when acted upon, depending on the `unread_action` Workflow Environment Variable. `archive` will mark the bookmark as read and `delete` will remove it from your account. Any other value (including none) will leave it untouched.

Bookmarks are auto-updated in accordance to the requirements of the Pinboard API. `:pinplusforceupdate` will force an update, but should be avoided.

![](https://i.imgur.com/Lr0iNij.png)

If you ever need to update your Pinboard API token, call `:pinplusresetapitoken`.

![](https://i.imgur.com/XOHDq0q.png)

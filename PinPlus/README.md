Add to and view your Pinboard bookmarks.

`pa` opens Pinboard’s “add bookmark” page in your frontmost browser. You can submit bookmarks with ↵ or dismiss the window with ⎋.

![](https://i.imgur.com/g6wAO6U.png)

Configure the `Hotkey Trigger` to add your current browser tab as an unread bookmark.

`pin` and `pun` are similar. The former shows all your bookmarks (type to filter), while the latter shows only the unread ones.

![](https://i.imgur.com/JK0RDqS.png)

In each case:

+ ↵ opens the bookmark in your default web browser.
+ ⇧↵ opens the bookmark in Pinboard’s website, so you can edit it at will.
+ ⌥↵ copies the bookmark’s URL to your clipboard.
+ ⌘↵ downloads the video on the page, if any (requires [DownMedia](https://github.com/vitorgalvao/alfred-workflows/tree/master/DownMedia)).
+ `fn` shows the bookmark’s description.
+ ⌃ shows the bookmark’s tags.

Unread bookmarks suffer an extra event when acted upon, depending on the `unread_action` Workflow Environment Variable. `archive` will mark the bookmark as read and `delete` will remove it from your account. Any other value (including none) will leave it untouched.

The `unread_order` Workflow Environment Variable affects the display of `pun`. Valid options are `oldest_first` and `newest_first`, defaulting to the latter.

Bookmarks are auto-updated every hour. Change `auto_refresh` to `0` to disable this behaviour. `:pinplusforceupdate` forces an update.

To reset your Pinboard API token, run `:pinplusresetapitoken`.

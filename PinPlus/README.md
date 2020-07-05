Add to and view your Pinboard bookmarks.

`pa` opens Pinboard’s “add bookmark” page in your frontmost browser. You can submit bookmarks with ↵ or dismiss the window with ⎋.

![](https://i.imgur.com/g6wAO6U.png)

If you have the [PinPlus app](https://github.com/vitorgalvao/pinplus) installed (get it with `:pinplusupdateapp`), that opens instead.

![](https://i.imgur.com/0SVjnKs.png)

Configure the `Hotkey Trigger` to add your current browser tab as an unread bookmark.

`pin` and `pun` are similar. The former shows all your bookmarks (type to filter), while the latter shows only the unread ones.

![](https://i.imgur.com/JK0RDqS.png)

In each case:

+ ↵ opens the bookmark in your default web browser.
+ ⇧↵ opens the bookmark in Pinboard’s website, so you can edit it at will.
+ ⌥↵ copies the bookmark’s URL to your clipboard.
+ ⌘↵ downloads the video on the page, if any. It requires [DownVid](https://github.com/vitorgalvao/alfred-workflows/tree/master/DownVid) and will automatically add to [WatchList](https://github.com/vitorgalvao/alfred-workflows/tree/master/WatchList) if available)
+ `fn` shows the bookmark’s description.
+ ⌃ shows the bookmark’s tags.

Unread bookmarks suffer an extra event when acted upon, depending on the `unread_action` Workflow Environment Variable. `archive` will mark the bookmark as read and `delete` will remove it from your account. Any other value (including none) will leave it untouched.

The `unread_order` Workflow Environment Variable affects the display of `pun`. Valid options are `oldest_first` and `newest_first`, defaulting to the latter.

`:pinpluslaunchd` will install (or later remove, running the same command) a `launchd` service to seamlessly fetch bookmarks every hour.

![](https://i.imgur.com/sstjtK2.png)

Bookmarks are auto-updated in accordance to the requirements of the Pinboard API. `:pinplusforceupdate` will force an update, but should be avoided. The `minutes_between_checks` Workflow Environment Variable defaults to `10`.

![](https://i.imgur.com/W2KmV8C.png)

If you ever need to update your Pinboard API token, call `:pinplusresetapitoken`.

![](https://i.imgur.com/J7fFguC.png)

Download media from [a plethora of sources](https://rg3.github.io/youtube-dl/supportedsites.html), even when embedded in other pages.

The main commands are `dv` to download video and `da` to download audio (often extracted from a video source). Both will present you with two download options, if available: the URL of your frontmost browser tab, and the URL in your clipboard.

![](https://i.imgur.com/CNaS35s.png)

Run any option with the ⌘ modifier, and the full playlist will be downloaded. Use ⌥ and it will toggle adding to [WatchList](https://github.com/vitorgalvao/alfred-workflows/tree/master/WatchList) (a separate Workflow).

Notifications will appear on download start and end.

![](https://i.imgur.com/GUr5P3y.png)

To see auto-refreshing download progress, run `dp`. Actioning it with ⌘ will restart the current download (readding to the end of the queue), while actioning with ⌃ will abort.

![](https://i.imgur.com/fZVsx3B.png)
 
`:downmediaservices` installs (or later removes) DownMedia actions to macOS Services. This allows you to right click a URL and download from the context menu.

![](https://i.imgur.com/gYqEcvb.png)

The Workflow Environment Variables represent the directory to download to, the audio format to save when using `da`, and the default behaviour of adding a download to WatchList (`true` or `false`).

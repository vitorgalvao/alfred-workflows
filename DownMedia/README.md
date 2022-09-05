Download media from [a plethora of sources](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md), even when embedded in other pages.

The main commands are `dv` to download video and `da` to download audio (often extracted from a video source). Both will present you with two download options, if available: the URL of your frontmost browser tab, and the URL in your clipboard.

![](https://i.imgur.com/FZnbdI3.png)

Run any option with the ⌘ modifier, and the full playlist will be downloaded. Use ⌥ and it will toggle adding to [WatchList](https://github.com/vitorgalvao/alfred-workflows/tree/master/WatchList) (a separate Workflow).

Notifications will appear on download start and end.

To see auto-refreshing download progress, run `dp`. Actioning it with ⌘ will restart the current download (readding to the end of the queue), while actioning with ⌃ will abort.

![](https://i.imgur.com/tHPw5y0.png)
 
`:downmediaservices` installs (or later removes) DownMedia actions to macOS Services. This allows you to right click a URL and download from the context menu.

![](https://i.imgur.com/i7NmBLx.png)

The Workflow Environment Variables represent the directory to download to, the audio format to save when using `da`, and the default behaviour of adding a download to WatchList (`true` or `false`). The `_title_template` ones determine [the name of saved files](https://github.com/yt-dlp/yt-dlp#output-template).

You will have to install [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) yourself because it has dependencies which are impractical to fulfil on a clean macOS installation. The simplest way is to install [Homebrew](https://brew.sh) and `brew install yt-dlp`.

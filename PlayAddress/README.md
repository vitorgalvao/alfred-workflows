Run `playadd` and available options will appear to play the URL in the frontmost browser tab or your clipboard.

![](https://i.imgur.com/xeUx0lj.png)

Pick one of them and the URL will play. ⌘↵ downloads the video (requires [DownMedia](https://github.com/vitorgalvao/alfred-workflows/tree/master/DownMedia)).

The Hotkey is a shortcut to play the URL in the frontmost browser tab.

If the `close_tab` Workflow Environment Variable is `true` and the URL is supported, the browser tabs with the matching URL will close.

If the `use_watchlist` Workflow Environment Variable is `true`, streams will be added and played from [WatchList](https://github.com/vitorgalvao/alfred-workflows/tree/master/WatchList) (a separate Workflow).

To play a stream you need [mpv](http://mpv.io/), [IINA](https://lhc70000.github.io/iina/), or [VLC](http://www.videolan.org/vlc/index.html).

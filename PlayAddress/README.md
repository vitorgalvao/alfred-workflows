Run `playadd` and available options will appear to play the URL in the frontmost browser tab or your clipboard.

![](https://i.imgur.com/rAWiidy.png)

Pick one of them and the URL will play. ⌘↵ downloads the video (requires [DownVid](https://github.com/vitorgalvao/alfred-workflows/tree/master/DownVid); adds to [WatchList](https://github.com/vitorgalvao/alfred-workflows/tree/master/WatchList) if available).

If the `close_tab` Workflow Environment Variable is `true` and the URL is supported, the browser tabs with the matching URL will close.

To play a stream you need [mpv](http://mpv.io/), [IINA](https://lhc70000.github.io/iina/), or [VLC](http://www.videolan.org/vlc/index.html).

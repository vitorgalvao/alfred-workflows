Stream from a selection of short films, powered by [Short of the Week](https://www.shortoftheweek.com/).

Run `shorts` and it’ll show a list of the latest films. Pick one and it’ll start streaming. Alternatively, add ⌘ to download the video (requires [DownMedia](https://github.com/vitorgalvao/alfred-workflows/tree/master/DownMedia)), ⌥ to see its synopsis, or ⌃ to copy the short’s link to the clipboard.

![](https://i.imgur.com/nhXigIF.png)

Short of the Week publishes a new short every day and building the initial list takes a few seconds, so after the initial download the list is cached for one day. If you want the list ready at all times without having to wait, run `:shortfilmslaunchd` to install (or later remove, running the same command) a `launchd` agent to seamlessly update the list every day close to the time Short of the Week updates their website.

![](https://i.imgur.com/pKrvlah.png)

To play a stream you need [mpv](http://mpv.io/), [IINA](https://lhc70000.github.io/iina/), or [VLC](http://www.videolan.org/vlc/index.html).

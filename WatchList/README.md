WatchList saves your media and streams to a list, eases the choice of what to play next and gets rid of it when you’re done.

Add files, directories, or URLs to your list with the `Add to watchlist` Universal Action. Items will be prepended or appended depending on the `add_item_order` Workflow Environment Variable. If the `move_on_add` Workflow Environment Variable is set, the paths will be moved to that directory (ignore once with ⌘).

Use the `lists_dir` Workflow Environment Variable to pick a custom save location for your data. This allows for easy syncing and cloud backups.

Next, interact with your list. Options begin with `wl`.

![](https://i.imgur.com/vtwvvxI.png)

`wlp` shows the list of items to play. A reference to each subtitle section can be found at the end.

![](https://i.imgur.com/CeHpXMh.png)

`wls` calls `wlp` under the hood, but with a custom sort order.

![](https://i.imgur.com/wr8MgEm.png)

In both cases:

* ↩ plays the selection.
* ⌃↩ opens the item’s URL in the default web browser.
* ⌥↩ downloads a stream (requires [DownMedia](https://github.com/vitorgalvao/alfred-workflows/tree/master/DownMedia)) or rescans a series’ directory (useful after manual changes).
* ⌘↩ marks as watched without playing.
* ⇧↩ appends to a temporary playlist. After adding the desired items, ↩ plays them in order. A playlist which was neither modified nor played for a few minutes will be ignored.
* ⇧ or ⌘Y shows a Quick Look preview on files and streams.

If the `top_on_play` Workflow Environment Variable is `true`, the item will be moved to the top of the list before beginning playback.

[mpv](http://mpv.io/), [IINA](https://lhc70000.github.io/iina/), and [VLC](http://www.videolan.org/vlc/index.html) are directly supported. If playback exits with a non-zero code, the item will not be marked as played (hence not trashed). Take advantage of that! Disable the behaviour by setting the `trash_on_watched` Workflow Environment Variable to `false`.

`wlu` is the watched list. Its size is controlled by the `maximum_watched` Workflow Environment Variable. Actioning an item will mark it unwatched and try to recover it from the Trash. If the item has an origin URL (shown in the subtitle):

* ⌘↩ opens it in the default web browser.
* ⌥↩ copies it to the clipboard.
* ⇧ or ⌘Y shows a Quick Look preview.

![](https://i.imgur.com/srW0zxy.png)

`wle` is for reordering, renaming, and manually removing of items.

[DownMedia](https://github.com/vitorgalvao/alfred-workflows/tree/master/DownMedia) and [PlayAddress](https://github.com/vitorgalvao/alfred-workflows/tree/master/PlayAddress) have options to add to your watchlist.

#### Subtitle reference:

There are three types of items: `files`, `series`, and `streams`. `stream`s can be further categorised into single item or playlist. Each result has its name as the top title. The subtitle confers more detailed information and follows this template:

```
≈ (4) 𐄁 22m 32s 𐄁 691M 𐄁 /Some/Path
```

* ≈. Indicates item is a `stream`.
    * `file`: N/A.
    * `series`: N/A.
    * `stream`: Always present.
* (4). Number of elements.
    * `file`: N/A.
    * `series`: Remaining audiovisual files in directory.
    * `stream`: Single item: N/A. Playlist: All elements.
* 22m 32s. Running time.
    * `file`: Running time of file.
    * `series`: Running time of first audiovisual file in directory.
    * `stream`: Combined running time of all elements.
* 691M. Size.
    * `file`: Size of file.
    * `series`: Size of first audiovisual file in directory.
    * `stream`: N/A.
* /Some/Path. Path.
    * `file`: Path of file.
    * `series`: Path of directory.
    * `stream`: URL.

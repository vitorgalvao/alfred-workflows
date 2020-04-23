Keep a list of audiovisual content to watch and listen to.
 
We often have series of videos and streams that we’d like to watch but not necessarily keep after, but tracking which we’ve already seen (and are thus safe to delete) can be a chore.
 
Select in the Finder the files or directories you wish to add to your list and apply the file action `Add to watchlist`. If the `move_on_add` Workflow Environment Variable is set, the items will be moved to that directory. Items will be prepended or appended to the list, depending on the `add_item_order` Workflow Environment Variable. Alternatively, call `swl` to add the URL in your clipboard as a stream (add ⌘ for the full playlist).

You then have some options you can pick from, all starting with `wl`.

![](https://i.imgur.com/jOKRSwY.png)

`wlp` shows the list of items you can play. A reference to each subtitle section can be found at the end.

![](https://i.imgur.com/anCe2I8.png)

`wls` calls `wlp` under the hood, but lets you first select a sort order.

![](https://i.imgur.com/SymAbSa.png)

In both cases, ↵ plays the selection. Add ⌃ to play without marking as watched or ⌥ to rescan a directory (useful if you made manual changes to it). ⌘↵ will mark as watched without playing. ⇧ or ⌘Y shows a quicklook preview on files and streams.

If the `top_on_play` Workflow Environment Variable is set to `true`, the item will be moved to the top of the list before starting playback.

Items starting with `≈` are streams. They show no file size (since they aren’t taking up any space locally) and present the link they were taken from as opposed to a location on disk. To play a stream you need [mpv](http://mpv.io/), [IINA](https://lhc70000.github.io/iina/), or [VLC](http://www.videolan.org/vlc/index.html).

An item will not be marked as watched if we can access the player’s CLI and it exits with a failure exit code.

`wlu` shows the list of watched items. The limit of recent items in this list is controlled by the `maximum_watched` Workflow Environment Variable. Action an item to mark it as unwatched. Note that in the case of files it does not recover them from the trash, as there is no reliable way to do so on macOS — that step you need to do yourself. If the item has a URL origin (you’ll see it in the subtitle) add ⌘ to open the URL in your default browser or ⌥ to copy it to the clipboard. If the item has an origin URL, ⇧ or ⌘Y shows a quicklook preview.

![](https://i.imgur.com/XK0W6Wj.png)

`wle` allows you to reorder, rename, and remove items from the list.

To keep your lists synced between machines, use the `lists_dir` Workflow Environment Variable to pick a custom save location.

Finally, if you use [DownVid](https://github.com/vitorgalvao/alfred-workflows/tree/master/DownVid) it has an option to add the downloaded video files directly to your watchlist.

#### Subtitle reference:

There are three types of items: `files`, `series`, and `streams`. `stream`s can be further categorised into single item or playlist. Each result has its name as the top title. The subtitle confers more detailed information and follows this template (`~` means it never shows):

```
≈ (4) 𐄁 22m 32s 𐄁 691M 𐄁 /Some/Path
```

+ ≈. Indicates item is a `stream`.
    + `file`: ~
    + `series`: ~
    + `stream`: Always present.
+ (4). Number of elements.
    + `file`: ~
    + `series`: Remaining audiovisual files in directory.
    + `stream`: Single item: ~. Playlist: All elements.
+ 22m 32s. Running time.
    + `file`: Running time of file.
    + `series`: Running time of first audiovisual file in directory.
    + `stream`: Combined running time of all elements.
+ 691M. Size.
    + `file`: Size of file.
    + `series`: Size of first audiovisual file in directory.
    + `stream`: ~
+ /Some/Path. Path.
    + `file`: Path of file.
    + `series`: Path of directory.
    + `stream`: URL.

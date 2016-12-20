View and manage a list of files and video streams at your own pace. This workflow was built with video in mind but works with just about any file or directory.
 
We often have series of videos and streams that we’d like to watch but not necessarily keep after, but keeping track of them all and which we’ve already seen (and are thus safe to delete), can be a chore.
 
Select in the Finder the files (or directories) you wish to add to your list, and apply the file action `Add to watchlist`. Every time you do this, the new files will be prepended to the list. You then have some options you can pick from, all starting with `wl`.

![](http://i.imgur.com/rN3bl4u.png)

If you choose any of the options that let you pick from a list (`wlp`, `wlu`, and `wls`) and continue typing after it (don’t add a space, just type), you’ll start filtering — names, file sizes, durations, and a few more — so you can quickly find the ones you want.

![](http://i.imgur.com/F3CuxuD.png)

Items starting with a ≈ are streams. They also show no file size (since they aren’t taking up any space locally) and show the link they were taken from, as opposed to a location on disk. To be able to stream video, you need either [mpv](http://mpv.io/) or [VLC](http://www.videolan.org/vlc/index.html).

![](http://i.imgur.com/HTe0cH9.png)

Sharing is particularly useful when you want to send the original link of something you watched to someone else, or to save it somewhere. Those are extracter from downloaded files, if they have that metadata ([DownVid](https://github.com/vitorgalvao/alfred-workflows/tree/master/DownVid), for example, adds it to downloaded videos). Use ⌘ to open the url in the default browser, as opposed to copying to the clipboard.

![](http://i.imgur.com/pleW6Qs.png)

`swl` will add the url in your clipboard as a stream.

You can also control parts of the workflow with [Alfred Remote](http://www.alfredapp.com/remote/).

![](http://i.imgur.com/ylgLbGJ.png)

If you use [DownVid](https://github.com/vitorgalvao/alfred-workflows/tree/master/DownVid), it has an option to add the downloaded video files directly to your watchlist.

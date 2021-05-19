List the contents of a directory and act on them. Call the workflow with `rdn` to sort from the most recently modified, `rdo` for the reverse; `rda` to sort from the most recently added, `rdz` for the reverse.

![](https://i.imgur.com/K7ro80G.png)

The list is auto-refreshed every few seconds, making for a good way to track changes.

To act on the selections, use the standard Alfred shortcuts. You can activate file actions, dive into directories, preview files, add them to the file buffer… ⌥↵ is hardcoded to always open the selection in the Finder.

Listing by added can be marginally slower than listing by modified due to the need to query Spotlight. To combat that, calling `:recentdownloadslaunchd` will install (or later remove, running the same command) a `launchd` agent to seamlessly update a file cache when the directory is modified.

By default the Workflow looks in `~/Downloads`. Change the value in the `downloads_dir` Workflow Environment Variable to use a different path.

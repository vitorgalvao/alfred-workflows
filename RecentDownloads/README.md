List the contents of a directory and act on them. Call the workflow with `rdn` to sort from the most recently modified, `rdo` for the reverse; `rda` to sort from the most recently added, `rdz` for the reverse.

![](https://i.imgur.com/9LxDIrE.png)

To act on the selections, use the standard Alfred shortcuts. You can activate file actions, dive into directories, preview files, add them to the file buffer — whatever you want to do that is supported by Alfred.

⌥↵ opens the selection in Finder, while ⇧↵ clears the cache for `rda` and `rdz`.

By default the Workflow looks in `~/Downloads`. Change the value in the `downloads_dir` Workflow Environment Variable to use a different path.

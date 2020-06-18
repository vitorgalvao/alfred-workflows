Call `qapps` and all apps excluding the ones you set in the `keep_alive` Workflow Environment Variable will quit. The Finder is added to the exclusion list by default, unless you set `kill_finder` to `true`.

![](https://i.imgur.com/7tcVJKV.png)

You’ll need to use the exact names of the apps as they present themselves to the system. To prevent multiple from quitting, separate their names with commas.

`qprocesses` will kill all processes, subject to the same `keep_alive` and `kill_finder` settings, meaning even things in the background that you don’t see will be asked to quit.

The External Triggers allow to temporarily override which apps to keep alive by passing them as the argument.

Note both options *ask* the apps to exit (`SIGTERM`) instead of *telling* them (`SIGKILL`). If you need to force processes to terminate, consider [ProcessControl](https://github.com/vitorgalvao/alfred-workflows/tree/master/ProcessControl) instead.

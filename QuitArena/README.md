Call `qapps` and all apps excluding the ones you set in the `keep_alive` Workflow Environment Variable will quit. The Finder and Alfred (including Alfred Preferences) are added to the exclusion list by default, unless you set their `kill_` variables to `true`.

![](https://i.imgur.com/o1xU4er.png)

Use the exact application names as they present themselves to the system. To prevent multiple apps from quitting, separate their names with commas.

`qprocesses` will kill all processes, subject to the same `keep_alive` and `kill_` settings, meaning even things in the background that you don’t see will be asked to quit.

The External Triggers allow to temporarily override which apps to keep alive by passing them as the argument.

Note both options *ask* the apps to exit (`SIGTERM`) instead of *telling* them (`SIGKILL`). If you need to force individual processes to terminate, use [ProcessControl](https://github.com/vitorgalvao/alfred-workflows/tree/master/ProcessControl) instead.

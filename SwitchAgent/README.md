Run `sa` and pick from the list (type to filter results) to switch the user agent for your frontmost browser on the fly.

![](https://i.imgur.com/cULF6XP.png)

Since they seldom change, the Workflow builds and references a file of available user agents. At any point you may ⌘↩ on a result to rebuild it (you’ll be instructed to do so on the first run). This makes normal usage considerably faster.

Currently supports Safari and Safari Technology Preview. Webkit is excluded because there’s no good method to detect if its `Develop` menu is active (a necessity for user agent switching to work).

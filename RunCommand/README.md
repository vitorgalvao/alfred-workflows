Provides both a `File Action` to run shell commands on selected files/directories and a `Keyword` to run them on the current directory. It will detect your default shell, and if it’s `bash`, `zsh`, `tcsh`, `csh`, or `fish`, it’ll load the appropriate startup files and your aliases.
 
For the `File Action`, use Alfred to pick what you want to run a command on and choose `Run command`. Alfred’s main window will appear and you simply type the command you want.

![](https://i.imgur.com/uFwqIxg.png)
 
For the `Keyword`, type `.` followed by a command. A space between the period and the command is not necessary. This will run the command on the active Finder window (e.g. `.touch this_file`). You can also easily chain commands (`.cd Desktop && rm that_file`).

![](https://i.imgur.com/3jV7tXm.png)

For commands that would benefit from the files not being at the end (like `cp` and `mv`), you can use `{}` as a placeholder for the files. So if you select some files and want to copy them to `~/Desktop/` you’d type `cp {} ~/Desktop/`.

To get the output of the command as `Large Type`, use ⌘ when actioning it.

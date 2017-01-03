`OneUpdater` is an updater you can plug with minimal configuration into workflows, to keep them up-to-date in users’ machines.

Easiest way to use it is to copy one of its `OneUpdater` nodes (the pink ones, with the note) to another workflow.

If the workflow actions anything (you press ↩ at some point during usage), copy the top node (`Run Script`). Connect it to the most used action and double click to edit it. Fill the top variables with the correct values, and you’re done.

![Setting up OneUpdater with Run Script](https://i.imgur.com/0QDS4R6.gif)

If the workflow doesn’t action anything (`Script Filter`s with no connections), copy the bottom node (`Script Filter`). Double click to edit it. Make its `Keyowrd` the same as the most used in the workflow, fill the top variables with the correct values, and you’re done.

![Setting up OneUpdater with Script Filter](https://i.imgur.com/b6uAjmN.gif)

The top lines (the ones that need changing) have comments explaining what they mean and some example values, but here’s an overview with a real example, from a version of [ShortFilms](https://github.com/vitorgalvao/alfred-workflows/tree/master/ShortFilms):

```
readonly remote_info_plist='https://raw.githubusercontent.com/vitorgalvao/alfred-workflows/master/ShortFilms/source/info.plist' 
readonly workflow_url='https://raw.githubusercontent.com/vitorgalvao/alfred-workflows/master/ShortFilms/ShortFilms.alfredworkflow'
readonly workflow_type='workflow'
readonly frequency_check='15'
```

`remote_info_plist` is the URL to this workflow’s up-to-date `info.plist` on a server. When checking for updates (in this case every 15 days, the number in `frequency_check`), the workflow version in that file will be compared to the one in the local workflow. If they differ, the code will continue. If `workflow_type` is set to `workflow`, `workflow_url` will be treated as the direct URL to a `.alfredworkflow`; it will be downloaded and opened. If `workflow_type` is set to `page`, `workflow_url` will be treated as a webpage and opened in the default browser.

For it to work you need only update the workflow version in the configuration sheet (which should be done anyway). When any update happens, the user will be informed via a notification. It will use `terminal-notfier` if it is somewhere in the workflow’s directory, otherwise it will use a plain AppleScript-called notification.

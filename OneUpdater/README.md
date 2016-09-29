`OneUpdater` is an updater you can plug with minimal configuration into workflows, to keep them up-to-date in users’ machines.

Easiest way to use it is to copy one of its `OneUpdater` nodes (the pink ones, with the note) to another workflow.

If the workflow actions anything (you press ↩ at some point during usage), copy the top node (`Run Script`). Connect it to the most used action and double click to edit it. Fill the top variables with the correct values, and you’re done.

![Setting up OneUpdater with Run Script](https://i.imgur.com/h0h5lki.gif)

If the workflow doesn’t action anything (`Script Filter`s with no connections), copy the bottom node (`Script Filter`). Double click to edit it. Make its `Keyowrd` the same as the most used in the workflow, fill the top variables with the correct values, and you’re done.

![Setting up OneUpdater with Script Filter](https://i.imgur.com/HKDOti9.gif)

The top lines (the ones that need changing) have comments explaining what they mean and some example values, but here’s an overview with a real example, from a version of [MarkdownBulletin](https://github.com/vitorgalvao/alfred-workflows/tree/master/MarkdownBulletin):

```
readonly local_file='info.plist'
readonly remote_file='https://raw.githubusercontent.com/vitorgalvao/alfred-workflows/master/MarkdownBulletin/info.plist' 
readonly workflow_url='https://github.com/packal/repository/raw/master/com.vitorgalvao.alfred.markdownbulletin/markdownbulletin.alfredworkflow'
readonly workflow_type='workflow'
readonly frequency_check='15'
```

`local_file` is some file inside the workflow’s directory (or anywhere, really) and `remote_file` is a file on a server. When checking for updates (in this case every 15 days, the number in `frequency_check`), `remote_file` will be downloaded and compared to `local_file`. If they differ, the code will continue. If `workflow_type` is set to `workflow`, `workflow_url` will be treated as the direct URL to a `.alfredworkflow`; it will be downloaded and opened. If `workflow_type` is set to `page`, `workflow_url` will be treated as a webpage and opened in the default browser.

For it to work smoothly, `local_file` (and its equivalent `remote_file`) should be one that always changes with every update. With Alfred 3, `info.plist` becomes a prime candidate as only its version needs to be updated (which should be done, anyway) for the file to change.

Since there’s no update file for the developer to manage, you can also configure `OneUpdater` on a workflow you haven’t developed and it will still work (provided the developer has the source available somewhere).

When any update happens, the user will be informed via a notification. It will use `terminal-notfier` if it is somewhere in the workflow’s directory, otherwise it will use a plain AppleScript-called notification.
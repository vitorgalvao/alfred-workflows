`OneUpdater` is an updater you can plug with minimal configuration into workflows, to keep them up-to-date in users’ machines.

Easiest way to use it is to copy one of its `OneUpdater` nodes (the pink ones, with the note) to another workflow.

If the workflow actions anything (you press ↵ at some point during usage), copy the top node (`Run Script`). Connect it to the most used action and double click to edit it. Fill the top variables with the correct values and you’re done.

![Setting up OneUpdater with Run Script](https://i.imgur.com/87AqLvI.gif)

If the workflow doesn’t action anything (`Script Filter`s with no connections), copy the bottom node (`Script Filter`) instead and make its `Keyword` the same as the most used in the workflow. Edit the top variables the same way.

The top lines must be set, and the rest of the code should be left untouched.

* `remote_info_plist` is the URL to the workflow’s up-to-date `info.plist` on a server.
* `workflow_url` and `download_type` work in tandem. `download_type` must be one of `direct`, `page`, or `github_release`.
  * When `direct`, `workflow_url` must be a direct link to a Workflow file.
  * When `page`, `workflow_url` must be a link to a download page.
  * When `github_release`, `workflow_url` must be of the form `username/repo`.
* `frequency_check` is the number of day between update checks. Set it to `0` when testing, so it fires on every use.

Example:

```
readonly remote_info_plist='https://raw.githubusercontent.com/vitorgalvao/alfred-workflows/master/ShortFilms/source/info.plist' 
readonly workflow_url='https://raw.githubusercontent.com/vitorgalvao/alfred-workflows/master/ShortFilms/ShortFilms.alfredworkflow'
readonly download_type='direct'
readonly frequency_check='4'
```

For it to work you need only update the workflow version in the configuration sheet (which should be done anyway). When any update happens, the user will be informed via a notification. It will be delivered by one of (in order and stopping at the first it finds) [`notificator`](https://github.com/vitorgalvao/notificator), [`terminal-notifier`](https://github.com/julienXX/terminal-notifier), or plain AppleScript-called notification.

With both `direct` and `github_release`, new Workflow versions will be downloaded directly and opened (`github_release` grabs the first file from the latest release of the repository). `page` will open a page on the default web browser.

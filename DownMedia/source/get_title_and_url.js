#!/usr/bin/osascript -l JavaScript

const frontmost_app_name = Application('System Events').applicationProcesses.where({ frontmost: true }).name()[0]
const frontmost_app = Application(frontmost_app_name)

if (['Google Chrome', 'Google Chrome Canary', 'Chromium', 'Opera', 'Vivaldi', 'Brave Browser'].indexOf(frontmost_app_name) > -1) {
  var current_tab_title = frontmost_app.windows[0].activeTab.name()
  var current_tab_url = frontmost_app.windows[0].activeTab.url()
} else if (['Safari', 'Safari Technology Preview', 'Webkit'].indexOf(frontmost_app_name) > -1) {
  var current_tab_title = frontmost_app.documents[0].name()
  var current_tab_url = frontmost_app.documents[0].url()
} else {
  throw new Error('You need a supported browser as your frontmost app')
}

current_tab_url + '\n' + current_tab_title

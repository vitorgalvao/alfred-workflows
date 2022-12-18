#!/usr/bin/osascript -l JavaScript

const frontmost_app = Application('System Events').applicationProcesses.where({ frontmost: true })
const frontmost_app_name = frontmost_app.name()[0]

const chromium_variants = ['Google Chrome', 'Chromium', 'Opera', 'Vivaldi', 'Brave Browser', 'Microsoft Edge']
const webkit_variants = ['Safari', 'Webkit']
const firefox_variants = ['firefox']

let current_tab_title, current_tab_url;

if (chromium_variants.some(app_name => frontmost_app_name.startsWith(app_name))) {
  current_tab_title = frontmost_app.windows[0].activeTab.name()
  current_tab_url = frontmost_app.windows[0].activeTab.url()
} else if (webkit_variants.some(app_name => frontmost_app_name.startsWith(app_name))) {
  current_tab_title = frontmost_app.windows[0].currentTab.name()
  current_tab_url = frontmost_app.windows[0].currentTab.url()
} else if (firefox_variants.some(app_name => frontmost_app_name.startsWith(app_name))) {
  current_tab_title = frontmost_app.windows[0].title()
  current_tab_url = frontmost_app.windows[0].groups[0].toolbars.byName('Navigation').comboBoxes[0].uiElements[0].value()
} else {
  throw new Error('You need a supported browser as your frontmost app')
}

current_tab_url + '\n' + current_tab_title

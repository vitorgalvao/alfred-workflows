#!/usr/bin/osascript -l JavaScript

const bookmarklet_code = "q=location.href;if(document.getSelection){d=document.getSelection();}else{d='';};p=document.title;void(open('https://pinboard.in/add?showtags=yes&url='+encodeURIComponent(q)+'&description='+encodeURIComponent(d)+'&title='+encodeURIComponent(p),'Pinboard','toolbar=no,scrollbars=yes,width=750,height=700'));"
const frontmost_app_name = Application('System Events').applicationProcesses.where({ frontmost: true }).name()[0]
const frontmost_app = Application(frontmost_app_name)

const chromium_variants = ['Google Chrome', 'Chromium', 'Opera', 'Vivaldi', 'Brave Browser', 'Microsoft Edge']
const webkit_variants = ['Safari', 'Webkit']

if (chromium_variants.some(app_name => frontmost_app_name.startsWith(app_name))) {
  frontmost_app.windows[0].activeTab.url = 'javascript:' + bookmarklet_code
} else if (webkit_variants.some(app_name => frontmost_app_name.startsWith(app_name))) {
  frontmost_app.doJavaScript(bookmarklet_code, { in: frontmost_app.windows[0].currentTab })
} else {
  throw new Error('You need a supported browser as your frontmost app')
}

Before using this workflow, you need to configure it with your Pinboard account by running `:configurepinadd` followed by your api token and your preferred browser.

![](https://i.imgur.com/6Wi0mXb.png)

You can get the API token of you Pinboard account by visiting https://pinboard.in/settings/password

Your preferred browser may be one of Safari, Webkit, Chrome, ChromeCanary, Chromium, or depends (“depends” uses the browser you have as the frontmost window, provided it’s one of the mentioned ones).

An example configuration would be: `:configurepinadd username:HSJWJK2HHSKI14QPDOIK safari`

When you’re all set, call `pin` followed by your tags and/or description — both are optional, and descriptions must be preceded by `// ` (two forward slashes and a space). Pick if it should be added as a regular bookmark or as a private one (this is important, as it’ll trump your default options), and you’re done.

![](http://imgur.com/lqt0ZnW.png)

The title of the bookmark will be the title of the page.
 
You can also precede your tags with `.` (a single period), and it will add the bookmark as unread.

![](http://imgur.com/79mgk9O.png)

There’s also a hotkey you can setup to quickly add bookmaks as unread (without any tags or description).

If adding a bookmark fails for any reason (for example, if the connection drops), you’ll get a notification and a `PinAddRetry.command` file will be added to your Desktop (if it happens multiple times, it’ll add an entry for each failed attempt). You can double-click this file at a later time to run it, and retry adding the bookmarks.

Run browser [bookmarklets](http://en.wikipedia.org/wiki/Bookmarklet) from Alfred, without needing to having them installed in the browser itself.

#### 1

For the first step, get this template workflow itself. Though this is not strictly necessary (you can build it yourself), it serves as a just starting point with most of the work already done. Proceed to open the workflow in Alfred.

Then get a browser bookmarklet to convert. In this example I use [squirt](http://squirt.io/). Go to the page that allows you to install the bookmaklet, and instead of adding it to your bookmarks bar, copy its link address.

![](http://i.imgur.com/jIbbOhq.gif)

#### 2

The next step may or may not be needed, depending on if the bookmarklet’s code has any double quotes (`"`) or is url encoded. In doubt, do it. Run `:cleanbookmarkletcode` to clean the code in your clipboard.

![](https://i.imgur.com/AQLlczy.png)

These substitutions are necessary to avoid problems when pasting the code in the top `Run Script` node.

#### 3

On to pasting the code. Open the top `Run Script` node, remove the line for the browser you do not want, and paste the bookmarklet’s code in place of the `<bookmarklet_code_here>` text (leave the quotes).

![](http://i.imgur.com/4tOY0OI.gif)

### Extra

If you’re not new to Alfred, you likely won’t need these steps, as you’ll probably know what to do.

#### 4

The template incudes both a `Keyword` and a `Hotkey` nodes to call the code. You can delete either one simply by clicking on it and pressing ⌫.

![](http://i.imgur.com/aDtale9.gif)

#### 5

If you choose to use the workflow via `Keyword`, do not forget to set it up with descriptions relevant to your bookmarklet.

![](http://i.imgur.com/Mdbl2Yy.gif)

#### 6

Lastly, edit the workflow’s details, and possibly its icon. I’ve pre-filled some of the information with my details, for completeness. Feel free to edit them, though.

![](http://i.imgur.com/xWSuaFG.png)


**Note on browsers:** This currently works with Safari and Chrome. Webkit, Chromium, and Google Chrome Canary use the same code, you need just change the name where appropriate (Webkit is the same as Safari, the others the same as Chrome). Other browsers generally have poor (or no) applescript support (needed for this), or require some options to be set in the browser itself.

**Note on instructions:** If you find subtle differences between the gifs and the actual workflow, that just means the workflow has been updated since but not the gifs (since they’re a bit time consuming), but the process is identical. If a workflow change drastically outdates the instructions (meaning they won’t be immediately perceptible) I’ll update the corresponding gifs.

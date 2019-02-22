Run browser [bookmarklets](http://en.wikipedia.org/wiki/Bookmarklet) from Alfred, without needing to having them installed in the browser itself.

Note that you may need to `Allow JavaScript from Apple Events` in your Browser.

#### 1

For the first step, get this template workflow itself. Though this is not strictly necessary (you can build it yourself) it serves as a starting point with most of the work already done. Proceed to open the workflow in Alfred.

Next, get a browser bookmarklet to convert by copying its link address.

![](https://i.imgur.com/dJ5XgkB.gif)

#### 2 

Run `:cleanbookmarkletcode` to clean the code in your clipboard. It performs substitutions necessary to avoid problems when pasting the code in the next step.

![](https://i.imgur.com/oIDEVcd.png)

#### 3

Open the `Arg and Vars` node and paste the code.

![](https://i.imgur.com/9SPYkmM.gif)

### Extra

If you’re not new to Alfred, you likely won’t need these steps as you’ll know what to do.

#### 4

The template includes both a `Keyword` and a `Hotkey` nodes to run the code. You can delete either one by clicking on it and pressing ⌫.

![](https://i.imgur.com/PRpCHu3.gif)

#### 5

If you choose to use the workflow via `Keyword`, do not forget to set it up.

![](https://i.imgur.com/ENFYAAe.gif)

#### 6

Lastly, edit the workflow’s details and its icon. For completeness it’s pre-filled with my details. Feel free to edit them.

![](https://i.imgur.com/KxIFI2A.png)

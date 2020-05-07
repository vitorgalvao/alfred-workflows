Invoke `ic` to open the current tab in your frontmost browser in a new incognito (Chromium-based browsers) or private (Webkit-based browsers) window. Actioning with ⌃↵ will also close the tab in your current window. ⌥↵ opens the tab in a new clean temporary browser profile window, and ⌘↵ does the same while closing the tab in the current window.

Webkit-based browsers do not support multiple profiles, so that feature is not available to them.

In addition, Webkit-based browsers do not support opening new private windows programatically, so to do it we can either fake a keyboard shortcut or click the menu options. Faking keyboard shortcuts can break in more situations, so this Workflow uses the latter technique. If your system is not in English, change the `webkit_menu_path` Workflow Environment Variable to the menu words in your language (they must be exact).

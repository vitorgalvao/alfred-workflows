Call `tmpmail` to make a temporary email address and open a background tab with the corresponding inbox. The address will be copied to your clipboard.

![](https://i.imgur.com/w7Y9kfZ.png)

Giving an argument will try to use that specific name, while leaving it blank will create a random address.

The `service` Workflow Environment Variable sets the service used for the inbox. Supported values: `teleosaurs.xyz`, `harakirimail.com`, `maildrop.cc`.

Because [Firefox does not support AppleScript](https://bugzilla.mozilla.org/show_bug.cgi?id=125419), the inbox will open in the foreground and you must manually return to the tab you were in.

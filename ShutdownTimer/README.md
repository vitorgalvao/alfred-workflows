The `shutdown` Keywords give you the option for an immediate or timed shutdown of your machine.

![](https://i.imgur.com/L6rETcW.png)

When timed, the Workflow will follow the values on the Workflow Environment Variables: turn off after `shutdown_seconds` and show a Large Type of the remaining time every `interval_seconds`. Invoke `shutdownabort` to cancel.

In both cases, `close_apps` determines if apps should be terminated beforehand.

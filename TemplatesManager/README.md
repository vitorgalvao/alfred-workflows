If you regularly need to set the same files or directory structures somewhere, say a set of prebuilt scripts and template files for certain types of regular projects, this workflow is meant to make your life easier.

It can take files, directory structures, and even URLs, and set them up as templates that’ll be copied over to your frontmost Finder window (if you’re using Path Finder, it will be used instead). Files and directory structures will be copied, and urls will be downloaded when requested (so you always get the latest version).

If you want to keep your templates synced between machines, use the `lists_dir` Workflow Environment Variable to pick a custom save location.

If you have a template that consists of a directory, you can place inside it an executable script with the name starting as `_templatesmanagerscript.` (the extension will be your pick), to be executed automatically after copying.

It has a lot of options and you’ll likely use most of them, so I’ll fire through them succinctly:

+ `Add to TemplatesManager` [File Action] — Add a file or directory to your local templates.
+ `tml` (TemplatesManagerList) [Script Filter] — Show a list of your local templates. Type to sort with your query. Press ↵ to copy the selected one to your frontmost Finder window.
    + `tml` (with ⌘) — If the selected template is a directory, instead of copying the directory itself, copy what’s inside it.
    + `tml` (with ⌥) — Delete your template.
+ `tme` (TemplatesManagerEdit) [Keyword] — Open the templates directory so you can add, remove, and edit them manually.
+ `rtml` (RemoteTemplatesManagerList) [Script Filter] — Show a list of your remote templates (download name and url). Type to sort with your query. Press ↵ on the selected one to download the file to your frontmost Finder window.
    + `rtml` (with ⌘) — Paste contents of template file, instead of downloading it.
    + `rtml` (with ⌥) — Remove the url from your remote templates list.
+ `rtme` (RemoteTemplatesManagerEdit) [Keyword] — Open the remote templates urls file in a text editor so you can add, remove, and edit them manually.
+ `rtma` (RemoteTemplatesManagerAdd) [Keyword] — takes the URL in your clipboard and adds it to your remote templates list.

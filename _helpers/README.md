# Workflow helpers

### `packal_placeholder.plist`

This one will likely only be of use to me.

This repository is the canonical source for all my Workflows. It’s their home for downloads and instructions. I only keep rectifying copies on Packal. They have a single trigger in it: `update`. It downloads and installs the latest version of the correct Workflow, replacing the placeholder.

To quickly build all such placeholders, I run a script that takes this `plist` as a template.

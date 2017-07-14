# Workflow helpers

### `_sharedresources`

Bundling dependencies with Workflows makes for a better experience. It ensures users can start using Workflows without fumbling with configurations or extra downloads. Many would have a hard time doing so. The tradeoff — a slight increase in size for the workflow — is mostly worth it.

This scripts saves from the duplication of always having to bundle the same tools, while keeping them updated.

* Call it with a single argument at a time.
* It checks if the argument is valid (i.e. if the script supports that tool).
  * If it does not, it fails and explains why.
  * If it does, it continues.
* It checks if we already have the tool installed (including in /usr/local/bin/).
  * If we do, it checks if it was previously installed by this script or not.
    * If installed by this script, check how long since its last update. If longer than a defined period, update it.
    * If not installed by this script, leave it alone.
  * If we do not (have the tool installed), download it to `Library/Application Support/Alfred 3/Workflow Data/com.vitorgalvao.alfred._sharedresources`.
* The full path to the tool is output.

### `packal_placeholder.plist`

This one will likely only be of use to me.

This repository is the canonical source for all my Workflows. It’s their home for downloads and instructions. I only keep rectifying copies on Packal. They have a single trigger in it: `update`. It downloads and installs the latest version of the correct Workflow, replacing the placeholder.

To quickly build all such placeholders, I run a script that takes this `plist` as a template.

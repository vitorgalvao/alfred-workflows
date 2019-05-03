# Workflow helpers

### `_sharedresources`

Bundling dependencies with Workflows makes for a better experience. It ensures users can start using Workflows without fumbling with configurations or extra downloads. Many would have a hard time doing so. The tradeoff — a slight increase in size for the workflow — is mostly worth it.

This scripts saves from the duplication of always having to bundle the same tools, while keeping them updated.

* Call it with the arguments for the tools you need (`--help` will list all valid ones).
* It checks if the arguments are valid (i.e. if the script supports those tools).
  * If it does not, it fails and explains why.
  * If it does, it continues.
* For each tool, it checks if we already have it installed (including in `/usr/local/bin/`).
  * If we do, it checks if it was previously installed by this script or not.
    * If yes, check how long since its last update. If longer than a defined period, update it.
    * If not, leave it alone.
  * If we do not (have the tool installed), download it to `~/Library/Application Support/Alfred/Workflow Data/com.vitorgalvao.alfred._sharedresources`.
* A `PATH` which includes all tools is output. Use it to set the `PATH` in your Workflow.

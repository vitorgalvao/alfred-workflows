#!/bin/bash

function error {
  echo "${1}" >&2
  exit 1
}

current_browser="$(osascript -l JavaScript -e '
    const frontmost_app_name = Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0]

    if (["Safari","Safari Technology Preview"].indexOf(frontmost_app_name) > -1) {
      frontmost_app_name
    } else {
      "Unsupported"
    }
')"

[[ "${current_browser}" == 'Unsupported' ]] && error 'You need a supported web browser as your frontmost app.'
[[ "${current_browser}" == 'Safari' ]] && [[ "$(defaults read com.apple.Safari IncludeDevelopMenu)" -eq 1 ]] || [[ "${current_browser}" == 'Safari Technology Preview' ]] && [[ "$(defaults read com.apple.SafariTechnologyPreview WebKitDeveloperExtrasEnabledPreferenceKey)" -eq 1 ]] && error 'You need to enable the Develop menu.'

echo -n "${current_browser}" # Will only output if the previous checks pass

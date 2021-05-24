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

if [[ "${current_browser}" == 'Safari' ]]; then
  [[ "$(defaults read com.apple.Safari IncludeDevelopMenu)" -eq 0 ]] && error 'You need to enable the Develop menu.'
elif [[ "${current_browser}" == 'Safari Technology Preview' ]]; then
  [[ "$(defaults read com.apple.SafariTechnologyPreview WebKitDeveloperExtrasEnabledPreferenceKey)" -eq 0 ]] && error 'You need to enable the Develop menu.'
else
  error 'You need a supported web browser as your frontmost app.'
fi

echo -n "${current_browser}" # Will only output if the previous checks pass

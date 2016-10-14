#!/bin/bash

set -e # Abort on any failure.

imgur_uploader_exec='./imgur'
resample_dpi_exec='./_licensed/resample-dpi/resample-dpi'

tmp_name="$(mktemp -t 'webscreenshot')"
delete_url_file='/tmp/webscreenshot_latest_upload_delete_url.txt'

notification() {
  ./_licensed/terminal-notifier/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "${alfred_workflow_name}" -message "${1}"
}

check_failure() {
  if [[ "$?" -ne 0 ]]; then
    afplay /System/Library/Sounds/Funk.aiff &
    notification 'Screenshot not uploaded.'
    exit 1
  fi
}

show_success() {
  afplay /System/Library/Sounds/Ping.aiff &
  notification 'Link copied to clipboard.'
}

resample_dpi() {
  local screenshot_file="${1}"
  bash "${resample_dpi_exec}" "${screenshot_file}" &>/dev/null

  echo "${screenshot_file}"
}

take_screenshot() {
  local screenshot_file="${tmp_name}.png"
  screencapture -i "${screenshot_file}"

  check_failure
  echo "${screenshot_file}"
}

copy_image() {
  local file_name="${1}"
  local file_extension=$([[ "${file_name}" = *.* ]] && echo ".${file_name##*.}" || echo '')
  local screenshot_file="${tmp_name}.${file_extension}"
  cp "${file_name}" "${screenshot_file}"

  echo "${screenshot_file}"
}

upload_file() {
  local screenshot_file="${1}"
  bash "${imgur_uploader_exec}" "${screenshot_file}" 2>> "${delete_url_file}" | tr -d '\n' | pbcopy

  check_failure
  show_success

  echo "└ Uploaded on $(date)" >> ${delete_url_file}
}

if [[ "${1}" == 'take_screenshot' ]]; then
  screenshot_file=$(take_screenshot)
  shift
elif [[ "${1}" == 'upload_image' ]]; then
  screenshot_file="$(copy_image "${2}")"
  shift 2
fi

if [[ "${1}" == 'resample' ]]; then
  screenshot_file="$(resample_dpi "${screenshot_file}")"
fi

upload_file "${screenshot_file}"

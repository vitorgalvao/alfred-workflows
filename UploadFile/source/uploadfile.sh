#!/bin/bash

readonly progress_file='/tmp/uploadfile_progress'
readonly name_file='/tmp/uploadfile_name' # for `ufp` (in Alfred)

function notification {
  ./_licensed/terminal-notifier/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "${alfred_workflow_name}" -message "${1}"
}

function ascii_basename {
  basename "${1}" | sed -e 's/[^a-zA-Z0-9._-]/-/g'
}

function transfer {
  readonly local given_file="${1}"

  # Make zip if acting on a directory
  if [[ -d "${given_file}" ]]; then
    readonly local dir_name=$(ascii_basename "${given_file}")
    readonly local zip_file="/tmp/${dir_name}.zip"
    ditto -ck "${given_file}" "${zip_file}"
    readonly local file_path="${zip_file}"
  else
    readonly local file_path="${given_file}"
  fi

  readonly local file_name=$(ascii_basename "${file_path}")
  echo -n "${file_name}" > "${name_file}"
  notification "Uploading “${file_name}”"

  # Upload and copy url to clipboard
  curl --globoff --progress-bar --upload-file "${file_path}" "https://transfer.sh/${file_name}" 2> "${progress_file}" | tr -d '\n' | pbcopy

  # Play sound and show message
  afplay /System/Library/Sounds/Ping.aiff
  notification "Uploaded “${file_name}”"
}

function kill_transfer {
  readonly local file_name="$(cat "${name_file}")"

  # Kill parent to prevent notification showing success and child to stop upload
  parent_process="$(pgrep -f 'bash uploadfile.sh upload')"
  oldest_child_process="$(pgrep -oP "${parent_process}")"
  kill "${parent_process}" "${oldest_child_process}"

  # Play sound and show message
  afplay /System/Library/Sounds/Funk.aiff
  notification 'Upload canceled'
}

if [[ "${1}" == 'upload' ]]; then
  transfer "${2}"
elif [[ "${1}" == 'abort' ]]; then
  kill_transfer
else
  echo 'A wrong option was given.'
  exit 1
fi

# Delete temporary files
rm "${progress_file}" "${name_file}"

#!/bin/bash

set -e # abort on any failure

imgur_screenshot_exec='./_licensed/imgur-screenshot/imgur-screenshot.sh'
resample_dpi_exec='./_licensed/resample-dpi/resample-dpi'

tmp_name="$(mktemp -t 'webscreenshot')"

notification() {
  ./_licensed/terminal-notifier/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'WebScreenshot' -message "${1}"
}

check_failure() {
  if [[ "$?" != '0' ]]; then
    afplay /System/Library/Sounds/Funk.aiff
    notification 'Screenshot not uploaded.'
  fi
}

show_success() {
  afplay /System/Library/Sounds/Ping.aiff
  notification 'Link copied to clipboard.'
}

resample_dpi() {
  local screenshot_file="$1"
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
  local file_name="$1"
  local file_extension=$([[ "${file_name}" = *.* ]] && echo ".${file_name##*.}" || echo '')
  local screenshot_file="${tmp_name}.${file_extension}"
  cp "${file_name}" "${screenshot_file}"

  echo "${screenshot_file}"
}

upload_file() {
  local screenshot_file="$1"
  bash "${imgur_screenshot_exec}" --open false "${screenshot_file}"

  check_failure
  show_success
}

if [[ "$1" == 'take_screenshot' ]]; then
  screenshot_file=$(take_screenshot)
  shift
elif [[ "$1" == 'upload_image' ]]; then
  screenshot_file="$(copy_image "$2")"
  shift 2
fi

if [[ "$1" == 'resample' ]]; then
  screenshot_file="$(resample_dpi "${screenshot_file}")"
fi

upload_file "${screenshot_file}"

# update external software
[[ $(find "${imgur_screenshot}" -mtime +15) ]] && bash "${imgur_screenshot}" --update
[[ $(find "${resample_dpi_exec}" -mtime +90) ]] && curl --location 'https://raw.githubusercontent.com/cowboy/dotfiles/master/bin/resample-dpi' --output "${resample_dpi_exec}"

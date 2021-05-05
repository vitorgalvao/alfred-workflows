#!/bin/zsh

readonly program="$(basename "${0}")"
readonly applet="$(dirname "$(dirname "$(dirname "${0}")")")/MacOS/applet"
readonly app="$(dirname "$(dirname "$(dirname "${applet}")")")"

function usage {
  echo "
    Usage:
      ${program} [options]

    Options:
      -m, --message <text>       Message text (mandatory).
      -t, --title <text>         Title text.
      -s, --subtitle <text>      Subtitle text.
      -a, --sound <sound_name>   Sound name (from /System/Library/Sounds).
      -h, --help                 Show this help.
  " | sed -E 's/^ {4}//'
}

# Options
args=()
while [[ "${1}" ]]; do
  case "${1}" in
    -h | --help)
      usage
      exit 0
      ;;
    -m | --message)
      notificator_message="${2}"
      shift
      ;;
    -t | --title)
      notificator_title="${2}"
      shift
      ;;
    -s | --subtitle)
      notificator_subtitle="${2}"
      shift
      ;;
    -a | --sound)
      notificator_sound="${2}"
      shift
      ;;
    --)
      shift
      args+=("${@}")
      break
      ;;
    -*)
      echo "Unrecognised option: ${1}"
      exit 1
      ;;
    *)
      args+=("${1}")
      ;;
  esac
  shift
done
set -- "${args[@]}"

if /usr/bin/xattr -p com.apple.quarantine "${app}" &> /dev/null; then
  /usr/bin/xattr -d com.apple.quarantine "${app}"
fi

if ! /usr/bin/codesign --verify "${app}" 2> /dev/null; then
  /usr/bin/codesign --sign - "${app}"
fi

if [[ -z "${notificator_message}" ]]; then
  echo 'A message is mandatory.' >&2
  exit 1
fi

osascript -l JavaScript -e 'ObjC.import("Cocoa"); while ($.NSEvent.modifierFlags & $.NSEventModifierFlagControl) { false }' # Prevent script from continuing while ctrl is pressed, otherwise we get the "Press Run to run this script, or Quit to quit." message

"${applet}" "${notificator_message}" "${notificator_title}" "${notificator_subtitle}" "${notificator_sound}"

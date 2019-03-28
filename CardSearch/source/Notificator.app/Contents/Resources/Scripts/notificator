#!/bin/bash

export notificator_message=''
export notificator_title=''
export notificator_subtitle=''
export notificator_sound=''

readonly program="$(basename "${0}")"
readonly applet="$(dirname "$(dirname "$(dirname "${0}")")")/MacOS/applet"
readonly app="$(dirname "$(dirname "$(dirname "${applet}")")")"

function syntax_error {
  echo -e "${program}: ${1}\nTry \`${program} --help\` for more information." >&2
  exit 1
}

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
    -*)
      syntax_error "unrecognized option: ${1}"
      ;;
    *)
      break
      ;;
  esac
  shift
done

if [[ -z "${notificator_message}" ]]; then
  echo 'A message is mandatory.' >&2
  exit 1
fi

touch "${app}" # Notifications will never fire if we do not do this the first time, for some reason
osascript -l JavaScript -e 'ObjC.import("Cocoa"); while ($.NSEvent.modifierFlags & $.NSEventModifierFlagControl) { false }' # Prevent script from continuing while ctrl is pressed, otherwise we get the "Press Run to run this script, or Quit to quit." message
"${applet}" "${notificator_message}" "${notificator_title}" "${notificator_subtitle}" "${notificator_sound}"

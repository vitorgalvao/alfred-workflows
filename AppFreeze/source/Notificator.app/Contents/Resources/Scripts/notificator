#!/bin/bash

export notificator_message=''
export notificator_title=''
export notificator_subtitle=''
export notificator_sound=''

readonly program="$(basename "${0}")"
readonly applet="$(dirname "$(dirname "$(dirname "${0}")")")/MacOS/applet"
readonly app="$(dirname "$(dirname "$(dirname "${applet}")")")"

readonly rsrc="$(dirname "$(dirname "${0}")")/applet.rsrc"
readonly rsrc_md5='bb347efb37a44961d1c636022db65182'
readonly rsrc_base64='AAABAAAAASQAAAAkAAAARgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABpAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAQAAAAEkAAAAJAAAAEYHAAAAIQAAAAAcAEYAAXNjc3oAAAASc3BzaAAAAB4AAP//AAAAAAEAAAAAAP//AAAAHgIAAAA='

function syntax_error {
  echo "${program}: ${1}\nTry \`${program} --help\` for more information." >&2
  exit 1
}

function usage {
  echo "
    usage: ${program} [options]
    options:
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

[[ "$(md5 -q "${rsrc}")" != "${rsrc_md5}" ]] && base64 --decode <<< "${rsrc_base64}" > "${rsrc}" # If the rsrc file changed for any reason, we might get the startup screen (asks to Run or Quit the script). This reverts it to a version that does not do that
touch "${app}" # For some reason, if we do not do this the first time notifications will never fire
"${applet}" "${notificator_message}" "${notificator_title}" "${notificator_subtitle}" "${notificator_sound}"

# THESE VARIABLES MUST BE SET. SEE THE ONEUPDATER README FOR AN EXPLANATION OF EACH.
readonly remote_info_plist=''
readonly workflow_url=''
readonly download_type=''
readonly frequency_check=''

# FROM HERE ON, CODE SHOULD BE LEFT UNTOUCHED!
function abort {
  echo "${1}" >&2
  exit 1
}

function url_exists {
  curl --silent --location --output /dev/null --fail --range 0-0 "${1}"
}

function notification {
  local -r notificator="$(find . -type d -name 'Notificator.app')"
  if [[ -n "${notificator}" ]]; then
    "${notificator}/Contents/Resources/Scripts/notificator" --message "${1}" --title "${alfred_workflow_name}" --subtitle 'A new version is available'
    return
  fi

  local -r terminal_notifier="$(find . -type f -name 'terminal-notifier')"
  if [[ -n "${terminal_notifier}" ]]; then
    "${terminal_notifier}" -title "${alfred_workflow_name}" -subtitle 'A new version is available' -message "${1}"
    return
  fi

  osascript -e "display notification \"${1}\" with title \"${alfred_workflow_name}\" subtitle \"A new version is available\""
}

# Local sanity checks
readonly local_info_plist='info.plist'
readonly local_version="$(/usr/libexec/PlistBuddy -c 'print version' "${local_info_plist}")"

[[ -n "${local_version}" ]] || abort 'You need to set a workflow version in the configuration sheet.'
[[ "${download_type}" =~ ^(direct|page|github_release)$ ]] || abort "'download_type' (${download_type}) needs to be one of 'direct', 'page', or 'github_release'."
[[ "${frequency_check}" =~ ^[0-9]+$ ]] || abort "'frequency_check' (${frequency_check}) needs to be a number."

# Check for updates
if [[ $(find "${local_info_plist}" -mtime +"${frequency_check}"d) ]]; then
  if ! url_exists "${remote_info_plist}"; then abort "'remote_info_plist' (${remote_info_plist}) appears to not be reachable."; fi # Remote sanity check

  readonly tmp_file="$(mktemp)"
  curl --silent --location --output "${tmp_file}" "${remote_info_plist}"
  readonly remote_version="$(/usr/libexec/PlistBuddy -c 'print version' "${tmp_file}")"

  if [[ "${local_version}" == "${remote_version}" ]]; then
    touch "${local_info_plist}" # Reset timer by touching local file
    exit 0
  fi

  if [[ "${download_type}" == 'page' ]]; then
    notification 'Opening download page…'
    open "${workflow_url}"
    exit 0
  fi

  download_url="$([[ "${download_type}" == 'github_release' ]] && curl --silent "https://api.github.com/repos/${workflow_url}/releases/latest" | grep 'browser_download_url' | head -1 | sed -E 's/.*browser_download_url": "(.*)"/\1/' || echo "${workflow_url}")"

  if url_exists "${download_url}"; then
    notification 'Downloading and installing…'
    curl --silent --location --output "${HOME}/Downloads/${alfred_workflow_name}.alfredworkflow" "${download_url}"
    open "${HOME}/Downloads/${alfred_workflow_name}.alfredworkflow"
  else
    abort "'workflow_url' (${download_url}) appears to not be reachable."
  fi
fi

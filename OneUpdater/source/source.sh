readonly remote_info_plist='https://someserver.tld/myworkflow/info.plist' # URL of remote info.plist
readonly workflow_url='https://someserver.tld/myworkflow.alfredworkflow' # URL to directly download workflow or workflow download page
readonly workflow_type='workflow' # Either 'workflow' if workflow_url points to direct download, or 'page' if it points to download page
readonly frequency_check='4' # Days between update checks

# FROM HERE ON, CODE SHOULD BE LEFT UNTOUCHED UNLESS YOU KNOW WHAT YOU ARE DOING
function abort {
  echo "${1}" >&2
  exit 1
}

function url_exists {
  curl --silent --location --output /dev/null --fail --range 0-0 "${1}"
}

function notification {
  readonly local notificator="$(find . -type d -name 'Notificator.app')"
  if [[ -n "${notificator}" ]]; then
    "${notificator}/Contents/Resources/Scripts/notificator" --message "${1}" --title "${alfred_workflow_name}" --subtitle 'A new version is available'
    return
  fi

  readonly local terminal_notifier="$(find . -type f -name 'terminal-notifier')"
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
[[ "${workflow_type}" =~ ^(workflow|page)$ ]] || abort "'workflow_type' (${workflow_type}) needs to be one of 'workflow' or 'page'."
[[ "${frequency_check}" =~ ^[0-9]+$ ]] || abort "'frequency_check' (${frequency_check}) needs to be a number."

# Check for updates
if [[ $(find "${local_info_plist}" -mtime +"${frequency_check}"d) ]]; then
  if ! url_exists "${remote_info_plist}"; then abort "'remote_info_plist' (${remote_info_plist}) appears to not be reachable."; fi # Remote sanity check

  readonly tmp_file="$(mktemp)"
  curl --silent --location --output "${tmp_file}" "${remote_info_plist}"
  readonly remote_version="$(/usr/libexec/PlistBuddy -c 'print version' "${tmp_file}")"

  if [[ "${local_version}" != "${remote_version}" ]]; then
    if [[ "${workflow_type}" == 'page' ]]; then
      notification 'Opening download page…'
      open "${workflow_url}"
    else
      if url_exists "${workflow_url}"; then
        notification 'Downloading and installing…'
        curl --silent --location --output "${HOME}/Downloads/${alfred_workflow_name}.alfredworkflow" "${workflow_url}"
        open "${HOME}/Downloads/${alfred_workflow_name}.alfredworkflow"
      else
        abort "'workflow_url' (${workflow_url}) appears to not be reachable."
      fi # url_exists
    fi # workflow_type
  else
    touch "${local_info_plist}" # Reset timer by touching local file
  fi # diff
fi #find

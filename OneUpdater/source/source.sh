readonly local_file='info.plist' # Local file to compare to remote_file
readonly remote_file='https://someserver.tld/myworkflow/info.plist' # Remote file (URL) to compare to local_file
readonly workflow_url='https://someserver.tld/myworkflow.alfredworkflow' # URL to directly download workflow or workflow download page
readonly workflow_type='workflow' # Either 'workflow' if workflow_url points to direct download, or 'page' if it points to download page
readonly frequency_check='15' # Days between update checks

# FROM HERE ON, CODE SHOULD BE LEFT UNTOUCHED UNLESS YOU KNOW WHAT YOU ARE DOING
function abort {
  echo "${1}" 1>&2
  exit 1
}

function url_exists {
  if curl --silent --location --output /dev/null --fail --range 0-0 "${1}"; then
    return 0
  else
    return 1
  fi
}

function notification {
  local readonly terminal_notifier="$(find . -name terminal-notifier.app)"

  if [[ -n "${terminal_notifier}" ]]; then
    "${terminal_notifier}"/Contents/MacOS/terminal-notifier -title "${alfred_workflow_name}" -subtitle 'A new version is available' -message "${1}"
  else
    osascript -e "display notification \"${1}\" with title \"${alfred_workflow_name}\" subtitle \"A new version is available\""
  fi
}

# Local sanity checks
[[ ! -f "${local_file}" ]] && abort "'local_file' ("${local_file}") appears to not point to an existing file."
[[ ! "${workflow_type}" =~ ^(workflow|page)$ ]] && abort "'workflow_type' ("${workflow_type}") needs to be one of 'workflow' or 'page'."
[[ ! "${frequency_check}" =~ ^[0-9]+$ ]] && abort "'frequency_check' ("${frequency_check}") appears to not be a number."

# Check for updates
if [[ $(find "${local_file}" -mtime +"${frequency_check}") ]]; then
  if ! url_exists "${remote_file}"; then abort "'remote_file' ("${remote_file}") appears to not be reachable."; fi # Remote sanity check

  readonly tmp_file="$(mktemp)"
  curl --silent --location --output "${tmp_file}" "${remote_file}"

  if [[ "$(diff "${local_file}" "${tmp_file}")" ]]; then
    if [[ "${workflow_type}" == 'page' ]]; then
      notification 'Opening download page…'
      open "${workflow_url}"
    else
      if url_exists "${workflow_url}"; then
        notification 'Downloading and installing…'
        curl --silent --location --output "${HOME}/Downloads/${alfred_workflow_name}.alfredworkflow" "${workflow_url}"
        open "${HOME}/Downloads/${alfred_workflow_name}.alfredworkflow"
      else
        abort "'workflow_url' ("${workflow_url}") appears to not be reachable."
      fi # url_exists
    fi # workflow_type
  else
    touch "${local_file}" # Reset timer by touching local file
  fi # diff
fi #find

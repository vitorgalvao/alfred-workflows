# set notifications
notification() {
  ./_licensed/terminal-notifier/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "${alfred_workflow_name}" -message "${1}"
}

if [[ "${1}" == 'restart_download_true' ]]; then
  notification 'Restarting download at bottom of queue'
  currentquery=$(cat '/tmp/downvidcurrentquery')

  osascript -e "tell application \"Alfred 3\" to run trigger \"new\" in workflow \"com.vitorgalvao.alfred.downvid\" with argument \"${currentquery}\""
else
  notification 'Download aborted'
  rm '/tmp/downvidprogress'
fi

# kill parent to prevent notification showing success and child to stop upload
parent_process="$(pgrep -f 'downvid.sh')"
child_process="$(pgrep -P "${parent_process}")"
kill "${parent_process}" "${child_process}"

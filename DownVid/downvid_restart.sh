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

kill $(ps -A | grep 'downvid.sh' | awk '{print $1}')

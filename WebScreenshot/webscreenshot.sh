imgur_screenshot='./_licensed/imgur-screenshot/imgur-screenshot.sh'

notification() {
  ./_licensed/terminal-notifier/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'CloudScreenshot' -message "${1}"
}

# Are we taking a screenshot or updating an existing file?
[[ "$1" == 'upload_image' ]] && image_file="$2"

# upload file and check for version
bash "${imgur_screenshot}" --open false --keep-file false "${image_file}"

# Act depending on outcome
if [[ "$?" == '0' ]]; then
  afplay /System/Library/Sounds/Ping.aiff
  notification 'Link copied to clipboard.'
else
  afplay /System/Library/Sounds/Funk.aiff
  notification 'Screenshot not uploaded.'
fi

# update if older than 15 days
[[ $(find "${imgur_screenshot}" -mtime +15) ]] && bash "${imgur_screenshot}" --update

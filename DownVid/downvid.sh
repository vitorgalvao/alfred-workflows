IFS=$'\n'

# Workflow Environment Variables
wev_downdir="${HOME}/${download_dir}"
wev_watchlist_downdir="${HOME}/${watchlist_download_dir}"

# global options for downloads
PATH=/usr/local/bin:$PATH
if [[ "$(which ffmpeg avconv)" ]]; then
  # download and embed subtitles
  subs_options=(--all-subs --embed-subs)
  # force a fileformat, for consistency between gettitle and getfile
  file_format=(--format bestvideo[ext=mp4]+bestaudio[ext=m4a]/best)
fi

# parse query
full_query="$@"
link_file=$(awk '{ print $1 }' <<< "${full_query}")
watchlist_bool=$(awk '{ gsub(".*_", "", $2); print $2 }' <<< "${full_query}")
playlist_bool=$(awk '{ gsub(".*_", "", $3); print $3 }' <<< "${full_query}")

# set file naming template depending on if downloading playlist
if [[ "${playlist_bool}" == 'true' ]]; then
  playlist_options='--yes-playlist'
  title_template='%(playlist)s-%(playlist_index)s-%(title)s.%(ext)s'
else
  playlist_options='--no-playlist'
  title_template='%(title)s.%(ext)s'
fi

# set notifications
notification() {
  ./_licensed/terminal-notifier/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "${alfred_workflow_name}" -message "${1}"
}

# update youtube-dl if it's more than 15 days old
if [[ $(find youtube-dl -mtime +15) ]]; then
  python youtube-dl --update
fi

gettitle() {
  # file location
  filename=$(python youtube-dl --get-filename --ignore-errors ${file_format[@]} ${playlist_options} --output "${downdir}/${title_template}" "${link}")

  # title
  title=$(basename "${filename%.*}")

  # check if url is valid
  if [[ -z "${filename}" ]]; then
    notification 'The url is invalid'
    exit 1
  else
    notification "Downloading “${title}”"
  fi
}

getfile() {
  progressfile='/tmp/downvidprogress'

  python youtube-dl --newline ${subs_options[@]} --ignore-errors ${file_format[@]} ${playlist_options} --output "${downdir}/${title_template}" "${link}" > "${progressfile}"

  # add metadata
  xmlencodedurl=$(echo "${link}" | perl -MHTML::Entities -CS -pe'$_ = encode_entities($_, q{&<>"'\''})')
  xattr -w com.apple.metadata:kMDItemWhereFroms '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><array><string>'"${xmlencodedurl}"'</string></array></plist>' "${filename}"

  rm "${progressfile}"
}

# download
echo -n "${full_query}" > '/tmp/downvidcurrentquery'
link="$(cat ${link_file})"

if [[ "${watchlist_bool}" == 'true' ]]; then
  downdir="${wev_watchlist_downdir}"
  gettitle
  getfile
  osascript -e "tell application \"Alfred 3\" to run trigger \"add_file_to_watchlist\" in workflow \"com.vitorgalvao.alfred.watchlist\" with argument \"${filename}\""
else
  downdir="${wev_downdir}"
  gettitle
  getfile
fi

notification "Downloaded “${title}”"

export LANG=en_GB.UTF-8 # deal with special characters
PATH=$(pwd):$PATH # to load youtube-dl
IFS=$'\n'

# global variables
readonly workflow_bundle_id="com.vitorgalvao.alfred.watchlist"
readonly non_volatile_prefs_dir="${HOME}/Library/Application Support/Alfred 2/Workflow Data/${workflow_bundle_id}"
readonly towatch="${non_volatile_prefs_dir}/towatch"
readonly watched="${non_volatile_prefs_dir}/watched"

# functions
notification() {
  ./_licensed/terminal-notifier/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "WatchList" -message "${1}"
}

wrong_item_type() {
  echo "Something went wrong. Item type is invalid ($1)."
  exit 1
}

prepend() {
  local line_to_prepend file_to_prepend_to tmp_prepend_file

  line_to_prepend="$1"
  file_to_prepend_to="$2"
  tmp_prepend_file="$(mktemp -t prepend)"

  echo "${line_to_prepend}" | cat - "${file_to_prepend_to}" > "${tmp_prepend_file}"
  mv "${tmp_prepend_file}" "${file_to_prepend_to}"
}

use_list() {
  chosen_list="$1"

  if [[ "${chosen_list}" == 'towatch' ]]; then
    list="${towatch}"
    valid='yes'
  elif [[ "${chosen_list}" == 'watched' ]]; then
    list="${watched}"
    valid='yes'
  elif [[ "${chosen_list}" == 'share' ]]; then
    list="${watched}"
    action='share'
  else
    echo 'You need to pick a valid list'
    exit 1
  fi
}

load_item() {
  line_number="$1"

  list_item=$(sed -n "${line_number}p" "${list}")
  IFS='⸗' read item_type item_title item_location item_size item_duration <<< "${list_item}"
}

what_video_player() {
  if [[ "$(mdfind kMDItemCFBundleIdentifier = io.mpv)" ]]; then
    video_player='mpv'
  elif [[ "$(mdfind kMDItemCFBundleIdentifier = org.videolan.vlc)" ]]; then
    video_player='vlc'
  else
    notification 'You need either mpv or vlc, to stream a video.'
    exit 1
  fi
}

play_file() {
  item_location="$1"

  if [[ "${item_type}" == 'file' ]]; then
    open "${item_location}"
  elif [[ "${item_type}" == stream ]]; then
    what_video_player
    open -a "${video_player}" "${item_location}"
  else
    wrong_item_type "${item_type}"
  fi
}

get_item_origin_url() {
  item_type="$1"
  item_location="$2"

  if [[ "${item_type}" == 'file' ]]; then
    mdls -name kMDItemWhereFroms "${item_location}" | sed -n '2p' | tr -d ' "\n'
  elif [[ "${item_type}" == 'stream' ]]; then
    echo "${item_location}"
  else
    wrong_item_type "${item_type}"
  fi
}

move_list_item() {
  line_number="$1"

  if [[ "${chosen_list}" == 'towatch' ]]; then
    origin_list="${towatch}"
    destiny_list="${watched}"
  elif [[ "${chosen_list}" == 'watched' ]]; then
    origin_list="${watched}"
    destiny_list="${towatch}"
  else
    echo 'You need to pick a valid list'
    exit 1
  fi

  list_item=$(sed -n "${line_number}p" "${origin_list}")
  sed -i '' "${line_number}d" "${origin_list}"
  prepend "${list_item}" "${destiny_list}"
}

watch_script_filter() {
  search="$1"

  echo "<?xml version='1.0'?><items>"
  list_contents=$(cat "${list}")
  for list_line in $(grep -in ".*${search}.*" <<< "${list_contents}"); do
    line_number="$(sed 's/:.*//' <<< ${list_line})"

    load_item "${line_number}"

    if [[ "${action}" == 'share' ]]; then
      url=$(get_item_origin_url "${item_type}" "${item_location}")
      if [[ -z "${url}" ]]; then
        url="This item has no metadata on where it's from"
        valid='no'
      else
        valid='yes'
      fi
      subtitle_item="<subtitle><![CDATA[${url}]]></subtitle>"
    else
      if [[ "${item_type}" == 'file' ]]; then
        if [[ "${item_duration}" != '' ]]; then
          subtitle_item="<subtitle>${item_duration} ⸗ ${item_size} ⸗ <![CDATA[${item_location}]]></subtitle>"
        else
          subtitle_item="<subtitle>${item_size} ⸗ <![CDATA[${item_location}]]></subtitle>"
        fi
      elif [[ "${item_type}" == 'stream' ]]; then
        subtitle_item="<subtitle>≈ ${item_duration} ⸗ <![CDATA[${item_location}]]></subtitle>"
      else
        wrong_item_type "${item_type}"
      fi
    fi

    echo "<item uuid='${line_number}' arg='${line_number}' valid='${valid}'>"
    echo "<title><![CDATA[${item_title}]]></title>"
    echo "${subtitle_item}"
    echo "<icon>icon.png</icon>"
    echo "</item>"
  done
  echo "</items>"
}

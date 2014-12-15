# deal with special characters
export LANG=en_GB.UTF-8

IFS=$'\n'

# global variables
workflow_bundle_id="com.vitorgalvao.alfred.watchlist"
non_volatile_prefs_dir="${HOME}/Library/Application Support/Alfred 2/Workflow Data/${workflow_bundle_id}"
towatch="${non_volatile_prefs_dir}/towatch"
watched="${non_volatile_prefs_dir}/watched"

# functions
notification() {
  ./_licensed/terminal-notifier/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "WatchList" -message "${1}"
}

get_item_origin_url() {
  mdls -name kMDItemWhereFroms "$1" | sed -n '2p' | tr -d ' "\n'
}

move_list_item() {
  list="$1"
  line_number="$2"

  if [[ "${list}" == 'towatch' ]]; then
    origin_list="${towatch}"
    destiny_list="${watched}"
  elif [[ "${list}" == 'watched' ]]; then
    origin_list="${watched}"
    destiny_list="${towatch}"
  else
    echo 'You need to pick a valid list'
    exit 1
  fi

  list_item=$(sed -n "${line_number}p" "${origin_list}")
  sed -i '' "${line_number}d" "${origin_list}"
  printf "${list_item}\n$(cat "${destiny_list}")" > "${destiny_list}"
}

watch_script_filter() {
  chosen_list="$1"
  search="$2"

  if [[ "${chosen_list}" == 'towatch' ]]; then
    list="${towatch}"
    valid='yes'
  elif [[ "${chosen_list}" == 'watched' ]]; then
    list="${watched}"
    valid='yes'
  elif [[ "${chosen_list}" == 'share' ]]; then
    list="${watched}"
  else
    echo 'You need to pick a valid list'
    exit 1
  fi

  echo "<?xml version='1.0'?><items>"
  list_contents=$(cat ${list})
  for list_line in $(echo "${list_contents}" | grep -in ".*${search}.*"); do
    line_number="$(echo ${list_line} | sed 's/:.*//')"
    list_item="$(echo ${list_line} | sed 's/.*://')"

    IFS='⸗' read item_type item_title item_location item_size item_duration <<< "${list_item}"

    if [[ "${chosen_list}" == 'share' ]]; then
      url=$(get_item_origin_url "${item_location}")
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
        echo "Feature still being considered"
      else
        echo "Something went wrong. Item type is invalid (${item_type})."
        exit 1
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

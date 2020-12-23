function download_app {
  local -r dest="${1}"
  local -r repo='vitorgalvao/sandwichtimer'
  local -r url="$(curl --silent "https://api.github.com/repos/${repo}/releases/latest" | grep 'browser_download_url' | head -1 | sed -E 's/.*browser_download_url": "(.*)"/\1/')"

  curl --silent --location --no-buffer "${url}" | ditto -xk - "${dest}"
}

function pomodoro {
  pkill -f "${sandwich_timer_app}/Contents/MacOS/SandwichTimer pomodoro" # Stop a previous running one
  "${sandwich_timer_app}/Contents/MacOS/SandwichTimer" 'pomodoro'
}

function quit {
  "${sandwich_timer_app}/Contents/MacOS/SandwichTimer" 'quit'
}

function timer {
  "${sandwich_timer_app}/Contents/MacOS/SandwichTimer" "${1}" "${2}"
}

if [[ ! -e "${sandwich_timer_app}" ]]; then
  echo 'SandwichTimer not found. Downloading…' >&2
  download_app '/Applications'
fi

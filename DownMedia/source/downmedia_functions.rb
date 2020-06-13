#!/usr/bin/env ruby

require 'cgi'
require 'json'
require 'open3'
require 'pathname'

# Helpers
def get_env(env_variable:, default:, make_pathname: false)
  if env_variable.nil? || env_variable.empty?
    return make_pathname ? Pathname.new(default).expand_path : default
  end

  make_pathname ? Pathname.new(env_variable).expand_path : env_variable
end

# Constants
ENV['PATH'] = Open3.capture2(Pathname.pwd.join('_sharedresources').to_path, 'ffmpeg', 'youtubedl').first

Add_to_watchlist = ENV['add_to_watchlist'] == 'true'

Audio_only_format = get_env(
  env_variable: ENV['audio_only_format'],
  default: 'best'
)

Download_dir = get_env(
  env_variable: ENV['download_dir'],
  default: Pathname(ENV['HOME']).join('Downloads').to_path,
  make_pathname: true
)

Pid_file = Pathname(ENV['alfred_workflow_cache']).join('pid.txt')
Progress_file = Pathname(ENV['alfred_workflow_cache']).join('progress.txt')
Query_file = Pathname(ENV['alfred_workflow_cache']).join('query.json')

def show_options(media_type)
  clipboard = Open3.capture2('pbpaste').first.strip
  tab_info = get_title_url

  script_filter_items = []

  common_options = {
    uid: "downmedia #{media_type}",
    subtitle: "Add to WatchList (⌥): #{Add_to_watchlist} 𐄁 Full Playlist (⌘): false",
    valid: true,
    variables: {
      media_type: media_type,
      add_to_watchlist: Add_to_watchlist,
      full_playlist: false
    },
    mods: {
      cmd: {
        subtitle: "Add to WatchList (⌥): #{Add_to_watchlist} 𐄁 Full Playlist (⌘): true",
        variables: {
          media_type: media_type,
          Add_to_watchlist: Add_to_watchlist,
          full_playlist: true # Modified variable
        }
      },
      alt: {
        subtitle: "Add to WatchList (⌥): #{!Add_to_watchlist} 𐄁 Full Playlist (⌘): false",
        variables: {
          media_type: media_type,
          add_to_watchlist: !Add_to_watchlist, # Modified variable
          full_playlist: false
        }
      },
      'cmd+alt': {
        subtitle: "Add to WatchList (⌥): #{!Add_to_watchlist} 𐄁 Full Playlist (⌘): true",
        variables: {
          media_type: media_type,
          add_to_watchlist: !Add_to_watchlist, # Modified variable
          full_playlist: true # Modified variable
        }
      }
    }
  }

  if tab_info
    tab_options = common_options.clone
    tab_options[:title] = tab_info[:title]
    tab_options[:arg] = tab_info[:url]

    script_filter_items.push(tab_options)
  end

  if clipboard.start_with?('http')
    clipboard_options = common_options.clone
    clipboard_options[:title] = clipboard
    clipboard_options[:arg] = clipboard

    script_filter_items.push(clipboard_options)
  end

  if script_filter_items.empty?
    script_filter_items.push(
      title: 'No URL found',
      subtitle: 'Did not find a URL in the clipboard or a supported browser as the frontmost app',
      valid: false
    )
  end

  puts({ items: script_filter_items }.to_json)
end

def show_progress
  ensure_data_paths

  script_filter_items = []

  if Progress_file.exist?
    progress_lines = Progress_file.readlines.select{ |line| line.start_with?('[download]') }.map { |line| line.sub(%r{^\[download\] }, '').strip }
    progress = progress_lines.last.strip rescue 'Getting progress info…'
    destination = Pathname(progress_lines.select { |line| line.start_with?('Destination:') }.last.sub('Destination: ', '')).basename rescue 'Getting destination name…'

    script_filter_items.push(
      uid: 'downmedia progress',
      title: progress,
      subtitle: destination,
      valid: false,
      mods: {
        cmd: {
          subtitle: 'Restart download at bottom of queue',
          valid: true,
          variables: { after_kill: 'restart' }
        },
        ctrl: {
          arg: 'abort',
          subtitle: 'Abort download',
          valid: true,
          variables: { after_kill: 'nothing' }
        }
      }
    )
  else
    script_filter_items.push(
      uid: 'downmedia progress',
      title: 'No Download in Progress',
      subtitle: 'Will auto-refresh if a download starts',
      valid: false
    )
  end

  puts({ rerun: 1, items: script_filter_items }.to_json)
end

def show_services
  services_dir = Pathname("#{ENV['HOME']}/Library/Services")
  audio_service = services_dir.join('DownMedia Audio.workflow')
  video_service = services_dir.join('DownMedia Video.workflow')

  script_filter_items = []

  if video_service.exist? && audio_service.exist?
    script_filter_items.push(
      title: 'Remove DownMedia Services',
      subtitle: 'Will be removed from ~/Library/Services',
      arg: 'uninstall'
    )
  else
    script_filter_items.push(
      title: 'Install DownMedia Services',
      subtitle: 'Will be installed to ~/Library/Services',
      arg: 'install'
    )
  end

  puts({ items: script_filter_items }.to_json)
end

def download_url(url, media_type, add_to_watchlist_string, full_playlist_string)
  # Setup
  add_to_watchlist = to_bool(add_to_watchlist_string)
  full_playlist = to_bool(full_playlist_string)
  encoded_url = CGI.escape_html(url)

  title_template = full_playlist ?
    '%(playlist)s/%(playlist_index)s-%(title)s.%(ext)s' :
    '%(title)s.%(ext)s'

  # Video format is forced for consistency between youtube-dl's --get-format and what it downloads
  flags = media_type == 'audio' ?
    ['--extract-audio', '--audio-quality', '0', '--audio-format', Audio_only_format] :
    ['--all-subs', '--embed-subs', '--format', 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best']

  full_playlist ?
    flags.push('--yes-playlist') :
    flags.push('--no-playlist')

  flags.push('--ignore-errors', '--output', Download_dir.join(title_template).to_path, url)

  # May fail in certain situations, due to bugs in getting the filename beforehand
  # https://github.com/ytdl-org/youtube-dl/issues/5710
  # https://github.com/ytdl-org/youtube-dl/issues/7137
  get_filename = Open3.capture2('youtube-dl', '--get-filename', *flags).first.strip

  save_path = full_playlist ?
    Pathname(get_filename.split("\n").first).dirname :
    Pathname(get_filename)

  title = save_path.basename(save_path.extname).to_path

  # Download
  error('Download failed', 'The URL is invalid') if get_filename.empty?
  notification("Downloading #{media_type.capitalize}", title)

  error('Download failed', 'You may be able to restart it with `dp`') unless system('youtube-dl', '--newline', *flags, out: Progress_file.to_path)
  notification('Download successful', title)

  # xattr returns before the action is complete, not giving enough time for the file to have the attribute before sending to WatchList, so only continue after the attribute is present
  system('/usr/bin/xattr', '-w', 'com.apple.metadata:kMDItemWhereFroms', "<!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'><plist version='1.0'><array><string>#{encoded_url}</string></array></plist>", save_path.to_path)
  sleep 1 while Open3.capture2('mdls', '-raw', '-name', 'kMDItemWhereFroms', save_path.to_path).first == '(null)'

  cleanup_tmp_files
  add_to_watchlist(save_path.to_path) if add_to_watchlist
end

def add_to_watchlist(path)
  warn 'You do not have WatchList installed. Download it at https://github.com/vitorgalvao/alfred-workflows/tree/master/WatchList' unless system('/usr/bin/osascript', '-e', %Q[tell application id "com.runningwithcrayons.Alfred" to run trigger "add_file_to_watchlist" in workflow "com.vitorgalvao.alfred.watchlist" with argument "#{path}"])
end

def save_query(url, media_type, add_to_watchlist, full_playlist)
  ensure_data_paths

  Query_file.write({
    alfredworkflow: {
      arg: url,
      variables: {
        media_type: media_type,
        add_to_watchlist: add_to_watchlist,
        full_playlist: false
      }
    }
  }.to_json)
end

def save_pid(pid)
  ensure_data_paths

  Pid_file.write(pid.to_s)
end

def kill_download
  # Kill parent to prevent notification showing success and child to stop download
  parent_process = Pid_file.read
  child_process = Open3.capture2('/usr/bin/pgrep', '-P', parent_process).first.strip

  system('kill', parent_process, child_process)
end

def get_title_url
  url_title = Open3.capture2(Pathname.pwd.join('get_title_and_url.js').to_path, '--').first.split("\n") # Second dummy argument is to not require shellescaping single argument

  return false if url_title.empty?

  { url: url_title.first, title: url_title.last }
end

def notification(title, message)
  system("#{Dir.pwd}/Notificator.app/Contents/Resources/Scripts/notificator", '--message', message, '--title', title)
end

def error(title, message)
  notification(title, message)
  abort
end

def ensure_data_paths
  Pathname(ENV['alfred_workflow_cache']).mkpath
end

def cleanup_tmp_files
  Pid_file.delete
  Progress_file.delete
  Query_file.delete
end

def to_bool(value)
  # Useful to assign booleans to Alfred's JSON variables, since those are converted to strings (true becomes "0" and false becomes "1")
  case value
  when true, 'true', 1, '1' then true
  when false, 'false', 0, '0', nil, '' then false
  else raise ArgumentError, "Invalid value: #{value.inspect}"
  end
end

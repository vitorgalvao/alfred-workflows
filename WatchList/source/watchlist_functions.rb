#!/usr/bin/env ruby

require 'json'
require 'open3'
require 'yaml'

ENV['PATH'] = Open3.capture2('./_sharedresources', 'mediainfo', 'youtubedl').first

Lists_dir = ENV['lists_dir'].nil? || ENV['lists_dir'].empty? ? ENV['alfred_workflow_data'] : File.expand_path(ENV['lists_dir'])
Towatch_list = "#{Lists_dir}/towatch.yaml".freeze
Watched_list = "#{Lists_dir}/watched.yaml".freeze
Quick_playlist = File.join(ENV['alfred_workflow_cache'], 'quick_playlist.txt')
Move_when_adding = !ENV['move_on_add'].nil? && !ENV['move_on_add'].empty?
Trash_on_watched = ENV['trash_on_watched'] != 'false'

def move_to_dir(path, target_dir)
  path_name = File.basename(path)
  target_path = File.join(target_dir, path_name)

  if File.dirname(path) == target_dir
    puts 'Path is already at target directory'
  elsif File.exist?(target_path)
    error('Can’t move because another target with the same name already exists')
  else
    File.rename(path, target_path)
  end

  target_path
end

def add_local_to_watchlist(path, id = random_hex, allow_move = true)
  ensure_data_paths
  require_audiovisual(path)

  target_path = Move_when_adding && allow_move ? move_to_dir(path, File.expand_path(ENV['move_on_add'])) : path

  if File.file?(target_path)
    add_file_to_watchlist(target_path, id)
  elsif File.directory?(target_path)
    add_dir_to_watchlist(target_path, id)
  else
    error('Not a valid path')
  end
end

def add_file_to_watchlist(file_path, id = random_hex)
  name = File.basename(file_path, File.extname(file_path))

  duration_machine = duration_in_seconds(file_path)
  duration_human = seconds_to_hms(duration_machine)

  size_machine = Open3.capture2('du', file_path).first.to_i
  size_human = Open3.capture2('du', '-h', file_path).first.slice(/[^\t]*/).strip

  size_duration_ratio = size_machine / duration_machine

  url = Open3.capture2('mdls', '-raw', '-name', 'kMDItemWhereFroms', file_path).first.split("\n")[1].strip.delete('"') rescue nil

  hash = {
    id => {
      'type' => 'file',
      'name' => name,
      'path' => file_path,
      'count' => nil,
      'url' => url,
      'duration' => {
        'machine' => duration_machine,
        'human' => duration_human
      },
      'size' => {
        'machine' => size_machine,
        'human' => size_human
      },
      'ratio' => size_duration_ratio
    }
  }

  add_to_list(hash, Towatch_list)
end

def add_dir_to_watchlist(dir_path, id = random_hex)
  name = File.basename(dir_path)

  hash = {
    id => {
      'type' => 'series',
      'name' => name,
      'path' => dir_path,
      'count' => 'counting files…',
      'url' => nil,
      'duration' => {
        'machine' => nil,
        'human' => 'getting duration…'
      },
      'size' => {
        'machine' => nil,
        'human' => 'calculating size…'
      },
      'ratio' => nil
    }
  }

  add_to_list(hash, Towatch_list)
  update_series(id)
end

def update_series(id)
  list_hash = YAML.load_file(Towatch_list)

  dir_path = list_hash[id]['path']
  audiovisual_files = list_audiovisual_files(dir_path)
  first_file = audiovisual_files.first
  count = audiovisual_files.count

  duration_machine = duration_in_seconds(first_file)
  duration_human = seconds_to_hms(duration_machine)

  size_machine = Open3.capture2('du', first_file).first.to_i
  size_human = Open3.capture2('du', '-h', first_file).first.slice(/[^\t]*/).strip

  size_duration_ratio = size_machine / duration_machine

  list_hash[id]['count'] = count
  list_hash[id]['duration']['machine'] = duration_machine
  list_hash[id]['duration']['human'] = duration_human
  list_hash[id]['size']['machine'] = size_machine
  list_hash[id]['size']['human'] = size_human
  list_hash[id]['ratio'] = size_duration_ratio

  File.write(Towatch_list, list_hash.to_yaml)
end

def add_url_to_watchlist(url, playlist = false, id = random_hex)
  playlist_flag = playlist ? '--yes-playlist' : '--no-playlist'

  all_names = Open3.capture2('youtube-dl', '--get-title', playlist_flag, url).first.split("\n")
  error "Could not add url as stream: #{url}" if all_names.empty?
  # If playlist, get the playlist name instead of the the name of the first item
  name = all_names.count > 1 ? Open3.capture2('youtube-dl', '--yes-playlist', '--get-filename', '--output', '%(playlist)s', url).first.split("\n").first : all_names[0]

  durations = Open3.capture2('youtube-dl', '--get-duration', playlist_flag, url).first.split("\n")
  count = durations.count > 1 ? durations.count : nil

  duration_machine = durations.map { |d| colons_to_seconds(d) }.inject(0, :+)
  duration_human = seconds_to_hms(duration_machine)

  hash = {
    id => {
      'type' => 'stream',
      'name' => name,
      'path' => nil,
      'count' => count,
      'url' => url,
      'duration' => {
        'machine' => duration_machine,
        'human' => duration_human
      },
      'size' => {
        'machine' => nil,
        'human' => nil
      },
      'ratio' => nil
    }
  }

  add_to_list(hash, Towatch_list)
  notification("Added as stream: “#{name}”")
end

def display_towatch(sort = nil)
  ensure_data_paths

  list_hash = YAML.load_file(Towatch_list)

  if list_hash == false || list_hash.nil?
    puts({ items: [{ title: 'Play (wlp)', subtitle: 'Nothing to watch', valid: false }] }.to_json)
    exit 0
  end

  script_filter_items = []

  hash_to_output =
    case sort
    when 'duration_ascending'
      list_hash.sort_by { |_id, content| content['duration']['machine'] }
    when 'duration_descending'
      list_hash.sort_by { |_id, content| content['duration']['machine'] }.reverse
    when 'size_ascending'
      list_hash.sort_by { |_id, content| content['size']['machine'] || Float::INFINITY }
    when 'size_descending'
      list_hash.sort_by { |_id, content| content['size']['machine'] || -Float::INFINITY }.reverse
    when 'best_ratio'
      list_hash.sort_by { |_id, content| content['ratio'] || -Float::INFINITY }.reverse
    else
      list_hash
    end

  hash_to_output.each do |id, details|
    item_count = details['count'].nil? ? '' : "(#{details['count']}) 𐄁 "

    # Common values
    item = {
      title: details['name'],
      arg: id,
      mods: {}
    }

    # Common modifications
    case details['type']
    when 'file', 'series' # Not a stream
      item[:subtitle] = "#{item_count}#{details['duration']['human']} 𐄁 #{details['size']['human']} 𐄁 #{details['path']}"
    end

    item[:mods][:control] = details['url'].nil? ? { subtitle: 'This item has no origin url', valid: false } : { subtitle: details['url'], arg: details['url'] }

    # Specific modifications
    case details['type']
    when 'file'
      item[:quicklookurl] = details['path']
      item[:mods][:alt] = { subtitle: 'This modifier is only available on series and streams', valid: false }
    when 'stream'
      item[:subtitle] = "≈ #{item_count}#{details['duration']['human']} 𐄁 #{details['url']}"
      item[:quicklookurl] = details['url']
      item[:mods][:alt] = { subtitle: 'Download stream' }
    when 'series'
      item[:mods][:alt] = { subtitle: 'Rescan series' }
    end

    script_filter_items.push(item)
  end

  puts({ items: script_filter_items }.to_json)
end

def display_watched
  ensure_data_paths

  list_hash = YAML.load_file(Watched_list)

  if list_hash == false || list_hash.nil?
    puts({ items: [{ title: 'Mark unwatched (wlu)', subtitle: 'You have no unwatched files', valid: false }] }.to_json)
    exit 0
  end

  script_filter_items = []

  list_hash.each do |id, details|
    # Common values
    item = {
      title: details['name'],
      arg: id,
      mods: {}
    }

    # Modifications
    if details['url'].nil?
      item[:subtitle] = details['path']
      item[:mods][:cmd] = { subtitle: 'This item has no origin url', valid: false }
      item[:mods][:alt] = { subtitle: 'This item has no origin url', valid: false }
    else
      item[:subtitle] = details['type'] == 'stream' ? details['url'] : "#{details['url']} 𐄁 #{details['path']}"
      item[:quicklookurl] = details['url']
      item[:mods][:cmd] = { subtitle: 'Open link in default browser', arg: details['url'] }
      item[:mods][:alt] = { subtitle: 'Copy link to clipboard', arg: details['url'] }
    end

    script_filter_items.push(item)
  end

  puts({ items: script_filter_items }.to_json)
end

def play(id, send_to_watched = true)
  send_to_top(id) if ENV['top_on_play'] == 'true'
  item = YAML.load_file(Towatch_list)[id]

  case item['type']
  when 'file'
    return unless play_item('file', item['path'])

    mark_watched(id) if send_to_watched == true
  when 'stream'
    return unless play_item('stream', item['url'])

    mark_watched(id) if send_to_watched == true
  when 'series'
    if !File.exist?(item['path']) && send_to_watched == true
      mark_watched(id)
      abort 'Marking as watched since the directory no longer exists'
    end

    first_file = list_audiovisual_files(item['path']).first

    return unless play_item('file', first_file)
    return if send_to_watched == false

    # If there are no more audiovisual files in the directory in addition to the one we just watched, trash the whole directory, else trash just the watched file
    if list_audiovisual_files(item['path']).reject { |e| e == first_file }.empty?
      mark_watched(id) if send_to_watched == true
    else
      trash(first_file) if Trash_on_watched
      update_series(id)
    end
  end
end

# By checking for and running the CLI of certain players instead of the app bundle, we get access to the exit status. That way, in the 'play' method, even if the file were to be marked as watched we do not do it unless it was a success.
# This means we can configure our video player to not exit successfully on certain conditions and have greater granularity with WatchList.
def play_item(type, path)
  return true if path.nil? || type != 'stream' && !File.exist?(path) # If non-stream item does not exist, exit successfully so it can still be marked as watched

  # The 'split' together with 'last' serves to try to pick the last installed version, in case more than one is found (multiple versions in Homebrew Cellar, for example)
  video_player = lambda {
    mpv_homebrew_apple_silicon = '/opt/homebrew/bin/mpv'
    return [mpv_homebrew_apple_silicon, '--no-terminal'] if File.executable?(mpv_homebrew_apple_silicon)

    mpv_homebrew_intel = '/usr/local/bin/mpv'
    return [mpv_homebrew_intel, '--no-terminal'] if File.executable?(mpv_homebrew_intel)

    mpv_app = Open3.capture2('mdfind', 'kMDItemCFBundleIdentifier', '=', 'io.mpv').first.strip.split("\n").last
    return [mpv_app + '/Contents/MacOS/mpv', '--no-terminal'] if mpv_app

    iina = Open3.capture2('mdfind', 'kMDItemCFBundleIdentifier', '=', 'com.colliderli.iina').first.strip.split("\n").last
    return iina + '/Contents/MacOS/IINA' if iina

    vlc = Open3.capture2('mdfind', 'kMDItemCFBundleIdentifier', '=', 'org.videolan.vlc').first.strip.split("\n").last
    return vlc + '/Contents/MacOS/VLC' if vlc

    'other'
  }.call

  error('To play a stream you need mpv, iina, or vlc') if video_player == 'other' && type == 'stream'

  video_player == 'other' ? system('open', '-W', path) : Open3.capture2(*video_player, path)[1].success?
end

def mark_watched(id)
  item = YAML.load_file(Towatch_list)[id]
  maximum_watched =
    begin
      Integer(ENV['maximum_watched'], 10)
    rescue ArgumentError
      20
    end

  switch_list(id, Towatch_list, Watched_list)
  list_hash = YAML.load_file(Watched_list)
  File.write(Watched_list, list_hash.first(maximum_watched).to_h.to_yaml)

  if item['type'] == 'stream'
    system('/usr/bin/afplay', '/System/Library/Sounds/Purr.aiff')
    return
  end

  # Trash
  return unless Trash_on_watched

  trashed_name = trash(item['path'])
  return if File.basename(item['path']) == trashed_name

  # If name had to change to send to Trash, update list with new name
  item['trashed_name'] = trashed_name
  list_hash[id] = item
  File.write(Watched_list, list_hash.first(maximum_watched).to_h.to_yaml)
end

def mark_unwatched(id)
  # Get item info early, before switching lists
  item = YAML.load_file(Watched_list)[id]

  switch_list(id, Watched_list, Towatch_list)

  # Try to recover trashed file
  return unless Trash_on_watched

  return if item['type'] == 'stream'

  if item['trashed_name']
    trashed_path = File.join(ENV['HOME'], '.Trash', item['trashed_name'])

    list_hash = YAML.load_file(Towatch_list)
    item.delete('trashed_name')
    list_hash[id] = item
    File.write(Towatch_list, list_hash.to_yaml)
  else
    trashed_path = File.join(ENV['HOME'], '.Trash', File.basename(item['path']))
  end

  error('Could not find item in Trash') unless File.exist?(trashed_path)
  error('Could not recover from Trash because another item exists at original location') if File.exist?(item['path'])

  File.rename(trashed_path, item['path'])
  system('/usr/bin/afplay', '/System/Library/Sounds/Submarine.aiff')
end

def download_stream(id)
  item = YAML.load_file(Towatch_list)[id]
  url = item['url']

  system("#{Dir.pwd}/downmedia-download", 'video', url)
  mark_watched(id)
end

def edit_towatch
  require 'tempfile'

  tmp_file = Tempfile.new('watchlist_edit')
  origin_order = ''

  origin_hash = YAML.load_file(Towatch_list)
  target_hash = {}

  origin_hash.keys.each { |id| origin_order += "#{id}: #{origin_hash[id]['name']}\n" }
  File.write(tmp_file, origin_order)
  system('open', '-ntW', tmp_file.to_path)

  target_order = File.read(tmp_file)
  target_order.split("\n").each do |item|
    id_name = item.split(':')
    id = id_name[0].strip
    name = id_name[1..-1].join(':').strip

    item_content_hash = origin_hash[id]
    abort "Unrecognised id: #{id}" if item_content_hash.nil?
    item_content_hash['name'] = name

    target_hash.store(id, item_content_hash)
  end

  File.write(Towatch_list, target_hash.to_yaml)
end

def verify_quick_playlist(minutes_threshold = 3)
  ensure_data_paths

  return false unless File.exist?(Quick_playlist)

  if (Time.now - File.mtime(Quick_playlist)) / 60 > minutes_threshold
    File.delete(Quick_playlist)
    return false
  end

  true
end

def add_to_quick_playlist(id)
  verify_quick_playlist
  File.write(Quick_playlist, "#{id}\n", mode: 'a')
end

def play_quick_playlist
  return false unless verify_quick_playlist

  ids = File.readlines(Quick_playlist, chomp: true)
  File.delete(Quick_playlist)

  ids.each do |id|
    system('osascript', '-l', 'JavaScript', '-e', "Application('com.runningwithcrayons.Alfred').runTrigger('play_id', { inWorkflow: 'com.vitorgalvao.alfred.watchlist', withArgument: '#{id}' })")
  end
end

def random_hex
  '%06x' % (rand * 0xffffff)
end

def colons_to_seconds(duration_colons)
  duration_colons.split(':').map(&:to_i).inject(0) { |a, b| a * 60 + b }
end

def duration_in_seconds(file_path)
  Open3.capture2('mediainfo', '--Output=General;%Duration%', file_path).first.to_i / 1000
end

def seconds_to_hms(total_seconds)
  return '[Unable to Get Duration]' if total_seconds.zero? # Can happen with youtube-dl's generic extractor (e.g. when adding direct link to an MP4)

  seconds = total_seconds % 60
  minutes = (total_seconds / 60) % 60
  hours = total_seconds / (60 * 60)

  duration_array = [hours, minutes, seconds]
  duration_array.shift while duration_array[0].zero? # Remove leading '0' time segments
  duration_array.join(':').sub(/$/, 's').sub(/(.*):/, '\1m ').sub(/(.*):/, '\1h ')
end

def audiovisual_file?(path)
  Open3.capture2('mdls', '-name', 'kMDItemContentTypeTree', path).first.include?('public.audiovisual-content')
end

def list_audiovisual_files(dir_path)
  escaped_path = dir_path.gsub(/([\*\?\[\]{}\\])/, '\\\\\1')
  Dir.glob("#{escaped_path}/**/*").map(&:downcase).sort.select { |e| audiovisual_file?(e) }
end

def require_audiovisual(path)
  if File.file?(path)
    return if audiovisual_file?(path)

    error('Is not an audiovisual file')
  elsif File.directory?(path)
    return unless list_audiovisual_files(path).first.nil?

    error('Directory has no audiovisual content')
  else
    error('Not a valid path')
  end
end

def add_to_list(hash, list)
  ENV['added_item_order'] == 'append' ? append_to_list(hash, list) : prepend_to_list(hash, list)
end

def prepend_to_list(input_hash, list)
  list_hash = YAML.load_file(list) || {}
  target_yaml = input_hash.merge(list_hash).to_yaml
  File.write(list, target_yaml)
end

def append_to_list(input_hash, list)
  list_hash = YAML.load_file(list) || {}
  target_yaml = list_hash.merge(input_hash).to_yaml
  File.write(list, target_yaml)
end

def delete_from_list(id, list)
  list_hash = YAML.load_file(list)
  list_hash.delete(id)
  target_yaml = list_hash.empty? ? '---' : list_hash.to_yaml
  File.write(list, target_yaml)
end

def switch_list(id, origin_list, target_list)
  ensure_data_paths

  id_hash = { id => YAML.load_file(origin_list)[id] }

  abort 'Item no longer exists' if id_hash.values.first.nil? # Detect if an item no longer exists before trying to move. Fix for cases where the same item is chosen a second time before having finished playing.

  delete_from_list(id, origin_list)
  prepend_to_list(id_hash, target_list)
end

def send_to_top(id)
  switch_list(id, Towatch_list, Towatch_list)
end

def ensure_data_paths
  require 'fileutils'

  Dir.mkdir(Lists_dir) unless Dir.exist?(File.expand_path(Lists_dir))
  FileUtils.touch(Towatch_list) unless File.exist?(Towatch_list)
  FileUtils.touch(Watched_list) unless File.exist?(Watched_list)

  Dir.mkdir(ENV['alfred_workflow_cache']) unless Dir.exist?(ENV['alfred_workflow_cache'])
end

def trash(path)
  Open3.capture2('osascript', '-l', 'JavaScript', '-e', 'function run(argv) { return Application("Finder").delete(Path(argv[0])).name() }', path).first.strip if File.exist?(path)
end

def notification(message, sound = '')
  system("#{Dir.pwd}/notificator", '--message', message, '--title', ENV['alfred_workflow_name'], '--sound', sound)
end

def error(message)
  notification(message, 'Sosumi')
  abort(message)
end

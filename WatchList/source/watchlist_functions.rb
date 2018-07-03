#!/usr/bin/env ruby

require 'json'
require 'open3'
require 'yaml'

ENV['PATH'] = Open3.capture2('./_sharedresources', 'mediainfo', 'trash', 'youtubedl').first
Towatch_list = "#{ENV['alfred_workflow_data']}/towatch.yaml".freeze
Watched_list = "#{ENV['alfred_workflow_data']}/watched.yaml".freeze

def move_to_dir(path, target_dir)
  path_name = File.basename(path)
  target_path = File.join(target_dir, path_name)

  error('Can’t move because a target with the same name already exists') if File.exist?(target_path)

  File.rename(path, target_path)
  target_path # Return value to it can be passed to add function
end

def add_local_to_watchlist(path)
  ensure_data_files

  if File.file?(path)
    add_file_to_watchlist(path)
  elsif File.directory?(path)
    add_dir_to_watchlist(path)
  else
    error('Not a valid path.')
  end
end

def add_file_to_watchlist(file_path)
  name = File.basename(file_path, File.extname(file_path))

  duration_machine = duration_in_seconds(file_path)
  duration_human = seconds_to_hms(duration_machine)

  size_machine = Open3.capture2('du', file_path).first.to_i
  size_human = Open3.capture2('du', '-h', file_path).first.slice(/[^\t]*/).strip

  size_duration_ratio = size_machine / duration_machine

  url = Open3.capture2('mdls', '-raw', '-name', 'kMDItemWhereFroms', file_path).first.split("\n")[1].strip.delete('"') rescue nil

  hash = {
    random_hex => {
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

def add_dir_to_watchlist(dir_path)
  error('Directory has no audiovisual content.') if find_audiovisual_files(dir_path).first.nil?

  id = random_hex
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
  audiovisual_files = find_audiovisual_files(dir_path)
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

def add_url_to_watchlist(url, playlist = false)
  playlist_flag = playlist ? '--yes-playlist' : '--no-playlist'

  all_names = Open3.capture2('youtube-dl', '--get-title', playlist_flag, url).first.split("\n")
  error "Could not add url as stream: #{url}." if all_names.empty?
  # If playlist, get the playlist name instead of the the name of the first item
  name = all_names.count > 1 ? Open3.capture2('youtube-dl', '--yes-playlist', '--get-filename', '--output', '%(playlist)s', url).first.split("\n").first : all_names[0]

  durations = Open3.capture2('youtube-dl', '--get-duration', playlist_flag, url).first.split("\n")
  count = durations.count > 1 ? durations.count : nil

  duration_machine = durations.map { |d| colons_to_seconds(d) }.inject(0, :+)
  duration_human = seconds_to_hms(duration_machine)

  hash = {
    random_hex => {
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
  ensure_data_files

  script_filter_items = []
  list_hash = YAML.load_file(Towatch_list)

  if list_hash == false || list_hash.nil?
    script_filter_items.push(title: 'Play (wlp)', subtitle: 'Nothing to watch. Go add something.', valid: false)
  else
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

      subtitle_info =
        if details['type'] == 'stream'
          "≈ #{item_count}#{details['duration']['human']} 𐄁 #{details['url']}"
        else
          "#{item_count}#{details['duration']['human']} 𐄁 #{details['size']['human']} 𐄁 #{details['path']}"
        end

      if details['type'] == 'series'
        script_filter_items.push(
          title: details['name'],
          subtitle: subtitle_info,
          arg: id,
          mods: { alt: { subtitle: 'Rescan series' } }
        )
      else
        script_filter_items.push(
          title: details['name'],
          subtitle: subtitle_info,
          arg: id,
          mods: { alt: { subtitle: 'Rescan is only available for series', valid: false } }
        )
      end
    end
  end

  puts({ items: script_filter_items }.to_json)
end

def display_watched
  ensure_data_files

  script_filter_items = []
  list_hash = YAML.load_file(Watched_list)

  if list_hash == false || list_hash.nil?
    script_filter_items.push(title: 'Mark unwatched (wlu)', subtitle: 'You have no unwatched files.', valid: false)
  else
    list_hash.each do |id, details|
      if details['type'] == 'stream'
        script_filter_items.push(
          title: details['name'],
          subtitle: details['url'],
          arg: id,
          mods: {
            cmd: {
              subtitle: 'Open link in default browser',
              arg: details['url']
            },
            alt: {
              subtitle: 'Copy link to clipboard',
              arg: details['url']
            }
          }
        )
      elsif details['url'].nil?
        script_filter_items.push(
          title: details['name'],
          subtitle: details['path'],
          arg: id,
          mods: {
            cmd: {
              subtitle: 'This item has no origin url.',
              valid: false
            },
            alt: {
              subtitle: 'This item has no origin url.',
              valid: false
            }
          }
        )
      else
        script_filter_items.push(
          title: details['name'],
          subtitle: "#{details['url']} 𐄁 #{details['path']}",
          arg: id,
          mods: {
            cmd: {
              subtitle: 'Open link in default browser',
              arg: details['url']
            },
            alt: {
              subtitle: 'Copy link to clipboard',
              arg: details['url']
            }
          }
        )
      end
    end
  end
  puts({ items: script_filter_items }.to_json)
end

def play(id, send_to_watched = true)
  send_to_top(id) if ENV['top_on_play'] == 'true'
  item = YAML.load_file(Towatch_list)[id]

  case item['type']
  when 'file'
    return unless play_item('file', item['path'])
    return if send_to_watched == false
    trash(item['path'])
    mark_watched(id)
  when 'stream'
    return unless play_item('stream', item['url'])
    mark_watched(id) if send_to_watched == true
  when 'series'
    if !File.exist?(item['path']) && send_to_watched == true
      mark_watched(id)
      abort 'Marking as watched since the directory no longer exists.'
    end

    audiovisual_files = find_audiovisual_files(item['path'])
    first_file = audiovisual_files.first

    return unless play_item('file', first_file)
    return if send_to_watched == false

    # If there are no more audiovisual files in the directory in addition to the one we just watched, trash the whole directory, else trash just the watched file
    if audiovisual_files.reject { |e| e == first_file }.empty?
      trash(item['path'])
      mark_watched(id) if send_to_watched == true
    else
      trash(first_file)
      update_series(id)
    end
  end
end

def mark_watched(id)
  maximum_watched = ENV['maximum_watched'].is_a?(Integer) ? ENV['maximum_watched'] : 9

  switch_list(id, Towatch_list, Watched_list)

  list_hash = YAML.load_file(Watched_list)
  return unless list_hash.count > maximum_watched

  # UNCOMMENT AFTER HIGH SIERRA AND DELETE THE UNCOMMENTED LINE
  # File.write(Watched_list, list_hash.first(maximum_watched).to_h.to_yaml)
  File.write(Watched_list, Hash[list_hash.first(maximum_watched)].to_yaml)
end

def mark_unwatched(id)
  switch_list(id, Watched_list, Towatch_list)
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

# By checking for and running the CLI of certain players instead of the app bundle, we get access to the exit status. That way, in the 'play' method, even if the file were to be marked as watched we do not do it unless it was a success.
# This means we can configure our video player to not exit successfully on certain conditions and have greater granularity with WatchList.
def play_item(type, path)
  return true if type != 'stream' && !File.exist?(path) # If non-stream item does not exist, exit successfully so it can still be marked as watched

  # The 'split' together with 'last' serves to try to pick the last installed version, in case more than one is found (multiple versions in Homebrew Cellar, for example)
  video_player = lambda {
    mpv_cli = Open3.capture2('mdfind', 'kMDItemCFBundleIdentifier', '=', 'io.mpv').first.strip.split("\n").last + '/Contents/MacOS/mpv'
    return mpv_cli if File.executable?(mpv_cli)

    iina_cli = Open3.capture2('mdfind', 'kMDItemCFBundleIdentifier', '=', 'com.colliderli.iina').first.strip.split("\n").last + '/Contents/MacOS/IINA'
    return iina_cli if File.executable?(iina_cli)

    vlc_cli = Open3.capture2('mdfind', 'kMDItemCFBundleIdentifier', '=', 'org.videolan.vlc').first.strip.split("\n").last + '/Contents/MacOS/VLC'
    return vlc_cli if File.executable?(vlc_cli)

    return 'other'
  }.call

  error('To play a stream you need mpv, iina, or vlc.') if video_player == 'other' && type == 'stream'

  video_player == 'other' ? system('open', '-W', path) : Open3.capture2(video_player, path)[1].success?
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

def find_audiovisual_files(dir_path)
  escaped_path = dir_path.gsub(/([\*\?\[\]{}\\])/, '\\\\\1')
  Dir.glob("#{escaped_path}/**/*").select { |e| audiovisual_file?(e) }
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
  ensure_data_files

  id_hash = { id => YAML.load_file(origin_list)[id] }
  delete_from_list(id, origin_list)
  prepend_to_list(id_hash, target_list)
end

def send_to_top(id)
  switch_list(id, Towatch_list, Towatch_list)
end

def ensure_data_files
  require 'fileutils'

  Dir.mkdir(ENV['alfred_workflow_data']) unless Dir.exist?(ENV['alfred_workflow_data'])
  Dir.mkdir(ENV['alfred_workflow_cache']) unless Dir.exist?(ENV['alfred_workflow_cache'])

  FileUtils.touch(Towatch_list) unless File.exist?(Towatch_list)
  FileUtils.touch(Watched_list) unless File.exist?(Watched_list)
end

def trash(path)
  system('trash', path)
end

def notification(message, sound = '')
  system("#{__dir__}/Notificator.app/Contents/Resources/Scripts/notificator", '--message', message, '--title', ENV['alfred_workflow_name'], '--sound', sound)
end

def error(message)
  notification(message, 'Funk')
  abort(message)
end

require 'cgi'
require 'fileutils'
require 'json'
require 'open-uri'
require 'open3'

Last_access_file = "#{ENV['alfred_workflow_cache']}/last_access_file.txt".freeze
All_bookmarks_json = "#{ENV['alfred_workflow_cache']}/all_bookmarks.json".freeze
Unread_bookmarks_json = "#{ENV['alfred_workflow_cache']}/unread_bookmarks.json".freeze

def notification(message, title = ENV['alfred_workflow_name'])
  system("#{Dir.pwd}/Notificator.app/Contents/Resources/Scripts/notificator", '--message', message, '--title', title)
end

def success_sound
  system('afplay', '/System/Library/Sounds/Tink.aiff')
end

def error_sound
  system('afplay', '/System/Library/Sounds/Sosumi.aiff')
end

def error(message)
  error_sound
  notification(message)
  abort(message)
end

def save_pinboard_token
  pinboard_token = Open3.capture2('osascript', '-l', 'JavaScript', '-e', "
    const app = Application.currentApplication()
    app.includeStandardAdditions = true

    const response = app.displayDialog('Your Pinboard API Token:', {
      defaultAnswer: 'Get it on https://pinboard.in/settings/password',
      withTitle: 'Pinboard API Token Missing',
      withIcon: Path('#{Dir.pwd}/icon.png'),
      buttons: ['Cancel', 'OK'],
      defaultButton: 'OK'
    })

    response.textReturned
  ").first.strip

  error('Cannot continue without a Pinboard token.') if pinboard_token.empty?

  system('security', 'add-generic-password', '-a', pinboard_token.split(':').first, '-s', 'Pinboard API Token', '-w', pinboard_token)
  error 'Seem either the API token is incorrect or Pinboard’s servers are down.' if URI("https://api.pinboard.in/v1/user/api_token/?auth_token=#{pinboard_token}").nil?

  grab_pinboard_token
end

def grab_pinboard_token
  pinboard_token = Open3.capture2('security', 'find-generic-password', '-s', 'Pinboard API Token', '-w').first.strip
  pinboard_token.empty? ? save_pinboard_token : pinboard_token
end

def reset_pinboard_token
  system('security', 'delete-generic-password', '-s', 'Pinboard API Token')
  save_pinboard_token
end

def grab_url_title
  url, title = Open3.capture2("#{Dir.pwd}/get_url_and_title.js", '--').first.strip.split('|') # Second dummy argument is to not require shellescaping single argument

  error('You need a supported web browser as your frontmost app.') if url.nil?
  title ||= url # For pages without a title tag

  [url, title]
end

def open_gui
  pinplus_app_path = Open3.capture2('mdfind', 'kMDItemCFBundleIdentifier = com.vitorgalvao.pinplus').first.strip
  pinplus_app_path.empty? ? system("#{Dir.pwd}/run_bookmarklet.js", '--') : system("#{pinplus_app_path}/Contents/MacOS/PinPlus") # Second dummy argument is to not require shellescaping single argument
end

def add_unread
  url, title = grab_url_title
  success_sound
  notification(url, title)

  url_encoded = CGI.escape(url)
  title_encoded = CGI.escape(title)

  result = JSON.parse(URI("https://api.pinboard.in/v1/posts/add?url=#{url_encoded}&description=#{title_encoded}&toread=yes&auth_token=#{grab_pinboard_token}&format=json").read)['result_code']

  return if result == 'done'

  error_log = "#{ENV['HOME']}/Desktop/pinplus_errors.log"

  reason = status.nil? ? 'Got no reply from server.' : result
  File.write(error_log, "---\n", mode: 'a') if File.exist?(error_log)

  File.write(error_log, "error: #{reason}\ntitle: #{title}\nurl: #{url}\nencoded title: #{title_encoded}\nencoded url: #{url_encoded}\n", mode: 'a')

  error('Error adding bookmark. See error log in Desktop.')
end

def synced_with_website?
  FileUtils.mkdir_p(ENV['alfred_workflow_cache']) unless Dir.exist?(ENV['alfred_workflow_cache'])

  last_access_local = File.exist?(Last_access_file) ? File.read(Last_access_file) : 'File does not yet exist'
  last_access_remote = JSON.parse(URI("https://api.pinboard.in/v1/posts/update?auth_token=#{grab_pinboard_token}&format=json").read)['update_time']

  if last_access_local == last_access_remote
    FileUtils.touch(Last_access_file)
    return true
  end

  File.write(Last_access_file, last_access_remote)
  false
end

def action_unread(action, url)
  url_encoded = CGI.escape(url)

  if action == 'delete'
    URI("https://api.pinboard.in/v1/posts/delete?url=#{url_encoded}&auth_token=#{grab_pinboard_token}").open
    return
  end

  return unless action == 'archive'

  toread = 'no'

  bookmark = JSON.parse(URI("https://api.pinboard.in/v1/posts/get?url=#{url_encoded}&auth_token=#{grab_pinboard_token}&format=json").read)['posts'][0]

  title_encoded = CGI.escape(bookmark['description'])
  description_encoded = CGI.escape(bookmark['extended'])
  shared = bookmark['shared']
  tags_encoded = CGI.escape(bookmark['tags'])

  URI("https://api.pinboard.in/v1/posts/add?url=#{url_encoded}&description=#{title_encoded}&extended=#{description_encoded}&shared=#{shared}&toread=#{toread}&tags=#{tags_encoded}&auth_token=#{grab_pinboard_token}")
end

def old_local_copy?
  return true unless File.exist?(Last_access_file)

  cache_minutes = ENV['minutes_between_checks'].to_i > 10 ? ENV['minutes_between_checks'].to_i : 10 # Default to keeping the cache for 10 minutes
  return false if ((Time.now - File.mtime(Last_access_file)) / 60).to_i < cache_minutes

  true
end

def show_bookmarks(bookmarks_file)
  fetch_bookmarks
  puts File.read(bookmarks_file)
end

def fetch_bookmarks(force = false)
  unless force
    return unless old_local_copy?
    return if synced_with_website?
  end

  all_bookmarks = JSON.parse(URI("https://api.pinboard.in/v1/posts/all?auth_token=#{grab_pinboard_token}&format=json").read)

  unread_bookmarks = []
  all_bookmarks.each do |bookmark|
    next unless bookmark['toread'] == 'yes'

    ENV['unread_order'] == 'oldest_first' ? unread_bookmarks.unshift(bookmark) : unread_bookmarks.push(bookmark)
  end

  write_bookmarks(all_bookmarks, All_bookmarks_json)
  write_bookmarks(unread_bookmarks, Unread_bookmarks_json)
end

def write_bookmarks(bookmarks, bookmarks_file)
  json = []

  bookmarks.each do |bookmark|
    split_href = bookmark['href'].split('/').reject { |a| a.start_with?('http') || a.empty? }.join(' ').sub('www.', '')

    json.push(
      title: bookmark['description'],
      subtitle: bookmark['href'],
      match: "#{bookmark['description']} #{split_href} #{bookmark['extended']} #{bookmark['tags']}",
      mods: {
        fn: { subtitle: bookmark['extended'] },
        ctrl: { subtitle: bookmark['tags'] }
      },
      arg: bookmark['href']
    )
  end

  File.write(bookmarks_file, { items: json }.to_json)
end

def search_in_website(url)
  username = grab_pinboard_token.sub(/:.*/, '')
  print "https://pinboard.in/search/u:#{username}?query=#{url.sub(%r{^(http[s]|ftp)://}, '')}".strip
end

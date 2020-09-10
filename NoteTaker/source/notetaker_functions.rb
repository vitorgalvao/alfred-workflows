require 'json'
require 'open3'
require 'pathname'

# Helpers
def get_env(env_variable:, default:, as_bool: false, as_pathname: false, match_list: [])
  # If boolean, return early
  if as_bool
    case env_variable
    when true, 'true', 'yes', 1, '1' then return true
    when false, 'false', 'no', 0, '0', nil, '' then return false
    else raise ArgumentError, "Invalid value: #{env_variable.inspect}"
    end
  end

  # Extract string
  var_as_string = lambda {
    return default if env_variable.nil? || env_variable.empty?
    return env_variable if match_list.empty? || match_list.include?(env_variable)

    default
  }.call

  # If pathname, make it now
  return Pathname.new(var_as_string).expand_path if as_pathname

  var_as_string
end

def display_notes(dir: Notes_dir)
  notes = dir.children.reject { |p| p.basename.to_path == '.DS_Store' }
  script_filter_items = []

  if notes.empty?
    script_filter_items.push(title: 'Make a new note')

    puts({
      variables: { add_note_external: true.to_s },
      items: script_filter_items
    }.to_json)

    return
  end

  notes.each do |note|
    note_name = note.basename(note.extname).to_path

    script_filter_items.push(
      uid: note_name,
      title: note_name,
      subtitle: 'Copy (↵), Copy and delete (⌘↵), Edit (⌥↵)',
      arg: note.to_path,
      quicklookurl: note.to_path
    )
  end

  warn script_filter_items.join("\n")

  puts({ items: script_filter_items }.to_json)
end

def add_note(title:, content: Open3.capture2('pbpaste').first, dir: Notes_dir)
  file = dir.join("#{title}.txt")

  while file.exist?
    # Use the same directory
    # Append file name without extension
    # Append current time
    # Append extension
    file = file.dirname.join(
      "#{file.basename(file.extname)} " \
      "#{Time.now.strftime('%y%m%d-%H%M%S')}" \
      "#{file.extname}"
    )
  end

  file.write(content)
end

def copy_note(path:)
  Open3.capture2('pbcopy', stdin_data: Pathname.new(path).read)
end

def edit_note(path:)
  system('open', '-t', path)
end

def trash(path:)
  escaped_path = path.gsub("'") { "\\'" } # Escape single quotes, since they are the delimiters for the path in the JXA command
  system('osascript', '-l', 'JavaScript', '-e', "Application('Finder').delete(Path('#{escaped_path}'))")
end

# Constants
Notes_dir = get_env(
  env_variable: ENV['notes_dir'],
  default: ENV['alfred_workflow_data'],
  as_pathname: true
)

# Always run
Notes_dir.mkpath

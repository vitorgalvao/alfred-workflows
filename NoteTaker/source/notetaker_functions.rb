require 'json'
require 'open3'
require 'pathname'

# Helpers
def get_env(variable:, default:, as_bool: false, as_pathname: false, match_list: [])
  # If boolean, return early
  if as_bool
    case variable
    when true, 'true', 'yes', 1, '1' then return true
    when false, 'false', 'no', 0, '0' then return false
    when nil, ''
      return default if [true, false].include?(default)
      raise ArgumentError, '"as_bool" is set but variable is nil/empty and "default" is not a boolean'
    else raise ArgumentError, "Invalid value: #{variable.inspect}"
    end
  end

  # Extract string
  var_as_string = lambda {
    return default if variable.nil? || variable.empty?
    return variable if match_list.empty? || match_list.include?(variable)

    default
  }.call

  # If pathname, make it now
  return Pathname.new(var_as_string).expand_path if as_pathname

  var_as_string
end

def display_notes(dir: Notes_dir)
  notes = dir.children.reject { |p| p.basename.to_path == '.DS_Store' }
  script_filter_items = []

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

  script_filter_items.push(
    title: 'New note',
    variables: { add_note_external: true.to_s },
  )

  puts({ items: script_filter_items }.to_json)
end

def add_note(title:, content:, dir: Notes_dir)
  forbidden_chars = [':', '/']
  file = dir.join("#{title.delete(forbidden_chars.join)}.#{File_ext}")

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
  file # Return note path for other functions
end

def copy_note(path:)
  Open3.capture2('pbcopy', stdin_data: Pathname.new(path).read)
end

def edit_note(path:)
  system('open', '-t', path)
end

def trash(path:)
  system('osascript', '-l', 'JavaScript', '-e', 'function run(argv) { Application("Finder").delete(Path(argv[0])) }', path)
end

# Constants
Notes_dir = get_env(
  variable: ENV['notes_dir'],
  default: ENV['alfred_workflow_data'],
  as_pathname: true
)

File_ext = get_env(
  variable: ENV['new_file_extension'],
  default: 'txt'
)

# Always run
Notes_dir.mkpath

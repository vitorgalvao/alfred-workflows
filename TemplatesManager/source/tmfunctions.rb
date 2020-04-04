#!/usr/bin/ruby

require 'fileutils'
require 'net/http'

Templates_dir = ENV['custom_templates_dir'].nil? || ENV['custom_templates_dir'].empty? ? ENV['alfred_workflow_data'] : File.expand_path(ENV['custom_templates_dir'])
Local_templates = Templates_dir + '/local/'
Remote_templates = Templates_dir + '/remote'
FileUtils.mkdir_p(Local_templates) unless Dir.exist?(Local_templates)
FileUtils.touch(Remote_templates) unless File.exist?(Remote_templates)

def finder_dir
  %x{osascript -l JavaScript -e '
    frontmost_app_name = Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0]
    frontmost_app = Application(frontmost_app_name)

    if (Object.is(frontmost_app_name, "Finder")) {
      decodeURI(frontmost_app.finderWindows[0].target.url()).slice(7).slice(0, -1)
    } else if (Object.is(frontmost_app_name, "Path Finder")) {
      frontmost_app.finderWindows[0].target.posixPath()
    } else {
      decodeURI(Application("Finder").home.url()).slice(7).slice(0, -1)
    }
  '}.sub(/\n$/, '/')
end

def notification(message)
  system("#{Dir.pwd}/Notificator.app/Contents/Resources/Scripts/notificator", '--message', message, '--title', ENV['alfred_workflow_name'])
end

def local_list
  Dir.entries(Local_templates).reject { |entry| entry =~ /^(\.{1,2}$|.DS_Store$)/ }
end

def remote_list
  File.readlines(Remote_templates)
end

def local_edit
  system('open', Local_templates)
end

def remote_edit
  system('open', '-t', Remote_templates)
end

def local_add(path)
  path_basename = File.basename(path)

  if local_list.include?(path_basename)
    notification('You already have a template with that name')
    abort 'A template with that name already exists'
  else
    FileUtils.cp_r(path, Local_templates)
    notification('Added to local templates')
  end
end

def remote_add(url)
  if remote_list.include?(url)
    notification('You already have a template with that name')
    abort 'A template with that name already exists'
  else
    File.open(Remote_templates, 'a') do |link|
      link.puts url
    end
    notification('Added to remote templates')
  end
end

def local_delete(local_array_pos)
  FileUtils.rm_r(Local_templates + local_list[local_array_pos])
end

def remote_delete(remote_array_pos)
  tmp_array = remote_list
  tmp_array.delete_at(remote_array_pos)

  File.open(Remote_templates, 'w+') do |line|
    line.puts tmp_array
  end
end

def local_info
  puts "<?xml version='1.0'?><items>"

  if local_list.empty?
    puts "<item valid='no'>"
    puts '<title>List templates (tml)</title>'
    puts '<subtitle>You need to add some local templates, first</subtitle>'
    puts '</item>'
  else
    local_list.each_index do |local_array_pos|
      template_title = local_list[local_array_pos]
      puts "<item uuid='#{local_array_pos}' arg='#{local_array_pos}' valid='yes'>"
      puts "<title><![CDATA[#{template_title}]]></title>"
      puts '</item>'
    end
  end

  puts '</items>'
end

def remote_info
  puts "<?xml version='1.0'?><items>"

  if remote_list.empty?
    puts "<item valid='no'>"
    puts '<title>List templates (rtml)</title>'
    puts '<subtitle>You need to add some remote templates, first</subtitle>'
    puts '</item>'
  else
    remote_list.each_index do |remote_array_pos|
      template_subtitle = remote_list[remote_array_pos]
      template_title = File.basename(template_subtitle)
      puts "<item uuid='#{remote_array_pos}' arg='#{remote_array_pos}' valid='yes'>"
      puts "<title><![CDATA[#{template_title}]]></title>"
      puts "<subtitle><![CDATA[#{template_subtitle}]]></subtitle>"
      puts '<icon>icon.png</icon>'
      puts '</item>'
    end
  end

  puts '</items>'
end

# run a _templatesmanagerscript.* in the copied directory
def local_script_run(location)
  tm_script = Dir.entries(location).find { |item| item =~ /_templatesmanagerscript\./ }

  return unless tm_script

  require 'shellwords'
  Dir.chdir(location)
  system("#{Dir.pwd}/#{tm_script}".shellescape)
end

# Copy files and directories directly
def local_put(local_array_pos)
  template_title = local_list[local_array_pos]
  item_location = Local_templates + template_title
  FileUtils.cp_r(item_location, finder_dir)

  # run _templatesmanagerscript.*, if a directory was copied
  dest_location = finder_dir + template_title
  local_script_run(dest_location) if File.directory?(dest_location)
end

# If source is a directory, copy what's inside of it
def local_put_files_only(local_array_pos)
  item_location = Local_templates + local_list[local_array_pos]

  # if used on a file, give a warning
  if File.file?(item_location)
    notification('This option should only be used on directories')
    abort 'This option should only be used on directories'
  else
    FileUtils.cp_r(Dir[item_location + '/*'], finder_dir)

    # run _templatesmanagerscript.*
    local_script_run(finder_dir)
  end
end

def remote_put(remote_array_pos)
  url = remote_list[remote_array_pos].gsub(/\n$/, '')
  file_name = File.basename(url)
  File.write(finder_dir + file_name, Net::HTTP.get(URI.parse(url)))
end

def remote_print(remote_array_pos)
  url = remote_list[remote_array_pos].gsub(/\n$/, '')
  print Net::HTTP.get(URI.parse(url))
end

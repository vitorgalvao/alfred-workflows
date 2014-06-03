#!/usr/bin/ruby

require 'fileutils'
require 'net/http'
require Dir.getwd + '/_licensed/terminal-notifier/lib/terminal-notifier.rb'

LocalTemplates = Dir.getwd + '/templates/local/'
RemoteTemplates = Dir.getwd + '/templates/remote'

def finderDir
  %x{osascript -e 'tell application "System Events"
     if (name of first process whose frontmost is true) is "Finder" then
     tell application "Finder" to return (POSIX path of (folder of the front window as alias))
     else
     return (POSIX path of (path to home folder))
     end if
     end tell'}.gsub(/\n$/, '/')
end

def notification(message)
  TerminalNotifier.notify(message, :title => 'TemplatesManager')
end

def localList
  Dir.entries(LocalTemplates).reject{ |entry| entry =~ /^(\.{1,2}$|.DS_Store$)/ }
end

def remoteList
  File.readlines(RemoteTemplates)
end

def localEdit
  system('open', LocalTemplates)
end

def remoteEdit
  system('open', '-t', RemoteTemplates)
end

def localAdd(path)
  pathBasename = File.basename(path)

  if localList.include?(pathBasename)
    notification('You already have a template with that name')
    abort 'A template with that name already exists'
  else
    FileUtils.cp_r(path, LocalTemplates)
    notification('Added to local templates')
  end
end

def remoteAdd(url)
  if remoteList.include?(url)
    notification('You already have a template with that name')
    abort 'A template with that name already exists'
  else
    File.open(RemoteTemplates, 'a') do |link|
      link.puts url
    end
    notification('Added to remote templates')
  end
end

def localDelete(localArrayPos)
  system(Dir.getwd + '/_licensed/trash/trash', LocalTemplates + localList[localArrayPos])
end

def remoteDelete(remoteArrayPos)
  tmpArray = remoteList.delete_at(remoteArrayPos)

  File.open(RemoteTemplates, 'w+') do |line|
    line.puts tmpArray
  end
end

def localInfo(searchQuery)
  puts "<?xml version='1.0'?><items>"

  if localList.empty?
    puts "<item uuid='none' arg='none' valid='no'>"
    puts "<title>List templates (tml)</title>"
    puts "<subtitle>You need to add some local templates, first</subtitle>"
    puts "<icon>icon.png</icon>"
    puts "</item>"
  else
    localList.each_index do |localArrayPos|
      templateTitle = localList[localArrayPos]

      if templateTitle =~ /#{searchQuery}/
        puts "<item uuid='#{localArrayPos}' arg='#{localArrayPos}' valid='yes'>"
        puts "<title><![CDATA[#{templateTitle}]]></title>"
        puts "<icon>icon.png</icon>"
        puts "</item>"
      end
    end
  end

  puts "</items>"
end

def remoteInfo(searchQuery)
  puts "<?xml version='1.0'?><items>"

  if remoteList.empty?
    puts "<item uuid='none' arg='none' valid='no'>"
    puts "<title>List templates (rtml)</title>"
    puts "<subtitle>You need to add some remote templates, first</subtitle>"
    puts "<icon>icon.png</icon>"
    puts "</item>"
  else
    remoteList.each_index do |remoteArrayPos|
      templateSubtitle = remoteList[remoteArrayPos]
      templateTitle = File.basename(templateSubtitle)

      if templateTitle =~ /#{searchQuery}/
        puts "<item uuid='#{remoteArrayPos}' arg='#{remoteArrayPos}' valid='yes'>"
        puts "<title><![CDATA[#{templateTitle}]]></title>"
        puts "<subtitle><![CDATA[#{templateSubtitle}]]></subtitle>"
        puts "<icon>icon.png</icon>"
        puts "</item>"
      end
    end
  end

  puts "</items>"
end

# run a _templatesmanagerscript.* in the copied directory
def localScriptRun(location)
  tmScript = Dir.entries(location).find{ |item| item =~ /_templatesmanagerscript\./ }
  if tmScript
    Dir.chdir(location)
    system("./" + tmScript)
  end
end

# Copy files and directories directly
def localPut(localArrayPos)
  templateTitle = localList[localArrayPos]
  itemLocation = LocalTemplates + templateTitle
  FileUtils.cp_r(itemLocation, finderDir)

  # run _templatesmanagerscript.*, if a directory was copied
  destLocation = finderDir + templateTitle
  localScriptRun(destLocation) if File.directory?(destLocation)
end

# If source is a directory, copy what's inside of it
def localPutFilesOnly(localArrayPos)
  itemLocation = LocalTemplates + localList[localArrayPos]

  # if used on a file, give a warning
  if File.file?(itemLocation)
    notification('This option should only be used on directories')
    abort 'This option should only be used on directories'
  else
    FileUtils.cp_r(Dir[itemLocation + '/*'], finderDir)

    # run _templatesmanagerscript.*
    localScriptRun(finderDir)
  end
end

def remotePut(remoteArrayPos)
  url = remoteList[remoteArrayPos].gsub(/\n$/, '')
  fileName = File.basename(url)
  File.write(finderDir + fileName, Net::HTTP.get(URI.parse(url)))
end

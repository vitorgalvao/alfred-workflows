#!/usr/bin/ruby

Redcarpet_dir = "#{Dir.pwd}/_licensed/Redcarpet"
Gem.paths = { 'GEM_PATH' => Gem.path.unshift(Redcarpet_dir).join(File::PATH_SEPARATOR) }

def notification(subtitle, message, sound = '')
  system("#{Dir.pwd}/Notificator.app/Contents/Resources/Scripts/notificator", '--message', message, '--subtitle', subtitle, '--sound', sound, '--title', ENV['alfred_workflow_name'])
end

begin
  require 'redcarpet'
rescue LoadError
  notification('Reinstalling converter…', 'Please wait a few seconds')

  require 'fileutils'
  FileUtils.rm_r(Redcarpet_dir) if Dir.exist?(Redcarpet_dir)

  if system('/usr/bin/gem', 'install', '--no-document', '--install-dir', Redcarpet_dir, 'redcarpet', out: File::NULL)
    notification('Finished reinstalling!', 'This should not be necessary again', 'Ping')
  else
    notification('There was an error', 'Please open a bug report', 'Funk')
    system('open', 'https://github.com/vitorgalvao/alfred-workflows/issues/new')
  end
end

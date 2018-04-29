#!/usr/bin/ruby

Redcarpet_dir = "#{__dir__}/_licensed/Redcarpet".freeze
$LOAD_PATH.unshift "#{Redcarpet_dir}/gems/redcarpet-3.4.0/lib"

def notification(subtitle, message, sound = '')
  system("#{__dir__}/Notificator.app/Contents/Resources/Scripts/notificator", '--message', message, '--subtitle', subtitle, '--sound', sound, '--title', ENV['alfred_workflow_name'])
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

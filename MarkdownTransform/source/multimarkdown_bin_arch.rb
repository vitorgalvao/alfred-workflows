#!/usr/bin/ruby

ENV['multimarkdown_bin'] = lambda {
  if Open3.capture2('/usr/sbin/sysctl', '-n', 'machdep.cpu.brand_string').first.start_with?('Apple')
    return "#{Dir.pwd}/_licensed/MultiMarkdown/multimarkdown"
  end

  "#{Dir.pwd}/_licensed/MultiMarkdown/multimarkdown_intel"
}.call

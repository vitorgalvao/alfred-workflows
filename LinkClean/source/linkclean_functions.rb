#!/usr/bin/env ruby

require 'json'
require 'open3'

def follow_redirects(url)
  Open3.capture2(
    'curl', '--silent', '--head', '--location', '--output', '/dev/null',
    '--write-out', '%{url_effective}', url
  ).first.strip
end

def clean_url(url)
  url
    .sub(%r{(https?://)(m\.|mobile\.|touch\.)(.*)}, '\1\3') # 'm.' 'mobile.' 'touch.'
    .sub(%r{\?.*}, '') # Anything after and including '?'
    .sub(%r{(https://(www|smile)?\.amazon\..*/)ref=.*}, '\1') # 'ref=' and after from amazon
end

def display_options
  script_filter_items = []

  clipboard = Open3.capture2('pbpaste').first

  argument = ARGV[0] || clipboard
  valid_state = argument.empty? ? false : true

  script_filter_items.push(
    title: 'Clean URL',
    subtitle: argument,
    arg: argument,
    valid: valid_state
  )

  puts({ items: script_filter_items }.to_json)
end

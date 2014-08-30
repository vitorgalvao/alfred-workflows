#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'

detailsFile = "/tmp/bugnot"

if File.exists?(detailsFile)
  File.delete(detailsFile)
end

if ARGV[0].nil?
  abort "You need to specify a website"
end

page = Nokogiri::HTML(open("http://bugmenot.com/view/" + ARGV[0]))

loginTotal = page.css('article.account').count

for account in 0..loginTotal-1
  loginSection = page.css('article.account')[account]
  username = loginSection.css('kbd')[0].text
  password = loginSection.css('kbd')[1].text
  success = loginSection.css('li.success_rate').attr('class').text.gsub(/\D*/, '')

  File.open(detailsFile, "a") do |f|
    f.puts username + "////" + password + "////" + success
  end
end

require 'cgi'
require 'open-uri'

specialChar = ARGV[0]
passLen = ARGV[1].to_i

# get passwords as arrays of characters
grc = CGI.unescapeHTML(open('https://www.grc.com/passwords.htm', &:read).split("\n").grep(/ASCII characters:/).to_s.gsub(/.*2>|<.*/, '')).split('') if specialChar == 'yes'
rorg = open('https://www.random.org/passwords/?num=8&len=24&format=html&rnd=new', &:read).split("\n").grep(/<li>/).last(8).join.to_s.gsub(/<li>|<\/li>/, '').split('')

# number of characters to take from each one
specialChar == 'yes' ? grcLen = rand(passLen/3..passLen*2/3) : grcLen = 0
rorgLen = passLen - grcLen

tmpPass = Array.new
finalPass = String.new

# get random characters from each array
grcLen.times do
  tmpPass << grc.delete_at(rand(grc.length))
end

rorgLen.times do
  tmpPass << rorg.delete_at(rand(rorg.length))
end

# get random characters union of both
passLen.times do
  finalPass += tmpPass.delete_at(rand(tmpPass.length))
end

print finalPass

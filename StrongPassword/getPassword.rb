require 'cgi'
require 'open-uri'

passLen = ARGV[0].to_i

# get passwords as arrays of characters
grc = CGI.unescapeHTML(open('https://www.grc.com/passwords.htm', &:read).split("\n").grep(/ASCII characters:/).to_s.gsub(/.*2>|<.*/, '')).split('')
rorg = open('https://www.random.org/passwords/?num=8&len=24&format=html&rnd=new', &:read).split("\n").grep(/<li>/).last(8).join.to_s.gsub(/<li>|<\/li>/, '').split('')

# number of characters to take from each one
grcLen = rand(passLen/3..passLen*2/3)
rorgLen = passLen - grcLen

grcPart = Array.new
rorgPart = Array.new
finalPass = String.new

# get random characters from each array
grcLen.times do
  grcPart << grc.delete_at(rand(grc.length))
end

rorgLen.times do
  rorgPart << rorg.delete_at(rand(rorg.length))
end

joinParts = grcPart + rorgPart

# get random characters union of both
passLen.times do
  finalPass += joinParts.delete_at(rand(joinParts.length))
end

print finalPass

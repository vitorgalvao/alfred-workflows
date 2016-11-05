list_file = "#{ENV['alfred_workflow_cache']}/list.json"
Dir.mkdir(ENV['alfred_workflow_cache']) unless Dir.exist?(ENV['alfred_workflow_cache'])

# Recheck films if list file does not exist or is older than a day or argument asks for it
if !File.exist?(list_file) || (((Time.now - File.mtime(list_file)) / (24 * 3600)).to_i > 1) || ARGV[0] == 'update_list'
  require 'rss'
  require 'json'
  require 'open-uri'
  require 'nokogiri'

  site_rss = 'https://www.shortoftheweek.com/feed'
  site_feed = RSS::Parser.parse(open(site_rss))

  script_filter_items = []

  # grab link from items, remove "/news/" links, load info from links into array
  site_feed.items.map(&:link).reject { |link| link.match('/news/') }.each do |item|
    # get details
    page = Nokogiri::HTML(open(item))
    url = page.at('.embed-wrapper').attr('data-src')
    title = page.at('h1.title').text
    image = 'https:' + page.at('.bar-hidden').at('img').attr('src')
    details = page.at('.details')
    genre = details.at('span').text
    author = details.css('span')[1].text.strip
    duration = details.at('time').text

    # set banner image as icon
    downloaded_image = "#{ENV['alfred_workflow_cache']}/#{File.basename(image)}"
    unless File.exist?(downloaded_image) # do not redownload or resize old images
      File.write(downloaded_image, open(image).read)
      image_width = %x(sips --getProperty pixelWidth "#{downloaded_image}" | tail -1 | awk '{print $2}').to_i
      image_height = %x(sips --getProperty pixelHeight "#{downloaded_image}" | tail -1 | awk '{print $2}').to_i
      smaller_dimension = (image_width > image_height ? image_height : image_width).to_s
      system('sips', '--cropToHeightWidth', smaller_dimension, smaller_dimension, downloaded_image)
    end

    script_filter_items.push(title: title, subtitle: "#{genre} / #{duration} / #{author}", icon: { path: downloaded_image }, quicklookurl: item, arg: url)
  end

  File.write(list_file, { items: script_filter_items }.to_json)
end

# Output list
puts File.open(list_file, &:read).to_s

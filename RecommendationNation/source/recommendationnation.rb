require 'csv'
require 'json'

Recommendations_Dir = ENV['recs_dir'].nil? || ENV['recs_dir'].empty? ? ENV['alfred_workflow_data'] : File.expand_path(ENV['recs_dir'])
Recommendations_File = File.join(Recommendations_Dir, 'recommendations.csv')

Sites = {
  film: {
    imdb: 'https://www.imdb.com/find?q=',
    letterboxd: 'https://letterboxd.com/search/'
  },
  book: {
    goodreads: 'https://www.goodreads.com/search?query='
  },
  television: {
    trakt: 'https://trakt.tv/search?query=',
    tvtime: 'https://www.tvtime.com/search?q='
  },
  game: {
    igdb: 'https://www.igdb.com/search?q=',
    gamespot: 'https://www.gamespot.com/search/?q=',
    gamefaqs: 'https://gamefaqs.gamespot.com/search?game=',
    ign: 'http://www.ign.com/search?q='
  },
  anime: {
    myanimelist: 'https://myanimelist.net/anime.php?q=',
    animeplanet: 'https://www.anime-planet.com/anime/all?name='
  },
  manga: {
    myanimelist: 'https://myanimelist.net/manga.php?q=',
    goodreads: 'https://www.goodreads.com/search?query='
  },
  comic: {
    leagueofcomicgeeks: 'https://leagueofcomicgeeks.com/search?keyword=',
    comicvine: 'https://comicvine.gamespot.com/search/?q='
  },
  other: {
    duckduckgo: 'https://duckduckgo.com/?q=',
    startpage: 'https://www.startpage.com/do/asearch?q=',
    google: 'https://www.google.com/search?q='
  }
}

def edit_list(list_file)
  system('open', '-t', list_file)
end

def add_line(list_file, type, title, person, reason)
  require 'fileutils'

  list_dir = File.dirname(list_file)
  FileUtils.mkdir_p(list_dir) unless Dir.exist?(list_dir)

  csv_line = [type, title, person, reason].map(&:strip).to_csv
  File.write(list_file, csv_line, mode: 'a')
end

def delete_line(list_file, line_number)
  lines = File.readlines(list_file)
  lines.delete_at(line_number)

  File.write(list_file, lines.join)
end

def move_to_top(list_file, line_number)
  lines = File.readlines(list_file)
  to_top = lines.delete_at(line_number.to_i)

  File.write(list_file, lines.unshift(to_top).join)
end

def show_recommendations(list_file)
  script_filter_items = []

  if !File.exist?(list_file) || File.zero?(list_file)
    script_filter_items.push(title: 'You have no saved recommendations.', valid: false)
  else
    File.readlines(list_file).each_with_index do |line, index|
      info = line.parse_csv
      script_filter_items.push(title: info[1], subtitle: "#{info[0].capitalize} rec from #{info[2]}. #{info[3]}.".sub(%r{\s*\.*$}, '.'), match: info.join(' '), arg: index)
    end
  end

  puts({ items: script_filter_items }.to_json)
end

def show_types(sites_hash)
  script_filter_items = []

  sites_hash.keys.each do |key|
    type = key.to_s
    script_filter_items.push(title: type.capitalize, arg: type)
  end

  puts({ items: script_filter_items }.to_json)
end

def show_type_sites(sites_hash, type)
  script_filter_items = []

  sites_hash[type.to_sym].each do |key, value|
    site = key.to_s
    script_filter_items.push(title: site, subtitle: value.to_s.split('/')[0..2].join('/'), arg: site)
  end

  puts({ items: script_filter_items }.to_json)
end

def open_site(list_file, sites_hash, line_number, force_generic_search = false)
  require 'cgi'

  info = File.readlines(list_file)[line_number].parse_csv
  title = CGI.escape(info[1])
  type = force_generic_search ? 'other' : info[0]

  type_sym = type.to_sym
  site_type = ENV[type + '_site']

  site_url = site_type.nil? || site_type.empty? || !sites_hash[type_sym].key?(site_type.to_sym) ? sites_hash[type_sym].first[1] : sites_hash[type_sym][site_type.to_sym]

  system('open', site_url + title)
end

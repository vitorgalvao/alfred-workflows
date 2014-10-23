#!/usr/bin/env ruby

require 'cgi'
require 'open-uri'
require 'nokogiri'

details_file = "/tmp/rottenmovies"

if File.exists?(details_file)
  File.delete(details_file)
end

if ARGV[0].nil?
  abort "You need to specify a movie title or url"
else
  movie_to_search = ARGV[0]
end

if movie_to_search.match(/^\/m\//) # the argument given was a movie page url
  page = Nokogiri::HTML(open("http://www.rottentomatoes.com/" + movie_to_search))
else
  page = Nokogiri::HTML(open("http://www.rottentomatoes.com/search/?search=" + CGI.escape(movie_to_search) + "#results_movies_tab"))
end

if page.at('title').text == 'Search Results - Rotten Tomatoes' # we're on the results list
  movie_results = page.css('ul#movie_results_ul li.media')

  for movie_block in movie_results
    movie_title = movie_block.css('div.nomargin a.articleLink').text
    movie_year = movie_block.css('span.movie_year').text.strip
    movie_score = movie_block.css('span.tMeterScore').text

    if movie_score.empty?
      movie_score = "—"
      movie_freshness = "noScore"
    else
      movie_freshness = movie_block.css('span.icon.tiny').attr('class').value.gsub(/.*(certified|fresh|rotten|noScore).*/m, '\1')
    end

    movie_url = movie_block.css('div.nomargin a.articleLink').attr('href').value

    File.open(details_file, "a") do |f|
      f.puts "#{movie_title} #{movie_year}" + "⸗" + "Critics: " + movie_score + "⸗" + movie_freshness + "⸗" + movie_url
    end
  end
else # we're on the exact movie page
  movie_block = page.css('div#mainColumn')
  movie_title = movie_block.css('h1.movie_title span').text.strip.gsub(/\n.*/m, '')
  movie_year = movie_block.css('h1.movie_title span span').text
  movie_score_critics = movie_block.css('div#all-critics-numbers span.meter-value span').text
  movie_score_audience = movie_block.css('div.audience-score.meter span.meter-value').text
  movie_audience_subtext = movie_block.css('div.audience-score.meter div.smaller.bold').text
  movie_freshness = movie_block.css('div#all-critics-numbers span.meter-tomato').attr('class').value.gsub(/.*(certified|fresh|rotten|noScore).*/, '\1')

  File.open(details_file, "a") do |f|
    f.puts "#{movie_title} #{movie_year}" + "⸗" + "Critics: " + movie_score_critics + "% | " + "Audience: " + movie_score_audience + " " + movie_audience_subtext + "⸗" + movie_freshness
  end
end

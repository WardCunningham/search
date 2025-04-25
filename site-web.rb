require 'json'
require 'date'

@links = {}
@pages = {}
@web = {}

def read
  Dir.new('sites').each do |site|
    next if site.match /^\./
    next unless Dir.exist?("sites/#{site}/pages")
    next if (Date.today - File.mtime("sites/#{site}/pages").to_date).to_i > 365
    size = Dir["sites/#{site}/pages/*"].size
    next if size < 10
    @pages[site] = size
    next unless File.exist?("sites/#{site}/sites.txt")
    @links[site] = File.readlines("sites/#{site}/sites.txt").map(&:chomp)
  end
end

def clean
  @links.each do |site, links|
    links.select! {|link| @pages.has_key?(link)}
  end
end

def merge
  @pages.each do |site, pages|
    @web[site] = {pages: pages, links: @links[site]}
  end
end

read
clean
merge

puts JSON.pretty_generate @web

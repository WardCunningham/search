require 'json'

@links = {}
@pages = {}
@web = {}

def read
  Dir.new('sites').each do |site|
    next if site.match /^\./
    next unless Dir.exists?("sites/#{site}/pages")
    @pages[site] = Dir["sites/#{site}/pages/*"].size
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
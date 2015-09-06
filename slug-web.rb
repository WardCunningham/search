require 'json'
require 'set'

@web = Hash.new { |hash, key| hash[key] = {forks: 0, links:Set.new} }

def read
  Dir.new('sites').each do |site|
    next if site.match /^\./
    next unless Dir.exists?("sites/#{site}/pages")
    Dir["sites/#{site}/pages/*"].each do |path|
      slug = (path.chomp.split(/\//))[3]
      @web[slug][:forks] += 1
      next unless File.exist?("sites/#{site}/pages/#{slug}/links.txt")
      @web[slug][:links].merge File.readlines("sites/#{site}/pages/#{slug}/links.txt").map(&:chomp)
    end
  end
end

def clean
  @web.each do |slug, node|
    node[:links] = node[:links].to_a.sort.select {|link| @web.has_key?(link)}
  end
end

read
clean

puts JSON.pretty_generate @web
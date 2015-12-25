# export graph as neo4j batch input files, nodes.csv & relations.csv
# ruby neo-batch.rb; neo4j-import --into wiki.db --nodes public/nodes.csv --relationships public/rels.csv

require 'csv'

@id = 0
@aloc = {}
@missing = {}

@nodes = CSV.open("public/nodes.csv", "wb")
@nodes << [':ID','title',':LABEL']

@rels = CSV.open("public/rels.csv", "wb")
@rels << [':START_ID',':END_ID',':TYPE']


def id label, title
  key = "#{label}-#{title}"
  return @aloc[key] unless @aloc[key].nil?
  @id += 1
  yield @id if block_given?
  @aloc[key] = @id
end

def dotitle slug
  id 'Title', slug do |here|
    title = slug.gsub(/\w+/, &:capitalize).gsub(/-/,' ')
    @nodes << [here, title, 'Title']
  end
end


def dopage domain, slug
  here = @id += 1
  @nodes << [here, slug, 'Page']
  there = dotitle slug
  @rels << [here, there, 'IS']
  links = "sites/#{domain}/pages/#{slug}/links.txt"
  if File.exist?(links)
    File.readlines(links).each do |link|
      there = dotitle link.chomp
      @rels << [here, there, 'LINK']
    end
  end
  sites = "sites/#{domain}/pages/#{slug}/sites.txt"
  if File.exist?(sites)
    File.readlines(sites).each do |site|
      there = id 'Site', site.chomp do |id|
        @missing[site.chomp] = id
      end
      @rels << [here, there, 'KNOWS']
    end
  end
  here
end


def dosite domain
  pages = "sites/#{domain}/pages"
  return unless File.exist?(pages)
  here = id 'Site', domain
  @nodes << [here, domain, 'Site']
  Dir.entries(pages).each do |slug|
    next if slug[0] == '.'
    there = dopage domain, slug
    @rels << [here, there, 'HAS']
  end
end

def dofederation
  Dir.entries("sites").each do |domain|
    next if domain[0] == '.'
    dosite domain
  end
  @missing.each do |domain,id|
    @nodes << [id, domain, 'Site']
  end
end

# dofederation

dosite 'ward.asia.wiki.org'
dosite 'forage.ward.fed.wiki.org'

@nodes.close
@rels.close
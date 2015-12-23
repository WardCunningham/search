# export graph as neo4j batch input files, nodes.csv & relations.csv
# ruby neo-batch.rb; neo4j-import --into wiki.db --nodes public/nodes.csv --relationships public/rels.csv

require 'csv'

@id = 0
@aloc = {}

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
  here
end


def dosite domain
  here = id 'Site', domain
  @nodes << [here, domain, 'Site']
  Dir.entries("sites/#{domain}/pages").each do |slug|
    next if slug[0] == '.'
    there = dopage domain, slug
    @rels << [here, there, 'HAS']
  end
end
	

dosite 'ward.asia.wiki.org'
dosite 'forage.ward.fed.wiki.org'

@nodes.close
@rels.close
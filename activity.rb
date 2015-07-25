# publish rosters as recent-activity
# usage: cd FedWiki/search; ruby activity.rb

require 'json'

@story = []

def add item
	item['id'] = rand(1000000000)
	@story << item
end

def roster
	result = []
	Dir.glob 'activity/*' do |filename|
		result << filename
		result << File.read(filename)
	end
	result
end

add({:type => 'paragraph', :text => 'Search has found new pages on these sites.' })
add({:type => 'paragraph', :text => 'Click » for sites of interest. See [[Recent Changes]]' })
add({:type => 'roster', :text => roster.join("\n\n")})

File.open 'public/recent-activity.json', 'w' do |file|
	file.puts JSON.pretty_generate({:title => 'Recent Activity', :story => @story})
end
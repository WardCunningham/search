# publish rosters as recent-activity
# usage: cd FedWiki/search; ruby activity.rb

require 'json'

@story = []

def add item
  item['id'] = rand(1000000000).to_s
  @story << item
end

def roster
  result = []
  Dir['activity/*00'].sort_by{ |f| File.ctime(f) }.reverse.each do |filename|
puts filename
    result << filename.split('/')[1]
    result << File.read(filename)
  end
  result
end

add({:type => 'paragraph', :text => 'Here we report sites we find with recently edited pages.' })
add({:type => 'paragraph', :text => `ruby counts.rb`.chomp})
add({:type => 'paragraph', :text => 'Click » for sites of interest. See [[Recent Changes]]' })
add({:type => 'roster', :text => roster.join("\n\n")})

File.open 'activity/recent-activity.json', 'w' do |file|
  file.puts JSON.pretty_generate({:title => 'Recent Activity', :story => @story})
end

# publish rosters as recent-activity
# usage: cd FedWiki/search; ruby activity.rb

require 'json'

@story = []
@sitemap = []

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

# Recent Activity

add({:type => 'paragraph', :text => 'Here we report sites we find with recently edited pages.' })
add({:type => 'paragraph', :text => `ruby counts.rb`.chomp})
add({:type => 'paragraph', :text => "This and past scans found #{`cat items.txt | wc -l`.chomp} unique items."})
synopsis = @story.map{|item| item[:text]}.join(' ')

add({:type => 'paragraph', :text => 'Click » for sites of interest. See [[Recent Changes]]' })
add({:type => 'roster', :text => roster.join("\n\n")})

File.open 'pages/recent-activity', 'w' do |file|
  file.puts JSON.pretty_generate({:title => 'Recent Activity', :story => @story})
end
@sitemap << {:title => 'Recent Activity', :synopsis => synopsis, :slug => 'recent-activity', :date => Time.now.to_i*1000}

# Visible Federation

@story = []
add({:type => 'paragraph', :text => 'Here we report all sites found, organized by domain name, excluding sites with less than ten pages.' })
add({:type => 'roster', :text => `ruby roster.rb`})

File.open 'pages/visible-federation', 'w' do |file|
  file.puts JSON.pretty_generate({:title => 'Visible Federation', :story => @story})
end
@sitemap << {:title => 'Visible Federation', :synopsis => @story[0][:text], :slug => 'visible-federation', :date => Time.now.to_i*1000}

# system/sitemap.json

File.open 'activity/sitemap.json', 'w' do |file|
  file.puts JSON.pretty_generate(@sitemap)
end

# report sites and pages scanned from most recent log
# usage: ruby counts.rb

require 'json'

# Debug ► Ruby:counts ► read Logs:Now-0000
recent = `ls -t logs | head -n 1`.chomp
log = File.read "logs/#{recent}"

sites = pages = 0
log.scan(/, (\d+) pages\b/) do |count|
	sites += 1
	pages += count[0].to_i
end

# Debug ► Ruby:counts ► write Search:counts.txt
counts = {date: Time.now.to_i, scan: {sites: sites, pages: pages}, index: {}}
`wc -l *.txt`.scan(/(\d+) (\w+)\.txt/) {|v,k| counts[:index][k] = v.to_i}
File.open('counts.txt','a') {|file| file.puts counts.to_json}

puts "We scanned #{sites} sites hosting #{pages} pages."

puts "http://3d.local:6789/scrape"
puts `curl -X POST -H 'Auth:3546736' -H 'Content-type:text/json' http://3d.local:6789/scrape -d '#{counts.to_json}'`
puts "https://rest.livecode.world/scrape"
puts `curl -X POST -H 'Auth:3546736' -H 'Content-type:text/json' https://rest.livecode.world/scrape -d '#{counts.to_json}'`

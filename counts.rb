# report sites and pages scanned from most recent log
# usage: ruby counts.rb

require 'json'

recent = `ls -t logs | head -n 1`.chomp
log = File.read "logs/#{recent}"

sites = pages = 0
log.scan(/, (\d+) pages, /) do |count|
	sites += 1
	pages += count[0].to_i
end

counts = {date: Time.now.to_i, scan: {sites: sites, pages: pages}, index: {}}
`wc -l *.txt`.scan(/(\d+) (\w+)\.txt/) {|v,k| counts[:index][k] = v.to_i}
File.open('counts.txt','a') {|file| file.puts counts.to_json}

puts "We scanned #{sites} sites hosting #{pages} pages."
# report sites and pages scanned from most recent log
# usage: ruby counts.rb

recent = `ls -t logs | head -n 1`.chomp
log = File.read "logs/#{recent}"

sites = pages = 0
log.scan(/, (\d+) pages, /) do |count|
	sites += 1
	pages += count[0].to_i
end

puts "We scanned #{sites} sites hosting #{pages} pages."
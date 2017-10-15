# look for new sites and add them to the search
# usage: cd sites; ruby found.rb $NOW

time = ARGV[0] || `date -u +%a-%H00`.chomp
have = `ls sites retired`
want = File.read('sites.txt')

diff = Hash.new(0)
have.split(/\n/).each {|site| diff[site] += 1}
want.split(/\n/).each {|site| diff[site] -= 1}
make = diff.select {|site, count| count == -1 and not site.match /local|\/|^192.168|^127.0/}
exit 0 unless make.length > 0

make.each {|site, count| Dir.mkdir "sites/#{site}"}

make = make.keys.join "\n"
File.open("activity/#{time}",'a') {|file| file.puts; file.puts make}

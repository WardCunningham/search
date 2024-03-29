# look for new sites and add them to the search
# usage: cd sites; ruby found.rb $NOW

time = ARGV[0] || `date -u +%a-%H00`.chomp

# Index ► Ruby:found ► read Sites:sites.txt ► read Retired:dir
have = `ls sites retired`
want = File.read('sites.txt')

diff = Hash.new(0)
have.split(/\n/).each {|site| diff[site] += 1}
want.split(/\n/).each {|site| diff[site] -= 1}
make = diff.select {|site, count| count == -1 and not site.match /\blocalhost\b|\.local\b|\blocaltest.me\b|\/|^192.168|^127.0/}
exit 0 unless make.length > 0

# Index ► Ruby:found ► make Sites:dir
make.each {|site, count| Dir.mkdir "sites/#{site}"}

# Debug ► Ruby:found ► write Activity:Now-0000
make = make.keys.join "\n"
File.open("activity/#{time}",'a') {|file| file.puts; file.puts make}

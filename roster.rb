# construct roster for whole federation from sites scraped
# usage: roster = `ruby roster.rb`

@hosts = {}

def tally site, addr
  if m = site.match(/([^.]+\.[^.]+)$/)
    @hosts[addr] ||= {}
    @hosts[addr][m[1]] ||= []
    @hosts[addr][m[1]] << site
  end
end

def dns domain
  return if domain =~ /^www\./
  dns = `host #{domain}`
  if m = dns.match(/^(.+?) is an alias for (.+?).\n\2 has address ([\d.]+)$/)
    tally m[1], m[3]
  elsif m = dns.match(/^(.+?) has address ([\d.]+)$/)
    tally m[1], m[2]
  end
end

def input
  list = `cd sites; ls | while read i; do echo \`ls $i/pages | wc -l\` $i; done 2>/dev/null`
  list.split("\n").each do |line|
    count, domain = line.split ' '
    dns domain if count.to_i >= 5
  end
end

def roster
  @hosts.each do |addr, domains|
    puts addr.gsub(/\./,'-')
    puts
    domains.each do |domain, sites|
      puts sites.join("\n")
      puts
    end
    puts
  end
end

input
roster
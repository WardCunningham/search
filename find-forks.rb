# curl -s http://ward.dojo.fed.wiki/david-bovill-sites.json | jq -r '.story[3].text|split("\n")|.[]' | ruby find-forks.rb

  want = $stdin.read().split("\n");
  Dir.glob ['sites/*/pages/*/sites.txt'] do |file|
    path = file.split(/\//)
    have = File.read(file).split(/\n/)
    have.each { |site|
      if want.include? site
        puts "have #{path[1]}/#{path[3]} want #{site}"
      end
    }
  end

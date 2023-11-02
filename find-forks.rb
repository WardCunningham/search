# curl -s http://ward.dojo.fed.wiki/david-bovill-sites.json | jq -r '.story[3].text|split("\n")|.[]' | ruby find-forks.rb

  want = $stdin.read().split("\n");
  Dir.glob ['sites/*/sites.txt'] do |file|
    path = file.split(/\//)
    have = File.read(file).split(/\n/)
    have.each { |site|
      if want.include? site
        Dir.glob ["sites/#{path[1]}/pages/*/sites.txt"] do |file2|
          path2 = file2.split(/\//)
          have2 = File.read(file2).split(/\n/)
          have2.each { |site2|
            if want.include? site2
              puts "have #{path[1]}/#{path2[3]} want #{site2}"
            end
          }
        end
      end
    }
  end

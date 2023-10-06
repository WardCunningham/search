# test xref to graph conversion

# cron.sh 45 Index ► Shell:cron ► runs Ruby:slug-web ► write Public:slug-web.json
# scrape.rb 11 Index ► Sites:dir ► read Ruby:scrape

lines = File
  .read('xref.txt')
  .split(/\n/)
  .map{ |line|
    line.split(/\s+/)
  }
  .map{ |file, num, sys, *codes|
    {
      file: file,
      num: num,
      sys: sys,
      codes: codes
        .join(" ")
        .split(/ *► */)
        .drop(1)
    }
  }
puts lines

# {:file=>"cron.sh", :num=>"45", :sys=>"Index", :code=>["Shell:cron", "runs Ruby:slug-web", "write Public:slug-web.json"]}
# {:file=>"scrape.rb", :num=>"11", :sys=>"Index", :code=>["Sites:dir", "read Ruby:scrape"]}


def node(graph,tuple)
  return tuple
end

def rel(graph,type,here,there)
  puts "#{type} from #{here} to #{there}"
end

graphs = Hash.new { {nodes:[],rels:[]} }
lines.each {|line|
  puts "#{line[:file]} #{line[:num]}"
  graph = graphs[line[:sys]]
  here = nil
  line[:codes].each { |code|
    first, rest = code.split(/ /)
    if (first.include?(':'))
      here = node(graph,first)
    else
      there = node(graph,rest)
      rel(graph,first,here,there)
    end
  }
  graphs[line[:sys]] = graph
}

# cron.sh 45
# runs from Shell:cron to Ruby:slug-web
# write from Shell:cron to Public:slug-web.json
# scrape.rb 11
# read from Sites:dir to Ruby:scrape


puts graphs
# test xref to graph conversion

require 'json'

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


def node(sys,graph,tuple)
  type,name = tuple.split(/:/)
  nid = graph[:nodes].find_index{|node| node[:type]==type && node[:props][:name]==name}
  if (!!nid)
    return nid
  else
    want = {type:type,in:[],out:[],props:{name:name}}
    graph[:nodes].push(want)
    return graph[:nodes].length-1
  end
end

def rel(graph,type,here,there)
  puts "#{type} from #{tuple(graph,here)} to #{tuple(graph,there) }"
  graph[:rels].push({type:type,from:here,to:there,props:{}})
  rid = graph[:rels].length-1
  graph[:nodes][here][:out].push(rid)
  graph[:nodes][there][:in].push(rid)
end

def tuple(graph,nid)
  node=graph[:nodes][nid]
  "#{node[:type]}:#{node[:props][:name]}"
end

graphs = Hash.new { {nodes:[],rels:[]} }
lines.each {|line|
  puts "\n#{line[:sys]} in #{line[:file]} #{line[:num]}"
  graph = graphs[line[:sys]]
  here = nil
  line[:codes].each { |code|
    first, rest = code.split(/ /)
    if (first.include?(':'))
      here = node(line[:sys],graph,first)
    else
      there = node(line[:sys],graph,rest)
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

File.open("README.graph.jsonl", 'w') { |file|
  graphs.each {|sys,graph|
    file.write("#{{name:sys,graph:graph}.to_json}\n")
  }
}
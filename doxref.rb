# find and convert graph annotations

require 'json'
require 'set'

puts "-- files --"
lines = []
Dir.glob ['*.sh','*.rb'] do |file|
  have = Set.new()
  script = File.read(file).split(/\n/)
  script.each_with_index do |line, index|
    next unless line.match(/^\w*#/)
    if line.include? "►"
      com, sys, *rest = line .split(/\s+/)
      codes = rest.join(" ").split(/ *► */).drop(1)
      lines << {file:file, num:index+1, sys:sys, codes:codes}
      have << sys
    end
  end
  puts "#{file} does #{have.to_a.join(", ")}" if have.size > 0
end

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

def rel(graph,type,here,there,props={})
  graph[:rels].push({type:type,from:here,to:there,props:props})
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
  graph = graphs[line[:sys]]
  props = {file:line[:file], line:line[:num]}

  here = nil
  line[:codes].each { |code|
    first, rest = code.split(/ /)
    if (first.include?(':'))
      here = node(line[:sys],graph,first)
    else  
      there = node(line[:sys],graph,rest)
      rel(graph,first,here,there,props)
    end
  }
  graphs[line[:sys]] = graph
}

puts "-- systems --"
File.open("README.graph.jsonl", 'w') { |file|
  graphs.each {|sys,graph|
    puts "#{sys} has #{graph[:nodes].size} nodes, #{graph[:rels].size} relations"
    file.write("#{{name:sys,graph:graph}.to_json}\n")
  }
}

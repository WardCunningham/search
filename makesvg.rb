# Convert graph.jsonl to dot and svg files
# Usage: mkdir graphs; cat README.graph.jsonl | ruby makesvg.rb

require 'json'

puts "-- drawings --"
while line = gets
  obj = JSON.parse(line)
  sys = obj['name']
  graph = obj['graph']
  puts "#{sys} has #{graph['nodes'].size} nodes, #{graph['rels'].size} relations"

  File.open("graphs/#{sys}.dot", 'w') { |file|
    file.puts "digraph { node [shape=box style=filled fillcolor=palegreen]"
    graph['nodes'].each_with_index {|n,i|
      file.puts "#{i} [label=\"#{n['type']}\\n#{n['props']['name']}\"]"}
    graph['rels'].each {|r|
      if(r['type']=='read')
        file.puts "#{r['to']} -> #{r['from']} [label=\"#{r['type']}\" dir=back]"
      else
        file.puts "#{r['from']} -> #{r['to']} [label=\"#{r['type']}\"]"
      end
    }
    file.puts "}"
  }
  `dot -Tsvg graphs/#{sys}.dot > graphs/#{sys}.svg`
end


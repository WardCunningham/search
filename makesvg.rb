# Convert graph.jsonl to dot and svg files
# Usage: mkdir graphs; cat README.graph.jsonl | ruby makesvg.rb

require 'json'

puts "-- drawings --"

scripts = ["Ruby","Shell","Perl"]
while line = gets
  obj = JSON.parse(line)
  sys = obj['name']
  graph = obj['graph']
  puts "#{sys} has #{graph['nodes'].size} nodes, #{graph['rels'].size} relations"

  File.open("graphs/#{sys}.dot", 'w') { |file|
    file.puts "digraph { node [shape=box style=filled fillcolor=palegreen]"
    graph['nodes'].each_with_index {|n,i|
      color = if scripts.include?n['type'] then 'fillcolor=lightblue' else '' end
      file.puts "#{i} [label=\"#{n['type']}\\n#{n['props']['name']}\" #{color}]"}
    graph['rels'].each {|r|
      src = "https://github.com/WardCunningham/search/blob/master/#{r['props']['file']}"
      props = "label=\"#{r['type']}\" URL=\"#{src}#L#{r['props']['line']}\""
      if(r['type']=='read')
        file.puts "#{r['to']} -> #{r['from']} [#{props} dir=back]"
      else
        file.puts "#{r['from']} -> #{r['to']} [#{props}]"
      end
    }
    file.puts "}"
  }
  `dot -Tsvg graphs/#{sys}.dot > graphs/#{sys}.svg`
end


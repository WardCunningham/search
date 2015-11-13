require 'pp'
@tree = {}

def insert domain
	branch = @tree
	domain.split('.').reverse().each do |name|
		branch[name] ||= {}
		branch = branch[name]
	end
	branch[''] = []
end

def input
	list = `cd sites; ls | while read i; do echo \`ls $i/pages | wc -l\` $i; done 2>/dev/null`
	list.split("\n").each do |line|
		count, domain = line.split ' '
		insert domain if count.to_i >= 10
	end
end

def depth node, n=0
	all = [n]
	node.each do |key, value|
		all << depth(value, n+1)
	end
	all.max
end

def total node
	sum = 1
	node.each do |key, value|
		sum += total(value)
	end
	sum
end

def group? node
	depth(node) == 2 or total(node) < 140
end

def leaf? node
	node.empty?
end

def cite path
	puts path[0..-2].reverse().join('.')
end

def look path, node
	# puts "-------- #{path.reverse().join('.')} #{depth node} #{total node}" 
	if group? node
		puts "\n#{path.reverse().join(' ')}\n\n" 
		cite(path) if leaf?(node)
		node.sort().each do |name, more|
			show path+[name], more
		end
	else
		cite(path) if leaf?(node)
		node.sort().each do |name, more|
			look path+[name], more
		end
	end
end

def show path, node
	cite(path) if leaf?(node)
	node.sort().each do |name, more|
		show path+[name], more
	end
end

input
look [], @tree
# pp @tree
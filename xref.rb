file = 'cron.sh'
script = File.read(file).split(/\n/)
script.each_with_index do |line, index|
  if line.include? "#"
    puts "#{file} #{index} #{line}"
  end
end

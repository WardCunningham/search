require 'json'
require 'fileutils'

def asSlug title
  title.gsub(/\s/, '-').gsub(/[^A-Za-z0-9-]/, '').downcase
end

def ago date
  "#{Time.now().to_i/60/60/24 - date.to_i/1000/60/60/24} days ago"
end

def sites
  Dir.glob 'sites/*' do |each|
    path, site = each.split '/'
    begin
      sitemap = JSON.parse `curl -s http://#{site}/system/sitemap.json`
      yield site, sitemap
    rescue => e
      puts "can't do sitemap for #{site}, #{e}"
    end
  end
end

def scrape site, slug, aspect
  result = yield
  return if result.empty?
  dirname = "sites/#{site}/pages/#{slug}"
  FileUtils.mkdir_p dirname unless File.directory? dirname
  File.open "#{dirname}/#{aspect}.txt", 'w' do |file|
    result.each do |word|
      file.puts word
    end
  end
  puts "\t\t\t#{aspect} #{result.length}"
end

def update site, pageinfo
  puts "\t#{pageinfo['title']}, #{ago pageinfo['date']}"
  begin
    slug = pageinfo['slug']
    page = JSON.parse `curl -s http://#{site}/#{slug}.json`
    story = page['story'] || []
    journal = page['journal'] || []
    puts "\t\tstory #{story.length}, journal #{journal.length}"

    scrape site, slug, 'words' do
      words = []
      story.each do |item|
        next unless text = item['text']
        text.scan /[A-Za-z]+/ do |word|
          word = word.downcase
          words.push word unless words.include? word
        end
      end
      words.sort
    end

    scrape site, slug, 'links' do
      words = []
      story.each do |item|
        next unless text = item['text']
        text.scan /\[\[([^\]]+)\]\]/ do |word|
          word = asSlug word[0]
          words.push word unless words.include? word
        end
      end
      words.sort
    end

    scrape site, slug, 'sites' do
      words = []
      story.each do |item|
        if word = item['site']
          words.push word.downcase unless words.include? word.downcase
        end
        if item['type'] == 'roster'
          item['text'].scan /^(([a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+)(:\d+)?)$/ do |word|
            word = word[0].downcase
            words.push word unless words.include? word
          end
        end
      end
      journal.each do |item|
        if word = item['site']
          words.push word.downcase unless words.include? word.downcase
        end
      end
      words.sort
    end

  rescue => e
    puts "can't do update for #{pageinfo['slug']}, #{e}"
  end
end

def scraped site
  mark = "sites/#{site}/scraped"
  if File.exist? mark
    since = File.mtime(mark).to_i*1000
  else
    since = 0
  end
  FileUtils.touch mark
  since
end

sites do |site, sitemap|
  since = scraped site
  puts "#{site}, #{sitemap.length} pages, since #{ago since}"
  sitemap.each do |pageinfo|
    date = pageinfo['date'] || 1
    update site, pageinfo if date > since
  end
end
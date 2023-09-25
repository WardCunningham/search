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
      codes = {
        6 => "unknown host",
        28 => "request timeout"
      }
      text = `curl -s -m 8 -L http://#{site}/system/sitemap.json`
      raise "curl #{codes[$?.exitstatus]||$?}" if $?!=0
      raise "empty response" if text.length == 0
      if text[0] == '<'
        raise $~.captures[0] if text.match(/<title>(.+?)<\/title>/)
        raise "looks like html"
      end
      raise "not expected json" if text[0] != '['
      sitemap = JSON.parse text
      yield site, sitemap
    rescue => e
      puts "#{site}, sitemap: #{e.to_s[0..50].gsub(/\s+/,' ')}"
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
    page = JSON.parse `curl -s -L http://#{site}/#{slug}.json`
    story = page['story'] || []
    journal = page['journal'] || []
    puts "\t\tstory #{story.length}, journal #{journal.length}"

    scrape site, slug, 'words' do
      words = []
      story.each do |item|
        next unless text = item['text']
        text.gsub! /[a-zA-Z0-9\+\/]{50,}/,''
        text.gsub! /<(.|\n)*?>/, '' if item['type'] == 'html'
        text.gsub! /\[((http|https|ftp):.*?) (.*?)\]/, '\3'
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
        words.push item['slug'] if item['slug']
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
          # item['text'].scan /^ROSTER ([A-Za-z0-9.-:]+\/[a-z0-9-]+)$/ do |word|
          #   word = word[0].downcase
          #   words.push word unless words.include? word
          # end
          # item['text'].scan /^REFERENCES ([A-Za-z0-9.-:]+\/[a-z0-9-]+)$/ do |word|
          #   word = word[0].downcase
          #   words.push word unless words.include? word
          # end
        end
      end
      journal.each do |item|
        if word = item['site']
          words.push word.downcase unless words.include? word.downcase
        end
      end
      words.sort
    end

    scrape site, slug, 'items' do
      words = []
      story.each do |item|
        id = item['alias'] || item['id']
        words.push id unless words.include? id
      end
      words.sort
    end

    scrape site, slug, 'plugins' do
      words = []
      story.each do |item|
        type = item['type']
        words.push type unless words.include? type
      end
      words.sort
    end


  rescue => e
    puts "\t#{pageinfo['slug']}, update: #{e}"
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
  puts "#{site}, #{sitemap.length} pages"
  sitemap.each do |pageinfo|
    date = pageinfo['date'] || 1
    # next if pageinfo['slug'] != 'gtexplainerexamples'
    # update site, pageinfo
    update site, pageinfo if date > since
  end
end

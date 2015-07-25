require 'sinatra'
require 'json'

set :bind, '0.0.0.0'

helpers do

  def has text, words
    words.each do |word|
      unless text.match /\b#{word}\b/
        return false
      end
    end
    return true
  end

  def search text
    return '' unless text
    words = text.scan /\w+/
    result = []
    Dir.glob 'sites/*/words.txt' do |filename|
      result << filename if has(File.read(filename), words)
    end
    result = result.map do |line|
      site = line.split('/')[1]
      "<a href=//#{site} target=#{site}><img src=//#{site}/favicon.png width=16> #{site}</a>"
    end
    result.join '<br>'
  end

  def sites words
    result = []
    Dir.glob 'sites/*/words.txt' do |filename|
      result << filename.split('/')[1] if has(File.read(filename), words)
    end
    result
  end

  def pages words, sites
    result = []
    sites.each do |site|
      Dir.glob "sites/#{site}/pages/*/words.txt" do |filename|
        result << filename if has(File.read(filename), words)
      end
    end
    result
  end

  def references pages
    result = Hash.new { |hash, key| hash[key] = [] }
    pages.each do |line|
      dir, site, dir, slug, dir = line.split '/'
      result[slug] << site
    end
    result
  end

  def format references
    result = []
    references.each do |slug,sites|
      result << "<p>#{slug.gsub /-/, ' '}<br>"
      sites.each do |site|
        href = "http://#{site}/view/#{slug}"
        flag = "http://#{site}/favicon.png"
        result << "<a href='#{href}' target='#{site}'><img src='#{flag}' width=16></a> "
      end
      result << "</p>"
    end
    result.join "\n"
  end

end

get '/' do
<<EOF
  <head>
    <script src='//ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js'></script>
    <script src='/search.js'></script>
    <link id='favicon' href='/favicon.png' rel='icon' type='image/png'>
  </head>
  <body style="padding:20px;">
    <p>Search: <input class=query type=text></input>
    <input type="radio" name="query" value="/search" checked>sites</input>
    <input type="radio" name="query" value="/pages">pages</input>
    </p>
    <div id=results style="padding-top:20px;"></div>
  </body>
EOF
end

get '/search' do
  content_type 'text/json'
  puts params.inspect
  {:results => search(params[:words])}.to_json
end

get '/pages' do
  content_type 'text/json'
  words = params['words'].scan /\w+/
  begin
    html = format references pages(words, sites(words))
    {:results => html}.to_json
  rescue => e
    {:result => "Trouble: #{e}"}.to_json
  end
end

get '/recent-activity.json' do
  headers 'Access-Control-Allow-Origin' => '*'
  send_file 'activity/recent-activity.json'
end

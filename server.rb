require 'sinatra'
require 'json'

set :bind, '0.0.0.0'

helpers do

  def search text
    return '' unless text
    words = text.scan /\w+/
    found = `grep -w -e '#{words[0]}' sites/*/words.txt`
    result = []
    found.split(/\n/).each do |line|
      site = line.split('/')[1]
      result.push "<a href=//#{site} target=#{site}><img src=//#{site}/favicon.png width=16> #{site}</a>"
    end
    result.join '<br>'
  end

  def sites words
    result = 'sites/*/words.txt'
    words.each do |word|
      result = `grep -w -l -e '#{word}' #{result.gsub /\n/, ' '}`
    end
    result
  end

  def pages words, sites
    result = sites.gsub /words.txt/, 'pages/*/words.txt'
    words.each do |word|
      result = `grep -w -l -e '#{word}' #{result.gsub /\n/, ' '}`
    end
    result
  end

  def references pages
    result = Hash.new { |hash, key| hash[key] = [] }
    pages.split(/\n/).each do |line|
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

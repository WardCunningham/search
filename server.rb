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

  def search sites
    result = sites.map do |site|
      "<a href=//#{site} target=#{site} title=#{site}><img src=//#{site}/favicon.png width=16> #{site}</a>"
    end
    result.join '<br>'
  end

  def sites find, words
    result = []
    Dir.glob "sites/*/#{find}.txt" do |filename|
      result << filename.split('/')[1] if has(File.read(filename), words)
    end
    result
  end

  def pages find, words, sites
    result = []
    sites.each do |site|
      Dir.glob "sites/#{site}/pages/*/#{find}.txt" do |filename|
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
        result << "<a href='#{href}' target='#{site}' title='#{site}'><img src='#{flag}' width=16></a> "
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
    <table>
    <tr><td>find:
      <td><input type="radio" name="find" value="words" checked>words</input>
      <td><input type="radio" name="find" value="links">links</input>
      <td><input type="radio" name="find" value="sites">sites</input>
    <tr><td>within:
      <td><input type="radio" name="within" value="sites" checked>sites</input>
      <td><input type="radio" name="within" value="pages">pages</input>
    <tr><td colspan=4>
      <input class=query type=text size=40></input>
    </table>
    <div id=results style="padding-top:20px;"></div>
    <a href="http://search.fed.wiki.org/federation-search.html">help</a> |
    <a href="http://ward.asia.wiki.org/ruby-sitemap-scrape.html">about</a>
  </body>
EOF
end

get '/search' do
  content_type 'text/json'
  find = params['find']||'words'
  query = params['query'].downcase.scan /\w+/
  begin
    html = case params['within']||'sites'
      when 'sites'
        search sites(find, query)
      when 'pages'
        format references pages(find, query, sites(find, query))
      else
        "Don't yet know within: '#{params['within']}'"
    end
    {:results => html}.to_json
  rescue => e
    {:results => "Trouble: #{e}"}.to_json
  end
end

get '/recent-activity.json' do
  headers 'Access-Control-Allow-Origin' => '*'
  send_file 'activity/recent-activity.json'
end

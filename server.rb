require 'sinatra'
require 'json'
require 'date'

# Query ► Ruby:server ► serve Public:files
# Query ► Ruby:server ► serve API:Search
# Query ► Ruby:server ► serve API:Index

set :bind, '0.0.0.0'
# https://stackoverflow.com/questions/10509774/sinatra-and-rack-protection-setting
set :protection, :except => [:json_csrf]

before do
  headers 'Access-Control-Allow-Origin' => '*'
end

helpers do

  def has text, words, op='and'
    words.each do |word|
      if text.match /(^| )#{word}($| )/
        return true if op == 'or'
      else
        return false if op == 'and'
      end
    end
    return op == 'and'
  end

  def search sites
    result = sites.map do |site|
      "<a href=//#{site} target=#{site} title=#{site}><img src=//#{site}/favicon.png width=16> #{site}</a>"
    end
    result.join '<br>'
  end

  def sites find, words, op='and'
    result = []
    Dir.glob "sites/*/#{find}.txt" do |filename|
      result << filename.split('/')[1] if has(File.read(filename), words, op)
    end
    result
  end

  def pages find, words, sites, op='and'
    result = []
    sites.each do |site|
      Dir.glob "sites/#{site}/pages/*/#{find}.txt" do |filename|
        result << filename if has(File.read(filename), words, op)
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

  def selected output
    puts output
    result = Hash.new { |hash, key| hash[key] = [] }
    output.split(/\n/).each do |line|
      site, slug = line.split '|'
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

  def split find, query
    if ['plugins'].include? find
      query.scan /\w+/
    elsif ['items','slugs','links'].include? find
      query.scan /[\w-]+/
    elsif ['sites'].include? find
      query.scan /[\w\.-]+/
    else
      query.downcase.scan /\w+/
    end
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
      <td><input type="radio" name="find" data-eg="dorkbot" value="words" checked>words</input>
      <td><input type="radio" name="find" data-eg="how-to-wiki" value="links">links</input>
      <td><input type="radio" name="find" data-eg="ward.fed.wiki.org" value="sites">sites</input>
      <td><input type="radio" name="find" data-eg="chorus-of-voices" value="slugs">slugs</input>
      <td><input type="radio" name="find" data-eg="dbed99c5d3c702b1" value="items">items</input>
      <td><input type="radio" name="find" data-eg="video" value="plugins">plugins</input>
    <tr><td>match:
      <td><input type="radio" name="match" data-eg="kitchen coffee apple" value="and" checked>all</input>
      <td><input type="radio" name="match" data-eg="dorkbot hackathon"value="or">any</input>
    <tr><td>within:
      <td><input type="radio" name="within" value="sites" checked>sites</input>
      <td><input type="radio" name="within" value="pages">pages</input>
    <tr><td>search: 
      <td colspan=5><i><span id=eg></span></i>
    <tr><td colspan=6>
      <input class=query type=text size=70></input>
    </table>
    <div id=results style="padding-top:20px;"></div>
    <a href="http://search.fed.wiki.org/search-help.html">help</a> |
    <a href="http://ward.asia.wiki.org/ruby-sitemap-scrape.html">about</a>
  </body>
EOF
end

get '/search' do
  content_type 'text/json'
  find = params['find']||'words'
  match = params['match']||'and'
  query = split find, params['query']
  begin
    html = case params['within']||'sites'
      when 'sites'
        search sites(find, query, match)
      when 'pages'
        if find=='plugins' || find=='items'
          find = find.gsub(/s$/,'')
          if match == 'or'
            cond = (query.map {|value| "#{find} = \"#{value}\"" }).join(" or ")
            sql = "select distinct site,slug from pages where #{cond} limit 100"
          else
            cond = query.map {|value| "select site,slug from pages where #{find} = \"#{value}\""}
            sql = cond.join(" intersect ")
          end
          puts sql
          format selected `sqlite3 public/pages.db '#{sql}'`
        else
          format references pages(find, query, sites(find, query, match), match)
        end
      else
        "Don't yet know within: '#{params['within']}'"
    end
    {:results => html}.to_json
  rescue => e
    {:results => "Trouble: #{e}"}.to_json
  end
end

get '/sites' do
  headers 'Access-Control-Allow-Origin' => '*'
  content_type 'text/json'
  find = params['find'] || 'slugs'
  match = params['match'] || 'and'
  query = split find, params['query']
  sites(find, query, match).to_json
end

# Query ► API:Search ► read Pages:words.txt ► read Sites:words.txt
post '/match', :provides => :json do
  # http://stackoverflow.com/questions/17870680/jquery-json-post-to-a-sinatra-route-not-working-correctly
  headers 'Access-Control-Allow-Origin' => '*'
  find = params['find'] || 'words'
  match = params['match'] || 'and'
  query = split find, params['query']
  if find=='plugins' || find=='items'
    find = find.gsub(/s$/,'')
    if match == 'or'
      cond = (query.map {|value| "#{find} = \"#{value}\"" }).join(" or ")
      sql = "select distinct site,slug from pages where #{cond} limit 100"
    else
      cond = query.map {|value| "select site,slug from pages where #{find} = \"#{value}\""}
      sql = cond.join(" intersect ")
    end
    result = selected `sqlite3 public/pages.db '#{sql}'`
  else
    result = references pages(find, query, sites(find, query, match), match)
  end
  halt 200, {:params => params, :result => result}.to_json
end

get '/xref' do
  headers 'Access-Control-Allow-Origin' => '*'
  content_type 'text/plain'
  `ruby xref.rb`
end

get '/favicon.png' do
  headers 'Access-Control-Allow-Origin' => '*'
  send_file 'favicon.png'
end

get '/system/sitemap.json' do
  headers 'Access-Control-Allow-Origin' => '*'
  send_file 'activity/sitemap.json'
end

get %r{/([a-z0-9-]+)\.json} do |slug|
  headers 'Access-Control-Allow-Origin' => '*'
  send_file "pages/#{slug}"
end

get %r{/([a-z]+\.txt)} do |file|
  headers 'Access-Control-Allow-Origin' => '*'
  send_file file
end

get '/tally/plugins.txt' do
  content_type 'text/plain'
  `cat sites/*/plugins.txt | sort | uniq -c | sort -nr`
end

get '/owner/:owner' do |owner|
  content_type 'text/plain'
  headers 'Access-Control-Allow-Origin' => '*'
  `perl owner.pl #{owner}`
end

get '/links/site-web.json' do
  `cat public/site-web.json`
end

get '/links/:from/:to' do |from,to|
  content_type 'text/plain'
  `cd sites/#{from}; grep '^#{to}$' pages/*/sites.txt | cut -d / -f 2`
end

get '/logs/online' do
  content_type 'text/plain'
  `perl online.pl`
end

get '/logs/retired' do
  content_type 'text/plain'
  headers 'Access-Control-Allow-Origin' => '*'
  `ls -tr retired`
end

get '/logs/detail-sites/:site' do |site|
  `sh detail-sites.sh #{site}`
end

get '/logs/detail-retired/:site' do |site|
  `sh detail-retired.sh #{site}`
end

get '/logs' do
  content_type 'text/html'
  headers 'Access-Control-Allow-Origin' => '*'
  `ls -t logs`.gsub /([^\n]+)/, '<a href="/logs/\1.txt">\1</a><br>'
end

get '/logs/:log' do |log|
  content_type 'text/plain'
  headers 'Access-Control-Allow-Origin' => '*'
  `cat logs/#{log.gsub(/\.txt$/,'')}`
end

get %r{/view/} do
  redirect '/'
end

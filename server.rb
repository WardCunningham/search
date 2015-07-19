require 'sinatra'
require 'json'

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

get '/' do
<<EOF
  <head>
    <script src='//ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js'></script>
    <script src='/search.js'></script>
  </head>
  <body style="padding:20px;">
    Search: <input type=text></input><br>
    <div id=results style="padding-top:20px;"></div>
  </body>
EOF
end

get '/search' do
  content_type 'text/json'
  puts params.inspect
  {:results => search(params[:words])}.to_json
end
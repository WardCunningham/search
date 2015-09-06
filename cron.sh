# run incrementail scrapes
# usage: 0 */6 * * * (cd FedWiki/search; LANG="en_US.UTF-8" sh cron.sh)

mkdir activity logs sites 2>/dev/null


ruby scrape.rb > logs/`date -u +%a-%H00`


find sites -name words.txt -newer words.txt | \
	cut -d / -f 2 | \
	sort | uniq > activity/`date -u +%a-%H00`

ruby rollup.rb
tar czf public/sites.tgz sites *.txt

ruby found.rb
ruby activity.rb

ruby site-web.rb > public/site-web.json
ruby slug-web.rb > public/slug-web.json

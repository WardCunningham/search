# run incrementail scrapes
# usage: 0 */6 * * * (cd FedWiki/scrape; sh cron.sh)


ruby scrape.rb > logs/`date -u +%a-%H00`


find sites -name words.txt -newer words.txt | \
	cut -d / -f 2 | \
	sort | uniq > activity/`date -u +%a-%H00`
ruby activity.rb


ruby rollup.rb
tar czf public/sites.tgz sites *.txt
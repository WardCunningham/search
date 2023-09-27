# run incrementail scrapes
# usage: 0 */6 * * * (cd FedWiki/search; LANG="en_US.UTF-8" sh cron.sh)

mkdir -p activity logs sites
NOW=`date -u +%a-%H00`

# Index ► Shell:cron ► write Pages:words.txt ► write Pages:sites.txt
# Status ► Shell:cron ► writes Logs:Now-0000
find logs -mtime +7 -exec rm {} \;
ruby scrape.rb > logs/$NOW

# Status ► Shell:cron ► writes Activity:Now-0000
find sites -name words.txt -newer words.txt | \
	cut -d / -f 2 | \
	perl -pe 's/^www\.//' | \
	sort | uniq > activity/$NOW

# Index ► Shell:cron ► run Ruby:rollup
ruby rollup.rb

# Index ► Shell:cron ► write Search:slugs.txt ► write Sites:slugs.txt
ls sites | while read site; do ls sites/$site/pages; done | sort | uniq > slugs.txt
ls sites | \
  while read site; do
    if [ `ls sites/$site/pages | wc -l` != "0" ] ; then
       ls sites/$site/pages > sites/$site/slugs.txt
       ls sites/$site/pages | \
         while read slug; do
           printf "%s\n" "$slug" > sites/$site/pages/$slug/slugs.txt
         done
    fi
  done

# Status ► Shell:cron ► writes Public:sites.tgz
tar czf public/sites.tgz sites *.txt retired

# Status ► Shell:cron ► runs Ruby:found ► runs Ruby:activity
find activity -mtime +7 -exec rm {} \;
ruby found.rb $NOW
ruby activity.rb

# Index ► Shell:cron ► runs Ruby:site-web ► write Public:site-web.json
ruby site-web.rb > public/site-web.json
(perl -e 'print "window.sites="'; cat public/site-web.json) > public/site-web.js

# Index ► Shell:cron ► runs Ruby:slug-web ► write Public:slug-web.json
ruby slug-web.rb > public/slug-web.json
(perl -e 'print "window.slugs="'; cat public/slug-web.json) > public/slug-web.js

# ruby neo-batch.rb
# sh neo-build.sh

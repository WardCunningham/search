# report details of a site is or has been indexed
# sh details.sh site

echo '<html><pre>'
( echo
  echo DNS Lookup
  host $1

  echo
  echo Possible Scrape Date
  date -r sites/$1/scraped

  echo
  echo '<details><summary>Recent Scrape Logs</summary>'
  (cd logs; egrep "^$1," `ls -t`)
  echo '</details>'
) | perl -pe "s/$1/.../" 2>/dev/null

count=`wc -l <sites/$1/sites.txt | sed 's/ //g'`
echo "<details><summary>Indexed Site References ($count)</summary>"
cat sites/$1/sites.txt
echo '</details>'

echo '</pre></html>'

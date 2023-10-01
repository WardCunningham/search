# report details of a retired site
# sh details.sh site

echo '<html><pre>'
( echo
  echo DNS Lookup
  host $1

  echo
  echo Possible Scrape Date
  date -r retired/$1/scraped

) | perl -pe "s/$1/.../" 2>/dev/null

echo
count=`wc -l <retired/$1/sites.txt | sed 's/ //g'`
echo "<details><summary>Indexed Site References ($count)</summary>"
cat retired/$1/sites.txt
echo '</details>'

count=`wc -l <retired/$1/slugs.txt | sed 's/ //g'`
echo "<details><summary>Indexed Page Slugs ($count)</summary>"
cat retired/$1/slugs.txt
echo '</details>'

echo '</pre></html>'

# report details of a site is or has been indexed
# sh details.sh site

( echo
  echo DNS Lookup
  host $1

  echo
  echo Possible Scrape Dates
  ls -l sites/$1/scraped
  ls -l retired/$1/scraped

  echo
  echo Recent Scrape Logs
  (cd logs; egrep "^$1," `ls -t`)
) | perl -pe "s/$1/.../" 2>/dev/null

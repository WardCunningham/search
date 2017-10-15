# examine logs for sites that have been consistently absent for all week
# ussage: l=`sh sites-absent.sh`; (cd sites; mv $l ../retired)

cat logs/* | grep ', sitemap: ' | sort | uniq -c | egrep '^  28 ' | cut -d , -f 1 | cut -d ' ' -f 4

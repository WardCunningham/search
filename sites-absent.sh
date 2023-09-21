# examine logs for sites that have been consistently absent for all week
# usage: l=`sh sites-absent.sh`; (cd sites; mv $l ../retired)
# usage: sh sites-absent.sh | while read l; do echo $l; mv sites/$l retired; done

cat logs/* | grep ', sitemap: ' | sort | uniq -c | egrep '^  28 ' | cut -d , -f 1 | cut -d ' ' -f 4

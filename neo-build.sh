# build neo4j db on remote server
# usage: sh neo-build.sh

server='root@bay.wiki.org'
path='/var/lib/neo4j/data'

scp public/{nodes,rels}.csv $server:$path

build="
date
cd $path
rm -rf new.db
neo4j-import --into new.db --nodes nodes.csv --relationships rels.csv
chmod -R a+w new.db
mv wiki.db old.db
mv new.db wiki.db
service neo4j-service restart
"
ssh $server "$build" >public/neo-build.log

# report sites online as of last scan
# usage: perl online.pl, http://search.fed.wiki.org:3030/logs/online

$latest = `ls -t logs | head -1`;
$pages = 0;
chomp $latest;
open (LOG, "logs/$latest");
foreach $_ (<LOG>) {
	if (/^(.+?), (\d+) pages/) {
		next if $2 == 0;
		print "$2\t$1\n";
		$pages += $2;
	}
}
print "# Online and non-empty from $latest for $pages total pages.\n"

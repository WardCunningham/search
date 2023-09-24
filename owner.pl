# Report site owner as encoded into initial html download
# Usage: perl owner.pl $site

my $site = $ARGV[0];
my $html = `curl -s -L $site`;
print "$1\n" if $html =~ /ownerName = '(.*?)';/;

# list sites reporting pages, even zero, in recent logs

cat logs/* | grep pages | sort | uniq

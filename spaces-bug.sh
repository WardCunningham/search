# Report sites with unexpected spaces in a title.
# Usage: cd search; sh spaces-bug.sh

cat slugs.txt| egrep '(^-)|(-$)' |
  while read s; do
    echo; echo $s
    egrep "^$s\$" sites/*/slugs.txt
  done > public/spaces-bug.txt
echo done

#!/bin/sh

# From: https://askubuntu.com/questions/889344/command-to-perform-a-recursive-chmod-to-make-all-sh-files-within-a-directory-ex
# Adds execute rights to every .sh file under this
chxmod(){ LC_ALL=C find -O2 ./ -type f -regex ".*\.\(sh\|zsh\|bash\|fish\|dash\)" -exec chmod +x {} \;

# ? Easier with grep and echo than sed. $1 line | $2 file
appendabsent(){ LC_ALL=C grep -xqF -- "$1" "$2" || echo "$1" >>"$2"; }

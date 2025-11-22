#!/bin/sh
#
# summary: a simple posix script for web searching
# repository: https://github.com/hollowillow/scripts
#
# usage: s [+engine] arg
# default engines: 
#
#       +d      DuckDuckGo (default)
#       +g      Google
#       +aw     Arch Wiki
#       +gw     Gentoo Wiki
#       +gh     GitHub
#       +np     NixOS Packages
#       +no     NisOS Options
#       +pdb    ProtonDB
#       +sdb    SteamDB
#       +y      YouTube
#       +drpg   DriveThruRPG
#
# dependencies: fzf

BROWSER="${BROWSER:-firefox}"
SEARCH_HIST_FILE="${XDG_STATE_HOME:-$HOME/.local/share}/search_history"
touch "$SEARCH_HIST_FILE"

if [ "$1" = "-h" ]; then
        sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"; exit 0
fi

QUERY="$(\
        tac "$SEARCH_HIST_FILE" |
        fzf \
        --prompt 'search: ' \
        --header="$(printf '%s\n' 'enter:print-query ctrl-o:open-from-history' "$FZF_DEFAULT_HEADER")" \
        --delimiter '|' --accept-nth="2" \
        --bind='enter:print-query' \
        --bind='ctrl-o:become:nohup $BROWSER {1}{2} >/dev/null 2>&1 &' \
        --query="$*"\
)"

case "$QUERY" in
        # common search engines
        +d\ *) ENGINE="duckduckgo.com/&q=";QUERY="$(printf '%s' "$QUERY" | sed "s/+d\ //")";;
        +g\ *) ENGINE="google.com/search?q=";QUERY="$(printf '%s\n' "$QUERY" | sed "s/+g\ //")";;
        # tech related
        +aw\ *) ENGINE="wiki.archlinux.org/index.php?search=";QUERY="$(printf '%s\n' "$QUERY" | sed "s/+aw\ //")";;
        +gw\ *) ENGINE="wiki.gentoo.org/index.php?title=search&search=";QUERY="$(printf '%s\n' "$QUERY" | sed "s/+gw\ //")";;
        +gh\ *) ENGINE="github.com/search?q=";QUERY="$(printf '%s\n' "$QUERY" | sed "s/+gh\ //")";;
        +np\ *) ENGINE="search.nixos.org/packages?channel=unstable&query=";QUERY="$(printf '%s\n' "$QUERY" | sed "s/+np\ //")";;
        +no\ *) ENGINE="search.nixos.org/options?channel=unstable&query=";QUERY="$(printf '%s\n' "$QUERY" | sed "s/+no\ //")";;
        +pdb\ *) ENGINE="www.protondb.com/search?q=";QUERY="$(printf '%s\n' "$QUERY" | sed "s/+pdb\ //")";;
        +sdb\ *) ENGINE="steamdb.info/search/?a=all&q=";QUERY="$(printf '%s\n' "$QUERY" | sed "s/+sdb\ //")";;
        # specific websites
        +y\ *) ENGINE="youtube.com/results?search_query=";QUERY="$(printf '%s\n' "$QUERY" | sed "s/+y\ //")";;
        +drpg\ *) ENGINE="drivethrurpg.com/en/browse?keyword=";QUERY="$(printf '%s\n' "$QUERY" | sed "s/+drpg\ //")";;
        # default
        *) ENGINE="duckduckgo.com/&q=";;
esac

if [ -n "$QUERY" ]; then
        printf '%s\n' "$ENGINE|$QUERY|$(date "+%y/%m/%d-%H:%M:%S")" >> "$SEARCH_HIST_FILE";
        nohup "$BROWSER" "$ENGINE$QUERY" >/dev/null 2>&1 &
else
        printf '%s\n' "No query!"; exit 1
fi

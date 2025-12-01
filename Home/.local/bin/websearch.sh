#!/usr/bin/env bash
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
set -euo pipefail

readonly BROWSER="${BROWSER:-firefox}"
readonly SEARCH_HIST_FILE="${XDG_STATE_HOME:-$HOME/.local/share}/search_history"
touch "$SEARCH_HIST_FILE"

if [[ ${1:-} == "-h" ]]; then
  sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"
  exit 0
fi

query=$(
  tac "$SEARCH_HIST_FILE" \
    | fzf \
      --prompt 'search: ' \
      --header="$(printf '%s\n' 'enter:print-query ctrl-o:open-from-history' "${FZF_DEFAULT_HEADER:-}")" \
      --delimiter '|' --with-nth="2" \
      --bind='enter:print-query' \
      --bind="ctrl-o:become:nohup $BROWSER {1}{2} &>/dev/null &" \
      --query="$*"
) || exit 0

engine="duckduckgo.com/&q="
case "$query" in
  # common search engines
  +d\ *)
    engine="duckduckgo.com/&q="
    query="${query#+d }"
    ;;
  +g\ *)
    engine="google.com/search?q="
    query="${query#+g }"
    ;;
  # tech related
  +aw\ *)
    engine="wiki.archlinux.org/index.php?search="
    query="${query#+aw }"
    ;;
  +gw\ *)
    engine="wiki.gentoo.org/index.php?title=search&search="
    query="${query#+gw }"
    ;;
  +gh\ *)
    engine="github.com/search?q="
    query="${query#+gh }"
    ;;
  +np\ *)
    engine="search.nixos.org/packages?channel=unstable&query="
    query="${query#+np }"
    ;;
  +no\ *)
    engine="search.nixos.org/options?channel=unstable&query="
    query="${query#+no }"
    ;;
  +pdb\ *)
    engine="www.protondb.com/search?q="
    query="${query#+pdb }"
    ;;
  +sdb\ *)
    engine="steamdb.info/search/?a=all&q="
    query="${query#+sdb }"
    ;;
  # specific websites
  +y\ *)
    engine="youtube.com/results?search_query="
    query="${query#+y }"
    ;;
  +drpg\ *)
    engine="drivethrurpg.com/en/browse?keyword="
    query="${query#+drpg }"
    ;;
esac

if [[ -n $query ]]; then
  printf '%s\n' "$engine|$query|$(date "+%y/%m/%d-%H:%M:%S")" >>"$SEARCH_HIST_FILE"
  nohup "$BROWSER" "${engine}${query}" &>/dev/null &
else
  printf '%s\n' "No query!" >&2
  exit 1
fi

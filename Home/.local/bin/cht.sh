#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'; export LC_ALL=C LANG=C

has(){ command -v "$1" &>/dev/null; }
die(){ printf 'Error: %s\n' "$*" >&2; exit 1; }
# Tool detection
for c in curl wget2 wget; do has "$c" && HTTP="$c" && break; done
[[ -z ${HTTP:-} ]] && die "curl/wget required"
for f in sk fzf; do has "$f" && FZF="$f" && break; done
[[ -z ${FZF:-} ]] && die "sk/fzf required"
get(){
  case "$HTTP" in
  curl) curl -fsL "$@" ;;
  wget*) "$HTTP" -qO- "$@" ;;
  esac
}
readonly CHT_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/cht_list"
readonly CHT_URL="cheat.sh"
cache(){
  [[ -f $CHT_CACHE && -n "$(find "$CHT_CACHE" -mtime -7 2>/dev/null)" ]] && return 0
  mkdir -p "${CHT_CACHE%/*}"
  get "${CHT_URL}/:list" >"$CHT_CACHE" || die "Failed to fetch list"
}
browse(){
  local sel q qlist url
  cache
  sel=$("$FZF" --ansi --reverse --cycle --prompt='cht> ' \
    --preview="curl -fsL ${CHT_URL}/{} 2>/dev/null | head -50" \
    --preview-window=right:70% <"$CHT_CACHE") || return 1
  qlist=$(get "${CHT_URL}/${sel}/:list" 2>/dev/null || :)
  if [[ -n $qlist ]]; then
    q=$(printf '%s' "$qlist" | "$FZF" --print-query --ansi --reverse \
      --prompt="cht/${sel}> " \
      --preview="curl -fsL ${CHT_URL}/${sel}/{1} 2>/dev/null || curl -fsL ${CHT_URL}/${sel}/{q} 2>/dev/null" \
      --preview-window=right:70% | tail -1)
  else
    read -rp "Query [${sel}]: " q
  fi
  q="${q// /+}"
  url="${CHT_URL}/${sel}${q:+/${q}}"
  printf '\n→ %s\n\n' "$url"
  get "$url"
}
query(){
  local lang="${1:-}" topic="${2:-}" flags="" url
  [[ -z $lang ]] && die "Language/topic required"
  [[ ${search:-0} -eq 1 ]] && lang="~${lang}" && topic="~${topic}"
  url="${CHT_URL}/${lang}${topic:+/${topic}}"
  [[ -n ${insens:-} ]] && flags+="i"
  [[ -n ${bound:-} ]] && flags+="b"
  [[ -n ${recur:-} ]] && flags+="r"
  [[ -n $flags ]] && url+="/${flags}"
  get "$url"
}

usage(){
  cat <<'EOF'
cht - cheat.sh TUI with fuzzy search

USAGE:
  cht [-sibr] [lang] [topic]
  cht             Interactive browser
  cht -u          Update cache

FLAGS:
  -s  Search mode (~)
  -i  Case insensitive
  -b  Word boundary
  -r  Recursive
  -u  Update cache
  -h  Help

EXAMPLES:
  cht               # Interactive mode
  cht python        # Browse Python sheets
  cht -s bash array # Search bash arrays
  cht rust Vec      # Show Rust Vec docs
EOF
}

search=0 insens="" bound="" recur=""
while getopts "sibruha" o; do
  case "$o" in
  s) search=1 ;;
  i)
    insens=1
    search=1
    ;;
  b)
    bound=1
    search=1
    ;;
  r)
    recur=1
    search=1
    ;;
  u)
    rm -f "$CHT_CACHE"
    cache
    printf '✓ Cache updated\n'
    exit 0
    ;;
  h | *)
    usage
    exit 0
    ;;
  esac
done
shift $((OPTIND - 1))
[[ $# -eq 0 ]] && browse || query "$@"

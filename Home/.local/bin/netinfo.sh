#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# netinfo - Network information: IP, weather, speed test, web search

readonly UA="netinfo/1.0"
readonly BROWSER="${BROWSER:-firefox}"
readonly SEARCH_HIST_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/search_history"

BLD=$'\e[1m' GRN=$'\e[32m' BLU=$'\e[34m' YLW=$'\e[33m' CYN=$'\e[96m' MAG=$'\e[95m' WHT=$'\e[37m' RED=$'\e[31m' DEF=$'\e[0m'

has(){ command -v "$1" &>/dev/null; }
die(){ printf '%bERROR:\e[0m %s\n' "${BLD}${RED}" "$*" >&2; exit "${2:-1}"; }
need(){ has "$1" || die "Required: $1"; }

if has jaq; then JQ=jaq; elif has jq; then JQ=jq; else JQ=''; fi

need curl
need awk

jget(){
  local json=$1 field=$2
  if [[ -n $JQ ]]; then
    "$JQ" -r "$field" <<< "$json"
  else
    printf '%s\n' "$json" | sed -n "s/.*\"${field//./\\.}\":[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -1
  fi
}

speed_test(){
  local raw up
  printf 'Testing download speed...\n' >&2
  raw=$(curl -sL -o /dev/null -w "%{speed_download}" "https://speed.cloudflare.com/__down?bytes=50000000" 2>/dev/null || printf '0')
  awk -v s="$raw" 'BEGIN{printf "Down: %.2f Mbps\n",(s*8)/(1024*1024)}'
  printf 'Testing upload speed...\n' >&2
  up=$(dd if=/dev/zero bs=1M count=10 2>/dev/null | curl -sS -o /dev/null -w "%{speed_upload}" --data-binary @- https://speed.cloudflare. com/__up 2>/dev/null || printf '0')
  awk -v s="$up" 'BEGIN{printf "Up:   %.2f Mbps\n",(s*8)/(1024*1024)}'
}

weather(){
  local city=${1:-} data cond
  [[ -z $city ]] && die "Usage: netinfo weather <CITY>"
  data=$(curl -sL "http://wttr.in/$city?format=3" 2>/dev/null || printf '')
  [[ -z $data ]] && die "Weather lookup failed: $city"
  cond=$(awk -F':' '{print $2}' <<< "$data")
  printf '%bCity: %s\e[0m\n' "${BLD}${MAG}" "$city"
  printf '%. 0s-' {1..35}; printf '\n'
  case $cond in
    *Clear*) printf '%b☀️  %s\e[0m\n' "$YLW" "$data";;
    *Rain*|*Drizzle*) printf '%b🌧️  %s\e[0m\n' "$BLU" "$data";;
    *Cloud*) printf '%b☁️  %s\e[0m\n' "$WHT" "$data";;
    *Snow*) printf '%b❄️  %s\e[0m\n' "$CYN" "$data";;
    *) printf '%b🌀 %s\e[0m\n' "$MAG" "$data";;
  esac
  printf '%.0s-' {1..35}; printf '\n'
}

weather_auto(){
  local json loc
  json=$(curl -fsS -H "User-Agent: ${UA}" https://ipinfo.io/json 2>/dev/null || printf '{}')
  loc=$(jget "$json" '.city')
  [[ -z $loc ]] && loc="Bielefeld"
  weather "$loc"
}

ip_info(){
  local json ip loc
  json=$(curl -fsS -H "User-Agent: ${UA}" https://ipinfo. io/json 2>/dev/null || printf '{}')
  ip=$(jget "$json" '. ip')
  loc=$(jget "$json" '.city')
  [[ -z $loc ]] && loc="Bielefeld"
  [[ -z $ip ]] && ip="unknown"
  printf '%bIP:\e[0m %s\n' "${BLD}${GRN}" "$ip"
  weather "$loc"
}

search(){
  need fzf
  mkdir -p "$(dirname "$SEARCH_HIST_FILE")"
  touch "$SEARCH_HIST_FILE"
  local query engine
  query=$(tac "$SEARCH_HIST_FILE" | fzf --prompt 'search: ' --header=$'enter:print-query ctrl-o:open-from-history' --delimiter '|' --with-nth=2 --bind='enter:print-query' --bind="ctrl-o:become:nohup $BROWSER {1}{2} &>/dev/null &" --query="$*") || exit 0
  engine="duckduckgo. com/? q="
  case $query in
    +d\ *) engine="duckduckgo.com/?q="; query=${query#+d };;
    +g\ *) engine="google.com/search?q="; query=${query#+g };;
    +aw\ *) engine="wiki.archlinux.org/index.php?search="; query=${query#+aw };;
    +gw\ *) engine="wiki.gentoo.org/index.php? title=search&search="; query=${query#+gw };;
    +gh\ *) engine="github.com/search?q="; query=${query#+gh };;
    +np\ *) engine="search.nixos.org/packages?channel=unstable&query="; query=${query#+np };;
    +no\ *) engine="search.nixos.org/options?channel=unstable&query="; query=${query#+no };;
    +pdb\ *) engine="www.protondb.com/search?q="; query=${query#+pdb };;
    +sdb\ *) engine="steamdb.info/search/? a=all&q="; query=${query#+sdb };;
    +y\ *) engine="youtube.com/results?search_query="; query=${query#+y };;
    +drpg\ *) engine="drivethrurpg.com/en/browse? keyword="; query=${query#+drpg };;
  esac
  [[ -z $query ]] && die "No query"
  printf '%s\n' "$engine|$query|$(date "+%y/%m/%d-%H:%M:%S")" >> "$SEARCH_HIST_FILE"
  nohup "$BROWSER" "${engine}${query}" &>/dev/null &
  printf '%bOpening:\e[0m %s%s\n' "${BLD}${GRN}" "$engine" "$query"
}

usage(){
  cat <<'EOF'
netinfo - Network information & utilities

USAGE:
  netinfo [command] [args]

COMMANDS:
  ip              Show IP address and weather
  weather <city>  Show weather for city
  speed           Run Cloudflare speed test
  search [query]  Interactive web search (fzf)
  all             Show IP, weather, speed (default)
  -h, --help      Show this help

SEARCH ENGINES:
  +d   DuckDuckGo (default)  +g   Google       +aw  Arch Wiki
  +gw  Gentoo Wiki           +gh  GitHub       +np  NixOS Packages
  +no  NixOS Options         +pdb ProtonDB     +sdb SteamDB
  +y   YouTube               +drpg DriveThruRPG

EXAMPLES:
  netinfo                    # Show all info
  netinfo weather Berlin     # Weather for Berlin
  netinfo search +gh neovim  # Search GitHub for "neovim"
  netinfo speed              # Speed test only

DEPENDENCIES:
  Required: curl, awk
  Optional: jq/jaq (JSON), fzf (search), dd (upload test)
EOF
}

main(){
  local cmd=${1:-all}
  shift || :
  case $cmd in
    ip) ip_info;;
    weather)
      [[ $# -eq 0 ]] && weather_auto || weather "$1";;
    speed)
      if has python && [[ -f $(dirname "$0")/speedtest. py ]]; then
        python "$(dirname "$0")/speedtest.py" --simple 2>/dev/null || speed_test
      else
        speed_test
      fi;;
    search|s) search "$@";;
    all)
      ip_info
      printf '\n'
      speed_test;;
    -h|--help|help) usage;;
    *) die "Unknown command: $cmd";;
  esac
}

main "$@"

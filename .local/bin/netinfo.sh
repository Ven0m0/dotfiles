#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob
IFS=$'\n\t'; export LC_ALL=C LANG=C

# netinfo: IP, weather, speed
# deps: curl (req) awk (speed fmt) dd (upload test) jq (optional), python speedtest.py (optional faster alt)
UA="netinfo/1.0"
CURL=${CURL:-curl}
WT_FMT="%l: %c %+t\n"

have(){ command -v "$1" &>/dev/null; }
jget(){ # jq wrapper if available else grep fallback
  if have jq; then jq -r "$2" <<<"$1"; else
    # naive extraction for simple fields
    printf '%s\n' "$1" | sed -n "s/.*\"${2//./\\.}\":[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -1
  fi
}

speed_test(){
  # Download
  local down raw up
  raw=$($CURL -sS -o /dev/null -w "%{speed_download}" -L "https://speed.cloudflare.com/__down?bytes=50000000") || raw=0
  awk -v s="$raw" 'BEGIN{printf "Down: %.2f Mbps\n",(s*8)/(1024*1024)}'
  # Upload (10 MiB)
  up=$(dd if=/dev/zero bs=1M count=10 2>/dev/null | \
    $CURL -sS -o /dev/null -w "%{speed_upload}" --data-binary @- https://speed.cloudflare.com/__up || printf 0)
  awk -v s="$up" 'BEGIN{printf "Up:   %.2f Mbps\n",(s*8)/(1024*1024)}'
}

weather(){
  local loc="$1"
  $CURL -fsS "https://wttr.in/${loc}?0" || printf 'Weather lookup failed\n' >&2
}

ip_info(){
  local json loc ip
  json=$($CURL -fsS -H "User-Agent: $UA" https://ipinfo.io/json || :)
  ip=$(jget "$json" '.ip')
  loc=$(jget "$json" '.region')
  [[ -z "$loc" ]] && loc="Bielefeld"
  printf "IP: %s\n" "${ip:-unknown}"
  weather "$loc"
}

usage(){
  printf 'netinfo usage:\n'
  printf '  ip        Show IP + weather\n'
  printf '  weather   Show weather (region arg opt)\n'
  printf '  speed     Run speed test (simple CF method)\n'
  printf '  all       IP+weather+speed\n'
  exit 0
}

main(){
  local cmd="${1:-all}"; shift || :
  case "$cmd" in
    ip) ip_info ;;
    weather) weather "${1:-Bielefeld}" ;;
    speed)
      if have python && [[ -f "$(dirname "$0")/speedtest.py" ]]; then
        python "$(dirname "$0")/speedtest.py" --simple || speed_test
      else
        speed_test
      fi
      ;;
    all) ip_info; speed_test ;;
    -h|--help|help) usage ;;
    *) printf 'Unknown cmd: %s\n' "$cmd"; usage ;;
  esac
}

main "$@"

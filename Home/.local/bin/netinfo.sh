#!/usr/bin/env bash
# netinfo - Network information: IP, weather, speed test

set -euo pipefail
IFS=$'\n\t'

readonly UA="netinfo/1.0"

# Helper functions
has(){ command -v "$1" &>/dev/null; }
die(){ printf 'ERROR: %s\n' "$*" >&2; exit "${2:-1}"; }
need(){ has "$1" || die "Required command not found: $1"; }

# Tool detection (jq fallback chain: jaq → jq)
if has jaq; then JQ=jaq; elif has jq; then JQ=jq; else JQ=''; fi

# Check dependencies
need curl
need awk

# JSON getter with jq fallback
jget(){
  local json="$1" field="$2"
  if [[ -n $JQ ]]; then
    "$JQ" -r "$field" <<< "$json"
  else
    # Naive extraction for simple fields
    printf '%s\n' "$json" | sed -n "s/.*\"${field//./\\.}\":[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -1
  fi
}

speed_test(){
  local raw up

  printf 'Testing download speed...\n' >&2
  raw=$(curl -sL -o /dev/null -w "%{speed_download}" "https://speed.cloudflare.com/__down?bytes=50000000" 2> /dev/null || printf '0')
  awk -v s="$raw" 'BEGIN{printf "Down: %.2f Mbps\n",(s*8)/(1024*1024)}'

  printf 'Testing upload speed...\n' >&2
  up=$(dd if=/dev/zero bs=1M count=10 2> /dev/null \
    | curl -sS -o /dev/null -w "%{speed_upload}" --data-binary @- https://speed.cloudflare.com/__up 2> /dev/null || printf '0')
  awk -v s="$up" 'BEGIN{printf "Up:   %.2f Mbps\n",(s*8)/(1024*1024)}'
}

weather(){
  local location="${1:-}"
  [[ -z $location ]] && location="Bielefeld"

  curl -sf "https://wttr.in/${location}?0" || {
    printf 'Weather lookup failed for: %s\n' "$location" >&2
    return 1
  }
}

ip_info(){
  local json ip loc

  json=$(curl -fsS -H "User-Agent: ${UA}" https://ipinfo.io/json 2> /dev/null || printf '{}')
  ip=$(jget "$json" '.ip')
  loc=$(jget "$json" '.region')

  [[ -z $loc ]] && loc="Bielefeld"
  [[ -z $ip ]] && ip="unknown"

  printf 'IP: %s\n' "$ip"
  weather "$loc"
}

usage(){
  cat << 'EOF'
netinfo - Network information tool

USAGE:
  netinfo [command] [args]

COMMANDS:
  ip        Show IP address and weather
  weather   Show weather (optional: region name)
  speed     Run speed test (Cloudflare method)
  all       Show IP, weather, and speed test (default)
  -h, --help  Show this help

EXAMPLES:
  netinfo              # Show all information
  netinfo ip           # Show IP and weather
  netinfo weather Berlin  # Show weather for Berlin
  netinfo speed        # Run speed test only

DEPENDENCIES:
  Required: curl, awk
  Optional: jq (for better JSON parsing), dd (for upload test)
EOF
}

main(){
  local cmd="${1:-all}"
  shift || :

  case "$cmd" in
    ip)
      ip_info
      ;;
    weather)
      weather "${1:-Bielefeld}"
      ;;
    speed)
      # Use speedtest.py if available, otherwise fallback
      if has python && [[ -f "$(dirname "$0")/speedtest.py" ]]; then
        python "$(dirname "$0")/speedtest.py" --simple 2> /dev/null || speed_test
      else
        speed_test
      fi
      ;;
    all)
      ip_info
      printf '\n'
      speed_test
      ;;
    -h | --help | help)
      usage
      ;;
    *)
      printf 'Unknown command: %s\n' "$cmd" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"

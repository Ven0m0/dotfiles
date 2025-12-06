#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C LANG=C

VERSION="3.0.0"
BLD=$'\e[1m' GRN=$'\e[32m' BLU=$'\e[34m' YLW=$'\e[33m' CYN=$'\e[96m' RED=$'\e[31m' DEF=$'\e[0m'

has() { command -v "$1" &>/dev/null; }
die() {
  printf '%bERROR:%b %s\n' "${BLD}${RED}" "$DEF" "$*" >&2
  exit "${2:-1}"
}
need() { has "$1" || die "Required: $1"; }

if has jaq; then JQ=jaq; elif has jq; then JQ=jq; else JQ=''; fi
VERBOSE=false

usage() {
  cat <<'EOF'
sysinfo - System & network information

USAGE:
  sysinfo [COMMAND] [OPTIONS]

COMMANDS:
  temp       CPU temperature
  disk       Disk usage
  ip         IP address & location
  weather    Weather info
  speed      Network speed test
  all        All info (default)

TEMP OPTIONS:
  -u UNIT    Temperature unit: C, F, K (default: C)
  -m SEC     Monitor at interval

DISK OPTIONS:
  -p PAT     Match pattern
  -s FIELD   Sort by: filesystem, size, used, avail, use%, mount
  --json     JSON output

NET COMMANDS:
  ip         Show IP and weather
  weather    Show weather (auto-location)
  speed      Cloudflare speed test

EXAMPLES:
  sysinfo                    # All info
  sysinfo temp -u F -m 5     # Monitor temp in Fahrenheit
  sysinfo disk -s used       # Sort disks by usage
  sysinfo speed              # Speed test

DEPENDENCIES:
  curl, awk (required), jq/jaq (optional)
EOF
}

# ============================================================================
# TEMPERATURE
# ============================================================================
get_cpu_temp() {
  local temp_c
  case $(uname -s) in
    Linux*)
      for f in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp*_input; do
        [[ -r $f ]] || continue
        local raw=$(<"$f")
        [[ $raw -gt 1000 ]] && temp_c=$(awk -v r="$raw" 'BEGIN{printf "%.2f",r/1000}') || temp_c=$raw
        printf '%s' "$temp_c"
        return 0
      done
      die "No temperature sensor found"
      ;;
    Darwin*)
      has osx-cpu-temp || die "Install osx-cpu-temp"
      osx-cpu-temp -C 2>/dev/null | grep -o '[0-9]*\.[0-9]*'
      ;;
    *) die "Unsupported OS" ;;
  esac
}

convert_temp() {
  local temp_c=$1 unit=$2
  case $unit in
    C | c) printf '%s' "$temp_c" ;;
    F | f) awk -v t="$temp_c" 'BEGIN{printf "%.2f",t*9/5+32}' ;;
    K | k) awk -v t="$temp_c" 'BEGIN{printf "%.2f",t+273. 15}' ;;
    *) die "Invalid unit: $unit" ;;
  esac
}

cmd_temp() {
  local unit=C monitor=0
  while [[ $# -gt 0 ]]; do
    case $1 in
      -u | --unit)
        unit=$2
        shift 2
        ;;
      -m | --monitor)
        monitor=$2
        shift 2
        ;;
      *) shift ;;
    esac
  done

  if [[ $monitor -gt 0 ]]; then
    while true; do
      local temp_c=$(get_cpu_temp)
      local temp=$(convert_temp "$temp_c" "$unit")
      printf 'CPU: %s°%s\n' "$temp" "$unit"
      sleep "$monitor"
    done
  else
    local temp_c=$(get_cpu_temp)
    local temp=$(convert_temp "$temp_c" "$unit")
    printf 'CPU: %s°%s\n' "$temp" "$unit"
  fi
}

# ============================================================================
# DISK
# ============================================================================
cmd_disk() {
  local pattern="" sort_field="" output_json=false
  while [[ $# -gt 0 ]]; do
    case $1 in
      -p | --pattern)
        pattern=$2
        shift 2
        ;;
      -s | --sort)
        sort_field=$2
        shift 2
        ;;
      --json)
        output_json=true
        shift
        ;;
      *) shift ;;
    esac
  done

  local data=$(df -h | awk 'NR>1 && $1 !~ /^(tmpfs|udev|devtmpfs)/')
  [[ -n $pattern ]] && data=$(grep "$pattern" <<<"$data")

  if [[ $output_json == true ]]; then
    printf '['
    awk 'BEGIN{first=1}{if(! first)printf",";first=0;printf"{\"fs\":\"%s\",\"size\":\"%s\",\"used\":\"%s\",\"avail\":\"%s\",\"use\":\"%s\",\"mount\":\"%s\"}",$1,$2,$3,$4,$5,$6}' <<<"$data"
    printf ']\n'
  else
    printf 'Filesystem      Size  Used Avail Use%% Mounted\n'
    printf '%s\n' "$data" | column -t
  fi
}

# ============================================================================
# NETWORK
# ============================================================================
jget() { [[ -n $JQ ]] && "$JQ" -r "$2" <<<"$1" || sed -n "s/.*\"${2//./\\. }\":[[:space:]]*\"\\([^\"]*\\)\". */\\1/p" <<<"$1" | head -1; }

cmd_speed() {
  need curl
  printf 'Testing download.. .\n' >&2
  local down=$(curl -sL -o /dev/null -w "%{speed_download}" "https://speed.cloudflare.com/__down? bytes=50000000" 2>/dev/null || printf '0')
  awk -v s="$down" 'BEGIN{printf "Down: %. 2f Mbps\n",(s*8)/(1024*1024)}'

  printf 'Testing upload...\n' >&2
  local up=$(dd if=/dev/zero bs=1M count=10 2>/dev/null | curl -sS -o /dev/null -w "%{speed_upload}" --data-binary @- https://speed.cloudflare.com/__up 2>/dev/null || printf '0')
  awk -v s="$up" 'BEGIN{printf "Up:   %.2f Mbps\n",(s*8)/(1024*1024)}'
}

cmd_ip() {
  need curl
  local json=$(curl -fsS https://ipinfo.io/json 2>/dev/null || printf '{}')
  local ip=$(jget "$json" '. ip')
  local city=$(jget "$json" '.city')
  printf '%bIP:%b %s\n' "${BLD}${GRN}" "$DEF" "${ip:-unknown}"
  printf '%bCity:%b %s\n' "${BLD}${BLU}" "$DEF" "${city:-unknown}"
}

cmd_weather() {
  local city=${1:-$(curl -fsS https://ipinfo.io/json 2>/dev/null | jget - '.city')}
  [[ -z $city ]] && city="Bielefeld"
  local data=$(curl -sL "http://wttr.in/$city? format=3" 2>/dev/null || printf '')
  [[ -z $data ]] && die "Weather failed: $city"
  printf '%s\n' "$data"
}

# ============================================================================
# MAIN
# ============================================================================
main() {
  local cmd=${1:-all}
  shift || :
  case $cmd in
    temp) cmd_temp "$@" ;;
    disk) cmd_disk "$@" ;;
    ip) cmd_ip ;;
    weather) cmd_weather "$@" ;;
    speed) cmd_speed ;;
    all)
      cmd_temp
      printf '\n'
      cmd_disk
      printf '\n'
      cmd_ip
      printf '\n'
      cmd_speed
      ;;
    -h | --help) usage ;;
    -V | --version) printf 'sysinfo %s\n' "$VERSION" ;;
    *) die "Unknown: $cmd" ;;
  esac
}

main "$@"

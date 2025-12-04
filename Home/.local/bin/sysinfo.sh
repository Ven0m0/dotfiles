#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
IFS=$'\n\t'

# sysinfo - System information: CPU temperature and disk usage
# Usage: sysinfo [COMMAND] [OPTIONS]

VERSION="2.0.0"
BLD=$'\e[1m' GRN=$'\e[32m' BLU=$'\e[34m' YLW=$'\e[33m' RED=$'\e[31m' DEF=$'\e[0m'

has(){ command -v "$1" &>/dev/null; }
die(){ printf '%bERROR:\e[0m %s\n' "${BLD}${RED}" "$*" >&2; exit "${2:-1}"; }
log_msg(){ [[ $VERBOSE == true ]] && printf '%s\n' "$*"; }
log_action(){ [[ $LOG_ENABLED == true ]] && printf '%s: %s\n' "$(date +"%Y-%m-%d %T")" "$*" >> "$LOG_FILE"; log_msg "$*"; }

VERBOSE=false LOG_ENABLED=false LOG_FILE="" OUTPUT_FILE=""

convert_temp(){
  local temp_c=$1 unit=$2 result
  case $unit in
    C|c) result=$temp_c;;
    F|f) result=$(awk -v t="$temp_c" 'BEGIN{printf "%.2f",t*9/5+32}');;
    K|k) result=$(awk -v t="$temp_c" 'BEGIN{printf "%.2f",t+273.15}');;
    *) die "Invalid unit: $unit";;
  esac
  printf '%s' "$result"
}

get_linux_temp(){
  local paths=(/sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp*_input)
  for f in "${paths[@]}"; do
    [[ -r $f ]] || continue
    local raw temp_c
    raw=$(<"$f")
    [[ $raw -gt 1000 ]] && temp_c=$(awk -v r="$raw" 'BEGIN{printf "%.2f",r/1000}') || temp_c=$raw
    printf '%s' "$temp_c"
    return 0
  done
  die "Could not find temperature sensor"
}

get_macos_temp(){
  has osx-cpu-temp || die "Install osx-cpu-temp: https://github.com/lavoiesl/osx-cpu-temp"
  local temp_c
  temp_c=$(osx-cpu-temp -C 2>/dev/null | grep -o '[0-9]*\.[0-9]*')
  [[ -z $temp_c ]] && die "Could not retrieve CPU temperature"
  printf '%s' "$temp_c"
}

get_freebsd_temp(){
  local temp_str temp_c
  temp_str=$(sysctl -n hw.acpi.thermal. tz0.temperature 2>/dev/null || printf '')
  [[ -z $temp_str ]] && die "Could not retrieve CPU temperature"
  temp_c=${temp_str%.*}
  printf '%s' "$temp_c"
}

get_cpu_temp(){
  local temp_c
  case $(uname -s) in
    Linux*) temp_c=$(get_linux_temp);;
    Darwin*) temp_c=$(get_macos_temp);;
    FreeBSD*) temp_c=$(get_freebsd_temp);;
    *) die "Unsupported OS (Linux/macOS/FreeBSD only)";;
  esac
  printf '%s' "$temp_c"
}

cpu_temp(){
  local unit=C monitor=0 output_json=false
  while [[ $# -gt 0 ]]; do
    case $1 in
      -u|--unit) unit=$2; shift 2;;
      -j|--json) output_json=true; shift;;
      -m|--monitor) monitor=$2; shift 2;;
      -h|--help) cat <<EOF
Usage: sysinfo temp [OPTIONS]
Options:
  -u, --unit UNIT      Temperature unit: C, F, K (default: C)
  -j, --json           Output in JSON format
  -m, --monitor SEC    Monitor at interval (seconds)
  -h, --help           Show this help
EOF
        return 0;;
      *) die "Unknown temp option: $1";;
    esac
  done
  if [[ $monitor -gt 0 ]]; then
    while true; do
      local temp_c temp
      temp_c=$(get_cpu_temp)
      temp=$(convert_temp "$temp_c" "$unit")
      if [[ $output_json == true ]]; then
        printf '{"cpu_temperature":"%s","unit":"%s"}\n' "$temp" "$unit"
      else
        printf 'CPU Temperature: %s°%s\n' "$temp" "$unit"
      fi
      log_action "CPU Temperature: $temp°$unit"
      sleep "$monitor"
    done
  else
    local temp_c temp
    temp_c=$(get_cpu_temp)
    temp=$(convert_temp "$temp_c" "$unit")
    if [[ $output_json == true ]]; then
      printf '{"cpu_temperature":"%s","unit":"%s"}\n' "$temp" "$unit"
    else
      printf 'CPU Temperature: %s°%s\n' "$temp" "$unit"
    fi
    log_action "CPU Temperature: $temp°$unit"
  fi
}

disk_usage(){
  local pattern="" exclude="" fstype="" include_all=false sort_field="" reverse=false output_json=false output_csv=false no_header=false
  while [[ $# -gt 0 ]]; do
    case $1 in
      -p|--pattern) pattern=$2; shift 2;;
      -e|--exclude) exclude=$2; shift 2;;
      -t|--type) fstype=$2; shift 2;;
      -a|--all) include_all=true; shift;;
      -s|--sort) sort_field=$2; shift 2;;
      -r|--reverse) reverse=true; shift;;
      --json) output_json=true; shift;;
      --csv) output_csv=true; shift;;
      --no-header) no_header=true; shift;;
      -h|--help) cat <<EOF
Usage: sysinfo disk [OPTIONS]
Options:
  -p, --pattern PAT    Match disk pattern (e.g., 'sda')
  -e, --exclude PAT    Exclude disks matching pattern
  -t, --type TYPE      Filter by filesystem type (e.g., 'ext4')
  -a, --all            Include all filesystems (tmpfs, etc.)
  -s, --sort FIELD     Sort by: filesystem, size, used, avail, use%, mount
  -r, --reverse        Reverse sort order
  --json               Output in JSON format
  --csv                Output in CSV format
  --no-header          Omit header row
  -h, --help           Show this help
EOF
        return 0;;
      *) die "Unknown disk option: $1";;
    esac
  done
  local df_opts="-h"
  [[ $include_all == true ]] && df_opts="$df_opts -a"
  local awk_filter='NR>1'
  if [[ $include_all == false ]]; then
    awk_filter="$awk_filter && \$1 !~ /^(tmpfs|udev|devtmpfs|run|shm)/"
  fi
  [[ -n $fstype ]] && awk_filter="$awk_filter && \$1 ~ /$fstype/"
  [[ -n $pattern ]] && awk_filter="$awk_filter && \$1 ~ /$pattern/"
  [[ -n $exclude ]] && awk_filter="$awk_filter && \$1 !~ /$exclude/"
  local sort_opts=""
  if [[ -n $sort_field ]]; then
    case $sort_field in
      filesystem) sort_opts="-k1";;
      size) sort_opts="-k2";;
      used) sort_opts="-k3";;
      avail) sort_opts="-k4";;
      use%) sort_opts="-k5";;
      mount) sort_opts="-k6";;
      *) die "Invalid sort field: $sort_field";;
    esac
  fi
  [[ $reverse == true ]] && sort_opts="$sort_opts -r"
  local data
  data=$(df $df_opts | awk "$awk_filter")
  if [[ $output_json == true ]]; then
    printf '['
    printf '%s\n' "$data" | awk 'BEGIN{first=1}{if(! first)printf",";first=0;printf"{\"filesystem\":\"%s\",\"size\":\"%s\",\"used\":\"%s\",\"avail\":\"%s\",\"use%%\":\"%s\",\"mount\":\"%s\"}",$1,$2,$3,$4,$5,$6}END{print"]"}'
  elif [[ $output_csv == true ]]; then
    [[ $no_header == false ]] && printf 'Filesystem,Size,Used,Avail,Use%%,Mounted on\n'
    printf '%s\n' "$data" | awk '{printf"%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6}'
  else
    {
      [[ $no_header == false ]] && printf 'Filesystem      Size  Used Avail Use%% Mounted on\n'
      printf '%s\n' "$data"
    } | column -t
  fi | { [[ -n $sort_opts ]] && sort $sort_opts || cat; }
  log_action "Disk usage displayed"
}

usage(){
  cat <<'EOF'
sysinfo - System information utilities

USAGE:
  sysinfo [COMMAND] [OPTIONS]

COMMANDS:
  temp       Show CPU temperature
  disk       Show disk usage
  all        Show both (default)
  -h, --help Show this help
  -V         Show version

GLOBAL OPTIONS:
  -v, --verbose      Verbose output
  -l, --log FILE     Log to file
  -o, --output FILE  Save output to file

EXAMPLES:
  sysinfo temp -u F -m 5        # Monitor temp in Fahrenheit
  sysinfo disk -s used -r        # Sort by used, descending
  sysinfo all --json             # All info in JSON
  sysinfo -v disk -p nvme        # Verbose, NVMe disks only

See 'sysinfo <command> -h' for command-specific options.
EOF
}

main(){
  local cmd=all
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help) usage; exit 0;;
      -V|--version) printf 'sysinfo %s\n' "$VERSION"; exit 0;;
      -v|--verbose) VERBOSE=true; shift;;
      -l|--log-file) LOG_FILE=$2 LOG_ENABLED=true; shift 2;;
      -o|--output) OUTPUT_FILE=$2; shift 2;;
      temp|disk|all) cmd=$1; shift; break;;
      *) die "Unknown option: $1";;
    esac
  done
  [[ -n $OUTPUT_FILE ]] && exec > >(tee -a "$OUTPUT_FILE")
  case $cmd in
    temp) cpu_temp "$@";;
    disk) disk_usage "$@";;
    all)
      cpu_temp "$@"
      printf '\n'
      disk_usage "$@";;
  esac
}

main "$@"

#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
readonly VERSION="3.0.0" BLD=$'\e[1m' GRN=$'\e[32m' BLU=$'\e[34m' YLW=$'\e[33m' CYN=$'\e[96m' RED=$'\e[31m' DEF=$'\e[0m'
die(){ printf '%bERROR:%b %s\n' "${BLD}${RED}" "$DEF" "$*" >&2; exit "${2:-1}"; }
need(){ has "$1" || die "Required: $1"; }
has jaq && JQ=jaq || has jq && JQ=jq || JQ=''
VERBOSE=false
usage(){
  cat <<'EOF'
sysinfo - System & network info
USAGE: sysinfo [COMMAND] [OPTIONS]
COMMANDS: temp disk ip weather speed all(default)
TEMP: -u UNIT(C/F/K) -m SEC(monitor)
DISK: -p PAT -s FIELD --json
EXAMPLES: sysinfo temp -u F -m 5
EOF
}
get_cpu_temp(){
  local temp_c
  case $(uname -s) in
    Linux*)
      for f in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp*_input;do
        [[ -r $f ]]||continue;local raw=$(<"$f")
        [[ $raw -gt 1000 ]] && temp_c=$(awk -v r="$raw" 'BEGIN{printf "%.2f",r/1000}')||temp_c=$raw
        printf '%s' "$temp_c";return 0
      done;die "No temperature sensor";;
    Darwin*) has osx-cpu-temp||die "Install osx-cpu-temp";osx-cpu-temp -C 2>/dev/null|grep -o '[0-9]*\.[0-9]*';;
    *) die "Unsupported OS";;
  esac
}
convert_temp(){ local temp_c=$1 unit=$2;case $unit in C|c) printf '%s' "$temp_c";;F|f) awk -v t="$temp_c" 'BEGIN{printf "%.2f",t*9/5+32}';;K|k) awk -v t="$temp_c" 'BEGIN{printf "%.2f",t+273.15}';;*) die "Invalid unit: $unit";;esac;}
cmd_temp(){
  local unit=C monitor=0
  while [[ $# -gt 0 ]];do case $1 in -u|--unit) unit=$2;shift 2;;-m|--monitor) monitor=$2;shift 2;;*) shift;;esac;done
  if [[ $monitor -gt 0 ]];then while :;do local temp_c=$(get_cpu_temp) temp=$(convert_temp "$temp_c" "$unit");printf 'CPU: %s°%s\n' "$temp" "$unit";sleep "$monitor";done
  else local temp_c=$(get_cpu_temp) temp=$(convert_temp "$temp_c" "$unit");printf 'CPU: %s°%s\n' "$temp" "$unit";fi
}
cmd_disk(){
  local pattern="" sort_field="" output_json=false
  while [[ $# -gt 0 ]];do case $1 in -p|--pattern) pattern=$2;shift 2;;-s|--sort) sort_field=$2;shift 2;;--json) output_json=true;shift;;*) shift;;esac;done
  local data=$(df -h|awk 'NR>1 && $1 !~ /^(tmpfs|udev|devtmpfs)/')
  [[ -n $pattern ]] && data=$(grep "$pattern" <<<"$data")
  if [[ $output_json == true ]];then
    printf '[';awk 'BEGIN{first=1}{if(!first)printf",";first=0;printf"{\"fs\":\"%s\",\"size\":\"%s\",\"used\":\"%s\",\"avail\":\"%s\",\"use\":\"%s\",\"mount\":\"%s\"}",$1,$2,$3,$4,$5,$6}' <<<"$data";printf ']\n'
  else printf 'Filesystem      Size  Used Avail Use%% Mounted\n';printf '%s\n' "$data"|column -t;fi
}
jget(){ [[ -n $JQ ]] && "$JQ" -r "$2" <<<"$1"||sed -n "s/.*\"${2//./\\.}\":[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" <<<"$1"|head -1;}
cmd_speed(){
  need curl
  printf 'Testing download...\n' >&2;local down=$(curl -sL -o /dev/null -w "%{speed_download}" "https://speed.cloudflare.com/__down?bytes=50000000" 2>/dev/null||printf '0');awk -v s="$down" 'BEGIN{printf "Down: %.2f Mbps\n",(s*8)/(1024*1024)}'
  printf 'Testing upload...\n' >&2;local up=$(dd if=/dev/zero bs=1M count=10 2>/dev/null|curl -sS -o /dev/null -w "%{speed_upload}" --data-binary @- https://speed.cloudflare.com/__up 2>/dev/null||printf '0');awk -v s="$up" 'BEGIN{printf "Up:   %.2f Mbps\n",(s*8)/(1024*1024)}'
}
cmd_ip(){ need curl;local json=$(curl -fsS https://ipinfo.io/json 2>/dev/null||printf '{}') ip=$(jget "$json" '.ip') city=$(jget "$json" '.city');printf '%bIP:%b %s\n%bCity:%b %s\n' "${BLD}${GRN}" "$DEF" "${ip:-unknown}" "${BLD}${BLU}" "$DEF" "${city:-unknown}";}
cmd_weather(){ local city=${1:-$(curl -fsS https://ipinfo.io/json 2>/dev/null|jget - '.city')};[[ -z $city ]] && city="Bielefeld";local data=$(curl -sL "http://wttr.in/$city?format=3" 2>/dev/null||printf '');[[ -z $data ]] && die "Weather failed: $city";printf '%s\n' "$data";}
main(){
  local cmd=${1:-all};shift||:
  case $cmd in
    temp) cmd_temp "$@";;disk) cmd_disk "$@";;ip) cmd_ip;;weather) cmd_weather "$@";;speed) cmd_speed;;
    all) cmd_temp;printf '\n';cmd_disk;printf '\n';cmd_ip;printf '\n';cmd_speed;;
    -h|--help) usage;;-V|--version) printf 'sysinfo %s\n' "$VERSION";;*) die "Unknown: $cmd";;
  esac
}
main "$@"

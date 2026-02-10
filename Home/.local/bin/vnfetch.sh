#!/usr/bin/env bash
# vnfetch - Heavily overoptimized bash fetch
set -euo pipefail; shopt -s nullglob; IFS=$'\n\t'
export LC_ALL=C
# --- Environment & Colors ---
BLK=$'\e[30m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m'
BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' WHT=$'\e[37m'
DEF=$'\e[0m'  BLD=$'\e[1m'
# --- Info Gathering ---
# User & Host
userhost="${USER:-$(id -un)}@${HOSTNAME:-$(< /etc/hostname)}"
# OS & Kernel
# Read os-release once, standardizing fields
if [[ -f /etc/os-release ]]; then
  source /etc/os-release
  os_name="${PRETTY_NAME:-$NAME}"
else
  os_name="Linux"
fi
kernel="$(< /proc/sys/kernel/osrelease)"
# Uptime (Pure Bash calculation from /proc/uptime)
read -r up_sec _ < /proc/uptime
up_h=$(( ${up_sec%%.*} / 3600 ))
up_m=$(( (${up_sec%%.*} % 3600) / 60 ))
uptime="${up_h}h ${up_m}m"
# Packages (Direct FS count is faster than pacman/dpkg calls)
pkgs=0
if [[ -d /var/lib/pacman/local ]]; then
  # Arch: Count directories in local db
  set -- /var/lib/pacman/local/*; pkgs=$(( $# - 1 )) # -1 for ALPM_DB_VERSION
elif [[ -f /var/lib/dpkg/status ]]; then
  # Debian: Count 'Package:' lines
  pkgs=$(grep -c '^Package:' /var/lib/dpkg/status)
fi
# Shell (Basename only)
shell="${SHELL##*/}"
# CPU (Parse first 'model name' from /proc/cpuinfo)
cpu=""
while IFS=':' read -r k v; do
  if [[ $k == "model name" ]]; then
    cpu="${v##* }"
    # Clean up common CPU clutter
    cpu="${cpu//(R)/}"; cpu="${cpu//(TM)/}"; cpu="${cpu//CPU /}"
    cpu="${cpu// @*/}"; break
  fi
done < /proc/cpuinfo
# Memory (Parse /proc/meminfo)
mem_tot=0 mem_avl=0
while IFS=':' read -r k v; do
  case $k in
    MemTotal)     mem_tot=${v//kB/}; mem_tot=${mem_tot// /} ;;
    MemAvailable) mem_avl=${v//kB/}; mem_avl=${mem_avl// /} ;;
  esac
  ((mem_tot > 0 && mem_avl > 0)) && break
done < /proc/meminfo
mem_usd=$((mem_tot - mem_avl))
mem_pct=$((100 * mem_usd / mem_tot))
# Colorize percentage: Green < 75%, Red >= 75%
((mem_pct < 75)) && mc="$GRN" || mc="$RED"
# Format as MiB (integer math is strictly faster than awk float)
mem_str="$((mem_usd / 1024)) / $((mem_tot / 1024)) MiB (${mc}${mem_pct}%${DEF})"
# Disk (df is unavoidable but fast enough)
read -r _ _ d_used d_avail d_pct _ < <(df -Pkh / 2>/dev/null | tail -1)
d_pct_n=${d_pct%\%}
((d_pct_n < 75)) && dc="$GRN" || dc="$RED"
disk_str="$d_used / $d_avail (${dc}${d_pct}${DEF})"
# --- Display Construction ---
label_w=10
OUT=""
append() {
  local k="$1" v="$2"
  [[ -n $v ]] && printf -v line "${BLD}%-${label_w}s${DEF} %s\n" "$k:" "$v" && OUT+="$line"
}
# Header
echo
printf "  ${BLD}%s${DEF}\n" "$userhost"
printf -v _sep "%*s" "${#userhost}" ""
printf "  ${CYN}%s${DEF}\n" "${_sep// /─}"; unset _sep
# Lines
append "OS"     "$os_name"
append "Kernel" "$kernel"
append "Uptime" "$uptime"
append "Pkgs"   "$pkgs"
append "Shell"  "$shell"
append "CPU"    "$cpu"
append "Memory" "$mem_str"
append "Disk"   "$disk_str"
# Final Print
echo "$OUT"

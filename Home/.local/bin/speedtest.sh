#!/usr/bin/env bash
# speedtest.sh - Optimized curl-based speedtest
set -euo pipefail; shopt -s nullglob; IFS=$'\n\t'
export LC_ALL=C
# --- Config & Helpers ---
DL_MB=100 UL_MB=20 PROBES=5
UPLOAD_URL="https://httpbin.org/post"
SERVERS=(
  "https://speed.cloudflare.com/"
  "https://nbg1-speed.hetzner.com/100MB.bin"
  "https://fsn1-speed.hetzner.com/100MB.bin"
  "https://ash-speed.hetzner.com/100MB.bin"
)
# Colors
R=$'\e[31m' G=$'\e[32m' B=$'\e[34m' C=$'\e[36m' W=$'\e[1;37m' N=$'\e[0m'
die() { printf "${R}ERROR:${N} %s\n" "$*" >&2; exit 1; }
has() { command -v "$1" >/dev/null; }
calc() { awk "BEGIN {printf \"%.2f\", $* }"; }
has curl || die "Missing dependency: curl"
usage() {
  cat <<EOF
${W}Usage:${N} ${0##*/} [-d DL_MB] [-u UL_MB] [-n PROBES] [-s SERVER] [-U UPLOAD_URL]
${B}Options:${N}
  -d  Download size in MB (default: $DL_MB)
  -u  Upload size in MB (default: $UL_MB)
  -n  Number of latency probes (default: $PROBES)
  -s  Force specific server URL
  -U  Custom upload endpoint
EOF
  exit 1
}
# --- Core Logic ---
measure_latency() {
  local url="$1" out
  out=$(curl -s -o /dev/null -w '%{time_connect}' --max-time 3 "$url") || echo "999"
  echo "$out $url"
}
find_best_server() {
  printf "${C}:: Probing servers (parallel)...${N}\n"
  local -a pids
  local tmp_dir; tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' EXIT
  for i in "${!SERVERS[@]}"; do
    measure_latency "${SERVERS[$i]}" > "$tmp_dir/$i" &
    pids+=($!)
  done
  wait "${pids[@]}"
  local best_time=999 best_url=""
  for f in "$tmp_dir"/*; do
    read -r t u < "$f"
    if (( $(echo "$t < $best_time" | bc -l 2>/dev/null || echo 0) )); then
      best_time=$t; best_url=$u
    fi
  done
  [[ -z $best_url ]] && die "All servers unreachable"
  printf "  ${G}Best:${N} %s (${W}%s ms${N})\n" "$best_url" "$(calc "$best_time * 1000")"
  echo "$best_url"
}
run_test() {
  # Parse Args
  while getopts "d:u:n:s:U:h" opt; do
    case $opt in
      d) DL_MB=$OPTARG ;; u) UL_MB=$OPTARG ;; n) PROBES=$OPTARG ;;
      s) SERVERS=("$OPTARG") ;; U) UPLOAD_URL=$OPTARG ;; h) usage ;; *) usage ;;
    esac
  done
  # 1. Server Selection
  local best_srv; best_srv=$(find_best_server)
  # 2. Download Test
  local dl_url="$best_srv"
  [[ $best_srv == *"cloudflare"* ]] && dl_url="${best_srv}__down?bytes=$((DL_MB * 1024 * 1024))"
  printf "\n${C}:: Downloading${N} ${W}%d MB${N} from %s...\n" "$DL_MB" "$dl_url"
  local dl_res; dl_res=$(curl -L -s -w "%{speed_download}" -o /dev/null "$dl_url" || echo 0)
  (( $(printf "%.0f" "$dl_res") > 0 )) || die "Download failed"
  local dl_mbps; dl_mbps=$(calc "$dl_res * 8 / 1000000")
  printf "  ${G}Speed:${N} ${W}%s Mbps${N} (Avg)\n" "$dl_mbps"
  # 3. Upload Test
  printf "\n${C}:: Uploading${N} ${W}%d MB${N} to %s...\n" "$UL_MB" "$UPLOAD_URL"
  # Generate dummy data stream on the fly to avoid disk I/O
  local ul_res; ul_res=$(dd if=/dev/zero bs=1M count="$UL_MB" status=none | \
    curl -s -w "%{speed_upload}" -o /dev/null -T - "$UPLOAD_URL" || echo 0)
  local ul_mbps; ul_mbps=$(calc "$ul_res * 8 / 1000000")
  printf "  ${G}Speed:${N} ${W}%s Mbps${N} (Avg)\n" "$ul_mbps"
}
run_test "$@"

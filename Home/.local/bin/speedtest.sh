#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
# speedtest-curl.sh - curl-only speedtest (ping-like, download, upload)
# Usage: speedtest-curl.sh [-s server_url] [-d dl_mb] [-u ul_mb] [-n probes] [-U upload_url]
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
source "./.lib.sh"
has curl || { printf 'curl required\n'; exit 1; }
CURL=$(command -v curl)

DL_MB=100
UL_MB=20
PROBES=5
SERVERS=("https://speed.cloudflare.com/" "https://nbg1-speed.hetzner.com/100MB.bin" "https://fsn1-speed.hetzner.com/100MB.bin" "https://ash-speed.hetzner.com/100MB.bin")
UPLOAD_URL="https://httpbin.org/post"

usage(){
  cat <<-USAGE
Usage: $0 [-d DL_MB] [-u UL_MB] [-n probes] [-s server_url] [-U upload_url]
Defaults: DL_MB=${DL_MB} UL_MB=${UL_MB} probes=${PROBES}
Example: $0 -d 200 -u 50 -n 7
USAGE
}

while getopts "hd:u:n:s:U:" opt; do
  case $opt in
    h) usage; exit 0 ;;
    d) DL_MB=$OPTARG ;;
    u) UL_MB=$OPTARG ;;
    n) PROBES=$OPTARG ;;
    s) SERVERS=("$OPTARG") ;;
    U) UPLOAD_URL=$OPTARG ;;
    *) usage; exit 1 ;;
  esac
done

# helpers
fmt_mbps(){
  local bps="${1:-0}"
  awk -v bps="$bps" 'BEGIN{printf "%.2f", (bps*8)/1000000}'
} # bytes/s -> Mbit/s

# 1) latency probe (time_connect) across servers
best_srv=""
best_lat=9999
printf 'Probing %d servers for latency (connect time) with %d probes each...\n' "${#SERVERS[@]}" "$PROBES"
for srv in "${SERVERS[@]}"; do
  # use small HEAD/GET; follow redirects; short timeout
  sum=0
  ok=0
  for ((i = 1; i <= PROBES; i++)); do
    t=$("$CURL" -s -o /dev/null -w '%{time_connect}' -L --max-time 6 "$srv" 2>/dev/null) || t=9999
    # ensure numeric
    case $t in '' | *[!0-9.]*) t=9999 ;; *) ;; esac
    sum=$(awk "BEGIN{print $sum + $t}")
    ok=$((ok + 1))
  done
  avg=$(awk "BEGIN{printf \"%.3f\", $sum / $ok}")
  printf '  %s -> avg connect: %s s\n' "$srv" "$avg"
  cmp=$(awk "BEGIN{print ($avg < $best_lat) ? 1 : 0}")
  if [[ $cmp -eq 1 ]]; then
    best_lat=$avg
    best_srv=$srv
  fi
done

printf '\nBest server (lowest connect): %s (%.3fs)\n\n' "$best_srv" "$best_lat"

# 2) download test
DL_BYTES=$((DL_MB * 1024 * 1024))
# choose a download URL - if best_srv looks like a directory/UI, prefer known file endpoints
if printf '%s' "$best_srv" | grep -qE 'speed.cloudflare.com'; then
  DL_URL="${best_srv}__down?bytes=${DL_BYTES}"
else
  # if the server already points to a file, use it; otherwise append known 100MB.bin if size matches
  case "$best_srv" in
    *100MB.bin) DL_URL="$best_srv" ;;
    *) DL_URL="$best_srv" ;;
  esac
fi

printf 'Download test: requesting ~%d MB from %s\n' "$DL_MB" "$DL_URL"
# single-stream download (more realistic per-connection throughput)
DL_OUT=$("$CURL" -s -L -o /dev/null -w '%{size_download} %{time_total} %{speed_download}' "$DL_URL") || {
  printf 'Download failed\n'
  exit 1
}
read -r bytes time_sec bps <<<"$DL_OUT"
mbps=$(fmt_mbps "$bps")
printf '  Downloaded: %s bytes in %s s - %s B/s = %s Mbps\n' "$bytes" "$time_sec" "$bps" "$mbps"

# 3) upload test - stream UL_MB from /dev/zero to upload URL
printf '\nUpload test: streaming %d MB to %s\n' "$UL_MB" "$UPLOAD_URL"
# generate stream and POST as binary
UL_OUT=$(dd if=/dev/zero bs=1M count="$UL_MB" 2>/dev/null \
  | "$CURL" -s -X POST --data-binary @- -H 'Content-Type: application/octet-stream' -w '%{size_upload} %{time_total} %{speed_upload}' -o /dev/null "$UPLOAD_URL") || {
  printf 'Upload failed\n'
  exit 1
}
read -r ubytes utime ubps <<<"$UL_OUT"
umbps=$(fmt_mbps "$ubps")
printf '  Uploaded: %s bytes in %s s - %s B/s = %s Mbps\n' "$ubytes" "$utime" "$ubps" "$umbps"

exit 0

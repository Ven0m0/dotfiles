#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
# Usage: av1pack [-r] <input> <outdir>
# - file  -> encode single
# - dir + -r -> recurse, keep structure, only video extensions
recursive=0
[[ ${1:-} == "-r" ]] && { recursive=1; shift; }
[[ $# -lt 2 ]] && { printf 'Usage: %s [-r] <input> <outdir>\n' "${0##*/}" >&2; exit 1; }
in="$1"
out="$2"
# Extensions to process
ext_re='.(mp4|mov|mkv|webm|mts|m2ts|avi|wmv|flv|ts)$'
encode_one(){
  local src="$1" rel dst
  if [[ -d "$in" ]]; then
    rel="${src#"$in"/}"
    dst="$out/${rel%.*}.mkv"
    mkdir -p "$(dirname "$dst")"
  else
    dst="${out%/}"
    [[ -d "$dst" ]] && dst="$dst/${src##*/}"
    dst="${dst%.*}.mkv"
  fi
  printf '==> %s\n' "$src"
  ffmpeg -hide_banner -nostdin -loglevel error -stats -i "$src" -map_metadata 0 -sn \
    -vf "hqdn3d=1.5:1.5:6:6,scale='if(gte(iw,ih),min(1920,iw),-2)':'if(gte(iw,ih),-2,min(1080,ih))',deband,format=yuv420p10le" \
    -c:v libsvtav1 -preset 3 -crf 26 -g 600 -pix_fmt yuv420p10le \
    -svtav1-params "tune=0:film-grain=6:enable-qm=1:qm-min=0:enable-variance-boost=1:tf-strength=1:sharpness=1:tile-columns=1:tile-rows=0:enable-dlf=2:scd=1" \
    -c:a libopus -b:a 128k -ac 2 -rematrix_maxval 1.0 -y "$dst"
}
if [[ -f "$in" ]]; then
  [[ ${in,,} =~ $ext_re ]] || { printf 'Skip (unsupported extension): %s\n' "$in" >&2; exit 1; }
  mkdir -p "$out"
  encode_one "$in"; exit 0
fi
[[ -d "$in" && $recursive -eq 1 ]] || { printf 'Error: for directories you must use -r\n' >&2; exit 1; }
mkdir -p "$out"
if command -v fd &>/dev/null; then
  while IFS= read -r f; do
    [[ ${f,,} =~ $ext_re ]] && encode_one "$f"
  done < <(fd . "$in" -tf)
else
  while IFS= read -r f; do
    [[ ${f,,} =~ $ext_re ]] && encode_one "$f"
  done < <(find "$in" -type f)
fi

#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
# Unified AV1 Encoder:  Single file or recursive batch
# Usage: 
#   av1pack <file> <out>                 → encode single file
#   av1pack -r <dir> <outdir>            → recurse, keep structure
#   av1pack -s <dir-or-file>             → smart scan:  skip AV1/existing, inline suffix
readonly OUT_SUFFIX="_av1"
readonly TARGET_EXT="mkv"
readonly MAX_JOBS=1
readonly EXT_RE='.(mp4|mov|mkv|webm|mts|m2ts|avi|wmv|flv|ts)$'
has(){ command -v -- "$1" &>/dev/null; }
log(){ printf '[%s] %s\n' "$(date +'%H:%M:%S')" "$*"; }
err(){ printf '[%s] [ERR] %s\n' "$(date +'%H:%M:%S')" "$*" >&2; }
is_av1(){
  local codec
  codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$1" 2>/dev/null || echo "err")
  [[ "$codec" == "av1" ]]
}
_check_av1_worker() {
  for f in "$@"; do
    if is_av1 "$f"; then
      log "Skip AV1: $f" >&2
    else
      printf "%s\0" "$f"
    fi
  done
}
export -f _check_av1_worker is_av1 log
encode_one(){
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  log "==> $src"
  nice -19 ffmpeg -hide_banner -nostdin -v error -y -stats -i "$src" -map_metadata 0 -sn \
    -vf "hqdn3d=1.5:1.5:6:6,scale='if(gte(iw,ih),min(1920,iw),-2)':'if(gte(iw,ih),-2,min(1080,ih))',deband,format=yuv420p10le" \
    -c:v libsvtav1 -preset 3 -crf 26 -g 600 -pix_fmt yuv420p10le \
    -svtav1-params "tune=0:film-grain=6:enable-qm=1:qm-min=0:enable-variance-boost=1:tf-strength=1:sharpness=1:tile-columns=1:tile-rows=0:enable-dlf=2:scd=1" \
    -c:a libopus -b:a 128k -ac 2 -rematrix_maxval 1.0 "$dst" || { err "Failed: $src"; rm -f "$dst"; return 1; }
}
run_ffzap(){
  local list_file="$1" args="$2"
  log "Engine: ffzap batch"
  ffzap --file-list "$list_file" --overwrite -f "$args" -o "{{dir}}/{{name}}${OUT_SUFFIX}. ${TARGET_EXT}"
}
run_ffmpeg_loop(){
  local -n targets=$1
  local args="$2" active=0
  log "Engine: ffmpeg sequential (Max: $MAX_JOBS)"
  for src in "${targets[@]}"; do
    local dst="${src%.*}${OUT_SUFFIX}.${TARGET_EXT}"
    (
      # shellcheck disable=SC2086
      if ffmpeg -v error -stats -hide_banner -nostdin -y -i "$src" $args "$dst"; then
        log "Done: $dst"
      else
        err "Failed: $src"; [[ -f "$dst" ]] && rm -f "$dst"
      fi
    ) &
    ((active++))
    ((active >= MAX_JOBS)) && { wait -n; ((active--)); }
  done
  wait
}
scan_files(){
  local root="$1"
  if has fd; then
    fd -tf -e mkv -e mp4 -e mov -e avi -e webm -e mts -e m2ts -e wmv -e flv -e ts .  "$root"
  else
    find "$root" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.mov" -o -name "*.avi" -o -name "*.webm" -o -name "*.mts" -o -name "*.m2ts" -o -name "*. wmv" -o -name "*.flv" -o -name "*.ts" \)
  fi
}
main(){
  local mode=single recursive=0 smart=0 in="" out=""
  # Parse flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -r) recursive=1; shift ;;
      -s) smart=1; shift ;;
      *) break ;;
    esac
  done
  [[ $# -lt 1 ]] && { err "Usage: ${0##*/} [-r|-s] <input> [<outdir>]"; exit 1; }
  in="$1"
  out="${2:-}"
  # Validate dependencies
  has ffmpeg || { err "Missing ffmpeg"; exit 1; }
  has ffprobe || { err "Missing ffprobe"; exit 1; }
  # Mode:  Single file
  if [[ -f "$in" ]]; then
    [[ ${in,,} =~ $EXT_RE ]] || { err "Unsupported:  $in"; exit 1; }
    [[ -z "$out" ]] && out="."
    mkdir -p "$out"
    local dst="$out"
    [[ -d "$dst" ]] && dst="$dst/${in##*/}"
    dst="${dst%.*}. ${TARGET_EXT}"
    encode_one "$in" "$dst"
    exit 0
  fi
  # Mode: Directory
  [[ -d "$in" ]] || { err "Input not found: $in"; exit 1; }
  # Recursive batch
  if [[ $recursive -eq 1 ]]; then
    [[ -z "$out" ]] && { err "Recursive mode requires <outdir>"; exit 1; }
    mkdir -p "$out"
    local candidates=() src dst rel
    mapfile -t candidates < <(scan_files "$in")
    [[ ${#candidates[@]} -eq 0 ]] && { log "No files found"; exit 0; }
    for src in "${candidates[@]}"; do
      [[ ${src,,} =~ $EXT_RE ]] || continue
      rel="${src#"$in"/}"
      dst="$out/${rel%.*}.${TARGET_EXT}"
      encode_one "$src" "$dst"
    done
    exit 0
  fi
  # Smart mode: skip AV1/existing, optional ffzap
  if [[ $smart -eq 1 ]]; then
    log "Scanning:  $in"
    local candidates=() valid=()
    mapfile -t candidates < <(scan_files "$in")
    [[ ${#candidates[@]} -eq 0 ]] && { log "No files"; exit 0; }
    local to_check=()
    for f in "${candidates[@]}"; do
      [[ "$f" == *"${OUT_SUFFIX}.${TARGET_EXT}" ]] && continue
      local out_file="${f%.*}${OUT_SUFFIX}.${TARGET_EXT}"
      [[ -f "$out_file" ]] && continue
      to_check+=("$f")
    done
    if [[ ${#to_check[@]} -gt 0 ]]; then
      local procs
      procs=$(nproc 2>/dev/null || echo 1)
      mapfile -d "" -t valid < <(printf '%s\0' "${to_check[@]}" | xargs -0 -P "$procs" bash -c '_check_av1_worker "$@"' _)
    fi
    [[ ${#valid[@]} -eq 0 ]] && { log "All processed"; exit 0; }
    log "Queued:  ${#valid[@]}"
    local args="-c:v libsvtav1 -preset 3 -crf 26 -g 600 -pix_fmt yuv420p10le -svtav1-params tune=0:film-grain=6:enable-qm=1:qm-min=0:enable-variance-boost=1:tf-strength=1:sharpness=1:tile-columns=1:tile-rows=0:enable-dlf=2:scd=1 -vf \"scale='if(gt(iw,ih),min(1920,iw),-2)':'if(gt(iw,ih),-2,min(1920,ih))',deband\" -c:a libopus -b:a 128k -ac 2 -rematrix_maxval 1.0"
    if has ffzap; then
      local list
      list=$(mktemp)
      printf '%s\n' "${valid[@]}" >"$list"
      run_ffzap "$list" "$args"
      rm -f "$list"
    else
      run_ffmpeg_loop valid "$args"
    fi
    exit 0
  fi
  err "For directories use -r (recursive) or -s (smart scan)"
  exit 1
}

main "$@"

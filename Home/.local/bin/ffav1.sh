#!/usr/bin/env bash
#
# SVT-AV1 Batch Encoder
# Preset: 3 (Aggressive) | CRF: 32 | Filter: 1080p-Limit + Deband
#
# Usage: ./encode.sh [path]
set -euo pipefail
shopt -s nullglob globstar
# --- Configuration ---
readonly MAX_JOBS=1 # Preset 3 is CPU heavy; keep low
readonly OUT_SUFFIX="_av1"
readonly TARGET_EXT="mkv"
# --- Dependencies ---
export LC_ALL=C
export IFS=$'\n\t'
has() { command -v -- "$1" &>/dev/null; }
# --- Logic ---
log() { printf '[%s] %s\n' "$(date +'%H:%M:%S')" "$*"; }
err() { printf '[%s] [ERR] %s\n' "$(date +'%H:%M:%S')" "$*" >&2; }
encode_file() {
  local src="$1"
  local base="${src%.*}"
  local out="${base}${OUT_SUFFIX}.${TARGET_EXT}"
  # Skip conditions
  if [[ "$src" == *"${OUT_SUFFIX}.${TARGET_EXT}" ]]; then return 0; fi
  if [[ -f "$out" ]]; then
    log "Skipping existing: $out"
    return 0
  fi
  log "Encoding: $src -> $out"
  # User-defined flags
  # Note: scale filter logic prevents upscaling beyond source dim, caps at 1920
  if ffmpeg -v error -stats -hide_banner -nostdin -y \
    -i "$src" \
    -c:v libsvtav1 \
    -preset 3 -crf 32 -g 600 -pix_fmt yuv420p10le \
    -svtav1-params film-grain=8:enable-qm=1:qm-min=0 \
    -vf "scale='if(gt(iw,ih),min(1920,iw),-2)':'if(gt(iw,ih),-2,min(1920,ih))',deband" \
    -c:a libopus -b:a 96k -ac 2 -rematrix_maxval 1.0 \
    -map_metadata 0 \
    -f mkv \
    "$out"; then
    log "Done: $out"
  else
    err "Failed: $src"
    [[ -f "$out" ]] && rm -f "$out"
  fi
}

main() {
  local target="${1:-.}"
  if ! has ffmpeg; then
    err "Missing ffmpeg."
    exit 1
  fi
  local files=()
  if has fd; then
    mapfile -t files < <(fd -t f -e mkv -e mp4 -e mov -e avi -e webm . "$target")
  else
    # Fallback to find
    while IFS= read -r f; do
      files+=("$f")
    done < <(find "$target" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.mov" -o -name "*.avi" -o -name "*.webm" \))
  fi
  if [[ ${#files[@]} -eq 0 ]]; then
    err "No video files found in $target"
    exit 0
  fi
  # Job Queue
  local active_jobs=0
  for f in "${files[@]}"; do
    encode_file "$f" &
    ((active_jobs++))

    if ((active_jobs >= MAX_JOBS)); then
      wait -n
      ((active_jobs--))
    fi
  done
  wait
}

main "$@"

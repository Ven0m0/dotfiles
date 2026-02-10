#!/usr/bin/env bash
# media-opt.sh - Optimized Parallel Media Converter
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'
export LC_ALL=C

# --- Config & Helpers ---
: "${JOBS:=$(nproc 2>/dev/null || echo 4)}" "${DRY:=0}" "${BACKUP:=0}" "${MTIME:=1}"
: "${QUAL:=95}" "${VCRF:=28}" "${VCODEC:=libsvtav1}" "${LOSSLESS:=1}"
BACKUP_DIR="${HOME}/.cache/media-opt/$(date +%Y%m%d_%H%M%S)"
B=$'\e[1;34m' G=$'\e[1;32m' R=$'\e[1;31m' Y=$'\e[1;33m' X=$'\e[0m'
log() { printf "%b[%s]%b %s\n" "$B" "$(date +%T)" "$X" "$*"; }
warn() { printf "%b[WARN]%b %s\n" "$Y" "$X" "$*" >&2; }
die() { printf "%b[ERR]%b %s\n" "$R" "$X" "$*" >&2; exit 1; }
has() { command -v "$1" >/dev/null; }

# --- Worker Function (Exported for xargs) ---
optimize_worker() {
  local f
  for f in "$@"; do

    local ext="${f##*.}" base="${f%.*}" sz_orig sz_new
    [[ -f "$f" ]] || continue
    sz_orig=$(stat -c%s "$f")
    # Backup logic
    if ((BACKUP)); then
      mkdir -p "$BACKUP_DIR/${f%/*}"
      cp -a "$f" "$BACKUP_DIR/$f"
    fi
    # Processing
    if ((DRY)); then echo "[DRY] Processing $f"; continue; fi
    case "${ext,,}" in
      jpg|jpeg)
        if ((LOSSLESS)); then has jpegoptim && jpegoptim -q -s "$f"
        else has jpegoptim && jpegoptim -q -m"$QUAL" -s "$f"; fi ;;
      png)
        if ((LOSSLESS)); then has oxipng && oxipng -q -o4 --strip safe "$f"
        else has pngquant && pngquant --force --skip-if-larger --quality "0-$QUAL" --ext .png "$f"; fi ;;
      webp)
        has cwebp && cwebp -q "$QUAL" -m 6 -mt "${LOSSLESS:+-lossless}" "$f" -o "$f.tmp" && mv -f "$f.tmp" "$f" ;;
      mp4|mkv|mov)
        local v_opts=(-c:v "$VCODEC" -crf "$VCRF" -preset 6 -c:a copy)
        [[ $VCODEC == "libsvtav1" ]] && v_opts+=(-svtav1-params "tune=0")
        has ffmpeg && ffmpeg -y -i "$f" "${v_opts[@]}" "$base.opt.mkv" </dev/null >/dev/null 2>&1
        [[ -f "$base.opt.mkv" ]] && mv "$base.opt.mkv" "$f" ;;
    esac
    sz_new=$(stat -c%s "$f")
    if ((sz_new >= sz_orig)); then
      # Revert if optimization failed to save space (images only)
      [[ $ext =~ ^(jpg|jpeg|png|webp)$ ]] && { cp -a "$BACKUP_DIR/$f" "$f" 2>/dev/null || true; }
      echo "  $f: Skipped (larger/same)"
    else
      local pct=$((100 - (sz_new * 100 / sz_orig)))
      printf "  %b%s%b: -%s%% (%s -> %s)\n" "$G" "$f" "$X" "$pct" "$(numfmt --to=iec $sz_orig)" "$(numfmt --to=iec $sz_new)"
    fi
    ((MTIME)) && touch -r "${BACKUP_DIR}/$f" "$f" 2>/dev/null || true
  done
}
export -f optimize_worker has

# --- Main ---
usage() {
  cat <<EOF
media-opt.sh - Parallel Media Optimizer
Usage: ${0##*/} [options] [path...]
Options:
  -j N        Jobs (default: $JOBS)
  -l/-L       Lossless (default) / Lossy
  -q N        Quality 1-100 (default: $QUAL)
  --crf N     Video CRF (default: $VCRF)
  --backup    Enable backups to ~/.cache/media-opt
  --dry-run   Simulate only
EOF
  exit 0
}

main() {
  local paths=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -j|--jobs) JOBS="$2"; shift 2 ;;
      -l|--lossless) LOSSLESS=1; shift ;;
      -L|--lossy) LOSSLESS=0; shift ;;
      -q|--quality) QUAL="$2"; shift 2 ;;
      --crf) VCRF="$2"; shift 2 ;;
      --backup) BACKUP=1; shift ;;
      --dry-run) DRY=1; shift ;;
      -h|--help) usage ;;
      *) paths+=("$1"); shift ;;
    esac
  done
  export JOBS DRY BACKUP BACKUP_DIR LOSSLESS QUAL VCRF VCODEC MTIME
  ((BACKUP)) && log "Backups enabled: $BACKUP_DIR"
  local search_paths="${paths[*]:-.}"
  log "Scanning $search_paths (Jobs: $JOBS)..."
  # Find files and pipe to xargs for parallel processing
  # Uses 'fd' if available for speed, falls back to 'find'
  if has fd; then
    fd -t f -0 -e jpg -e jpeg -e png -e webp -e mp4 -e mkv -e mov . ${paths[@]}
  else
    find ${paths[@]} -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.mp4" -o -iname "*.mkv" \) -print0
  fi | xargs -0 -P "$JOBS" -n 20 bash -c 'optimize_worker "$@"' _
  
  log "Done."
}

main "$@"

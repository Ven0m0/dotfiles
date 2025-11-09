#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob globstar extglob
IFS=$'\n\t'; export LC_ALL=C LANG=C

# imgtool: convert/compress/display/thumb for images/videos
# Usage:
#   imgtool convert [-t webp|avif] [-q Q] [-o OUTDIR] FILE...
#   imgtool compress [-q Q] FILE...
#   imgtool display FILE|DIR...
#   imgtool thumb [-s SIZE] [-o OUTDIR] FILE...

have(){ command -v "$1" &>/dev/null; }

# tool resolution (cached)
MAGICK="${MAGICK:-}"; [[ -z "$MAGICK" && $(command -v magick || :) ]] && MAGICK=magick || :
CWEBP="${CWEBP:-}"; [[ -z "$CWEBP" && $(command -v cwebp || :) ]] && CWEBP=cwebp || :
AVIFENC="${AVIFENC:-}"; [[ -z "$AVIFENC" && $(command -v avifenc || :) ]] && AVIFENC=avifenc || :
FFTHUMB="${FFTHUMB:-}"; [[ -z "$FFTHUMB" && $(command -v ffmpegthumbnailer || :) ]] && FFTHUMB=ffmpegthumbnailer || :
CHAFACMD="${CHAFACMD:-}"; [[ -z "$CHAFACMD" && $(command -v chafa || :) ]] && CHAFACMD=chafa || :

out_path(){
  local outdir="$1" in="$2" newext="$3"
  local base="${in##*/}" stem="${base%.*}"
  printf '%s/%s.%s' "${outdir%/}" "$stem" "$newext"
}

is_image(){ local m; m=$(file --mime-type -b -- "$1" 2>/dev/null || printf '') || :; [[ "$m" == image/* ]]; }
is_video(){ local m; m=$(file --mime-type -b -- "$1" 2>/dev/null || printf '') || :; [[ "$m" == video/* ]]; }

usage(){
  printf '%s\n' \
    "imgtool convert [-t webp|avif] [-q Q] [-o OUTDIR] FILE..." \
    "imgtool compress [-q Q] FILE..." \
    "imgtool display FILE|DIR..." \
    "imgtool thumb [-s SIZE] [-o OUTDIR] FILE..."
}

cmd_convert(){
  local to="webp" q="" outdir="."
  while (( $# )); do
    case "$1" in
      -t) to="$2"; shift 2 ;;
      -q) q="$2"; shift 2 ;;
      -o) outdir="$2"; shift 2 ;;
      --) shift; break ;;
      -h|--help) usage; return 0 ;;
      -*) printf 'bad flag: %s\n' "$1" >&2; return 2 ;;
      *) break ;;
    esac
  done
  mkdir -p -- "$outdir" || :
  [[ "$to" =~ ^(webp|avif)$ ]] || { printf 'target must be webp|avif\n' >&2; return 2; }
  (( $# )) || { printf 'no inputs\n' >&2; return 2; }

  local f out
  for f in "$@"; do
    [[ -f "$f" ]] || { printf 'skip (not file): %s\n' "$f" >&2; continue; }
    is_image "$f" || { printf 'skip (not image): %s\n' "$f" >&2; continue; }
    if [[ "$to" == "webp" ]]; then
      out="$(out_path "$outdir" "$f" webp)"
      if [[ -n "$CWEBP" ]]; then
        "$CWEBP" ${q:+-q "$q"} -mt -m 6 -metadata all -- "$f" -o "$out"
      elif [[ -n "$MAGICK" ]]; then
        "$MAGICK" convert "$f" -quality "${q:-82}" -define webp:method=6 -strip "$out"
      else
        printf 'need cwebp or magick\n' >&2; return 3
      fi
    else
      out="$(out_path "$outdir" "$f" avif)"
      if [[ -n "$AVIFENC" ]]; then
        "$AVIFENC" ${q:+--min "$q" --max "$q"} --speed 6 --jobs 0 -- "$f" "$out"
      elif [[ -n "$MAGICK" ]]; then
        "$MAGICK" convert "$f" -quality "${q:-32}" -define heic:speed=6 -strip "$out"
      else
        printf 'need avifenc or magick\n' >&2; return 3
      fi
    fi
    printf '%s -> %s\n' "$f" "$out"
  done
}

cmd_compress(){
  local q="82"
  while (( $# )); do
    case "$1" in
      -q) q="$2"; shift 2 ;;
      --) shift; break ;;
      -h|--help) usage; return 0 ;;
      -*) printf 'bad flag: %s\n' "$1" >&2; return 2 ;;
      *) break ;;
    esac
  done
  (( $# )) || { printf 'no inputs\n' >&2; return 2; }

  local f ext tmp
  for f in "$@"; do
    [[ -f "$f" ]] || { printf 'skip (not file): %s\n' "$f" >&2; continue; }
    ext="${f##*.}"; ext="${ext,,}"
    case "$ext" in
      jpg|jpeg|png)
        [[ -n "$MAGICK" ]] || { printf 'need magick for %s\n' "$f" >&2; continue; }
        tmp="${f}.tmp"; "$MAGICK" convert "$f" -strip -quality "$q" "$tmp" && mv -f -- "$tmp" "$f"
        ;;
      webp)
        [[ -n "$CWEBP" ]] || { printf 'need cwebp for %s\n' "$f" >&2; continue; }
        tmp="${f%.webp}.tmp.webp"
        "$CWEBP" -q "$q" -mt -m 6 -metadata all -- "$f" -o "$tmp" && mv -f -- "$tmp" "$f"
        ;;
      avif)
        [[ -n "$AVIFENC" ]] || { printf 'need avifenc for %s\n' "$f" >&2; continue; }
        # re-encode (lossy); note: avif is often already efficient
        tmp="${f%.avif}.tmp.avif"
        "$AVIFENC" --min "$q" --max "$q" --speed 6 --jobs 0 -- "$f" "$tmp" && mv -f -- "$tmp" "$f"
        ;;
      *) printf 'skip (unknown ext): %s\n' "$f" >&2 ;;
    esac
  done
}

term_dim(){
  local lines cols
  read -r lines cols < <(stty size </dev/tty 2>/dev/null || printf '40 120\n')
  printf '%sx%s' "$cols" "$lines"
}

display_one(){
  local p="$1" dim; dim="$(term_dim)"
  if [[ -n "${KITTY_WINDOW_ID:-}" || -n "${GHOSTTY_RESOURCES_DIR:-}" ]] && have kitten; then
    kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" -- "$p" | sed '$d' | sed $'$s/$/\e[m/'
  elif [[ -n "$CHAFACMD" ]]; then
    "$CHAFACMD" -f sixel -s "$dim" --animate false -- "$p" || "$CHAFACMD" -f symbols -s "$dim" -- "$p"
  else
    file --brief --dereference --mime -- "$p"
  fi
}

cmd_display(){
  (( $# )) || { printf 'no inputs\n' >&2; return 2; }
  local p
  for p in "$@"; do
    if [[ -d "$p" ]]; then
      mapfile -t imgs < <(find -- "$p" -maxdepth 1 -type f)
      ((${#imgs[@]})) || { printf 'empty: %s\n' "$p" >&2; continue; }
      display_one "${imgs[0]}"
    else
      display_one "$p"
    fi
  done
}

cmd_thumb(){
  local size="1200" outdir="."
  while (( $# )); do
    case "$1" in
      -s) size="$2"; shift 2 ;;
      -o) outdir="$2"; shift 2 ;;
      --) shift; break ;;
      -h|--help) usage; return 0 ;;
      -*) printf 'bad flag: %s\n' "$1" >&2; return 2 ;;
      *) break ;;
    esac
  done
  mkdir -p -- "$outdir" || :
  (( $# )) || { printf 'no inputs\n' >&2; return 2; }

  local f out base
  for f in "$@"; do
    [[ -f "$f" ]] || { printf 'skip (not file): %s\n' "$f" >&2; continue; }
    base="${f##*/}"; base="${base%.*}"
    out="${outdir%/}/${base}.jpg"
    if is_video "$f"; then
      [[ -n "$FFTHUMB" ]] || { printf 'need ffmpegthumbnailer for video: %s\n' "$f" >&2; continue; }
      "$FFTHUMB" -i "$f" -o "$out" -s "$size"
    elif is_image "$f"; then
      [[ -n "$MAGICK" ]] || { printf 'need magick for image: %s\n' "$f" >&2; continue; }
      "$MAGICK" convert "$f" -thumbnail "${size}x${size}>" -strip "$out"
    else
      printf 'skip (unknown type): %s\n' "$f" >&2
    fi
    printf '%s -> %s\n' "$f" "$out"
  done
}

main(){
  local cmd="${1:-}"; shift || :
  case "${cmd:-}" in
    convert) cmd_convert "$@" ;;
    compress) cmd_compress "$@" ;;
    display) cmd_display "$@" ;;
    thumb) cmd_thumb "$@" ;;
    ""|-h|--help|help) usage ;;
    *) printf 'unknown: %s\n' "$cmd" >&2; usage; return 2 ;;
  esac
}
main "$@"

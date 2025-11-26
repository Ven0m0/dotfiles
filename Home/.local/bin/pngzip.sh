#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t'; export LC_ALL=C LANG=C

usage(){ printf 'usage: %s [-g] [-q] [-t] [-r DPI] [dir|file...]\n' "${0##*/}"; exit 0;}
# opts
GRAYSCALE=0; TOUCH=0; VERBOSE=1; DPI=0
while getopts ":gqtr:h" o; do
  case $o in
    g) GRAYSCALE=1 ;;
    q) VERBOSE=0 ;;
    t) TOUCH=1 ;;
    r) DPI=${OPTARG//[^0-9]/} ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

# Input targets
targets=()
for x in "${@:-.}"; do
  if [[ -d $x ]]; then
    mapfile -t files < <(fd -tf -e png --strip-cwd-prefix "$x")
    targets+=("${files[@]}")
  elif [[ -f $x && $x == *.png ]]; then
    targets+=("$x")
  fi
done
[[ ${#targets[@]} -eq 0 ]] && usage

for f in "${targets[@]}"; do
  [[ -f $f && -r $f && -w $f ]] || { ((VERBOSE)) && printf "skip: %s\n" "$f"; continue; }
  # copy timestamp if --touch
  preserve=()
  ((TOUCH)) && preserve+=("--preserve=timestamps")
  orig_size=$(stat -c %s "$f")
  # optional grayscale step
  grayargs=()
  ((GRAYSCALE)) && grayargs+=(--grayscale)
  # PNGQUANT (lossy palette, best bang-size first)
  tmpq="${f}.pq.$$"
  pngquant -Q 70-95 --strip "${grayargs[@]}" --force -o "$tmpq" -- "$f" &>/dev/null || rm -f "$tmpq"
  if [[ -s $tmpq && $(stat -c %s "$tmpq") -lt $orig_size ]]; then
    cp "${preserve[@]}" "$tmpq" "$f"
    ((VERBOSE)) && printf 'pngquant: %s %s → %s\n' "$f" "$orig_size" "$(stat -c %s "$f")"
  fi
  rm -f "$tmpq"
  # OXIPNG (lossless, deep recompress after lossy for further gain)
  oxipng -o max --strip all --alpha --zopfli -P --zi 25 --fix --scale16 -- "$f" &>/dev/null || :
  osize=$(stat -c %s "$f")
  # OPT: optional pngcrush for DPI
  if ((DPI>0)); then
    tmpc="${f}.cr.$$"
    pngcrush -brute -l 9 -res "$DPI" -s "$f" "$tmpc" &>/dev/null && \
      [[ -s $tmpc && $(stat -c %s "$tmpc") -lt $osize ]] && \
      cp "${preserve[@]}" "$tmpc" "$f" && \
      ((VERBOSE)) && printf 'pngcrush: %s set DPI %s %s → %s\n' "$f" "$DPI" "$osize" "$(stat -c %s "$f")"
    rm -f "$tmpc"
  fi
  ((VERBOSE)) && printf "%s: %s → %s bytes\n" "$f" "$orig_size" "$(stat -c %s "$f")"
done

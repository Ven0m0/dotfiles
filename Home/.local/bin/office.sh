#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C LANG=C

repack_zip(){
  local f="$1"; local t="${f%.*}-opt.${f##*.}" d=$(mktemp -d)
  unzip -q "$f" -d "$d"
  (cd "$d" && zip -9 -q -r "../$t" .)
  rm -rf "$d"; printf '%s\n' "$t"
}
repack_odt_zstd(){
  local f="$1"; local t="${f%.*}-zstd.odt" d=$(mktemp -d)
  unzip -q "$f" -d "$d"
  (cd "$d" && zip --compression-method zstd -q -r "../$t" .)
  rm -rf "$d"; printf '%s\n' "$t"
}
odt_wrap(){
  find . -type f -regex '.*\.\(odt\|docx\|xlsx\)' |
  while IFS= read -r f; do repack_zip "$f"; done
}
lossless_pdf(){
  gs -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dCompatibilityLevel=1.7 \
    -dNOPAUSE -dQUIET -dBATCH -sOutputFile=out.pdf in.pdf
#qpdf --linearize --object-streams=generate in.pdf out.pdf
#qpdf --compress-streams=y --recompress-flate out.pdf out.pdf
}
lossy_pdf(){
  gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook \
    -dNOPAUSE -dQUIET -dBATCH -sOutputFile=out.pdf in.pdf
}
compress_office() {
  local f="$1"
  case $f in
    *.odt|*.docx|*.xlsx) repack_zip "$f" ;;
    *.pdf)
      local out="${f%.*}-opt.pdf"
      gs -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dCompatibilityLevel=1.7 \
         -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$out" "$f" || :
      printf '%s\n' "$out" ;;
  esac
}

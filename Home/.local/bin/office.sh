#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C LANG=C

die(){ printf '%s\n' "$*" >&2; exit 1; }
has(){ command -v "$1" &>/dev/null; }
req(){ has "$1" || die "missing: $1"; }

repack_zip(){ local f=$1 t=${f%.*}-opt.${f##*.} d; d=$(mktemp -d); unzip -q "$f" -d "$d"; (cd "$d" && zip -9 -q -r "../$t" .); rm -rf "$d"; printf '%s\n' "$t"; }
repack_zstd(){ local f=$1 t=${f%.*}-zstd.${f##*.} d; d=$(mktemp -d); unzip -q "$f" -d "$d"; (cd "$d" && zip --compression-method zstd -q -r "../$t" .); rm -rf "$d"; printf '%s\n' "$t"; }
pdf_lossless(){ 
  local f=$1 o=${f%.*}-opt.pdf
  gs -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dCompatibilityLevel=1.7 \
    -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$o" "$f" 2>/dev/null || return 1
  printf '%s\n' "$o"
}
pdf_lossy(){
  local f=$1 o=${f%.*}-lossy.pdf
  gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH \
    -sOutputFile="$o" "$f" 2>/dev/null || return 1
  printf '%s\n' "$o"
}
validate_office(){
  local f=$1 d; d=$(mktemp -d)
  if unzip -tq "$f" -d "$d" 2>/dev/null; then
    [[ -f "$d/content.xml" || -f "$d/word/document.xml" || -f "$d/xl/workbook.xml" ]] && printf 'OK\n' || printf 'INVALID\n'
  else
    printf 'CORRUPT\n'
  fi
  rm -rf "$d"
}
compress_file(){
  local f=$1 mode=${2:-deflate}
  case $f in
    *.pdf) [[ $mode == lossy ]] && pdf_lossy "$f" || pdf_lossless "$f" ;;
    *.odt|*.ods|*.odp) [[ $mode == zstd ]] && repack_zstd "$f" || repack_zip "$f" ;;
    *.docx|*.xlsx|*.pptx) repack_zip "$f" ;;
    *) printf 'skip: %s\n' "$f" >&2; return 1 ;;
  esac
}
batch_compress(){
  local mode=${1:-deflate} dir=${2:-.}
  local -a files=()
  if has fd; then
    mapfile -t files < <(fd -e pdf -e odt -e ods -e odp -e docx -e xlsx -e pptx . "$dir")
  else
    mapfile -t files < <(find "$dir" -type f \( -name '*.pdf' -o -name '*.odt' -o -name '*.ods' -o -name '*.odp' -o -name '*.docx' -o -name '*.xlsx' -o -name '*.pptx' \))
  fi
  [[ ${#files[@]} -eq 0 ]] && die "no office files in $dir"
  if has parallel; then
    printf '%s\n' "${files[@]}" | parallel -j+0 --bar bash -c "$(declare -f compress_file repack_zip repack_zstd pdf_lossless pdf_lossy); compress_file \"\$1\" \"$mode\"" _ {}
  else
    local pids=() maxjobs=$(($(nproc 2>/dev/null || echo 4)))
    for f in "${files[@]}"; do
      compress_file "$f" "$mode" &
      pids+=($!)
      ((${#pids[@]} >= maxjobs)) && { wait "${pids[@]}"; pids=(); }
    done
    wait
  fi
}
lint_office(){
  local dir=${1:-.}
  local -a files=()
  has fd && mapfile -t files < <(fd -e odt -e ods -e odp -e docx -e xlsx -e pptx . "$dir") || \
    mapfile -t files < <(find "$dir" -type f \( -name '*.odt' -o -name '*.ods' -o -name '*.odp' -o -name '*.docx' -o -name '*.xlsx' -o -name '*.pptx' \))
  for f in "${files[@]}"; do
    printf '%s: %s\n' "$f" "$(validate_office "$f")"
  done
}
strip_metadata(){
  local f=$1 t=${f%.*}-clean.${f##*.} d; d=$(mktemp -d)
  unzip -q "$f" -d "$d"
  find "$d" -name 'meta.xml' -delete
  [[ -f "$d/docProps/core.xml" ]] && : >"$d/docProps/core.xml"
  [[ -f "$d/docProps/app.xml" ]] && : >"$d/docProps/app.xml"
  (cd "$d" && zip -9 -q -r "../$t" .)
  rm -rf "$d"; printf '%s\n' "$t"
}
show_stats(){
  local f=$1
  case $f in
    *.pdf) pdfinfo "$f" 2>/dev/null | grep -E '^(Pages|File size|PDF version):' || : ;;
    *.odt|*.ods|*.odp|*.docx|*.xlsx|*.pptx)
      local d; d=$(mktemp -d)
      unzip -q "$f" -d "$d"
      printf 'Size: %s\n' "$(du -sh "$f" | cut -f1)"
      printf 'Files: %s\n' "$(find "$d" -type f | wc -l)"
      printf 'Compress: %s\n' "$(unzip -l "$f" | awk 'NR==2 {print $4}')"
      rm -rf "$d" ;;
  esac
}
usage(){
  cat <<'EOF'
office.sh - Office document compression & linting
Usage: office.sh <cmd> [args]

Commands:
  compress <file> [mode]    Compress single file (mode: deflate|zstd|lossy)
  batch <mode> [dir]        Batch compress (parallel if available)
  lint [dir]                Validate office documents
  strip <file>              Remove metadata
  stats <file>              Show document statistics
  
Examples:
  office.sh compress doc.odt zstd
  office.sh batch deflate ./docs
  office.sh lint ~/documents
EOF
}

main(){
  [[ $# -lt 1 ]] && { usage; exit 1; }
  case $1 in
    compress) [[ $# -lt 2 ]] && die "usage: compress <file> [mode]"; compress_file "$2" "${3:-deflate}" ;;
    batch) batch_compress "${2:-deflate}" "${3:-.}" ;;
    lint) lint_office "${2:-.}" ;;
    strip) [[ $# -lt 2 ]] && die "usage: strip <file>"; strip_metadata "$2" ;;
    stats) [[ $# -lt 2 ]] && die "usage: stats <file>"; show_stats "$2" ;;
    *) usage; exit 1 ;;
  esac
}
main "$@"

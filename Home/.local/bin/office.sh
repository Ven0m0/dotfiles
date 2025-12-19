#!/usr/bin/env bash
# shellcheck source=../lib/bash-common.sh
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s
source "${s%/bin/*}/lib/bash-common.sh"
init_strict
img_opt(){ case $1 in *.png) has oxipng && oxipng -q -o2 "$1"||has optipng && optipng -q "$1";;*.jpg|*.jpeg) has jpegoptim && jpegoptim -q -s "$1";;esac;}
repack_zip(){ local f=$1 t=${f%.*}-opt.${f##*.} d=$(mktemp -d);unzip -q "$f" -d "$d";(cd "$d" && zip -9 -q -r "../$t" .);rm -rf "$d";printf '%s\n' "$t";}
repack_zstd(){ local f=$1 t=${f%.*}-zstd.${f##*.} d=$(mktemp -d);unzip -q "$f" -d "$d";(cd "$d" && zip --compression-method zstd -q -r "../$t" .);rm -rf "$d";printf '%s\n' "$t";}
pdf_lossless(){ local f=$1 o=${f%.*}-opt.pdf;gs -sDEVICE=pdfwrite -dPDFSETTINGS=/default -dCompatibilityLevel=1.7 -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$o" "$f" 2>/dev/null||return 1;printf '%s\n' "$o";}
pdf_lossy(){ local f=$1 o=${f%.*}-lossy.pdf;gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -q -dBATCH -dDownsampleColorImages=true -dDownsampleMonoImages=true -dDownsampleGrayImages=true -sOutputFile="$o" "$f" 2>/dev/null||return 1;printf '%s\n' "$o";}
validate_office(){ local f=$1 d=$(mktemp -d);if unzip -tq "$f" -d "$d" 2>/dev/null;then [[ -f "$d/content.xml" || -f "$d/word/document.xml" || -f "$d/xl/workbook.xml" ]] && printf 'OK\n'||printf 'INVALID\n';else printf 'CORRUPT\n';fi;rm -rf "$d";}
compress_media(){
  local d=$1 mode=${2:-lossless} -a imgs=() pdfs=()
  mapfile -t imgs < <(find "$d" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \))
  mapfile -t pdfs < <(find "$d" -type f -iname '*.pdf')
  [[ ${#imgs[@]} -gt 0 ]] && printf '%s\n' "${imgs[@]}"|xargs -P"$(nproc 2>/dev/null||printf 4)" -I{} bash -c "$(declare -f img_opt has);img_opt {}"
  for p in "${pdfs[@]}";do local t="${p%.*}-t.pdf" s=$([[ $mode == lossy ]] && printf ebook||printf prepress);gs -sDEVICE=pdfwrite -dPDFSETTINGS=/$s -dCompatibilityLevel=1.7 -dNOPAUSE -q -dBATCH -sOutputFile="$t" "$p" 2>/dev/null && mv "$t" "$p";done
}
repack_media(){ local f=$1 mode=${2:-lossless} t=${f%.*}-media.${f##*.} d=$(mktemp -d);unzip -q "$f" -d "$d";compress_media "$d" "$mode";(cd "$d" && zip -9 -q -r "../$t" .);rm -rf "$d";printf '%s\n' "$t";}
compress_file(){
  local f=$1 mode=${2:-deflate}
  case $f in
    *.pdf) [[ $mode == lossy ]] && pdf_lossy "$f"||pdf_lossless "$f";;
    *.odt|*.ods|*.odp) [[ $mode == zstd ]] && repack_zstd "$f"||repack_zip "$f";;
    *.docx|*.xlsx|*.pptx) repack_zip "$f";;
    *) printf 'skip: %s\n' "$f" >&2;return 1;;
  esac
}
batch_compress(){
  local mode=${1:-deflate} dir=${2:-.} -a files=()
  has fd && mapfile -t files < <(fd -e pdf -e odt -e ods -e odp -e docx -e xlsx -e pptx . "$dir")||mapfile -t files < <(find "$dir" -type f \( -name '*.pdf' -o -name '*.odt' -o -name '*.ods' -o -name '*.odp' -o -name '*.docx' -o -name '*.xlsx' -o -name '*.pptx' \))
  [[ ${#files[@]} -eq 0 ]] && die "no office files in $dir"
  printf '%s\n' "${files[@]}"|xargs -P"$(nproc 2>/dev/null||printf 4)" -I{} bash -c "$(declare -f compress_file repack_zip repack_zstd pdf_lossless pdf_lossy);compress_file {} $mode" _
}
lint_office(){
  local dir=${1:-.} -a files=()
  has fd && mapfile -t files < <(fd -e odt -e ods -e odp -e docx -e xlsx -e pptx . "$dir")||mapfile -t files < <(find "$dir" -type f \( -name '*.odt' -o -name '*.ods' -o -name '*.odp' -o -name '*.docx' -o -name '*.xlsx' -o -name '*.pptx' \))
  for f in "${files[@]}";do printf '%s: %s\n' "$f" "$(validate_office "$f")";done
}
strip_metadata(){ local f=$1 t=${f%.*}-clean.${f##*.} d=$(mktemp -d);unzip -q "$f" -d "$d";find "$d" -name 'meta.xml' -delete;[[ -f "$d/docProps/core.xml" ]] && : >"$d/docProps/core.xml";[[ -f "$d/docProps/app.xml" ]] && : >"$d/docProps/app.xml";(cd "$d" && zip -9 -q -r "../$t" .);rm -rf "$d";printf '%s\n' "$t";}
show_stats(){
  local f=$1
  case $f in
    *.pdf) pdfinfo "$f" 2>/dev/null|grep -E '^(Pages|File size|PDF version):'||:;;
    *.odt|*.ods|*.odp|*.docx|*.xlsx|*.pptx) local d=$(mktemp -d);unzip -q "$f" -d "$d";printf 'Size: %s\n' "$(du -sh "$f"|cut -f1)";printf 'Files: %s\n' "$(find "$d" -type f|wc -l)";printf 'Compress: %s\n' "$(unzip -l "$f"|awk 'NR==2 {print $4}')";rm -rf "$d";;
  esac
}
usage(){
  cat <<'EOF'
office.sh - Office document compression & linting
Usage: office.sh <cmd> [args]
Commands:
  compress <file> [mode]    Compress single file (mode: deflate|zstd|lossy)
  batch <mode> [dir]        Batch compress (parallel if available)
  media <file> [mode]       Compress embedded images/PDFs (mode: lossless|lossy)
  deep <file> [mode]        Full compress: archive + media
  lint [dir]                Validate office documents
  strip <file>              Remove metadata
  stats <file>              Show document statistics
Examples:
  office.sh compress doc.odt zstd
  office.sh batch deflate ./docs
  office.sh media report.docx lossy
EOF
}
main(){
  [[ $# -lt 1 ]] && { usage;exit 1;}
  case $1 in
    compress) [[ $# -lt 2 ]] && die "usage: compress <file> [mode]";compress_file "$2" "${3:-deflate}";;
    batch) batch_compress "${2:-deflate}" "${3:-.}";;
    media) [[ $# -lt 2 ]] && die "usage: media <file> [mode]";repack_media "$2" "${3:-lossless}";;
    deep) [[ $# -lt 2 ]] && die "usage: deep <file> [mode]";local m=${3:-deflate} tmp;tmp=$(compress_file "$2" "$m") && repack_media "$tmp" "$([[ $m == lossy ]] && printf lossy||printf lossless)";;
    lint) lint_office "${2:-.}";;
    strip) [[ $# -lt 2 ]] && die "usage: strip <file>";strip_metadata "$2";;
    stats) [[ $# -lt 2 ]] && die "usage: stats <file>";show_stats "$2";;
    *) usage;exit 1;;
  esac
}
main "$@"

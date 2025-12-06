#!/bin/bash
set -euo pipefail
shopt -s nullglob
IFS=$'\n\t'

# Extracts archives. Usage: extract.sh FILE [OUT_DIR]
main() {
  [[ $# -lt 1 || $# -gt 2 ]] && {
    printf 'Usage: extract.sh FILE [OUT_DIR]\n' >&2
    exit 1
  }
  local f=$1 out=${2:-.}
  [[ -f $f ]] || {
    printf 'File %s not found\n' "$f" >&2
    exit 1
  }
  [[ -d $out ]] || { mkdir -p "$out" && printf 'Created %s\n' "$out"; }
  case ${f,,} in
  *.tar.xz) chk tar && tar -xf "$f" -C "$out" ;;
  *.tar.gz | *.tgz) chk tar && tar -xzf "$f" -C "$out" ;;
  *.tar.bz2) chk tar && tar -xjf "$f" -C "$out" ;;
  *.tar.zst) chk tar && tar --zstd -xf "$f" -C "$out" ;;
  *.tar) chk tar && tar -xf "$f" -C "$out" ;;
  *.bz | *.bz2) chk bzip2 && bzip2 -dkc "$f" >"$out/${f%.bz*}" ;;
  *.gz) chk gzip && gzip -dc "$f" >"$out/${f%.gz}" ;;
  *.xz) chk xz && xz -dkc "$f" >"$out/${f%.xz}" ;;
  *.zst) chk zstd && zstd -dco "$out/${f%.zst}" "$f" ;;
  *.zip | *.jar) chk unzip && unzip -q "$f" -d "$out" ;;
  *.Z) chk uncompress && uncompress -c "$f" | tar -xC "$out" ;;
  *.rar) chk unrar && unrar x -inul "$f" "$out/" ;;
  *.7z) chk 7z && 7z x -o"$out" "$f" >/dev/null ;;
  *)
    printf 'Unsupported: %s\n' "$f" >&2
    exit 1
    ;;
  esac
}
chk() { command -v "$1" >/dev/null || {
  printf '%s required\n' "$1" >&2
  exit 1
}; }
main "$@"

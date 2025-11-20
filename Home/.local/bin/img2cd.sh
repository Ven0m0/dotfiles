#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob
export LC_ALL=C LANG=C

# Burn audio CD image to disk using cdrdao
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>

die(){ printf 'Error: %s\n' "$*" >&2; exit 1; }

usage(){
  cat <<'EOF'
img2cd - Burn audio CD image to disk

USAGE:
  img2cd TOCFILE

ARGUMENTS:
  TOCFILE    Path to TOC (Table of Contents) file

OPTIONS:
  -h, --help Show this help message

DESCRIPTION:
  Burns an audio image to CD using cdrdao with the generic-mmc-raw
  driver. The disk will be automatically ejected after burning.

EXAMPLES:
  img2cd audio.toc
  img2cd mycd.cue

REQUIREMENTS:
  - cdrdao (for burning audio CDs)
  - sudo (for device access)
EOF
}

main(){
  # Check for help flag
  if [[ ${#} -ne 1 ]]; then
    die "Expected 1 argument, got ${#}"
  fi

  if [[ $1 == -h || $1 == --help ]]; then
    usage
    exit 0
  fi

  # Check dependencies
  command -v cdrdao &>/dev/null || die "cdrdao not found. Install it first."

  local toc="$1"
  [[ -f $toc ]] || die "TOC file not found: $toc"

  printf 'Burning CD from: %s\n' "$toc"
  sudo cdrdao write --eject --driver generic-mmc-raw "$toc"
  printf '✓ CD burned successfully\n'
}

main "$@"

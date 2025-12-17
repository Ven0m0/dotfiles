#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
# Interactive Deduplication Pipeline (Fclones -> Czkawka)
# Usage: ./dedupe.sh <target_directory>
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
has(){ command -v -- "$1" &>/dev/null; }
msg(){ printf '%s\n' "$@"; }
log(){ printf '%s\n' "$@" >&2; }
die(){ printf '%s\n' "$1" >&2; exit "${2:-1}"; }

readonly TARGET="${1:-}"
readonly RPT_PREFIX="dedupe_report"
readonly -a CZ_BASE=("-u" "-W" "-X" "-M" "-E" "*/.git" "*/tmp*")
[[ -z $TARGET || ! -d $TARGET ]] && die "Usage:  $0 <directory>"
for tool in fclones czkawka-cli; do
  has "$tool" || die "Error: $tool is not installed."
done

# --- Interaction ---
msg "" "Target: $TARGET" ""
# 1. Backup Verification
msg "SAFETY CHECK"
read -rp "Have you created a backup of this directory? [y/N] " backup_ans
[[ !  ${backup_ans,,} =~ ^y ]] && die "Aborting. Please backup your data first."
# 2. Strategy Selection
msg "" "STRATEGY" \
  "1) Hardlink (Safe) - Replaces exact duplicates with hardlinks.  Saves space, keeps filenames." \
  "2) Delete   (Risk) - Permanently deletes duplicates." \
  "3) Dry Run  (Info) - Scan and report only."
read -rp "Select option [1-3]: " strat_ans
MODE="dry"
FCLONES_CMD=""
CZ_ACTION=""
if [[ $strat_ans == 1 ]]; then
  MODE="hardlink"
  FCLONES_CMD="link"
elif [[ $strat_ans == 2 ]]; then
  MODE="delete"
  FCLONES_CMD="remove"
  CZ_ACTION="DELETE"
fi
timestamp(){ printf '%(%H:%M:%S)T' -1; }
phase(){ log "" "[ $(timestamp) ] $*"; }
run_fclones(){
  phase "Phase 1: Fclones (Exact Match)"
  local rpt="${RPT_PREFIX}_fclones. txt"
  fclones group "$TARGET" >"$rpt"
  local cnt
  cnt=$(grep -c '^[0-9a-f]' "$rpt" || : )
  if [[ $cnt -eq 0 ]]; then
    log "   No exact duplicates found."
    return
  fi
  log "   Found $cnt groups."
  if [[ $MODE != dry ]]; then
    log "   EXECUTING: fclones $FCLONES_CMD..."
    fclones "$FCLONES_CMD" <"$rpt"
  else
    log "   DRY RUN: See $rpt"
  fi
}
run_czkawka(){
  local type=$1
  phase "Phase 2: Czkawka ($type)"
  local -a cmd=(czkawka-cli "$type" "$TARGET" "${CZ_BASE[@]}")
  if [[ $MODE == delete ]]; then
    cmd+=("-D" "AEN")
    log "   EXECUTING: Deleting All Except Newest..."
    "${cmd[@]}"
  elif [[ $MODE == hardlink && $type == dup ]]; then
    log "   Skipping Czkawka action (Fclones handled hardlinks)."
    "${cmd[@]}"
  else
    log "   DRY RUN: Scanning only..."
    "${cmd[@]}"
  fi
}
run_fclones
run_czkawka dup
if [[ $MODE == hardlink ]]; then
  phase "Skipping Fuzzy Image/Video scan (Cannot hardlink different files)."
else
  run_czkawka image
  run_czkawka video
fi
phase "Done."

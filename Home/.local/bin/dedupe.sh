#!/usr/bin/env bash
# Role: Interactive Deduplication Pipeline (Fclones -> Czkawka)
# Usage: ./dedupe.sh <target_directory>
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'
export LC_ALL=C LANG=C

# --- Configuration ---
readonly TARGET="${1:-}"
readonly RPT_PREFIX="dedupe_report"
# Czkawka flags from request (Quoted)
readonly CZ_EXCLUDES=("-E" "*/.git" "*/tmp*")
readonly CZ_COMMON=("-u" "-W" "-X" "-M" "${CZ_EXCLUDES[@]}")

# --- Validation ---
if [[ -z $TARGET || ! -d $TARGET ]]; then
  printf "Usage: %s <directory>\n" "$0" >&2
  exit 1
fi

# --- Check Dependencies ---
for tool in fclones czkawka-cli; do
  if ! command -v "$tool" &>/dev/null; then
    printf "Error: %s is not installed.\n" "$tool" >&2
    exit 1
  fi
done

# --- Interaction ---
printf "\nTarget: %s\n" "$TARGET"

# 1. Backup Verification
printf "\nSAFETY CHECK\n"
read -r -p "Have you created a backup of this directory? [y/N] " backup_ans
if [[ ! ${backup_ans,,} =~ ^y ]]; then
  printf "Aborting. Please backup your data first.\n"
  exit 1
fi

# 2. Strategy Selection
printf "\nSTRATEGY\n"
printf "1) Hardlink (Safe) - Replaces exact duplicates with hardlinks. Saves space, keeps filenames.\n"
printf "2) Delete   (Risk) - Permanently deletes duplicates.\n"
printf "3) Dry Run  (Info) - Scan and report only.\n"
read -r -p "Select option [1-3]: " strat_ans

MODE="dry"
FCLONES_CMD=""
CZ_ACTION=""

case "$strat_ans" in
  1)
    MODE="hardlink"
    FCLONES_CMD="link"
    # Czkawka hardlink support via CLI is complex/varied;
    # we will skip Czkawka destructive actions in this mode to be safe.
    ;;
  2)
    MODE="delete"
    FCLONES_CMD="remove"
    CZ_ACTION="DELETE"
    ;;
  *)
    MODE="dry"
    ;;
esac

# --- Execution ---
log(){ printf "\n[ %(%H:%M:%S)T ] %s\n" -1 "$*"; }

run_fclones(){
  log "Phase 1: Fclones (Exact Match)"
  local rpt="${RPT_PREFIX}_fclones.txt"

  # 1. Group
  fclones group "$TARGET" >"$rpt"

  local cnt
  cnt=$(grep -c "^[0-9a-f]" "$rpt" || true)

  if [[ $cnt -eq 0 ]]; then
    printf "   No exact duplicates found.\n"
    return
  fi
  printf "   Found %s groups.\n" "$cnt"

  # 2. Action
  if [[ $MODE != "dry" ]]; then
    printf "   EXECUTING: fclones %s...\n" "$FCLONES_CMD"
    fclones "$FCLONES_CMD" <"$rpt"
  else
    printf "   DRY RUN: See %s\n" "$rpt"
  fi
}

run_czkawka(){
  local type="$1"
  log "Phase 2: Czkawka ($type)"

  local cmd=("czkawka-cli" "$type" "$TARGET")
  cmd+=("${CZ_COMMON[@]}")

  if [[ $MODE == "delete" ]]; then
    # Danger: Apply user's delete flags
    cmd+=("-D" "AEN")
    printf "   EXECUTING: Deleting All Except Newest...\n"
    "${cmd[@]}"
  elif [[ $MODE == "hardlink" && $type == "dup" ]]; then
    # Czkawka 'dup' can technically hardlink, but fclones usually handles this better.
    # We run dry here to avoid conflicts or complex flag mapping.
    printf "   Skipping Czkawka action (Fclones handled hardlinks).\n"
    "${cmd[@]}"
  else
    printf "   DRY RUN: Scanning only...\n"
    "${cmd[@]}"
  fi
}

# --- Main ---
run_fclones

# Only run destructive image/video scans if explicitly deleting.
# You cannot hardlink "similar" images (they are different files).
run_czkawka "dup"

if [[ $MODE == "hardlink" ]]; then
  log "Skipping Fuzzy Image/Video scan (Cannot hardlink different files)."
else
  run_czkawka "image"
  run_czkawka "video"
fi

log "Done."

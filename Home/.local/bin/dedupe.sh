#!/usr/bin/env bash
# Role: Media Deduplication Pipeline (Fclones -> Czkawka)
# Usage: ./dedupe.sh <target_directory> [execute]
# Dep: fclones, czkawka-cli, ffmpeg (for video analysis)
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t' LC_ALL=C LANG=C
# --- Configuration ---
readonly TARGET="${1:-}"
readonly MODE="${2:-dry}" # Default to dry-run
readonly RPT_PREFIX="dedupe_report"
# Validate Input
if [[ -z "$TARGET" || ! -d "$TARGET" ]]; then
  printf "Usage: %s <directory> [execute]\n" "$0" >&2
  printf "Error: Target directory missing or invalid.\n" >&2
  exit 1
fi
# User-defined flags from prompt (Quoted to prevent globbing)
# Note: -D AEN = Delete All Except Newest
# Note: Ensure your version of czkawka supports -X -M (custom/version-specific flags)
readonly CZ_EXCLUDES=("-E" "*/.git" "*/tmp*")
readonly CZ_FLAGS=("-u" "-W" "-X" "-M" "${CZ_EXCLUDES[@]}")
# Check Dependencies
for tool in fclones czkawka-cli; do
  if ! command -v "$tool" &>/dev/null; then
    printf "❌ Error: %s is not installed.\n" "$tool" >&2; exit 1
  fi
done
# --- Functions ---
log(){ printf "\n🔹 [ %s ] %s\n" "$(date +%H:%M:%S)" "$*"; }
run_fclones(){
  log "Phase 1: Fclones (Exact Dedupe)"
  local rpt="${RPT_PREFIX}_fclones.txt"
  # 1. Group duplicates
  # --cache is recommended for large datasets
  fclones group "$TARGET" > "$rpt"
  local dupe_count
  dupe_count=$(grep -c "^[0-9a-f]" "$rpt" || true)
  if [[ "$dupe_count" -eq 0 ]]; then
    printf "   No exact duplicates found.\n"; return
  fi
  printf "   Found %s groups of exact duplicates.\n" "$dupe_count"
  # 2. Process
  if [[ "$MODE" == "execute" ]]; then
    printf "   ⚡ EXECUTING deletion on exact matches...\n"
    # Pipe the report into remove. 
    # Safety: fclones handles inode verification.
    fclones remove < "$rpt"
  else
    printf "   🚧 DRY RUN: See %s for list. Run with 'execute' to delete.\n" "$rpt"
  fi
}
run_czkawka(){
  local tool_mode="$1" # dup, image, or video
  log "Phase 2: Czkawka ($tool_mode)"
  local cmd=("czkawka-cli" "$tool_mode" "$TARGET")
  # Append User Flags
  cmd+=("${CZ_FLAGS[@]}")
  # Handle Delete Flag Safety
  if [[ "$MODE" == "execute" ]]; then
    # Dangerous: Automatically deletes All Except Newest
    cmd+=("-D" "AEN")
    printf "   ⚡ EXECUTING deletion (Keep Newest)...\n"
  else
    printf "   🚧 DRY RUN: Scanning only...\n"
    # Ensure -D is NOT passed here to prevent deletion
  fi
  # Exec
  "${cmd[@]}"
}
# --- Execution ---
log "Starting dedupe on: $TARGET"
log "Mode: ${MODE^^}"
# 1. Exact Matches (Fastest/Safest)
run_fclones
# 2. Fuzzy/Specific Matches (Slower/Heuristic)
# Note: 'dup' is redundant if fclones runs, but included per request.
run_czkawka "dup"
run_czkawka "image"
run_czkawka "video"
log "Done."

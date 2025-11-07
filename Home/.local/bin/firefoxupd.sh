#!/usr/bin/env bash
# Source common shell utilities
source "${HOME}/.local/lib/shell-common.sh" || {
  echo "Error: Failed to load shell-common.sh" >&2
  exit 1
}

declare -a found=()
# Check native packages - use mapfile for efficient array population
mapfile -t pacman_lines < <(pacman -Q 2>/dev/null | grep -Ei 'firefox|librewolf|waterfox|floorp|icecat')
for line in "${pacman_lines[@]}"; do
  found+=("pacman: $line")
done

# Check flatpak - use mapfile for efficient array population
mapfile -t flatpak_lines < <(flatpak list --app 2>/dev/null | grep -Ei 'firefox|librewolf|waterfox|floorp|icecat')
for line in "${flatpak_lines[@]}"; do
  found+=("flatpak: $line")
done

# Check binaries in PATH
for browser in firefox librewolf waterfox floorp; do
  if has "$browser"; then
    found+=("binary: $browser")
  fi
done
# Output results
if [[ ${#found[@]} -eq 0 ]]; then
  echo "❌ No Firefox or forks found."
else
  echo "✅ Firefox or forks detected:"
  printf '%s\n' "${found[@]}"
fi

foxdir(){
  local PROFILE_DIR="${HOME}/.mozilla/firefox" ACTIVE_PROF ACTIVE_PROF_DIR
  ACTIVE_PROF=$(awk -F= '/^\[.*\]/{f=0} /^\[Install/{f=1; next} f && /^Default=/{print $2; exit}' "${PROFILE_DIR}/installs.ini" 2>/dev/null)
  [[ -z "$ACTIVE_PROF" ]] && { ACTIVE_PROF=$(awk -F= '/^\[.*\]/{f=0} /^\[Profile[0-9]+\]/{f=1} f && /^Default=1/ {found=1} f && /^Path=/{if(found){print $2; exit}}' "${PROFILE_DIR}/profiles.ini" 2>/dev/null); }
  [[ -n "$ACTIVE_PROF" ]] && { ACTIVE_PROF_DIR="${PROFILE_DIR}/${ACTIVE_PROF}"; printf '%s\n' "$ACTIVE_PROF_DIR"; } || { echo "❌ Could not determine active Firefox profile." >&2; exit 1; }
}
FOXYDIR="$(foxdir)"

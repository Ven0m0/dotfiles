#!/usr/bin/env bash
# arc-raiders-mod.sh - Deploy Arc Raiders config files to Steam Proton paths
# Adapts linutil/arc-raiders-mod.sh to use local dotfiles configs instead of cloning

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
RESET=$'\e[0m'

die()  { printf '%bERROR: %s%b\n' "${RED}" "$*" "${RESET}" >&2; exit 1; }
log()  { printf '%b[v] %s%b\n' "${GREEN}" "$*" "${RESET}"; }
warn() { printf '%b[!] %s%b\n' "${YELLOW}" "$*" "${RESET}"; }

STEAM_APP_ID="1808500"
STEAM_GAME="Arc Raiders"
COMPATDATA_SUFFIX="compatdata/${STEAM_APP_ID}/pfx/drive_c/users/steamuser/Local Settings/Application Data/PioneerGame/Saved/Config/WindowsClient"

find_steamapps() {
    local candidates=(
        "$HOME/.local/share/Steam/steamapps"
        "$HOME/.steam/steam/steamapps"
        "/opt/steam/steamapps"
        "/usr/local/steam/steamapps"
    )

    local vdf="$HOME/.local/share/Steam/config/libraryfolders.vdf"
    if [[ -f "$vdf" ]]; then
        while IFS= read -r line; do
            if [[ "$line" =~ \"path\"[[:space:]]+\"([^\"]+)\" ]]; then
                candidates+=("${BASH_REMATCH[1]}/steamapps")
            fi
        done < "$vdf"
    fi

    for dir in "${candidates[@]}"; do
        if [[ -d "${dir}/common/${STEAM_GAME}" ]]; then
            echo "$dir"
            return 0
        fi
    done
    return 1
}

deploy_configs() {
    local steamapps
    steamapps="$(find_steamapps)"
    [[ -n "$steamapps" ]] || die "Could not locate '${STEAM_GAME}' in any Steam library"
    log "Found Steam library: ${steamapps}"

    local dest="${steamapps}/${COMPATDATA_SUFFIX}"

    if [[ ! -d "$dest" ]]; then
        warn "Compatdata directory missing, creating: ${dest}"
        mkdir -p "$dest" || die "Failed to create directory: ${dest}"
    fi

    log "Deploying Engine.ini..."
    # Remove read-only flag if previously set, to allow overwrite
    chmod u+w "${dest}/Engine.ini" 2>/dev/null || true
    cp "${SCRIPT_DIR}/Engine.ini" "${dest}/Engine.ini" || die "Failed to copy Engine.ini"
    # Lock read-only so the game cannot overwrite custom settings
    chmod 444 "${dest}/Engine.ini"
    log "Engine.ini deployed (locked read-only)"

    log "Deploying GameUserSettings.ini..."
    cp "${SCRIPT_DIR}/GameUserSettings.ini" "${dest}/GameUserSettings.ini" || die "Failed to copy GameUserSettings.ini"
    log "GameUserSettings.ini deployed"

    printf '\n%b[v] Arc Raiders configuration deployed successfully%b\n' "${GREEN}" "${RESET}"
    printf '    Destination: %s\n' "${dest}"
}

deploy_configs

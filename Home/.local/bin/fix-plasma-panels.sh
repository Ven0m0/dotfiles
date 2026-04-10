#!/usr/bin/env bash
set -euo pipefail

has() { command -v -- "$1" &>/dev/null; }
die() { printf '\e[31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
log() { printf '\e[34mINFO: %s\e[0m\n' "$*"; }

# Fix KDE Plasma panels/menus not loading after boot
# Run this when taskbar/panels are missing
set -euo pipefail

has() { command -v -- "$1" &>/dev/null; }
die() { printf '\e[31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
log() { printf '\e[34mINFO: %s\e[0m\n' "$*"; }

# Fix KDE Plasma panels/menus not loading after boot
# Run this when taskbar/panels are missing
echo "Killing plasmashell..."
kill -9 $(pgrep plasmashell) 2>/dev/null
sleep 2

echo "Rebuilding KDE config cache..."
kbuildsycoca6 2>/dev/null

echo "Waiting for plasmashell to respawn..."
sleep 3

if pgrep plasmashell > /dev/null; then
    echo "plasmashell is running (PID: $(pgrep plasmashell))"
else
    echo "Starting plasmashell..."
    plasmashell --no-respawn &
    disown
    sleep 3
fi

echo "Done. Panels should be visible now."

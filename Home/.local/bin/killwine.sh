#!/usr/bin/env bash
set -euo pipefail

# Kill Wine processes safely
has() { command -v "$1" &>/dev/null; }

# Kill wine server
has wineserver && wineserver -k || true

# Kill wine-related processes
mapfile -t pids < <(ps -ef | grep -E -i '(wine|processid|\.exe)' | grep -v grep | awk '{print $2}')
if [[ ${#pids[@]} -gt 0 ]]; then
  kill -9 "${pids[@]}" 2>/dev/null || true
fi

# Kill pressure vessel
pkill -9 pressure-vessel-adverb 2>/dev/null || true

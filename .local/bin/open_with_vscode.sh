#!/usr/bin/env bash
# https://github.com/AhmetCanArslan/linux-scripts/blob/main/openWithVSCode/open_with_vscode.sh
for uri in "$@"; do
    path=$(echo "$uri" | sed 's/^file:\/\///' | sed 's/%20/ /g')
    code --new-window "$path"
done

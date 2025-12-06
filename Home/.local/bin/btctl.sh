#!/usr/bin/env bash
set -euo pipefail
# FZF Wrapper to connect to devices using bluetoothctl

# Check if bluetooth service is running, start if not
if ! systemctl is-active --quiet bluetooth.service; then
  printf "Bluetooth service not running, starting...\n"
  if command -v sudo &>/dev/null; then
    sudo systemctl start bluetooth.service
  else
    systemctl start bluetooth.service
  fi
  sleep 1
fi

# TODO: retry mechanism if connection fails
choice=$(bluetoothctl devices | fzf --prompt="Choose Device: " --height 40% --reverse -m)
device=$(printf '%s' "$choice" | awk '{print $2}')
[[ -n $device ]] || exit 0
bluetoothctl connect "$device"

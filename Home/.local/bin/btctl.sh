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

choice=$(bluetoothctl devices | fzf --prompt="Choose Device: " --height 40% --reverse -m)
device=$(printf '%s' "$choice" | awk '{print $2}')
[[ -n $device ]] || exit 0

# Retry connection with exponential backoff
max_retries=3
retry_count=0
delay=2

while ((retry_count <= max_retries)); do
  if ((retry_count > 0)); then
    printf "Retrying connection (attempt %d/%d) in %ds...\n" "$retry_count" "$max_retries" "$delay"
    sleep "$delay"
    delay=$((delay * 2))
  fi

  if bluetoothctl connect "$device"; then
    printf "Successfully connected to device\n"
    exit 0
  fi

  ((retry_count++))
done

printf "Failed to connect after %d attempts\n" "$max_retries" >&2
exit 1

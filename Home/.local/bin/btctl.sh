#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
sleepy(){ read -rt "${1:-1}" -- <> <(:) &>/dev/null || :; }
systemctl is-active --quiet bluetooth.service || {
  printf "Bluetooth service not running, starting...\n"
  sudo systemctl start bluetooth.service
  sleepy 1
}
choice=$(bluetoothctl devices|fzf --prompt="Choose Device: " --height 40% --reverse -m)
device=$(printf '%s' "$choice"|awk '{print $2}')
[[ -n $device ]] || exit 0
max_retries=3 retry_count=0 delay=2
while ((retry_count <= max_retries)); do
  ((retry_count > 0)) && {
    printf "Retrying (%d/%d) in %ds...\n" "$retry_count" "$max_retries" "$delay"
    sleepy "$delay"
    delay=$((delay * 2))
  }
  bluetoothctl connect "$device" && { printf "Successfully connected\n"; exit 0; }
  ((retry_count++))
done
printf "Failed after %d attempts\n" "$max_retries" >&2
exit 1

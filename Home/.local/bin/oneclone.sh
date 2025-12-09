#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'
export LC_ALL=C LANG=C

rmount(){
  mkdir -p ~/OneDrive
  rclone mount onedrive: ~/OneDrive \
    --vfs-cache-mode full \
    --vfs-cache-max-size 10G \
    --vfs-cache-max-age 24h \
    --dir-cache-time 1h \
    --buffer-size 64M \
    --vfs-read-chunk-size 32M \
    --vfs-read-chunk-size-limit off \
    --tpslimit 4 \
    --daemon
}

rtrans(){
  mkdir -p ~/OneDrive ~/Documents
  rclone copy ~/Documents onedrive:Documents \
    --transfers 8 \
    --checkers 16 \
    --onedrive-chunk-size 128M \
    --tpslimit 4 \
    --progress
}

# shellcheck disable=SC2139
alias mount-drive="rclone mount onedrive: ~/OneDrive --vfs-cache-mode full --vfs-cache-max-size 10G --daemon"

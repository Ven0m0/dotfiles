#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob
export LC_ALL=C LANG=C IFS=$'\n\t'

# Copy ISO/IMG file to USB device with progress indicator
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
# Requires: dd, pv, stat

# Helper functions
die(){ printf '\e[0;31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
log(){ printf '\e[0;33m>>> %s\e[0m\n' "$*"; }
info(){ printf '\e[0;36m### %s\e[0m\n' "$*"; }

usage(){
  cat <<'EOF'
iso-to-usb - Copy ISO/IMG file to USB device with progress

USAGE:
  iso-to-usb ISO_FILE DEVICE

ARGUMENTS:
  ISO_FILE    Path to .iso or .img file
  DEVICE      Block device (e.g., /dev/sdc)

OPTIONS:
  -h, --help  Show this help message

EXAMPLES:
  iso-to-usb fedora-livecd.iso /dev/sdc
  iso-to-usb ubuntu.img /dev/sdb

REQUIREMENTS:
  - dd (for writing to device)
  - pv (for progress indicator)
  - stat (for file size detection)

WARNING:
  This will DESTROY all data on the target device!
  Double-check the device path before proceeding.
EOF
}

check_dependencies(){
  local -a deps=(dd pv stat)
  for cmd in "${deps[@]}"; do
    command -v "$cmd" &>/dev/null || die "Required command '$cmd' not found"
  done
}

check_args(){
  case ${#} in
    1)
      if [[ $1 == -h || $1 == --help ]]; then
        usage
        exit 0
      fi
      die "Expected 2 arguments, got ${#}"
      ;;
    2) ;;
    *)
      die "Expected 2 arguments, got ${#}"
      ;;
  esac

  [[ -f $1 ]] || die "First argument should be a file: $1"

  # Check file extension
  local ext="${1##*.}"
  ext="${ext,,}"
  [[ $ext == iso || $ext == img ]] || die "First argument should be an .iso or .img file: $1"

  [[ -b $2 ]] || die "Destination should be a block device (e.g., /dev/sdc): $2"
}

check_mounts(){
  local device="$1"
  log "Checking if $device is currently mounted..."

  if grep -q "$device" /proc/mounts; then
    die "Device $device is mounted. Unmount it first!"
  fi
}

confirm_copy(){
  log "⚠️  WARNING: This will DESTROY all data on $1!"
  log "Are you sure you want to continue? [y/N]"
  read -r confirm
  if [[ $confirm != y && $confirm != Y ]]; then
    info "Cancelled by user"
    exit 0
  fi
}

copy_iso_to_usb(){
  local iso="$1" destination="$2" iso_size

  iso_size=$(stat -c '%s' "$iso")
  log "Copying $iso (${iso_size} bytes) to $destination..."

  dd if="$iso" bs=4M status=none | \
    pv --size "$iso_size" --progress --timer --eta --rate --bytes | \
    sudo dd of="$destination" bs=4M status=none conv=fsync

  log "Syncing..."
  sync
  log "✓ Copy completed successfully!"
}

main(){
  check_dependencies
  check_args "$@"

  local iso="$1" destination="$2"

  check_mounts "$destination"
  confirm_copy "$destination"
  copy_iso_to_usb "$iso" "$destination"
}

main "$@"

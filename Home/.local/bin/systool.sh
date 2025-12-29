#!/usr/bin/env bash
# systool.sh - System Maintenance Utilities
set -euo pipefail; shopt -s nullglob; IFS=$'\n\t'
# --- Helpers ---
die(){ printf '\e[31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
warn(){ printf '\e[33mWARN: %s\e[0m\n' "$*" >&2; }
log(){ printf '\e[34mINFO: %s\e[0m\n' "$*"; }
has(){ command -v "$1" >/dev/null; }
need(){ has "$1" || die "Missing dependency: $1"; }
# --- Commands ---
cmd_ln2(){
  # Usage: systool ln2 LINK > TARGET  OR  systool ln2 TARGET < LINK
  local link="" target=""
  if [[ "${2:-}" == ">" ]]; then link="$1"; target="$3"
  elif [[ "${2:-}" == "<" ]]; then target="$1"; link="$3"
  else die "Usage: $0 ln2 LINK > TARGET | TARGET < LINK"; fi
  [[ -e "$target" ]] || die "Target '$target' not found"
  mkdir -p "$(dirname "$link")"
  ln -sffn "$target" "$link"
  log "Linked: $link -> $target"
}
cmd_swap(){
  local size="${1:-4G}" path="${2:-/swapfile}"
  [[ -f $path ]] && die "Swap file $path already exists"
  log "Creating ${size} swap at $path..."
  # Try fallocate (fast), failover to dd (compatible)
  if ! sudo fallocate -l "$size" "$path" 2>/dev/null; then
    warn "fallocate failed, using dd..."
    sudo dd if=/dev/zero of="$path" bs=1M count=$(( ${size%G} * 1024 )) status=progress
  fi
  sudo chmod 600 "$path"; sudo mkswap "$path"; sudo swapon "$path"
  if ! grep -q "$path" /etc/fstab; then
    echo "$path none swap sw 0 0" | sudo tee -a /etc/fstab
    log "Added to /etc/fstab"
  fi
  log "Success: $(free -h | awk '/Swap/{print $2}') swap active"
}
cmd_symclean(){
  local dir="${1:-.}"
  log "Removing broken symlinks in $dir..."
  find "$dir" -xtype l -print -delete
}
cmd_usb(){
  local dev="${1:-}" mountpoint="${2:-/mnt/usb}"
  if [[ -z $dev ]]; then
    lsblk -o NAME,TRAN,SIZE,FSTYPE,LABEL,MOUNTPOINT | grep 'usb'
    read -rp "Enter device (e.g. sdb1): " dev
  fi
  [[ $dev == /dev/* ]] || dev="/dev/$dev"
  [[ -b $dev ]] || die "Invalid device: $dev"
  sudo mkdir -p "$mountpoint"
  sudo mount "$dev" "$mountpoint"
  log "Mounted $dev at $mountpoint"
}
cmd_sysz(){
  need du; need sort
  local dir="${1:-.}"
  log "Calculating sizes in $dir (top 20)..."
  du -ah --max-depth=1 "$dir" 2>/dev/null | sort -rh | head -n 20
}
cmd_prsync(){
  local src="${1:-}" dst="${2:-}" jobs="${3:-$(nproc)}"
  [[ -z $src || -z $dst ]] && die "Usage: $0 prsync SRC DST [JOBS]"
  need rsync; need find
  log "Scanning source: $src"
  local tmp; tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  # 1. List files with sizes and sort descending (LPT algorithm for better packing)
  find "$src" -type f -printf "%s %P\n" | sort -nr > "$tmp/files"
  log "Bin-packing files into $jobs chunks..."
  # 2. Initialize bucket sizes
  local -a buckets; for ((i=0; i<jobs; i++)); do buckets[i]=0; done
  # 3. Distribute files to the emptiest bucket (Greedy)
  while read -r size file; do
    local min_idx=0 min_val=${buckets[0]}
    for ((i=1; i<jobs; i++)); do
      if (( buckets[i] < min_val )); then min_val=${buckets[i]}; min_idx=$i; fi
    done
    buckets[min_idx]=$((buckets[min_idx] + size))
    printf "%s\n" "$file" >> "$tmp/chunk_$min_idx"
  done < "$tmp/files"
  
  log "Starting $jobs rsync workers..."
  for ((i=0; i<jobs; i++)); do
    [[ -f "$tmp/chunk_$i" ]] && \
      rsync -a --files-from="$tmp/chunk_$i" "$src" "$dst" &
  done
  wait
  log "Parallel sync complete."
}
usage(){
  cat <<EOF
systool - System Maintenance
Usage: ${0##*/} [COMMAND] [ARGS]

Commands:
  ln2 LINK > TARGET | TARGET < LINK   Smart symlink creation
  swap [SIZE] [PATH]                  Create/enable swap (default: 4G /swapfile)
  symclean [DIR]                      Delete broken symlinks recursively
  usb [DEV] [MOUNT]                   Mount USB device (interactive if no DEV)
  sysz [DIR]                          Show top disk usage in directory
  prsync SRC DST [JOBS]               Parallel rsync with load balancing
EOF
  exit 1
}
# --- Main ---
[[ $# -eq 0 ]] && usage
CMD="$1"; shift
case "$CMD" in
  ln2|swap|symclean|usb|sysz|prsync) "cmd_$CMD" "$@" ;;
  -h|--help) usage ;;
  *) die "Unknown command: $CMD" ;;
esac

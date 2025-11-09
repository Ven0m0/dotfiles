#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob globstar extglob
IFS=$'\n\t'; export LC_ALL=C LANG=C

# sysmaint: unified system helpers
# subcmds:
#   ln2        Intuitive ln wrapper: OPTIONS... LINK_NAME > TARGET  |  OPTIONS... TARGET < LINK_NAME
#   swap       Swap two paths (files/dirs)
#   symclean   Remove broken symlinks in DIR (default: $PWD)
#   usb        Interactive mount/unmount removable partitions (/dev/sd[b-z][0-9]+)
#   sysz       Wrapper for sysz (if present) or minimal fzf systemctl UI
#   prsync     Parallel rsync wrapper (GNU parallel -> xargs -P -> seq)
# Notes:
#   - Uses sudo when needed and available
#   - Aims Arch/Debian/Termux; avoids nonessential deps; fast, safe, concise

# -- utils ---------------------------------------------------------------------

have(){ command -v "$1" &>/dev/null; }
die(){ printf 'error: %s\n' "$*" >&2; exit 1; }
warn(){ printf 'warn: %s\n' "$*" >&2; }
log(){ printf 'info: %s\n' "$*"; }
abspath(){ readlink -f -- "$1"; }

SUDO=""; (( EUID != 0 )) && have sudo && SUDO="sudo"

# -- ln2 -----------------------------------------------------------------------

ln2_usage(){
  printf 'Make links using LINK > TARGET or TARGET < LINK.\n'
  printf 'Usage: sysmaint ln2 [LN_OPTIONS...] LINK_NAME ">" TARGET\n'
  printf '   or: sysmaint ln2 [LN_OPTIONS...] TARGET "<" LINK_NAME\n'
  printf 'Example: sysmaint ln2 -s ~/.config/nvim > ~/dotfiles/nvim\n'
}

ln2_cmd(){
  local -a args; args=("$@")
  (( ${#args[@]} >= 3 )) || { ln2_usage; return 2; }
  [[ " ${args[*]} " =~ \ --help\  || " ${args[*]} " =~ \ -h\  ]] && { ln2_usage; return 0; }

  local op1 op op2
  op2=${args[-1]}
  op=${args[-2]}
  op1=${args[-3]}
  args=("${args[@]::${#args[@]}-3")

  [[ "$op1" == -* ]] && { ln2_usage; return 2; }

  local target link
  case "$op" in
    '>') target=$op2; link=$op1 ;;
    '<') target=$op1; link=$op2 ;;
    *) ln2_usage; return 2 ;;
  esac

  ln "${args[@]}" -- "$target" "$link"
}

# -- swap ----------------------------------------------------------------------

swap_usage(){
  printf 'Swap two filesystem paths.\n'
  printf 'Usage: sysmaint swap PATH1 PATH2\n'
}

swap_cmd(){
  (( $# == 2 )) || { swap_usage; return 2; }
  local a="$1" b="$2" tmp
  if [[ -d "$a" ]]; then
    tmp="tmp.$$.dir"; mkdir -p -- "$tmp"
  else
    tmp="$(mktemp)"
  fi
  mv -- "$a" "$tmp"
  mv -- "$b" "$a"
  if [[ -d "$tmp" && "$tmp" == tmp.*.dir ]]; then
    mv -- "$tmp" "$b"
  else
    mv -- "$tmp" "$b"
  fi
}

# -- symclean ------------------------------------------------------------------

symclean_usage(){
  printf 'Remove broken symlinks in DIR (default: $PWD).\n'
  printf 'Usage: sysmaint symclean [DIR]\n'
}

symclean_cmd(){
  local dir="${1:-$PWD}"
  [[ -d "$dir" ]] || die "not a directory: $dir"
  log "cleaning broken symlinks in: $dir"
  # Robust: broken links => -xtype l (or -L + -type l)
  # Prefer -xtype l (no symlink following surprises)
  find "$dir" -xtype l -print -delete 2>/dev/null || \
  find -L "$dir" -type l -print -delete 2>/dev/null || :
}

# -- usb (mount/umount) --------------------------------------------------------

usb_usage(){
  printf 'Interactive mount/unmount USB partitions.\n'
  printf 'Usage: sysmaint usb [-n COUNT] [-s START_LETTER] [-b MOUNT_BASE]\n'
  printf 'Defaults: COUNT=4 START=b BASE=/mnt/usbstick\n'
}

usb_cmd(){
  local count=4 start="b" base="/mnt/usbstick"
  while (( $# )); do
    case "$1" in
      -n) count="$2"; shift 2 ;;
      -s) start="$2"; shift 2 ;;
      -b) base="${2%/}"; shift 2 ;;
      -h|--help) usb_usage; return 0 ;;
      *) break ;;
    esac
  done

  have lsblk || die "lsblk required"
  local line; local -a lines
  while IFS= read -r line; do lines+=("$line"); done < <(
    lsblk -pn -o NAME,UUID,FSTYPE,LABEL,MOUNTPOINT | grep -E "^/dev/sd[$start-z][0-9]" || :
  )
  local n="${#lines[@]}"
  (( n > 0 )) || { log "no new device detected"; return 0; }

  log "Mount/Umount tool"
  local -a names uuids fss labels mpts
  local i=0
  for line in "${lines[@]}"; do
    # NAME UUID FSTYPE LABEL MOUNTPOINT (LABEL/MOUNTPOINT can contain spaces; constrain with -o order)
    # Safe split: cut first 4 fields, remainder is mountpoint
    local name uuid fs label mp rest
    name="${line%% *}"; rest="${line#* }"
    uuid="${rest%% *}"; rest="${rest#* }"
    fs="${rest%% *}"; rest="${rest#* }"
    label="${rest%% *}"; mp="${rest#* }"
    names[i]="$name"; uuids[i]="$uuid"; fss[i]="$fs"; labels[i]="$label"; mpts[i]="$mp"
    printf '  %2d) %s %s [%s]%s\n' "$((i+1))" "${uuids[i]:-—}" "${fss[i]:-—}" "${labels[i]:-—}" \
      "$([[ -n ${mpts[i]} ]] && printf '  -> %s' "${mpts[i]}")"
    ((i++))
  done
  printf '  q) quit\n'

  local pick=""
  if have fzf; then
    pick="$(printf '%s\n' $(seq 1 "$n") q | fzf --prompt='Choose: ' --height=20% --no-info --border || :)"
  fi
  [[ -z "$pick" ]] && { read -r -p "Choose [1-$n/q]: " pick || :; }
  [[ "$pick" =~ ^[Qq]$ ]] && { log "exit"; return 0; }
  [[ "$pick" =~ ^[0-9]+$ ]] || { warn "invalid choice"; return 1; }
  (( pick>=1 && pick<=n )) || { warn "out of range"; return 1; }
  local idx=$((pick-1))

  local name="${names[idx]}" uuid="${uuids[idx]}" fs="${fss[idx]}" mp="${mpts[idx]}"

  # determine free mountpoint
  local selmp=""
  if [[ -z "$mp" ]]; then
    local k
    for ((k=1; k<=count; k++)); do
      local try="${base}${k}"
      # free if not in current lsblk mountpoints
      local used=0
      for mp in "${mpts[@]}"; do [[ "$mp" == "$try" ]] && { used=1; break; }; done
      (( used == 0 )) && { selmp="$try"; break; }
    done
    [[ -z "$selmp" ]] && die "increase port count with -n"
    $SUDO mkdir -p -- "$selmp" || :
    $SUDO mount -o gid=users,fmask=113,dmask=002 -U "$uuid" "$selmp"
    log "mounted $uuid as $selmp"
  else
    $SUDO umount -- "$mp"
    log "unmounted $uuid [$mp]"
  fi
}

# -- sysz (wrapper/minimal) ----------------------------------------------------

sysz_usage(){
  printf 'Wrapper for sysz; falls back to minimal fzf over systemctl.\n'
  printf 'Usage: sysmaint sysz [args passed to sysz or systemctl]\n'
}

sysz_cmd(){
  local here="$(dirname -- "$0")"
  if [[ -x "$here/sysz" ]]; then
    exec "$here/sysz" "$@"
  fi
  have fzf || die "fzf required for fallback UI (or place sysz beside this script)"
  # minimal fallback
  local pick
  pick="$(
    systemctl list-units --all --no-legend --full --plain --no-pager \
      | awk '{print $1}' | sort -u \
      | fzf --ansi --multi --prompt="Units: " --preview='SYSTEMD_COLORS=1 systemctl status --no-pager -- {1}' --preview-window=70%
  )" || return 1
  [[ -z "$pick" ]] && return 1
  SYSTEMD_COLORS=1 systemctl status --no-pager -- $pick
}

# -- prsync --------------------------------------------------------------------

prsync_usage(){
  printf 'Parallel rsync wrapper.\n'
  printf 'Usage: sysmaint prsync [--parallel=N] RSYNC_ARGS...\n'
  printf 'Notes: requires GNU parallel or falls back to xargs -P/-n 1\n'
}

_prsync_distribute(){ # in: file with "size path"; out: chunk files
  local list="$1" chunks="$2"
  local -a sums; sums=()
  local i; for ((i=0;i<chunks;i++)); do sums[i]=0; : >"${TMPDIR}/chunk.${i}"; done
  local sz path min_i min_v idx=0
  while IFS= read -r sz path; do
    # find min bucket
    min_i=0; min_v=${sums[0]}
    for ((i=1;i<chunks;i++)); do (( ${sums[i]} < min_v )) && { min_v=${sums[i]}; min_i=$i; }; done
    sums[min_i]=$(( sums[min_i] + sz ))
    printf '%s\n' "$path" >> "${TMPDIR}/chunk.${min_i}"
    (( ++idx % 25000 == 0 )) && printf 'info: distributed %d\n' "$idx" >&2
  done < <(cat -- "$list")
  # reverse every other chunk for better pipeline mix
  for ((i=1;i<chunks;i+=2)); do
    [[ -s "${TMPDIR}/chunk.${i}" ]] && tac "${TMPDIR}/chunk.${i}" > "${TMPDIR}/chunk.${i}.r" && mv -f -- "${TMPDIR}/chunk.${i}.r" "${TMPDIR}/chunk.${i}" || :
  done
}

prsync_cmd(){
  (( $# >= 1 )) || { prsync_usage; return 2; }
  local par=""
  if [[ "${1:-}" == --parallel=* ]]; then par="${1##*=}"; shift; fi
  [[ -n "$par" ]] || par="$(nproc 2>/dev/null || printf '10')"
  log "using up to ${par} processes"

  TMPDIR="$(mktemp -d)"; trap 'rm -rf "$TMPDIR"' EXIT

  log "building file list (dry-run)"
  local list="${TMPDIR}/files.all"
  rsync "$@" --out-format="%l %n" --no-v --dry-run 2>/dev/null \
    | grep -vF "sending incremental file list" \
    | sort -nr > "$list"
  local total_files total_size
  total_files=$(wc -l < "$list")
  total_size=$(awk '{ts+=$1}END{printf "%.0f", ts}' < "$list")
  log "${total_files} ($(( total_size/1024**2 )) MB) files to transfer"
  (( total_files > 0 )) || { warn "nothing to transfer"; return 0; }

  log "distributing among chunks"
  _prsync_distribute "$list" "$par"

  log "starting transfers"
  if have parallel; then
    find "$TMPDIR" -type f -name 'chunk.*' -print0 \
      | parallel -0 -j "$par" -t -- rsync --files-from={} "$@"
  elif have xargs; then
    find "$TMPDIR" -type f -name 'chunk.*' -print0 \
      | xargs -0 -n1 -P"$par" -I{} sh -c 'rsync --files-from="{}" "$@"' _ "$@"
  else
    # sequential
    while IFS= read -r f; do rsync --files-from="$f" "$@"; done < <(find "$TMPDIR" -type f -name 'chunk.*')
  fi
}

# -- usage ---------------------------------------------------------------------

usage(){
  printf 'sysmaint: ln2 | swap | symclean | usb | sysz | prsync\n'
  printf 'Usage: sysmaint <subcmd> [args]\n'
}

# -- main ----------------------------------------------------------------------

main(){
  local cmd="${1:-}"; shift || :
  case "$cmd" in
    ln2) ln2_cmd "$@" ;;
    swap) swap_cmd "$@" ;;
    symclean) symclean_cmd "$@" ;;
    usb) usb_cmd "$@" ;;
    sysz) sysz_cmd "$@" ;;
    prsync) prsync_cmd "$@" ;;
    ""|-h|--help|help) usage ;;
    *) die "unknown subcmd: $cmd" ;;
  esac
}
main "$@"

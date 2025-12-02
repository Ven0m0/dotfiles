#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob globstar extglob
IFS=$'\n\t'
export LC_ALL=C LANG=C

have() { command -v "$1" &> /dev/null; }
die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}
warn() { printf 'warn: %s\n' "$*" >&2; }
log() { printf 'info: %s\n' "$*"; }
SUDO=""
((EUID != 0)) && have sudo && SUDO=sudo

usage() {
  printf 'sysmaint subcmds:\n'
  printf '  ln2        LINK > TARGET | TARGET < LINK\n'
  printf '  swap       Swap two paths\n'
  printf '  symclean   Remove broken symlinks in DIR\n'
  printf '  usb        Interactive mount/unmount removable partitions\n'
  printf '  sysz       Interactive systemctl UI (integrated)\n'
  printf '  prsync     Parallel rsync wrapper\n'
}

# -------- ln2 ----------
ln2_usage() { printf 'Usage: sysmaint ln2 [ln opts] LINK > TARGET | TARGET < LINK\n'; }
ln2_cmd() {
  local -a a
  a=("$@")
  ((${#a[@]} >= 3)) || {
    ln2_usage
    return 2
  }
  [[ " ${a[*]} " =~ \ -h\  || " ${a[*]} " =~ \ --help\  ]] && {
    ln2_usage
    return 0
  }
  local op1 op op2
  op2=${a[-1]}
  op=${a[-2]}
  op1=${a[-3]}
  a=("${a[@]:0:${#a[@]}-3}")
  [[ $op1 == -* ]] && {
    ln2_usage
    return 2
  }
  local tgt link
  case "$op" in
    '>')
      tgt=$op2
      link=$op1
      ;;
    '<')
      tgt=$op1
      link=$op2
      ;;
    *)
      ln2_usage
      return 2
      ;;
  esac
  ln "${a[@]}" -- "$tgt" "$link"
}

# -------- swap ----------
swap_usage() { printf 'Usage: sysmaint swap A B\n'; }
swap_cmd() {
  (($# == 2)) || {
    swap_usage
    return 2
  }
  local file_a="$1" file_b="$2" tmp
  if [[ -d $file_a ]]; then
    tmp="tmp.$$.dir"
    mkdir -p "$tmp"
  else tmp="$(mktemp)"; fi
  mv -- "$file_a" "$tmp" && mv -- "$file_b" "$file_a" && mv -- "$tmp" "$file_b"
}

# -------- symclean ----------
symclean_usage() { printf 'Usage: sysmaint symclean [DIR]\n'; }
symclean_cmd() {
  local d="${1:-$PWD}"
  [[ -d $d ]] || die "not dir: $d"
  log "cleaning broken symlinks in $d"
  find "$d" -xtype l -print -delete 2> /dev/null || find -L "$d" -type l -print -delete 2> /dev/null || :
}

# -------- usb ----------
usb_usage() { printf 'Usage: sysmaint usb [-n COUNT] [-s START_LETTER] [-b BASE=/mnt/usbstick]\n'; }
usb_cmd() {
  local cnt=4 start="b" base="/mnt/usbstick"
  while (($#)); do
    case "$1" in
      -n)
        cnt="$2"
        shift 2
        ;;
      -s)
        start="$2"
        shift 2
        ;;
      -b)
        base="${2%/}"
        shift 2
        ;;
      -h | --help)
        usb_usage
        return 0
        ;;
      *) break ;;
    esac
  done
  have lsblk || die lsblk
  mapfile -t lines < <(lsblk -pn -o NAME,UUID,FSTYPE,LABEL,MOUNTPOINT | grep -E "^/dev/sd[$start-z][0-9]" || :)
  ((${#lines[@]})) || {
    log "no new device"
    return 0
  }
  log "Mount/Umount tool"
  local i=0
  local -a names uuids fss labels mpts
  for line in "${lines[@]}"; do
    local name uuid fs label mp rest
    name="${line%% *}"
    rest="${line#* }"
    uuid="${rest%% *}"
    rest="${rest#* }"
    fs="${rest%% *}"
    rest="${rest#* }"
    label="${rest%% *}"
    mp="${rest#* }"
    names[i]="$name"
    uuids[i]="$uuid"
    fss[i]="$fs"
    labels[i]="$label"
    mpts[i]="$mp"
    printf ' %2d) %s %s [%s]%s\n' "$((i + 1))" "${uuids[i]:-—}" "${fss[i]:-—}" "${labels[i]:-—}" \
      "$([[ -n ${mpts[i]} ]] && printf ' -> %s' "${mpts[i]}")"
    ((i++))
  done
  printf '  q) quit\n'
  local pick=""
  if have fzf; then pick="$(printf '%s\n' "$(seq 1 "${#lines[@]}")" q | fzf --prompt='Choose: ' --height=15 --no-info || :)"; fi
  [[ -z $pick ]] && { read -r -p "Choose [1-${#lines[@]}/q]: " pick || :; }
  [[ $pick =~ ^[Qq]$ ]] && {
    log exit
    return 0
  }
  [[ $pick =~ ^[0-9]+$ ]] || {
    warn invalid
    return 1
  }
  ((pick >= 1 && pick <= ${#lines[@]})) || {
    warn range
    return 1
  }
  local idx=$((pick - 1))
  local uuid="${uuids[idx]}" mp="${mpts[idx]}"
  if [[ -z $mp ]]; then
    local k free=""
    for ((k = 1; k <= cnt; k++)); do
      local candidate="${base}${k}"
      local used=0
      for mp in "${mpts[@]}"; do [[ $mp == "$candidate" ]] && {
        used=1
        break
      }; done
      ((used == 0)) && {
        free="$candidate"
        break
      }
    done
    [[ -z $free ]] && die "increase -n"
    "$SUDO" mkdir -p "$free" || :
    "$SUDO" mount -o gid=users,fmask=113,dmask=002 -U "$uuid" "$free"
    log "mounted $uuid at $free"
  else
    "$SUDO" umount -- "$mp"
    log "unmounted $uuid [$mp]"
  fi
}

# -------- sysz (integrated) ----------
sysz_help_keys() {
  cat << 'EOF'
Keys:
  TAB toggle sel
  ctrl-v cat unit
  ctrl-s pick states
  ctrl-r daemon-reload
  ctrl-p hist prev
  ctrl-n hist next
  ? show keys
EOF
}

sysz_help() {
  cat << EOF
sysz: interactive systemctl via fzf.
Usage: sysmaint sysz [opts] [command] [-- args]
Opts:
  -u,--user       only user units
  --sys,--system  only system units
  -s,--state ST   filter state (repeatable)
  -V,--verbose    show systemctl cmds
  -v,--version    show version
  -h,--help       help

Commands (otherwise interactive):
  start stop restart status edit reload enable disable cat journal follow mask unmask show

$(sysz_help_keys)
EOF
}

sysz_cmd() {
  have fzf || die "fzf required"
  local PROG="sysz" VER=1.4.3 VERBOSE=false
  local HIST="${SYSZ_HISTORY:-${XDG_CACHE_HOME:-$HOME/.cache}/sysz/history}"
  local -a MANAGERS STATES
  if ((EUID == 0)); then MANAGERS=(system); else MANAGERS=(user system); fi

  local arg
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -u | --user)
        MANAGERS=(user)
        shift
        ;;
      --sys | --system)
        MANAGERS=(system)
        shift
        ;;
      -s | --state)
        STATES+=("--state=$2")
        shift 2
        ;;
      --state=*)
        STATES+=("$1")
        shift
        ;;
      -V | --verbose)
        VERBOSE=true
        shift
        ;;
      -v | --version)
        printf '%s %s\n' "$PROG" "$VER"
        return 0
        ;;
      -h | --help)
        sysz_help
        return 0
        ;;
      *) break ;;
    esac
  done

  local CMD=""
  local -a EXTRA
  while [[ $# -gt 0 ]]; do
    case "$1" in
      _fzf_preview)
        shift
        sysz_preview "$@"
        return
        ;;
      _fzf_cat)
        shift
        sysz_cat "$@"
        return
        ;;
      --)
        shift
        EXTRA=("$@")
        break
        ;;
      re)
        CMD=restart
        shift
        ;;
      s)
        CMD=status
        shift
        ;;
      ed)
        CMD=edit
        shift
        ;;
      en)
        CMD=enable
        shift
        ;;
      d | dis)
        CMD=disable
        shift
        ;;
      j)
        CMD=journal
        shift
        ;;
      f)
        CMD=follow
        shift
        ;;
      c)
        CMD='cat'
        shift
        ;;
      *)
        CMD="$1"
        shift
        ;;
    esac
  done

  mkdir -p "$(dirname "$HIST")"
  : > "$HIST" || :

  # validate states
  local ST
  for ST in "${STATES[@]}"; do
    ST="${ST##*=}"
    [[ -n $ST ]] && systemctl --state=help | grep -Fx "$ST" &> /dev/null || die "bad state: $ST"
  done

  # loop for unit selection
  local -a UNITS
  local KEY
  while :; do
    mapfile -t UNITS < <(sysz_list_units "${MANAGERS[@]}" "${STATES[@]}" \
      | fzf --multi --ansi --expect=ctrl-r,ctrl-s \
        --history="$HIST" \
        --prompt="Units: " \
        --header='? help' \
        --bind "?:preview(echo '$(sysz_help_keys)')" \
        --bind "ctrl-v:preview('$0' sysz _fzf_cat {})" \
        --preview="'$0' sysz _fzf_preview {}" \
        --preview-window=70%)
    ((${#UNITS[@]})) || return 1
    KEY="${UNITS[0]}"
    UNITS=("${UNITS[@]:1}")
    case "$KEY" in
      ctrl-r)
        sysz_daemon_reload
        continue
        ;;
      ctrl-s)
        sysz_pick_states STATES
        continue
        ;;
    esac
    ((${#UNITS[@]})) || return 1
    break
  done

  local -a CMDS
  if [[ -n $CMD ]]; then
    CMDS=("$CMD")
  else
    CMDS=("$(sysz_pick_commands "${UNITS[@]}" "${EXTRA[@]}")")
    ((${#CMDS[@]})) || return 1
  fi

  local U M UNIT CODE=0
  for U in "${UNITS[@]}"; do
    M=$(sysz_manager "$U")
    UNIT="${U##* }"
    for CMD in "${CMDS[@]}"; do
      sysz_exec "$M" "$UNIT" "$CMD" "${EXTRA[@]}" || CODE=$?
      [[ ${#UNITS[@]} -eq 1 ]] && return "$CODE"
    done
  done
}

sysz_manager() { case ${1%% *} in '[user]') printf -- '--user' ;; '[system]') printf -- '--system' ;; *) die "mgr" ;; esac }

sysz_cat() {
  local M=$(sysz_manager "$1")
  local U="${1##* }"
  SYSTEMD_COLORS=1 systemctl "$M" cat -- "$U"
}
sysz_preview() {
  local M=$(sysz_manager "$1")
  local U="${1##* }"
  if [[ $U == *@.* ]]; then sysz_cat "$@"; else SYSTEMD_COLORS=1 systemctl "$M" status --no-pager -- "$U"; fi
}

sysz_show() { systemctl "$1" show "$2" -p "$3" --value; }

sysz_sort() {
  local line mgr unit uclean n type
  while IFS= read -r line; do
    mgr=${line%% *}
    unit=${line##* }
    uclean=${unit//$'\e'[\[(]*([0-9;])[@-n]/}
    if [[ $unit =~ \.service$ ]]; then
      n=0
      [[ $mgr == "[system]" ]] && n=1
    elif [[ $unit =~ \.timer$ ]]; then
      n=2
      [[ $mgr == "[system]" ]] && n=3
    elif [[ $unit =~ \.socket$ ]]; then
      n=4
      [[ $mgr == "[system]" ]] && n=5
    elif [[ $mgr == "[user]" ]]; then
      n=6
    else
      n=7
    fi
    type=${unit##*.}
    printf '%s\n' "$n$type${unit//-/} $mgr $unit"
  done | sort -bifu | cut -d' ' -f2-
}

sysz_list() {
  local -a args
  args=(--all --no-legend --full --plain --no-pager "$@")
  (
    systemctl list-units "${args[@]}"
    systemctl list-unit-files "${args[@]}"
  ) \
    | sort -u -t ' ' -k1,1 | while read -r l; do
    local unit=${l%% *}
    if [[ $l == *" active "* ]]; then
      printf '\033[0;32m%s\033[0m\n' "$unit"
    elif [[ $l == *" failed "* ]]; then
      printf '\033[0;31m%s\033[0m\n' "$unit"
    elif [[ $l == *" not-found "* ]]; then
      printf '\033[1;33m%s\033[0m\n' "$unit"
    else
      printf '%s\n' "$unit"
    fi
  done
}

sysz_list_units() {
  local -a mgrs states
  mgrs=("$@")
  states=()
  # separate states
  local x
  for x in "${mgrs[@]}"; do [[ $x == --state=* ]] && states+=("$x"); done
  # filter out states from mgrs
  local -a mm
  for x in "${mgrs[@]}"; do [[ $x != --state=* ]] && mm+=("${x#--}"); done
  local M
  for M in "${mm[@]}"; do sysz_list "--$M" "${states[@]}" | sed -E "s/^/[$M] /"; done | sysz_sort
}

sysz_daemon_reload() {
  local picks
  picks="$(printf '%s\n' '[system] daemon-reload' '[user] daemon-reload' | fzf --multi --no-info --prompt='Reload: ')" || return 1
  [[ -z $picks ]] && return 1
  local line
  while IFS= read -r line; do
    case "$line" in '[user] daemon-reload') systemctl --user daemon-reload ;;
    '[system] daemon-reload') ((EUID == 0)) && systemctl --system daemon-reload || sudo systemctl --system daemon-reload ;;
    esac
  done <<< "$picks"
}

sysz_pick_states() {
  local -n ref="$1"
  mapfile -t chosen < <(systemctl --state=help | grep -v ':' | grep -v 'ing' | sort -u | grep -v '^$' \
    | fzf --multi --prompt='States: ') || return 1
  ((${#chosen[@]})) || return 0
  ref=()
  local st
  for st in "${chosen[@]}"; do ref+=("--state=$st"); done
}

sysz_pick_commands() {
  local -a units
  units=()
  while [[ $1 != "" && $1 != "--" ]]; do
    units+=("$1")
    shift
  done
  shift || :
  local -a extra
  extra=("$@")
  local MULTI=false ACTIVE LOAD UF CAN U PREVIEW
  if ((${#units[@]} > 1)); then
    MULTI=true
    PREVIEW="$(printf '%s\n' "${units[@]}")"
    PREVIEW_CMD="echo -n '$PREVIEW'"
  else
    U="${units[0]}"
    [[ $U == *@.* ]] && read -r -p "$U param: " PARAM && U="${U/@/@$PARAM}" && units[0]="$U"
    ACTIVE=$(sysz_show "$(sysz_manager "$U")" "${U##* }" ActiveState)
    LOAD=$(sysz_show "$(sysz_manager "$U")" "${U##* }" LoadState)
    UF=$(sysz_show "$(sysz_manager "$U")" "${U##* }" UnitFileState)
    CAN=$(sysz_show "$(sysz_manager "$U")" "${U##* }" CanReload)
    PREVIEW_CMD="'$0' sysz _fzf_preview '$U'"
  fi
  mapfile -t cmds < <(
    echo status "${extra[*]}"
    [[ $MULTI == true || $ACTIVE == active ]] && printf '\033[0;31mrestart\033[0m %s\n' "${extra[*]}"
    [[ $MULTI == true || $ACTIVE != active ]] && printf '\033[0;32mstart\033[0m %s\n' "${extra[*]}"
    [[ $MULTI == true || $ACTIVE == active ]] && printf '\033[0;31mstop\033[0m %s\n' "${extra[*]}"
    [[ $MULTI == true || $UF != enabled ]] && {
      printf '\033[0;32menable\033[0m %s\n' "${extra[*]}"
      printf '\033[0;32menable\033[0m --now %s\n' "${extra[*]}"
    }
    [[ $MULTI == true || $UF == enabled ]] && {
      printf '\033[0;31mdisable\033[0m %s\n' "${extra[*]}"
      printf '\033[0;31mdisable\033[0m --now %s\n' "${extra[*]}"
    }
    echo journal "${extra[*]}"
    echo follow "${extra[*]}"
    [[ $MULTI == true || $CAN == yes ]] && printf 'reload %s\n' "${extra[*]}"
    [[ $MULTI == true || ($UF != masked && $LOAD != masked) ]] && printf '\033[0;31mmask\033[0m %s\n' "${extra[*]}"
    [[ $MULTI == true || $UF == masked || $LOAD == masked ]] && printf '\033[0;32munmask\033[0m %s\n' "${extra[*]}"
    echo cat "${extra[*]}"
    echo edit "${extra[*]}"
    echo show "${extra[*]}"
  )
  mapfile -t pick < <(printf '%s\n' "${cmds[@]}" | fzf --multi --ansi --no-info --prompt='Commands: ' --preview="$PREVIEW_CMD" --preview-window=80%)
  printf '%s\n' "${pick[@]}"
}

sysz_exec() {
  local M="$1" UNIT="$2" CMD="$3"
  shift 3
  local -a args
  args=("$@")
  local base="${CMD%% *}"
  local run=(systemctl "$M")
  case "$base" in
    journal)
      sysz_journal "$M" "$UNIT" -xe "${args[@]}"
      return
      ;;
    follow)
      sysz_journal "$M" "$UNIT" -xef "${args[@]}"
      return
      ;;
    status)
      SYSTEMD_COLORS=1 "${run[@]}" status --no-pager "${args[@]}" -- "$UNIT"
      return
      ;;
    cat | show | edit)
      "${run[@]}" "$base" "${args[@]}" -- "$UNIT"
      return
      ;;
    mask | unmask | start | stop | restart | reload | enable | disable)
      "${run[@]}" "$CMD" "${args[@]}" -- "$UNIT" || return $?
      SYSTEMD_COLORS=1 "${run[@]}" status --no-pager -- "$UNIT"
      return
      ;;
    *)
      "${run[@]}" "$CMD" "${args[@]}" -- "$UNIT"
      return
      ;;
  esac
}

sysz_journal() {
  local M="$1" UNIT="$2"
  shift 2
  if [[ $M == --user ]]; then
    journalctl --user-unit="$UNIT" "$@"
  else
    if ((EUID != 0)); then sudo journalctl --unit="$UNIT" "$@"; else journalctl --unit="$UNIT" "$@"; fi
  fi
}

# -------- prsync ----------
prsync_usage() { printf 'Usage: sysmaint prsync [--parallel=N] RSYNC_ARGS...\n'; }
prsync_cmd() {
  (($#)) || {
    prsync_usage
    return 2
  }
  local par=""
  if [[ $1 == --parallel=* ]]; then
    par="${1##*=}"
    shift
  fi
  [[ -n $par ]] || par="$(nproc 2> /dev/null || printf 10)"
  log "parallel=$par"
  local TMP
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  log "dry-run listing"
  rsync "$@" --out-format="%l %n" --no-v --dry-run 2> /dev/null \
    | grep -vF "sending incremental file list" | sort -nr > "$TMP/all"
  local total
  total=$(wc -l < "$TMP/all")
  local size
  size=$(awk '{s+=$1}END{printf "%.0f",s}' < "$TMP/all")
  log "$total files ($((size / 1024 ** 2)) MB)"
  ((total)) || {
    warn none
    return 0
  }
  # distribute
  local i
  for ((i = 0; i < par; i++)); do : > "$TMP/chunk.$i"; done
  local -a sum
  for ((i = 0; i < par; i++)); do sum[i]=0; done
  local sz path idx=0
  while read -r sz path; do
    local mi=0 mv=${sum[0]} j
    for ((j = 1; j < par; j++)); do ((${sum[j]} < mv)) && {
      mv=${sum[j]}
      mi=$j
    }; done
    sum[mi]=$((sum[mi] + sz))
    printf '%s\n' "$path" >> "$TMP/chunk.$mi"
    ((++idx % 25000 == 0)) && log "distributed $idx"
  done < "$TMP/all"
  for ((i = 1; i < par; i += 2)); do [[ -s "$TMP/chunk.$i" ]] && tac "$TMP/chunk.$i" > "$TMP/r" && mv "$TMP/r" "$TMP/chunk.$i" || :; done
  log transferring
  if have parallel; then
    find "$TMP" -name 'chunk.*' -print0 | parallel -0 -j "$par" -t -- rsync --files-from={} "$@"
  elif have xargs; then
    find "$TMP" -name 'chunk.*' -print0 | xargs -0 -n1 -P"$par" -I{} rsync --files-from={} "$@"
  else
    while read -r f; do rsync --files-from="$f" "$@"; done < <(find "$TMP" -name 'chunk.*')
  fi
}

main() {
  local c="${1:-}"
  shift || :
  case "$c" in
    ln2) ln2_cmd "$@" ;;
    swap) swap_cmd "$@" ;;
    symclean) symclean_cmd "$@" ;;
    usb) usb_cmd "$@" ;;
    sysz) sysz_cmd "$@" ;;
    prsync) prsync_cmd "$@" ;;
    "" | -h | --help | help) usage ;;
    *) die "unknown subcmd: $c" ;;
  esac
}
main "$@"

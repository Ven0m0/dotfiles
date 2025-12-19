#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# shellcheck source=../lib/bash-common.sh
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s
source "${s%/bin/*}/lib/bash-common.sh"
init_strict
msg(){ printf '%s\n' "$@"; }

# Prefer kdotool, then ydotool. Keys fallback to wtype only if a click backend exists.
click_backend=""
key_backend=""
if has kdotool; then
  click_backend="kdotool"
  key_backend="kdotool"
elif has ydotool; then
  click_backend="ydotool"
  key_backend="ydotool"
elif has wtype; then
  key_backend="wtype"
fi

[[ -z $click_backend ]] && die "Need kdotool or ydotool for clicks."
[[ -z $key_backend ]] && die "Need kdotool, ydotool, or wtype for keys."
# Config (tweak if needed)
FISH_CLICK_DOWN_S=0.10
FISH_RECAST_WAIT_S=9.50
FISH_POST_CAST_S=0.50
EAT_INTERVAL_S=60
EAT_PRE_SWAP_S=0.15
EAT_SWAP_TO_FOOD_KEY=6
EAT_SWAP_BACK_KEY=1
EAT_HOLD_S=3.50
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/mc_afk"
PID_FISH="$STATE_DIR/fish.pid"
PID_EAT="$STATE_DIR/eat.pid"
mkdir -p "$STATE_DIR"
is_running(){ local p=$1; [[ -n ${p:-} && -d /proc/$p ]]; }
key_name(){
  local k=$1
  if [[ $k =~ ^[0-9]$ ]]; then
    printf 'KEY_%s' "$k"
  else
    printf '%s' "$k"
  fi
}
press_key(){
  local kname
  kname=$(key_name "$1")
  case "$key_backend" in
    kdotool) kdotool key --delay 0 --clearmodifiers "$kname" ;;
    ydotool) ydotool key "$kname" ;;
    wtype)   wtype -k "$kname" ;;
  esac
}
click_right_once(){
  case "$click_backend" in
    kdotool) kdotool click 3 ;;
    ydotool) ydotool click 0x111 ;; # BTN_RIGHT
  esac
}
start_fish(){
  local pid
  [[ -f $PID_FISH ]] && pid=$(<"$PID_FISH")
  if is_running "${pid:-}"; then
    log "Fishing already running (pid ${pid})."
    return
  fi
  ( while :; do
      click_right_once
      sleep "$FISH_CLICK_DOWN_S"
      sleep "$FISH_RECAST_WAIT_S"
      click_right_once
      sleep "$FISH_CLICK_DOWN_S"
      sleep "$FISH_POST_CAST_S"
    done ) &
  echo $! > "$PID_FISH"
  log "Fishing started (pid $!)."
}
stop_fish(){
  local p=""
  [[ -f $PID_FISH ]] && p=$(<"$PID_FISH")
  if is_running "$p"; then
    kill "$p" && rm -f "$PID_FISH"
    log "Fishing stopped."
  else
    rm -f "$PID_FISH"
    log "Fishing not running."
  fi
}
start_eat(){
  local pid
  [[ -f $PID_EAT ]] && pid=$(<"$PID_EAT")
  if is_running "${pid:-}"; then
    log "Eating timer already running (pid ${pid})."
    return
  fi
  ( while :; do
      sleep "$EAT_INTERVAL_S"
      sleep "$EAT_PRE_SWAP_S"
      press_key "$EAT_SWAP_TO_FOOD_KEY"
      sleep 0.2
      click_right_once
      sleep "$EAT_HOLD_S"
      sleep 0.2
      press_key "$EAT_SWAP_BACK_KEY"
      sleep 0.2
    done ) &
  echo $! > "$PID_EAT"
  log "Eating timer started (pid $!)."
}

stop_eat(){
  local p=""
  [[ -f $PID_EAT ]] && p=$(<"$PID_EAT")
  if is_running "$p"; then
    kill "$p" && rm -f "$PID_EAT"
    log "Eating timer stopped."
  else
    rm -f "$PID_EAT"
    log "Eating timer not running."
  fi
}
status(){
  local pf="" pe=""
  [[ -f $PID_FISH ]] && pf=$(<"$PID_FISH")
  [[ -f $PID_EAT ]] && pe=$(<"$PID_EAT")
  if is_running "$pf"; then log "Fishing: running (pid $pf)"; else log "Fishing: stopped"; fi
  if is_running "$pe"; then log "Eating: running (pid $pe)"; else log "Eating: stopped"; fi
}
usage(){
  msg "Usage: $0 [fish-start|fish-stop|fish-toggle|eat-start|eat-stop|eat-toggle|stop-all|status]"
  msg "Bind via xbindkeys/sxhkd:"
  msg "  F7 -> bash -lc '$0 fish-toggle'"
  msg "  F6 -> bash -lc '$0 eat-toggle'"
  exit 1
}
cmd="${1:-}"
case "$cmd" in
  fish-start)   start_fish ;;
  fish-stop)    stop_fish ;;
  fish-toggle)  { [[ -f $PID_FISH ]] && pid=$(<"$PID_FISH"); is_running "${pid:-}"; } && stop_fish || start_fish ;;
  eat-start)    start_eat ;;
  eat-stop)     stop_eat ;;
  eat-toggle)   { [[ -f $PID_EAT ]] && pid=$(<"$PID_EAT"); is_running "${pid:-}"; } && stop_eat || start_eat ;;
  stop-all)     stop_fish; stop_eat ;;
  status)       status ;;
  *)            usage ;;
esac

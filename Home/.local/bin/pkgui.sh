#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'

# --- Init ---
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
export HOME="/home/${SUDO_USER:-$USER}" SHELL="$(command -v bash)"
readonly R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' C=$'\e[36m' M=$'\e[35m' BD=$'\e[1m' D=$'\e[0m' UL=$'\e[4m' IT=$'\e[3m'
readonly CFG="${XDG_CONFIG_HOME:-$HOME/.config}/pkgui" CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/pkgui" HIST="${PKGUI_HISTORY:-$CACHE/history}" PKGLIST="${PKGUI_PKGLIST:-$CFG/packagelist}"
readonly FILE_NATIVE="$CFG/native. txt" FILE_AUR="$CFG/aur.txt"
declare -A _pkgui_cmd_cache _CI _CQ _CL _CLO _CUPD
_CUPD_TIME=0
mkdir -p "$CFG" "$CACHE" "${HIST%/*}"

# --- Helpers ---
_pkgui_has(){
  [[ -n ${_pkgui_cmd_cache[$1]:-} ]] && return "${_pkgui_cmd_cache[$1]}"
  command -v "$1" &>/dev/null && _pkgui_cmd_cache["$1"]=0||_pkgui_cmd_cache["$1"]=1
  return "${_pkgui_cmd_cache[$1]}"
}
_pkgui_die(){ printf '%b[ERR]%b %s\n' "$R" "$D" "$*" >&2; exit 1; }
_pkgui_msg(){ printf '%b%s%b\n' "$G" "$*" "$D"; }
_pkgui_warn(){ printf '%b[WARN]%b %s\n' "$Y" "$D" "$*" >&2; }

# --- Package Manager Detection ---
for p in ${PARUZ:-paru yay pacman}; do _pkgui_has "$p" && PAC="$p" && break; done
[[ -z ${PAC:-} ]] && _pkgui_die "No pkg mgr (pacman/paru/yay)"
for f in ${FINDER:-sk fzf}; do _pkgui_has "$f" && FND="$f" && break; done
[[ -z ${FND:-} ]] && _pkgui_die "No fuzzy finder (sk/fzf)"
FZF_THEME="${FZF_THEME:-hl: italic:#FFFF00,hl+:bold: underline:#FF0000,fg:#98A0C5,fg+:bold:#FFFFFF,bg:#13172A,bg+:#0F1222,border:#75A2F7,label: bold:#75A2F7,preview-fg:#C0CAF5,preview-bg:#0F1222,marker: bold:#FF0000,pointer:bold:#FF0000,prompt:bold:#75A2F7,spinner:#FF0000,header: italic:#75A2F7,info:#FFFF00,scrollbar:#75A2F7,separator:#75A2F7,gutter:#13172A}"

_pkgui_ver(){ printf '%b%s%b v5. 3.0 - Unified Arch Package Manager TUI\n' "$BD" "${0##*/}" "$D"; }
_pkgui_help(){
  cat <<'EOF'
USAGE:  pkgui [CMD|FLAG] [ARGS]
FLAGS:  -s TERM (search) -S TERM (install) -l (list) -R (remove) -u (update) -i (info) -h (help) -v (version)
CMDS:  
  PACKAGE:   s/S/l/R/A/O/U/u/F/b/a
  SYSTEM:   M/C/m/f/k  
  LISTS:    P/B/T/L/X/I  
  CONFIG:   i/n/h/v
  ORPHAN:   orphan [-l|-a] (list/auto-remove orphaned packages)
FZF:  Tab(select) Ctrl-i(install) Ctrl-r(remove) Ctrl-s(info) Ctrl-p(PKGBUILD) Ctrl-/(layout) ?(help)
EOF
}

_pkgui_fzf(){
  local -a o=(--ansi --cycle --reverse --inline-info --no-scrollbar --color="$FZF_THEME" --history="$HIST")
  [[ $FND == sk ]] && o+=(--no-hscroll)
  while (($#)); do
    case $1 in
      -m) o+=(-m); shift ;;
      -h) o+=(--header "$2"); shift 2 ;;
      -p) o+=(--preview "$2" --preview-window='down: 60%: wrap'); shift 2 ;;
      -l) o+=(--preview-label "$2"); shift 2 ;;
      -b) o+=(--bind "$2"); shift 2 ;;
      *) shift ;;
    esac
  done
  "$FND" "${o[@]}"
}

# --- Info & Cache ---
_pkgui_info(){ [[ -n ${_CI[$1]:-} ]] && printf '%s\n' "${_CI[$1]}" && return; local r; r=$("$PAC" --color=always -Si "$1" 2>/dev/null | grep -v '^ '); _CI[$1]=$r; printf '%s\n' "$r"; }
_pkgui_infoq(){ [[ -n ${_CQ[$1]:-} ]] && printf '%s\n' "${_CQ[$1]}" && return; local r; r=$("$PAC" -Qi --color=always "$1" 2>/dev/null); _CQ[$1]=$r; printf '%s\n' "$r"; }
_pkgui_list(){ [[ -n ${_CL[$*]:-} ]] && printf '%s\n' "${_CL[$*]}" && return; local r; r=$("$PAC" -Ss --quiet "$@" 2>/dev/null||: ); _CL[$*]=$r; printf '%s\n' "$r"; }
_pkgui_listq(){ [[ -n ${_CLO[$*]:-} ]] && printf '%s\n' "${_CLO[$*]}" && return; local r; r=$("$PAC" -Qs --quiet "$@" 2>/dev/null||:); _CLO[$*]=$r; printf '%s\n' "$r"; }
_pkgui_prev_pkg(){
  local pkg=$1 mode=${2:-repo}
  if [[ $mode == aur ]]; then
    printf "=== Info ===\n"; "$PAC" --color=always -Si "$pkg" 2>/dev/null||echo "N/A"
    printf "\n=== PKGBUILD ===\n"; _pkgui_has curl && curl -fsSL "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD? h=$pkg" 2>/dev/null||: 
    printf "\n=== Tree ===\n"; _pkgui_has curl && curl -fsSL "https://aur.archlinux.org/cgit/aur.git/tree/? h=$pkg" 2>/dev/null | grep 'tree/' | sed -n 's/.*tree\/\([^?"]*\).*/\1/p' | sort -u | while read -r f; do echo "  - $f"; done||:
  else
    _pkgui_info "$pkg"
  fi
}

# --- AUR RPC Search Integration ---
_pkgui_search_aur_rpc(){
  _pkgui_has curl||_pkgui_die "curl required for AUR search"
  _pkgui_has jq||_pkgui_die "jq required for AUR search"
  local query=${1:-}
  [[ -z $query ]] && { read -rp "AUR search term: " query; [[ -z $query ]] && return 1; }
  
  _pkgui_msg "Searching AUR for '$query'..."
  local raw preview_fn
  raw=$(curl -fsSL "https://aur.archlinux.org/rpc/?v=5&type=search&arg=$query" 2>/dev/null)
  
  local count; count=$(jq -r '.resultcount' <<<"$raw")
  ((count==0)) && { _pkgui_warn "No results for '$query'"; return 1; }
  
  preview_fn='
    pkg=$(cut -f1 <<<{})
    curl -fsSL "https://aur.archlinux.org/rpc/?v=5&type=info&arg=$pkg" 2>/dev/null | jq -r ". results[0] | \"Name:         \(.Name // \"N/A\")\nVersion:     \(.Version // \"N/A\")\nMaintainer:  \(.Maintainer // \"orphan\")\nVotes:       \(.NumVotes // 0)\nPopularity:  \(.Popularity // 0.0)\nOut-of-date:  \(if .OutOfDate then \"YES\" else \"no\" end)\nDescription: \(.Description // \"N/A\")\nURL:         \(.URL // \"N/A\")\nLicense:     \(.License // [] | join(\", \"))\""
  '
  
  export -f _pkgui_fzf; export FND FZF_THEME HIST PAC
  local selected
  selected=$(jq -r '.results[] | "\(.Name)\t\(.Version)\t\(.Maintainer//"-")\t\(.Description//"-")"' <<<"$raw" | \
    _pkgui_fzf -m \
      -h $'Ctrl-i: install Ctrl-p:PKGBUILD Ctrl-s:info' \
      -l "[AUR:  $count results]" \
      -p "bash -c '$preview_fn'" \
      -b "ctrl-i: execute($PAC -S {1} </dev/tty >/dev/tty 2>&1)+abort" \
      -b "ctrl-p:execute(curl -fsSL 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h={1}' | less)+abort" | cut -f1)
  
  [[ -z $selected ]] && return 0
  printf '%s\n' "$selected"
}

# --- Search & Local ---
_pkgui_search(){
  export -f _pkgui_info _pkgui_fzf _pkgui_prev_pkg; export PAC FND FZF_THEME HIST; declare -gA _CI
  _pkgui_list "$@" | _pkgui_fzf -m -h $'Ctrl-i: install Ctrl-r:remove Ctrl-s:info Ctrl-p:PKGBUILD' -l '[search]' -p "bash -c '_pkgui_info {}'" -b "ctrl-i:execute($PAC -S {} </dev/tty >/dev/tty 2>&1)+abort" -b "ctrl-r:execute($PAC -Rns {} </dev/tty >/dev/tty 2>&1)+abort"
}
_pkgui_local(){
  export -f _pkgui_infoq _pkgui_fzf; export PAC FND FZF_THEME HIST; declare -gA _CQ
  _pkgui_listq "$@" | _pkgui_fzf -m -h $'Ctrl-r:remove Ctrl-s:info' -l '[local]' -p "bash -c '_pkgui_infoq {}'" -b "ctrl-r:execute($PAC -Rns {} </dev/tty >/dev/tty 2>&1)+abort"
}
_pkgui_browse_aur(){
  export -f _pkgui_prev_pkg _pkgui_fzf; export PAC FND FZF_THEME HIST
  _pkgui_msg "Loading AUR..."
  "$PAC" -Slq 2>/dev/null | _pkgui_fzf -m -h $'Ctrl-i:install Ctrl-p: PKGBUILD' -l '[AUR]' -p "bash -c '_pkgui_prev_pkg {} aur'" -b "ctrl-i:execute($PAC -S {} </dev/tty >/dev/tty 2>&1)+abort" -b "ctrl-p:execute(curl -fsSL 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h={}' | less)+abort"
}

# --- Orphan Management ---
_pkgui_orphans(){
  local mode="${1:-interactive}" -a orphans
  mapfile -t orphans < <("$PAC" -Qdttq 2>/dev/null)
  local count=${#orphans[@]}
  
  if ((count==0)); then
    _pkgui_msg "No orphaned packages found!"
    return 0
  fi
  
  case $mode in
    list)
      printf '%bFound %d orphaned packages:%b\n\n' "$Y" "$count" "$D"
      for pkg in "${orphans[@]}"; do
        local size desc
        size=$("$PAC" -Qi "$pkg" 2>/dev/null | awk '/Installed Size/{print $4,$5}')
        desc=$("$PAC" -Qi "$pkg" 2>/dev/null | awk -F':  ' '/Description/{print $2}')
        printf '%b▸ %s%b\n  Size: %s\n  %s\n\n' "$B" "$pkg" "$D" "$size" "$desc"
      done
      ;;
    auto)
      _pkgui_msg "Auto-removing $count orphans..."
      [[ $PAC == pacman ]] && sudo pacman -Rns --noconfirm --nosave "${orphans[@]}"||"$PAC" -Rns --noconfirm --nosave "${orphans[@]}"
      _pkgui_msg "Complete!"
      ;;
    interactive)
      export -f _pkgui_infoq _pkgui_fzf; export PAC FND FZF_THEME HIST; declare -gA _CQ
      printf '%s\n' "${orphans[@]}" | _pkgui_fzf -m -h $'Ctrl-r:remove Enter: remove' -l "[orphan:  $count]" -p "bash -c '_pkgui_infoq {}'" -b "ctrl-r:execute($PAC -Rns {} </dev/tty >/dev/tty 2>&1)+abort" -b "enter:execute($PAC -Rns {} </dev/tty >/dev/tty 2>&1)+abort"
      ;;
  esac
}

_pkgui_opt_deps(){
  export -f _pkgui_infoq _pkgui_fzf; export PAC FND FZF_THEME HIST; declare -gA _CQ
  "$PAC" -Qttdq 2>/dev/null | _pkgui_fzf -m -h 'Select optional deps' -l '[optional]' -p "bash -c '_pkgui_infoq {}'"
}

# --- Install/Remove ---
_pkgui_inst(){ local -a p; mapfile -t p; ((${#p[@]}==0)) && return; [[ $PAC == pacman ]] && sudo pacman -S "${p[@]}"||"$PAC" -S "${p[@]}"; }
_pkgui_rm(){ local -a p; mapfile -t p; ((${#p[@]}==0)) && return; [[ $PAC == pacman ]] && sudo pacman -Rns --nosave "${p[@]}"||"$PAC" -Rns --nosave "${p[@]}"; }

# --- Update ---
_pkgui_upd_check(){
  local now pac aur=0 flat=0; now=$(printf '%(%s)T' -1)
  if ((now-_CUPD_TIME<300)) && [[ -n ${_CUPD[pac]:-} ]]; then
    pac=${_CUPD[pac]}; aur=${_CUPD[aur]:-0}; flat=${_CUPD[flat]:-0}
  else
    _pkgui_msg "Checking updates... "; pac=$(checkupdates 2>/dev/null | wc -l)
    [[ $PAC != pacman ]] && aur=$("$PAC" -Qua 2>/dev/null | wc -l)
    _pkgui_has flatpak && flat=$(flatpak remote-ls --updates 2>/dev/null | wc -l)
    _CUPD[pac]=$pac; _CUPD[aur]=$aur; _CUPD[flat]=$flat; _CUPD_TIME=$now
  fi
  printf '\n%bUpdate Summary:%b\nPacman: %b%d%b\n' "$BD" "$D" "$C" "$pac" "$D"
  ((aur>0)) && printf 'AUR:      %b%d%b\n' "$C" "$aur" "$D"
  ((flat>0)) && printf 'Flatpak:%b%d%b\n' "$C" "$flat" "$D"
  printf '\n'
}
_pkgui_upd_full(){
  _pkgui_msg "Full update..."
  [[ $PAC == pacman ]] && sudo pacman -Syu||"$PAC" -Syu
  _pkgui_has flatpak && { _pkgui_msg "Flatpak... "; flatpak update -y --noninteractive; sudo flatpak update -y --noninteractive &>/dev/null||: ; }
  _pkgui_msg "Complete!"
}
_pkgui_upd_flat(){ _pkgui_has flatpak||{ _pkgui_warn "Flatpak not installed"; return 1; }; _pkgui_msg "Flatpak..."; flatpak update -y --noninteractive; sudo flatpak update -y --noninteractive; }

# --- System ---
_pkgui_mirrors(){
  if _pkgui_has reflector; then _pkgui_msg "Reflector... "; sudo reflector --verbose --protocol https --age 6 --sort rate --save /etc/pacman.d/mirrorlist; sudo pacman -Syy
  elif _pkgui_has pacman-mirrors; then _pkgui_msg "pacman-mirrors..."; sudo pacman-mirrors -f 0 && sudo pacman -Syy
  else _pkgui_warn "Install reflector"; fi
}
_pkgui_clean(){
  _pkgui_msg "Cleaning..."
  [[ $PAC == pacman ]] && sudo pacman -Sc||"$PAC" -Sc
  _pkgui_has paccache && sudo paccache -rk2
  [[ -d $HOME/.cache/yay ]] && paccache -rk1 --cachedir "$HOME/.cache/yay" &>/dev/null
  [[ -d $HOME/.cache/paru ]] && paccache -rk1 --cachedir "$HOME/.cache/paru" &>/dev/null
}
_pkgui_fw(){
  _pkgui_has fwupdmgr||{ _pkgui_warn "Install fwupd"; return 1; }
  _pkgui_msg "Firmware... "; fwupdmgr refresh --force &>/dev/null
  if fwupdmgr get-updates 2>/dev/null | grep -qE 'No updatable|No updates'; then echo "None"
  else fwupdmgr get-updates; read -rp "Update?  [y/N] " ans; [[ ${ans,,} == y ]] && fwupdmgr update; fi
}
_pkgui_svc(){ _pkgui_msg "Failed services..."; local f; f=$(systemctl --failed --no-pager --no-legend | wc -l); ((f>0)) && systemctl --failed --no-pager||echo "None"; }
_pkgui_maint(){
  _pkgui_msg "Maintenance scan..."
  printf '\n%b=== Orphans ===%b\n' "$BD" "$D"; "$PAC" -Qdttq 2>/dev/null | wc -l | xargs printf '%d\n'
  printf '\n%b=== Optional ===%b\n' "$BD" "$D"; "$PAC" -Qettq 2>/dev/null | wc -l | xargs printf '%d\n'
  printf '\n%b=== Cache ===%b\n' "$BD" "$D"; du -sh /var/cache/pacman/pkg/ 2>/dev/null||echo "N/A"
  printf '\n%b=== Failed Svc ===%b\n' "$BD" "$D"; systemctl --failed --no-pager --no-legend | wc -l | xargs printf '%d\n'
  printf '\n'
}

# --- Lists ---
_pkgui_gen_lists(){
  local d="$CFG/lists"; mkdir -p "$d"; _pkgui_msg "Generating..."
  pacman -Qeq >"$d/explicit.txt"; pacman -Qdq >"$d/deps.txt"; pacman -Qnq >"$d/native.txt"; pacman -Qmq >"$d/foreign.txt"; pacman -Qdttq 2>/dev/null >"$d/orphans.txt"||:
  expac -H M '%m %n' | sort -h >"$d/by-size.txt"; expac --timefmt='%Y-%m-%d %T' '%l %n' | sort >"$d/by-install.txt"
  _pkgui_has flatpak && flatpak list >"$d/flatpak. txt"
  _pkgui_msg "Done:  $d"; find "$d" -name '*.txt' -printf '%p %s\n'
}
_pkgui_backup(){ local b="$PKGLIST. $(date +%Y%m%d-%H%M%S)"; pacman -Qeq >"$b"; _pkgui_msg "Backup: $b"; }
_pkgui_restore(){
  export -f _pkgui_fzf; export FND FZF_THEME HIST; local b
  compgen -G "$PKGLIST.*" >/dev/null||{ _pkgui_warn "No backups"; return 1; }
  b=$(find .  -maxdepth 1 -name "$PKGLIST.*" -printf '%T@ %p\0' | sort -zrn | cut -zd' ' -f2- | tr '\0' '\n' | _pkgui_fzf -h "Backup" -p "cat {}")
  [[ -z $b ]] && return
  _pkgui_msg "Restoring:  $b"
  [[ $PAC == pacman ]] && xargs -a "$b" sudo pacman -S --needed||xargs -a "$b" "$PAC" -S --needed
}
_pkgui_sync_list(){ _pkgui_msg "Syncing... "; pacman -Qeq | sort >"$PKGLIST"; _pkgui_msg "Synced: $PKGLIST"; }
_pkgui_export(){
  _pkgui_msg "Exporting native... "; pacman -Qqne >"$FILE_NATIVE"; _pkgui_msg "Native: $FILE_NATIVE ($(wc -l <"$FILE_NATIVE"))"
  _pkgui_msg "Exporting AUR..."; pacman -Qqme >"$FILE_AUR"; _pkgui_msg "AUR: $FILE_AUR ($(wc -l <"$FILE_AUR"))"
  printf '\n%bExport:%b\nNative:  %s\nAUR: %s\n' "$BD" "$D" "$FILE_NATIVE" "$FILE_AUR"
}
_pkgui_import(){
  [[ -s $FILE_NATIVE ]] && { _pkgui_msg "Importing native..."; sudo pacman -S --needed - <"$FILE_NATIVE"||_pkgui_warn "Issues"; }||_pkgui_warn "Skip native"
  if [[ -s $FILE_AUR ]]; then
    [[ $PAC == pacman ]] && _pkgui_warn "AUR needs paru/yay"||{ _pkgui_msg "Importing AUR..."; "$PAC" -S --needed - <"$FILE_AUR"||_pkgui_warn "Issues"; }
  else _pkgui_warn "Skip AUR"; fi
  _pkgui_msg "Complete!"
}
_pkgui_info_sys(){
  local now total=0 explicit=0 deps=0 orphans=0 foreign=0 flatpak_count=0; now=$(printf '%(%s)T' -1)
  if ((now-${_CI[time]:-0}>60)); then
    local -a pkg_all pkg_e pkg_d pkg_o pkg_m
    mapfile -t pkg_all < <(pacman -Qq 2>/dev/null); mapfile -t pkg_e < <(pacman -Qeq 2>/dev/null); mapfile -t pkg_d < <(pacman -Qdq 2>/dev/null); mapfile -t pkg_o < <(pacman -Qdttq 2>/dev/null); mapfile -t pkg_m < <(pacman -Qmq 2>/dev/null)
    _CI[total]=${#pkg_all[@]}; _CI[explicit]=${#pkg_e[@]}; _CI[deps]=${#pkg_d[@]}; _CI[orphans]=${#pkg_o[@]}; _CI[foreign]=${#pkg_m[@]}; _CI[time]=$now
  fi
  total=${_CI[total]}; explicit=${_CI[explicit]}; deps=${_CI[deps]}; orphans=${_CI[orphans]}; foreign=${_CI[foreign]}
  _pkgui_has flatpak && flatpak_count=$(flatpak list 2>/dev/null | wc -l)
  printf '%b=== System ===%b\n%bHost:%b     %s\n%bKernel:%b   %s\n%bUptime:%b   %s\n%bPkgs:%b     %d\n%bExplicit:%b %d\n%bDeps:%b     %d\n%bOrphans:%b  %d\n%bForeign:%b  %d\n%bManager:%b  %s\n%bFinder:%b   %s\n' "$BD" "$D" "$BD" "$D" "$(hostname)" "$BD" "$D" "$(uname -r)" "$BD" "$D" "$(uptime -p)" "$BD" "$D" "$total" "$BD" "$D" "$explicit" "$BD" "$D" "$deps" "$BD" "$D" "$orphans" "$BD" "$D" "$foreign" "$BD" "$D" "$PAC" "$BD" "$D" "$FND"
  ((flatpak_count>0)) && printf '%bFlatpak:%b %d\n' "$BD" "$D" "$flatpak_count"
  printf '\n'
}
_pkgui_notify(){
  _pkgui_has notify-send||{ _pkgui_warn "Install libnotify"; return 1; }
  local pac aur=0; pac=$(checkupdates 2>/dev/null | wc -l)
  [[ $PAC != pacman ]] && aur=$("$PAC" -Qua 2>/dev/null | wc -l)
  ((pac>0||aur>0)) && { notify-send "pkgui:  Updates" "Pacman: $pac, AUR: $aur" --icon=dialog-information; _pkgui_msg "Notified:  Pacman=$pac, AUR=$aur"; }||_pkgui_msg "Up to date"
}

# --- Main ---
main(){
  [[ $EUID -eq 0 ]] && _pkgui_die "Do not run as root.  Sudo will be requested when needed."
  
  case "${1:-}" in
    -s) shift; _pkgui_search "$@" ;;
    -S) shift; _pkgui_search "$@" | _pkgui_inst ;;
    -l) _pkgui_local ;;
    -R) _pkgui_local | _pkgui_rm ;;
    -u) _pkgui_upd_full ;;
    -i) _pkgui_info_sys ;;
    -v|--version) _pkgui_ver; exit 0 ;;
    -h|--help) _pkgui_help; exit 0 ;;
    orphan)
      shift
      case "${1:-interactive}" in
        -l|--list) _pkgui_orphans list ;;
        -a|--auto) _pkgui_orphans auto ;;
        -h|--help) cat <<'EOF'
pkgui orphan - Manage orphaned packages

Usage:  pkgui orphan [OPTIONS]
  -l, --list    List orphans without removal prompt
  -a, --auto    Auto-remove all orphans (no confirmation)
  (default)     Interactive fuzzy finder
EOF
          ;;
        *) _pkgui_orphans interactive ;;
      esac
      ;;
    *) ;;
  esac
  [[ $# -eq 0 ]] && _pkgui_menu
}

_pkgui_menu(){
  local choice
  while : ; do
    choice=$(cat <<'MENU' | "$FND" --prompt='Action:  ' --height=40 --header="pkgui v5.3" || exit 0
s - Search packages
S - Search & install
l - List local
R - Remove packages
A - Remove orphans (interactive)
O - Remove optional deps
U - Check updates
u - System update
F - Update flatpak
b - Browse AUR
a - AUR search & install
M - Maintenance scan
C - Clean cache
m - Mirrors
f - Firmware
k - Failed services
P - Generate pkg lists
B - Backup list
T - Restore backup
L - Sync packagelist
X - Export (native+AUR)
I - Import (native+AUR)
i - System info
n - Desktop notify
h - Help
v - Version
MENU
    )
    case "${choice%% *}" in
      s) _pkgui_search ;; S) _pkgui_search | _pkgui_inst ;; l) _pkgui_local ;; R) _pkgui_local | _pkgui_rm ;; A) _pkgui_orphans interactive ;; O) _pkgui_opt_deps | _pkgui_rm ;; U) _pkgui_upd_check ;; u) _pkgui_upd_full ;; F) _pkgui_upd_flat ;; b) _pkgui_browse_aur ;; a) _pkgui_search_aur_rpc | _pkgui_inst ;; M) _pkgui_maint ;; C) _pkgui_clean ;; m) _pkgui_mirrors ;; f) _pkgui_fw ;; k) _pkgui_svc ;; P) _pkgui_gen_lists ;; B) _pkgui_backup ;; T) _pkgui_restore ;; L) _pkgui_sync_list ;; X) _pkgui_export ;; I) _pkgui_import ;; i) _pkgui_info_sys ;; n) _pkgui_notify ;; h) _pkgui_help ;; v) _pkgui_ver ;;
      *) continue ;;
    esac
  done
}

main "$@"

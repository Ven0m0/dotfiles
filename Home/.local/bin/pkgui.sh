#!/usr/bin/env bash
# pkgui - Enhanced unified package manager TUI
# Merged features from pacui, parus, fuzzy-pkg-finder, cylon
set -euo pipefail; shopt -s lastpipe nullglob globstar extglob
export LC_ALL=C LANG=C SHELL="$(command -v bash)" HOME="/home/${SUDO_USER:-$USER}"
# Colors
readonly RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' BLU=$'\e[34m'
readonly CYN=$'\e[36m' MGN=$'\e[35m' BLD=$'\e[1m' DEF=$'\e[0m' UL=$'\e[4m'
# Paths
readonly CFG="${XDG_CONFIG_HOME:-$HOME/.config}/pkgui"
readonly CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/pkgui"
readonly PKGLIST="${CFG}/pkglists"
readonly AUR_META="${CACHE}/aur-meta"
mkdir -p "${CFG}" "${CACHE}" "${PKGLIST}" "${AUR_META}"
# Helpers
has(){ command -v "$1" &>/dev/null; }
err(){ printf '%b[ERR]%b %s\n' "${RED}" "${DEF}" "$*" >&2; }
die(){ err "$@"; exit 1; }
msg(){ printf '%b%s%b\n' "${GRN}" "$*" "${DEF}"; }
warn(){ printf '%b[WARN]%b %s\n' "${YLW}" "${DEF}" "$*"; }
info(){ printf '%b[INFO]%b %s\n' "${BLU}" "${DEF}" "$*"; }
# Pkg mgr & fuzzy finder
for p in ${PARUZ:-paru yay pacman}; do has "$p" && PAC="$p" && break; done
[[ -z ${PAC:-} ]] && die "No pkg mgr (pacman/paru/yay)"
for f in ${FINDER:-sk fzf}; do has "$f" && FND="$f" && break; done
[[ -z ${FND:-} ]] && die "No fuzzy finder (sk/fzf)"
# Cache
declare -A _CACHE_INFO _CACHE_INFOQ _CACHE_LIST _CACHE_LOCALLIST

_ver(){
  printf '%b%s%b -- %bv4.0.0%b Enhanced unified pacman/paru TUI\n' \
    "${BLD}" "${0##*/}" "${DEF}" "${UL}" "${DEF}"
  printf 'Features: pacui + parus + fuzzy-pkg-finder + cylon\n'
}

_help(){
  cat <<EOF
${BLD}USAGE${DEF}  ${0##*/} ${UL}CMD${DEF} [${UL}ARGS${DEF}]

${BLD}PACKAGE OPERATIONS${DEF}
  s         Search packages
  l         List local packages
  S         Search & install
  D         Search & download only
  R         Remove packages
  A         Remove orphans
  O         Remove optional deps (not required)
  U         Check for updates
  u         System update (all)
  F         Update flatpak packages
  N         Update snap packages

${BLD}SYSTEM MAINTENANCE${DEF}
  M         Run system maintenance scan
  C         Clean package cache
  V         Show vulnerable packages (arch-audit)
  W         Show Arch news (RSS)
  m         Mirror management
  
${BLD}PACKAGE LISTS${DEF}
  P         Generate package lists
  B         Backup package list
  T         Restore from backup

${BLD}INFO & CONFIG${DEF}
  i         System info
  n         Desktop notification of updates
  c         Edit config file
  -h, h     Show this help
  -v, v     Show version

${BLD}KEYS${DEF}
  Tab        Select/multi-select
  Enter      Confirm action
  Ctrl-P     Preview PKGBUILD (AUR)
  Ctrl-S     View detailed info
  Ctrl-O     Download only
  Ctrl-/     Toggle preview
  Alt-P      Toggle preview
  Alt-J/K    Scroll preview
  Ctrl-N/B   Next/prev selected

${BLD}EXAMPLES${DEF}
  ${0##*/} s firefox       Search firefox
  ${0##*/} S firefox       Install firefox
  ${0##*/} U               Check updates
  ${0##*/} u               Full system update
  ${0##*/} V               Check vulnerable pkgs
  ${0##*/} P               Generate pkg lists
EOF
}
_fzf(){
  local -a opts=(--ansi --cycle --no-mouse --reverse --inline-info)
  opts+=(--color='pointer:green,marker:green')
  [[ ${FND} == sk ]] && opts+=(--no-hscroll) || opts+=(--no-scrollbar)
  while (($#)); do
    case "$1" in
      -m) opts+=(-m); shift ;;
      -h) opts+=(--header "$2"); shift 2 ;;
      -p) opts+=(--preview "$2" --preview-window='down:65%:wrap'); shift 2 ;;
      -l) opts+=(--preview-label "$2"); shift 2 ;;
      -b) opts+=(--bind "$2"); shift 2 ;;
      *) shift ;;
    esac
  done
  "${FND}" "${opts[@]}"
}
_info(){
  [[ -n ${_CACHE_INFO[$1]:-} ]] && { printf '%s\n' "${_CACHE_INFO[$1]}"; return 0; }
  local r; r=$("${PAC}" --color=always --noconfirm -Si "$1" 2>/dev/null | grep --color=never -v '^ ')
  _CACHE_INFO[$1]="${r}"; printf '%s\n' "${r}"
}
_infoq(){
  [[ -n ${_CACHE_INFOQ[$1]:-} ]] && { printf '%s\n' "${_CACHE_INFOQ[$1]}"; return 0; }
  local r; r=$("${PAC}" -Qs --color=always "^$1$" && printf '\n' && "${PAC}" -Qi --list --color=always "$1" 2>/dev/null)
  _CACHE_INFOQ[$1]="${r}"; printf '%s\n' "${r}"
}
_getlist(){
  [[ -n ${_CACHE_LIST[$*]:-} ]] && { printf '%s\n' "${_CACHE_LIST[$*]}"; return 0; }
  local r; r=$("${PAC}" -Ss --quiet "$@" 2>/dev/null || :)
  _CACHE_LIST[$*]="${r}"; printf '%s\n' "${r}"
}
_getlocal(){
  [[ -n ${_CACHE_LOCALLIST[$*]:-} ]] && { printf '%s\n' "${_CACHE_LOCALLIST[$*]}"; return 0; }
  local r; r=$("${PAC}" -Qs --quiet "$@" 2>/dev/null || :)
  _CACHE_LOCALLIST[$*]="${r}"; printf '%s\n' "${r}"
}
# Sync AUR metadata
_aur_sync(){
  local meta="${AUR_META}/packages-meta.txt"
  local d1 d2
  [[ -f ${meta} ]] && d1=$(stat -c %y "${meta}") || d1="1970-01-01"
  d1="${d1:0:10}"; d2=$(date -I'date')
  [[ ${d2///-/} > ${d1///-/} ]] || return 0
  info "Syncing AUR metadata..."
  [[ -d ${AUR_META} ]] || mkdir -p "${AUR_META}"
  if has curl; then
    curl -fsSL https://aur.archlinux.org/packages-meta-ext-v1.json.gz 2>/dev/null | \
      zcat | has jq && jq -r '.[] | "\(.Name)\t\(.Description)"' > "${meta}" || :
  fi
}
# Preview with PKGBUILD support
_preview_pkg(){
  local pkg="$1" mode="${2:-repo}"
  if [[ ${mode} == aur ]]; then
    printf "=== Package Info ===\n"
    "${PAC}" --color=always -Si "${pkg}" 2>/dev/null || echo "No info"
    printf "\n=== PKGBUILD Preview ===\n"
    has curl && curl -fsSL "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=${pkg}" 2>/dev/null || :
  else
    _info "${pkg}"
  fi
}
_search(){
  export -f _info _fzf _preview_pkg; export PAC FND; declare -gA _CACHE_INFO
  _getlist "$@" | _fzf -m \
    -h $'Enter:install  Ctrl-O:download  Ctrl-S:info  Ctrl-P:PKGBUILD\nAlt-P:toggle preview  Alt-J/K:scroll' \
    -l '[package info]' \
    -p "bash -c '_info {}'" \
    -b "ctrl-s:execute(bash -c '_info {} | less -R')" \
    -b "ctrl-p:execute(bash -c '_preview_pkg {} aur | less -R')" \
    -b "alt-p:toggle-preview" \
    -b "alt-d:preview-half-page-down,alt-u:preview-half-page-up" \
    -b "alt-k:preview-up,alt-j:preview-down" \
    -b "ctrl-n:next-selected,ctrl-b:prev-selected"
}
_local(){
  export -f _infoq _fzf; export PAC FND; declare -gA _CACHE_INFOQ
  _getlocal "$@" | _fzf -m \
    -h $'Enter:remove  Ctrl-S:info\nAlt-P:toggle preview  Alt-J/K:scroll' \
    -l '[package info]' \
    -p "bash -c '_infoq {}'" \
    -b "ctrl-s:execute(bash -c '_infoq {} | less -R')" \
    -b "alt-p:toggle-preview" \
    -b "alt-d:preview-half-page-down,alt-u:preview-half-page-up" \
    -b "alt-k:preview-up,alt-j:preview-down" \
    -b "ctrl-n:next-selected,ctrl-b:prev-selected"
}
_orphans(){
  export -f _infoq _fzf; export PAC FND; declare -gA _CACHE_INFOQ
  "${PAC}" -Qdttq "$@" 2>/dev/null | _fzf -m \
    -h $'Enter:remove  Ctrl-S:info\nAlt-P:toggle preview  Alt-J/K:scroll' \
    -l '[orphan package info]' \
    -p "bash -c '_infoq {}'" \
    -b "ctrl-s:execute(bash -c '_infoq {} | less -R')" \
    -b "alt-p:toggle-preview" \
    -b "alt-d:preview-half-page-down,alt-u:preview-half-page-up" \
    -b "alt-k:preview-up,alt-j:preview-down" \
    -b "ctrl-n:next-selected,ctrl-b:prev-selected"
}

# Optional deps not explicitly installed
_optional_deps(){
  export -f _infoq _fzf; export PAC FND; declare -gA _CACHE_INFOQ
  pacman -Qttdq 2>/dev/null | _fzf -m \
    -h $'Enter:remove optional deps\nAlt-P:toggle preview  Alt-J/K:scroll' \
    -l '[optional deps]' \
    -p "bash -c '_infoq {}'" \
    -b "ctrl-s:execute(bash -c '_infoq {} | less -R')" \
    -b "alt-p:toggle-preview" \
    -b "ctrl-n:next-selected,ctrl-b:prev-selected"
}

_inst(){
  local -a pkgs=(); mapfile -t pkgs
  (( ${#pkgs[@]} == 0 )) && return 0
  if [[ ${PAC} == pacman ]]; then
    sudo pacman --noconfirm -S "${pkgs[@]}"
  else
    "${PAC}" --noconfirm -S "${pkgs[@]}"
  fi
}
_download(){
  local -a pkgs=(); mapfile -t pkgs
  (( ${#pkgs[@]} == 0 )) && return 0
  if [[ ${PAC} == pacman ]]; then
    sudo pacman -Syw "${pkgs[@]}"
  else
    "${PAC}" -Syw "${pkgs[@]}"
  fi
}
_rmv(){
  local -a pkgs=(); mapfile -t pkgs
  (( ${#pkgs[@]} == 0 )) && return 0
  if [[ ${PAC} == pacman ]]; then
    sudo pacman -Rns --nosave "${pkgs[@]}"
  else
    "${PAC}" -Rns --nosave "${pkgs[@]}"
  fi
}

# Check updates (from fuzzy-pkg-finder/pacui)
_check_updates(){
  msg "Checking for updates..."
  local pac_up aur_up flat_up snap_up
  pac_up=$(checkupdates 2>/dev/null | wc -l)
  aur_up=0
  [[ ${PAC} != pacman ]] && aur_up=$("${PAC}" -Qua 2>/dev/null | wc -l)
  flat_up=0; has flatpak && flat_up=$(flatpak remote-ls --updates 2>/dev/null | wc -l)
  printf '\n%bUpdate Summary:%b\n' "${BLD}" "${DEF}"
  printf '  Pacman:  %b%d%b\n' "${CYN}" "${pac_up}" "${DEF}"
  [[ ${aur_up} -gt 0 ]] && printf '  AUR:     %b%d%b\n' "${CYN}" "${aur_up}" "${DEF}"
  [[ ${flat_up} -gt 0 ]] && printf '  Flatpak: %b%d%b\n' "${CYN}" "${flat_up}" "${DEF}"
  [[ ${snap_up} -gt 0 ]] && printf '  Snap:    %b%d%b\n' "${CYN}" "${snap_up}" "${DEF}"
  printf '\n'
}

# Full system update (pacui-style)
_full_update(){
  msg "Starting full system update..."
  # Pacman/AUR
  if [[ ${PAC} == pacman ]]; then
    sudo pacman -Syu --noconfirm
  else
    "${PAC}" -Syu --noconfirm
  fi
  # Flatpak
  if has flatpak; then
    msg "Updating flatpak packages..."
  flatpak update -y --noninteractive
  sudo flatpak update -y --noninteractive
  fi
  msg "Update complete!"
}

# Update flatpak only
_update_flatpak(){
  has flatpak || { warn "Flatpak not installed"; return 1; }
  msg "Updating flatpak packages..."
  flatpak update -y --noninteractive
  sudo flatpak update -y --noninteractive
}

# Vulnerable packages (from cylon/pacui)
_check_vulns(){
  has arch-audit || { warn "Install arch-audit: sudo pacman -S arch-audit"; return 1; }
  msg "Checking for vulnerable packages (CVE)..."
  arch-audit -u || echo "No vulnerable packages found"
}

# Arch news RSS (from pacui/cylon)
_arch_news(){
  has curl || { warn "curl required"; return 1; }
  msg "Fetching Arch Linux news..."
  curl -fsSL 'https://archlinux.org/feeds/news/' 2>/dev/null | \
    grep -E '<title>|<pubDate>|<link>' | \
    sed -e 's/<[^>]*>//g' -e 's/^[[:space:]]*//' | \
    paste - - - | head -n 10 | \
    awk -F'\t' '{printf "%s\n  %s\n  %s\n\n", $1, $2, $3}' | less -R
}

# Mirror management (from pacui)
_mirrors(){
  if has reflector; then
    msg "Updating mirrors with reflector..."
    sudo reflector --verbose --protocol https --age 6 --sort rate \
      --save /etc/pacman.d/mirrorlist
    sudo pacman -Syy
  elif has pacman-mirrors; then
    msg "Updating mirrors with pacman-mirrors..."
    sudo pacman-mirrors -f 0 && sudo pacman -Syy
  else
    warn "Install reflector (Arch) or pacman-mirrors (Manjaro)"
  fi
}

# Clean cache (from cylon/pacui)
_clean_cache(){
  msg "Cleaning package cache..."
  if [[ ${PAC} == pacman ]]; then
    sudo pacman -Sc
  else
    "${PAC}" -Sc
  fi
  has paccache && sudo paccache -rk2
}

# Generate package lists (from cylon/pacui)
_gen_pkglists(){
  msg "Generating package lists in ${PKGLIST}..."
  cd "${PKGLIST}" || return 1
  local lists=(
    "pacman -Qeq > explicit.txt"
    "pacman -Qdq > deps.txt"
    "pacman -Qnq > native.txt"
    "pacman -Qmq > foreign.txt"
    "pacman -Qtq > unrequired.txt"
    "pacman -Qdttq > orphans.txt"
    "pacman -Qettq > opt-deps.txt"
    "expac -H M '%m\t%n' | sort -h > by-size.txt"
    "expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort > by-install.txt"
  )
  for cmd in "${lists[@]}"; do
    eval "${cmd}" 2>/dev/null || :
  done
  has paclist && {
    paclist core > core.txt
    paclist extra > extra.txt
    [[ -d /var/lib/pacman/sync/aur ]] && paclist aur > aur.txt || :
  }
  has flatpak && flatpak list > flatpak.txt
  has snap && snap list > snap.txt
  msg "Package lists generated: ${PKGLIST}"
  ls -lh "${PKGLIST}"/*.txt 2>/dev/null | awk '{print $9, $5}'
}

# Backup package list (from cylon)
_backup_pkgs(){
  local bak="${PKGLIST}/backup-$(date +%Y%m%d-%H%M).txt"
  pacman -Qeq > "${bak}"
  msg "Backup created: ${bak}"
}

# Restore from backup (from cylon)
_restore_pkgs(){
  local bak
  [[ -f ${PKGLIST}/backup-*.txt ]] || { warn "No backups found"; return 1; }
  bak=$(ls -t "${PKGLIST}"/backup-*.txt | head -1)
  msg "Restoring from: ${bak}"
  if [[ ${PAC} == pacman ]]; then
    sudo pacman -S --needed - < "${bak}"
  else
    "${PAC}" -S --needed - < "${bak}"
  fi
}

# System info (from cylon)
_system_info(){
  cat <<EOF

${BLD}=== System Information ===${DEF}
${BLD}Hostname:${DEF}     $(hostname)
${BLD}Kernel:${DEF}       $(uname -r)
${BLD}Uptime:${DEF}       $(uptime -p)
${BLD}Packages:${DEF}     $(pacman -Q | wc -l) total
${BLD}Explicit:${DEF}     $(pacman -Qe | wc -l)
${BLD}Dependencies:${DEF} $(pacman -Qd | wc -l)
${BLD}Orphans:${DEF}      $(pacman -Qdttq 2>/dev/null | wc -l)
${BLD}Foreign (AUR):${DEF} $(pacman -Qm | wc -l)
${BLD}Pkg Manager:${DEF}  ${PAC}
${BLD}Fuzzy Finder:${DEF} ${FND}

EOF
  has flatpak && printf '%bFlatpak pkgs:%b  %d\n' "${BLD}" "${DEF}" "$(flatpak list 2>/dev/null | wc -l)"
  has snap && printf '%bSnap pkgs:%b     %d\n' "${BLD}" "${DEF}" "$(snap list 2>/dev/null | wc -l)"
  printf '\n'
}

# Desktop notification (from cylon)
_notify_updates(){
  has notify-send || { warn "Install libnotify"; return 1; }
  local pac_up aur_up
  pac_up=$(checkupdates 2>/dev/null | wc -l)
  aur_up=0
  [[ ${PAC} != pacman ]] && aur_up=$("${PAC}" -Qua 2>/dev/null | wc -l)
  if [[ ${pac_up} -gt 0 || ${aur_up} -gt 0 ]]; then
    notify-send "pkgui: Updates Available" \
      "Pacman: ${pac_up}, AUR: ${aur_up}" --icon=dialog-information
    msg "Notification sent: Pacman=${pac_up}, AUR=${aur_up}"
  else
    msg "System up to date"
  fi
}

# System maintenance (from cylon)
_maintenance(){
  msg "Running system maintenance scan..."
  printf '\n%b=== Orphaned Packages ===%b\n' "${BLD}" "${DEF}"
  pacman -Qdttq 2>/dev/null | wc -l | xargs printf '%d orphans found\n'
  printf '\n%b=== Optional Dependencies Not Installed ===%b\n' "${BLD}" "${DEF}"
  pacman -Qettq 2>/dev/null | wc -l | xargs printf '%d packages\n'
  printf '\n%b=== Cache Size ===%b\n' "${BLD}" "${DEF}"
  du -sh /var/cache/pacman/pkg/ 2>/dev/null || echo "N/A"
  printf '\n%b=== Failed Systemd Services ===%b\n' "${BLD}" "${DEF}"
  systemctl --failed --no-pager --no-legend | wc -l | xargs printf '%d failed services\n'
  has arch-audit && {
    printf '\n%b=== Vulnerable Packages ===%b\n' "${BLD}" "${DEF}"
    arch-audit -u 2>/dev/null | wc -l | xargs printf '%d vulnerable packages\n'
  }
  printf '\n'
}

# Edit config
_edit_config(){
  local cfg="${CFG}/config"
  [[ -f ${cfg} ]] || cat > "${cfg}" <<'EOF'
# pkgui configuration
PARUZ="paru yay pacman"
FINDER="sk fzf"
NOTIFY_ON_UPDATE=false
AUTO_CLEAN_CACHE=false
EOF
  "${EDITOR:-nano}" "${cfg}"
}

# Main dispatcher
[[ $# -eq 0 ]] && { _help; exit 1; }
case "$1" in
  s) shift; _search "$@";;
  l) shift; _local "$@";;
  S) shift; _search "$@" | _inst;;
  D) shift; _search "$@" | _download;;
  R) shift; _local "$@" | _rmv;;
  A) shift; _orphans "$@" | _rmv;;
  O) shift; _optional_deps | _rmv;;
  U) _check_updates;;
  u) _full_update;;
  F) _update_flatpak;;
  N) _update_snap;;
  M) _maintenance;;
  C) _clean_cache;;
  V) _check_vulns;;
  W) _arch_news;;
  m) _mirrors;;
  P) _gen_pkglists;;
  B) _backup_pkgs;;
  T) _restore_pkgs;;
  i) _system_info;;
  n) _notify_updates;;
  c) _edit_config;;
  -h|h|--help) _help;;
  -v|v|--version) _ver;;
  *) die "Invalid command: $1";;
esac

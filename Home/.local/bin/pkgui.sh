#!/usr/bin/env bash
# pkgui - Unified pacman/paru/yay TUI with fuzzy search
set -euo pipefail; shopt -s lastpipe nullglob globstar
export LC_ALL=C LANG=C SHELL="$(command -v bash)" HOME="/home/${SUDO_USER:-$USER}"
# Colors
readonly RED=$'\e[31m' BLD=$'\e[1m' DEF=$'\e[0m' UL=$'\e[4m'
has(){ command -v "$1" &>/dev/null; }
err(){ printf '%b[ERR]%b %s\n' "${RED}" "${DEF}" "$*" >&2; }
die(){ err "$@"; exit 1; }
_ver(){ printf '%b%s%b -- %bv3.1.0%b unified pacman/paru TUI (merged with fzpacman)\n' "${BLD}" "${0##*/}" "${DEF}" "${UL}" "${DEF}"; }
_help(){
  cat <<EOF
${BLD}USAGE${DEF}  ${0##*/} ${UL}CMD${DEF} [${UL}KEYWORDS${DEF}]

${BLD}COMMANDS${DEF}
  s         Search packages
  l         List local packages
  S         Search and install
  D         Search and download only
  R         List and remove packages
  A         List and remove orphans
  u         Update package list
  k         Generate SSH key <email> <user@host>
  -h, h     Show this help
  -v, v     Show version

${BLD}KEYS${DEF}
  Tab        Select/multi-select
  Enter      Confirm action
  Ctrl-S     View detailed info
  Ctrl-O     Download only (in search mode)
  Ctrl-J/K   Navigate preview
  Alt-P      Toggle preview
  Alt-J/K    Scroll preview

${BLD}EXAMPLES${DEF}
  ${0##*/} s firefox       Search for firefox
  ${0##*/} S firefox       Search and install firefox
  ${0##*/} D firefox       Search and download firefox (no install)
  ${0##*/} l               Browse installed packages
  ${0##*/} R firefox       Remove firefox
  ${0##*/} A               Remove orphaned packages
EOF
}

# Find package manager
for p in ${PARUZ:-paru yay pacman}; do has "${p}" && PAC="${p}" && break; done
[[ -z ${PAC:-} ]] && die "No package manager found (pacman/paru/yay)"
# Find fuzzy finder
for f in ${FINDER:-sk fzf}; do has "${f}" && FND="${f}" && break; done
[[ -z ${FND:-} ]] && die "No fuzzy finder found (sk/fzf)"
# Cache for package info
declare -A _CACHE_INFO _CACHE_INFOQ _CACHE_LIST _CACHE_LOCALLIST

_fzf(){
  local -a opts=(--ansi --cycle --no-mouse --reverse --inline-info --color='pointer:green,marker:green')
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
  local r
  r=$("${PAC}" --color=always --noconfirm -Si "$1" 2>/dev/null | grep --color=never -v '^ ')
  _CACHE_INFO[$1]="${r}"
  printf '%s\n' "${r}"
}

_infoq(){
  [[ -n ${_CACHE_INFOQ[$1]:-} ]] && { printf '%s\n' "${_CACHE_INFOQ[$1]}"; return 0; }
  local r
  r=$("${PAC}" -Qs --color=always "^$1$" && printf '\n' && "${PAC}" -Qi --list --color=always "$1" 2>/dev/null)
  _CACHE_INFOQ[$1]="${r}"
  printf '%s\n' "${r}"
}

_getlist(){
  [[ -n ${_CACHE_LIST[$*]:-} ]] && { printf '%s\n' "${_CACHE_LIST[$*]}"; return 0; }
  local r
  r=$("${PAC}" -Ss --quiet "$@" 2>/dev/null || :)
  _CACHE_LIST[$*]="${r}"
  printf '%s\n' "${r}"
}

_getlocal(){
  [[ -n ${_CACHE_LOCALLIST[$*]:-} ]] && { printf '%s\n' "${_CACHE_LOCALLIST[$*]}"; return 0; }
  local r
  r=$("${PAC}" -Qs --quiet "$@" 2>/dev/null || :)
  _CACHE_LOCALLIST[$*]="${r}"
  printf '%s\n' "${r}"
}

_search(){
  export -f _info _fzf; export PAC FND; declare -gA _CACHE_INFO
  _getlist "$@" | _fzf -m \
    -h $'Enter:install  Ctrl-O:download  Ctrl-S:info\nAlt-P:toggle preview  Alt-J/K:scroll' \
    -l '[package info]' \
    -p "bash -c '_info {}'" \
    -b "ctrl-s:execute(bash -c '_info {} | less -R')" \
    -b "alt-p:toggle-preview" \
    -b "alt-d:preview-half-page-down,alt-u:preview-half-page-up" \
    -b "alt-k:preview-up,alt-j:preview-down"
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
    -b "alt-k:preview-up,alt-j:preview-down"
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
    -b "alt-k:preview-up,alt-j:preview-down"
}

_inst(){
  local -a pkgs=(); mapfile -t pkgs
  (( ${#pkgs[@]} == 0 )) && return 0
  if [[ ${PAC} == pacman ]]; then
    sudo pacman -S "${pkgs[@]}"
  else
    "${PAC}" -S "${pkgs[@]}"
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

_pkglist(){
  local dir="${HOME}/.pkglist"
  local aur="${dir}/aur" manual="${dir}/manual"
  mkdir -p "${dir}"
  has paclist || die "pacman-contrib is required for this feature"
  paclist aur 2>/dev/null | awk '{print $1}' > "${aur}"
  paclist manual 2>/dev/null | awk '{print $1}' > "${manual}"
  pacman -Qeq > "${dir}/pacman-all"
  pacman -Qeq | grep -vFf "${aur}" | grep -vFf "${manual}" > "${dir}/pacman"
  sudo pacman -Qkk 2>&1 | awk '/Modification/{sub(/^[^\/]*/,"");sub(/ \(.*\)$/,"");print}' | sort > "${dir}/modified-files"
  printf 'Package list updated → %s\n' "${dir}"
}

_sshkey(){
  [[ $# -lt 2 ]] && die "Usage: ${0##*/} k <email> <user@host>"
  local email="$1" target="$2"
  local keyfile="${HOME}/.ssh/${target%%@*}_ed25519"
  ssh-keygen -t ed25519 -a 100 -f "${keyfile}" -C "${email}"
  ssh-copy-id -i "${keyfile}.pub" "${target}"
}

# Main command dispatcher
[[ $# -eq 0 ]] && { _help; exit 1; }
case "$1" in
  s) shift; _search "$@";;
  l) shift; _local "$@";;
  S) shift; _search "$@" | _inst;;
  D) shift; _search "$@" | _download;;
  R) shift; _local "$@" | _rmv;;
  A) shift; _orphans "$@" | _rmv;;
  u) _pkglist;;
  k) shift; _sshkey "$@";;
  -h|h|--help) _help;;
  -v|v|--version) _ver;;
  *) die "Invalid command: $1";;
esac

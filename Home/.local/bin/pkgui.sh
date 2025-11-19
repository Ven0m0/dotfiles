#!/usr/bin/env bash
shopt -s lastpipe nullglob globstar
export LC_ALL=C LANG=C SHELL="$(command -v bash)" HOME="/home/${SUDO_USER:-$USER}"

RED=$'\e[31m' BLD=$'\e[1m' DEF=$'\e[0m' UL=$'\e[4m'
has(){ command -v "$1" &>/dev/null; }
err(){ printf '%b[ERR]%b %s\n' "$RED" "$DEF" "$*" >&2; }
die(){ err "$@"; exit 1; }
_ver(){ cat <<< "${BLD}${0##*/}${DEF} -- ${UL}v3.0.0${DEF} unified pacman/paru TUI"; }

_help(){
  cat <<EOF
${BLD}USAGE${DEF}  ${0##*/} ${UL}CMD${DEF} [${UL}KEYWORDS${DEF}]
${BLD}CMD${DEF}    s|l|S|R|A (search|local|install|remove|autoremove)  u(update-pkglist)  k(ssh-key) <email> <user@host>
${BLD}KEYS${DEF}   Tab:select Enter:confirm C-s:info C-j/k:nav
EOF
}

for p in ${PARUZ:-paru:yay:pacman}; do has "$p" && PAC=$p && break; done
[[ -z $PAC ]] && die "no pkg mgr"
for f in ${FINDER:-sk:fzf}; do has "$f" && FND=$f && break; done
[[ -z $FND ]] && die "no finder (sk/fzf)"
declare -A _CACHE_INFO _CACHE_INFOQ _CACHE_LIST _CACHE_LOCALLIST

_fzf(){
  local -a a=(--ansi --cycle --no-mouse --reverse --inline-info)
  [[ $FND == sk ]] && a+=(--no-hscroll) || a+=(--no-scrollbar)
  while (($#)); do
    case $1 in
      -m) a+=(--multi); shift;;
      -h) a+=(--header "$2"); shift 2;;
      -p) a+=(--preview "$2" --preview-window=wrap); shift 2;;
      -b) a+=(--bind "$2"); shift 2;;
      *) shift;;
    esac
  done
  "$FND" "${a[@]}"
}
_info(){
  [[ -n ${_CACHE_INFO[$1]} ]] && { echo "${_CACHE_INFO[$1]}"; return; }
  local r=$("$PAC" --color=always --noconfirm -Si "$1" 2>/dev/null | grep --color=never -v '^ ')
  _CACHE_INFO[$1]=$r
  echo "$r"
}
_infoq(){
  [[ -n ${_CACHE_INFOQ[$1]} ]] && { echo "${_CACHE_INFOQ[$1]}"; return; }
  local r=$("$PAC" -Qs --color=always "^$1$" && echo && "$PAC" -Qi --list --color=always "$1" 2>/dev/null)
  _CACHE_INFOQ[$1]=$r
  echo "$r"
}
_getlist(){
  [[ -n ${_CACHE_LIST[$*]} ]] && { echo "${_CACHE_LIST[$*]}"; return; }
  local r=$("$PAC" -Ss --quiet "$@" 2>/dev/null)
  _CACHE_LIST[$*]=$r
  echo "$r"
}
_getlocal(){
  [[ -n ${_CACHE_LOCALLIST[$*]} ]] && { echo "${_CACHE_LOCALLIST[$*]}"; return; }
  local r=$("$PAC" -Qs --quiet "$@" 2>/dev/null)
  _CACHE_LOCALLIST[$*]=$r
  echo "$r"
}
_search(){
  export -f _info _fzf; export PAC FND; declare -gA _CACHE_INFO
  _getlist "$@" | _fzf -m -h "C-s:info" -p "bash -c '_info {}'" -b "ctrl-s:execute(bash -c '_info {} | less -R')"
}
_local(){
  export -f _infoq _fzf; export PAC FND; declare -gA _CACHE_INFOQ
  _getlocal "$@" | _fzf -m -h "C-s:info" -p "bash -c '_infoq {}'" -b "ctrl-s:execute(bash -c '_infoq {} | less -R')"
}
_orphans(){
  export -f _infoq _fzf; export PAC FND; declare -gA _CACHE_INFOQ
  "$PAC" -Qdttq "$@" 2>/dev/null | _fzf -m -h "C-s:info" -p "bash -c '_infoq {}'" -b "ctrl-s:execute(bash -c '_infoq {} | less -R')"
}
_inst(){
  declare -a p=(); mapfile -t p
  (( ${#p[@]} )) || return 0
  [[ $PAC == pacman ]] && sudo pacman -S "${p[@]}" || "$PAC" -S "${p[@]}"
}
_rmv(){
  declare -a p=(); mapfile -t p
  (( ${#p[@]} )) || return 0
  [[ $PAC == pacman ]] && sudo pacman -Rns --nosave "${p[@]}" || "$PAC" -Rns --nosave "${p[@]}"
}
_pkglist(){
  local d="$HOME/.pkglist" a="$d/aur" m="$d/manual"
  mkdir -p "$d"
  has paclist || die "pacman-contrib needed"
  paclist aur 2>/dev/null | awk '{print $1}' > "$a"
  paclist manual 2>/dev/null | awk '{print $1}' > "$m"
  pacman -Qeq > "$d/pacman-all"
  pacman -Qeq | grep -vFf "$a" | grep -vFf "$m" > "$d/pacman"
  sudo pacman -Qkk 2>&1 | awk '/Modification/{sub(/^[^\/]*/,"");sub(/ \(.*\)$/,"");print}' | sort > "$d/modified-files"
  printf 'pkglist ✓ → %s\n' "$d"
}
_sshkey(){
  [[ $# -lt 2 ]] && die "Usage: ${0##*/} k <email> <user@host>"
  local e="$1" t="$2" k="$HOME/.ssh/${t%%@*}_ed25519"
  ssh-keygen -t ed25519 -a 100 -f "$k" -C "$e"
  ssh-copy-id -i "${k}.pub" "$t"
}
[[ $# -eq 0 ]] && { _help; exit 1; }
case $1 in
  s) shift; _search "$@";;
  l) shift; _local "$@";;
  S) shift; _search "$@" | _inst;;
  R) shift; _local "$@" | _rmv;;
  A) shift; _orphans "$@" | _rmv;;
  u) _pkglist;;
  k) shift; _sshkey "$@";;
  -h|h) _help;;
  -v|v) _ver;;
  *) die "invalid: $1";;
esac

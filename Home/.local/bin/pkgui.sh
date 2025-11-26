#!/usr/bin/env bash
# pkgui - Unified package manager TUI (merged: pacui + yayfzf + fuzzy-pkg-finder)
set -euo pipefail; shopt -s lastpipe nullglob globstar extglob
export LC_ALL=C LANG=C SHELL="$(command -v bash)" HOME="/home/${SUDO_USER:-$USER}"
# Colors
readonly R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' C=$'\e[36m' M=$'\e[35m'
readonly BD=$'\e[1m' D=$'\e[0m' UL=$'\e[4m' IT=$'\e[3m'
# Paths
readonly CFG="${XDG_CONFIG_HOME:-$HOME/.config}/pkgui"
readonly CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/pkgui"
readonly HIST="${PKGUI_HISTORY:-$CACHE/history}"
mkdir -p "$CFG" "$CACHE" "${HIST%/*}"
# Utils
has(){ command -v "$1" &>/dev/null; }
die(){ printf '%b[ERR]%b %s\n' "$R" "$D" "$*" >&2; exit 1; }
msg(){ printf '%b%s%b\n' "$G" "$*" "$D"; }
warn(){ printf '%b[WARN]%b %s\n' "$Y" "$D" "$*"; }
# Detect pkg mgr & fuzzy finder
for p in ${PARUZ:-paru yay pacman}; do has "$p" && PAC="$p" && break; done
[[ -z ${PAC:-} ]] && die "No pkg mgr (pacman/paru/yay)"
for f in ${FINDER:-sk fzf}; do has "$f" && FND="$f" && break; done
[[ -z ${FND:-} ]] && die "No fuzzy finder (sk/fzf)"
# FZF theme
FZF_THEME="${FZF_THEME:-hl:italic:#FFFF00,hl+:bold:underline:#FF0000,fg:#98A0C5,fg+:bold:#FFFFFF,bg:#13172A,bg+:#0F1222,border:#75A2F7,label:bold:#75A2F7,preview-fg:#C0CAF5,preview-bg:#0F1222,marker:#00FF00,pointer:#FF0000,query:#FF0000,info:italic:#98A0C5}"
# Cache
declare -A _CI _CQ _CL _CLO
_ver(){ printf '%b%s%b v4.1.0 - Unified pacman/AUR TUI\n' "$BD" "${0##*/}" "$D"; }
_help(){
  cat <<'EOF'
USAGE  pkgui CMD [ARGS]

PACKAGE OPS
  s   Search packages           S   Search & install
  l   List local packages       D   Download only
  R   Remove packages           A   Remove orphans
  O   Remove optional deps      U   Check updates
  u   System update (full)      F   Update flatpak
  N   Update snap

SYSTEM MAINT
  M   Maintenance scan          C   Clean cache
  V   Vulnerable pkgs (CVE)     W   Arch news
  m   Mirror management         p   pacdiff (.pacnew)
  f   Firmware updates          k   Check failed services

PKG LISTS
  P   Generate pkg lists        B   Backup list
  T   Restore from backup

CONFIG/INFO
  i   System info               c   Edit config
  e   Edit system configs       n   Desktop notify
  h   Show help                 v   Show version

FZF KEYS
  Tab       Select              Shift-Tab  Deselect
  Ctrl-i    Install selected    Ctrl-r     Remove selected
  Ctrl-u    Update all          Ctrl-d     Deselect all
  Ctrl-p    PKGBUILD preview    Ctrl-s     Show info
  Ctrl-/    Toggle layout       Ctrl-v     Toggle preview
  ?         Show keys           Esc/Ctrl-c Exit
EOF
}
_fzf(){
  local -a o=(--ansi --cycle --reverse --inline-info --no-scrollbar)
  o+=(--color="$FZF_THEME" --history="$HIST")
  [[ $FND == sk ]] && o+=(--no-hscroll)
  while (($#)); do
    case $1 in
      -m) o+=(-m); shift ;;
      -h) o+=(--header "$2"); shift 2 ;;
      -p) o+=(--preview "$2" --preview-window='down:60%:wrap'); shift 2 ;;
      -l) o+=(--preview-label "$2"); shift 2 ;;
      -b) o+=(--bind "$2"); shift 2 ;;
      *) shift ;;
    esac
  done
  "$FND" "${o[@]}"
}
_info(){
  [[ -n ${_CI[$1]:-} ]] && { printf '%s\n' "${_CI[$1]}"; return 0; }
  local r; r=$("$PAC" --color=always -Si "$1" 2>/dev/null | grep -v '^ ')
  _CI[$1]=$r; printf '%s\n' "$r"
}
_infoq(){
  [[ -n ${_CQ[$1]:-} ]] && { printf '%s\n' "${_CQ[$1]}"; return 0; }
  local r; r=$("$PAC" -Qi --color=always "$1" 2>/dev/null)
  _CQ[$1]=$r; printf '%s\n' "$r"
}
_list(){
  [[ -n ${_CL[$*]:-} ]] && { printf '%s\n' "${_CL[$*]}"; return 0; }
  local r; r=$("$PAC" -Ss --quiet "$@" 2>/dev/null || :)
  _CL[$*]=$r; printf '%s\n' "$r"
}
_listq(){
  [[ -n ${_CLO[$*]:-} ]] && { printf '%s\n' "${_CLO[$*]}"; return 0; }
  local r; r=$("$PAC" -Qs --quiet "$@" 2>/dev/null || :)
  _CLO[$*]=$r; printf '%s\n' "$r"
}
_prev_pkg(){
  local pkg=$1 mode=${2:-repo}
  if [[ $mode == aur ]]; then
    printf "=== Package Info ===\n"
    "$PAC" --color=always -Si "$pkg" 2>/dev/null || echo "No info"
    printf "\n=== PKGBUILD ===\n"
    has curl && curl -fsSL "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$pkg" 2>/dev/null || :
  else
    _info "$pkg"
  fi
}
_search(){
  export -f _info _fzf _prev_pkg; export PAC FND FZF_THEME HIST; declare -gA _CI
  _list "$@" | _fzf -m \
    -h $'Enter:install  Ctrl-i:install  Ctrl-r:remove  Ctrl-p:PKGBUILD  Ctrl-s:info\nCtrl-u:update  Ctrl-/:layout  Ctrl-v:preview  ?:keys' \
    -l '[package info]' \
    -p "bash -c '_info {}'" \
    -b "ctrl-i:execute($PAC -S {} </dev/tty >/dev/tty 2>&1)" \
    -b "ctrl-s:execute(_info {} | less -R)" \
    -b "ctrl-p:execute(_prev_pkg {} aur | less -R)" \
    -b "ctrl-u:execute($PAC -Syu </dev/tty >/dev/tty 2>&1)" \
    -b "alt-p:toggle-preview" \
    -b "ctrl-/:change-preview-window(down,60%|right,60%|hidden)"
}
_local(){
  export -f _infoq _fzf; export PAC FND FZF_THEME HIST; declare -gA _CQ
  _listq "$@" | _fzf -m \
    -h $'Enter:remove  Ctrl-r:remove  Ctrl-s:info  Ctrl-/:layout  ?:keys' \
    -l '[installed package]' \
    -p "bash -c '_infoq {}'" \
    -b "ctrl-r:execute($PAC -Rns {} </dev/tty >/dev/tty 2>&1)" \
    -b "ctrl-s:execute(_infoq {} | less -R)" \
    -b "ctrl-/:change-preview-window(down,60%|right,60%|hidden)"
}
_orphans(){
  export -f _infoq _fzf; export PAC FND FZF_THEME HIST; declare -gA _CQ
  "$PAC" -Qdttq 2>/dev/null | _fzf -m \
    -h $'Enter:remove  Ctrl-r:remove  Ctrl-s:info' \
    -l '[orphan]' \
    -p "bash -c '_infoq {}'" \
    -b "ctrl-r:execute($PAC -Rns {} </dev/tty >/dev/tty 2>&1)"
}
_opt_deps(){
  export -f _infoq _fzf; export PAC FND FZF_THEME HIST; declare -gA _CQ
  "$PAC" -Qttdq 2>/dev/null | _fzf -m \
    -h $'Enter:remove optional deps' \
    -l '[optional dep]' \
    -p "bash -c '_infoq {}'"
}
_inst(){
  local -a p; mapfile -t p
  (( ${#p[@]} == 0 )) && return 0
  [[ $PAC == pacman ]] && sudo pacman -S "${p[@]}" || "$PAC" -S "${p[@]}"
}
_dl(){
  local -a p; mapfile -t p
  (( ${#p[@]} == 0 )) && return 0
  [[ $PAC == pacman ]] && sudo pacman -Syw "${p[@]}" || "$PAC" -Syw "${p[@]}"
}
_rm(){
  local -a p; mapfile -t p
  (( ${#p[@]} == 0 )) && return 0
  [[ $PAC == pacman ]] && sudo pacman -Rns --nosave "${p[@]}" || "$PAC" -Rns --nosave "${p[@]}"
}
_upd_check(){
  msg "Checking updates..."
  local pac aur flat snap
  pac=$(checkupdates 2>/dev/null | wc -l)
  aur=0; [[ $PAC != pacman ]] && aur=$("$PAC" -Qua 2>/dev/null | wc -l)
  flat=0; has flatpak && flat=$(flatpak remote-ls --updates 2>/dev/null | wc -l)
  snap=0; has snap && snap=$(snap refresh --list 2>/dev/null | tail -n +2 | wc -l)
  printf '\n%bUpdate Summary:%b\n' "$BD" "$D"
  printf '  Pacman:  %b%d%b\n' "$C" "$pac" "$D"
  (( aur > 0 )) && printf '  AUR:     %b%d%b\n' "$C" "$aur" "$D"
  (( flat > 0 )) && printf '  Flatpak: %b%d%b\n' "$C" "$flat" "$D"
  (( snap > 0 )) && printf '  Snap:    %b%d%b\n' "$C" "$snap" "$D"
  printf '\n'
}
_upd_full(){
  msg "Full system update..."
  [[ $PAC == pacman ]] && sudo pacman -Syu || "$PAC" -Syu
  if has flatpak; then
    msg "Updating flatpak..."
    flatpak update -y --noninteractive &>/dev/null
    sudo flatpak update -y --noninteractive &>/dev/null
  fi
  if has snap; then
    msg "Updating snap..."
    sudo snap refresh &>/dev/null
  fi
  msg "Update complete!"
}
_upd_flat(){ has flatpak || { warn "Flatpak not installed"; return 1; }
  msg "Updating flatpak..."
  flatpak update -y --noninteractive
  sudo flatpak update -y --noninteractive
}
_upd_snap(){ has snap || { warn "Snap not installed"; return 1; }
  msg "Updating snap..."
  sudo snap refresh
}
_vulns(){ has arch-audit || { warn "Install: sudo pacman -S arch-audit"; return 1; }
  msg "Checking vulnerabilities (CVE)..."
  arch-audit -u || echo "No vulnerable packages"
}
_news(){ has curl || { warn "curl required"; return 1; }
  msg "Fetching Arch news..."
  curl -fsSL 'https://archlinux.org/feeds/news/' 2>/dev/null | \
    grep -E '<title>|<pubDate>|<link>' | sed -e 's/<[^>]*>//g' -e 's/^[[:space:]]*//' | \
    paste - - - | head -n 10 | awk -F'\t' '{printf "%s\n  %s\n  %s\n\n", $1, $2, $3}' | less -R
}
_mirrors(){
  if has reflector; then
    msg "Updating mirrors (reflector)..."
    sudo reflector --verbose --protocol https --age 6 --sort rate --save /etc/pacman.d/mirrorlist
    sudo pacman -Syy
  elif has pacman-mirrors; then
    msg "Updating mirrors (pacman-mirrors)..."
    sudo pacman-mirrors -f 0 && sudo pacman -Syy
  else
    warn "Install reflector (Arch) or pacman-mirrors (Manjaro)"
  fi
}
_clean(){
  msg "Cleaning cache..."
  [[ $PAC == pacman ]] && sudo pacman -Sc || "$PAC" -Sc
  has paccache && sudo paccache -rk2
  [[ -d $HOME/.cache/yay ]] && paccache -rk1 --cachedir "$HOME/.cache/yay" &>/dev/null
  [[ -d $HOME/.cache/paru ]] && paccache -rk1 --cachedir "$HOME/.cache/paru" &>/dev/null
}
_pacdiff(){ has pacdiff || { warn "Install pacman-contrib"; return 1; }
  msg "Running pacdiff..."
  if [[ -n ${DIFFPROG:-} ]]; then
    sudo pacdiff
  else
    sudo DIFFPROG="diff --side-by-side --suppress-common-lines --color=always" pacdiff
  fi
}
_fw(){ has fwupdmgr || { warn "Install fwupd"; return 1; }
  msg "Checking firmware updates..."
  fwupdmgr refresh --force &>/dev/null
  if fwupdmgr get-updates 2>/dev/null | grep -qE 'No updatable|No updates|updated successfully'; then
    echo "No firmware updates available"
  else
    fwupdmgr get-updates
    read -rp "Run fwupdmgr update? [y/N] " ans
    [[ ${ans,,} == y ]] && fwupdmgr update
  fi
}
_svc(){
  msg "Checking failed systemd services..."
  local f; f=$(systemctl --failed --no-pager --no-legend | wc -l)
  if (( f > 0 )); then
    systemctl --failed --no-pager
  else
    echo "No failed services"
  fi
}
_maint(){
  msg "System maintenance scan..."
  printf '\n%b=== Orphans ===%b\n' "$BD" "$D"
  "$PAC" -Qdttq 2>/dev/null | wc -l | xargs printf '%d orphans\n'
  printf '\n%b=== Optional Deps ===%b\n' "$BD" "$D"
  "$PAC" -Qettq 2>/dev/null | wc -l | xargs printf '%d packages\n'
  printf '\n%b=== Cache ===%b\n' "$BD" "$D"
  du -sh /var/cache/pacman/pkg/ 2>/dev/null || echo "N/A"
  printf '\n%b=== Failed Services ===%b\n' "$BD" "$D"
  systemctl --failed --no-pager --no-legend | wc -l | xargs printf '%d failed\n'
  has arch-audit && {
    printf '\n%b=== Vulnerabilities ===%b\n' "$BD" "$D"
    arch-audit -u 2>/dev/null | wc -l | xargs printf '%d vulnerable\n'
  }
  has pacdiff && {
    printf '\n%b=== .pacnew/.pacsave Files ===%b\n' "$BD" "$D"
    pacdiff -o 2>/dev/null | wc -l | xargs printf '%d files need review\n'
  }
  printf '\n'
}
_gen_lists(){
  local d="$CFG/lists"
  mkdir -p "$d"
  msg "Generating lists in $d..."
  pacman -Qeq > "$d/explicit.txt"
  pacman -Qdq > "$d/deps.txt"
  pacman -Qnq > "$d/native.txt"
  pacman -Qmq > "$d/foreign.txt"
  pacman -Qtq > "$d/unrequired.txt"
  pacman -Qdttq 2>/dev/null > "$d/orphans.txt" || :
  expac -H M '%m\t%n' | sort -h > "$d/by-size.txt"
  expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort > "$d/by-install.txt"
  has flatpak && flatpak list > "$d/flatpak.txt"
  has snap && snap list > "$d/snap.txt"
  msg "Generated: $d"
  ls -lh "$d"/*.txt 2>/dev/null | awk '{print $9, $5}'
}
_backup(){
  local b="$CFG/backup-$(date +%Y%m%d-%H%M).txt"
  pacman -Qeq > "$b"
  msg "Backup: $b"
}
_restore(){
  local b
  [[ -f $CFG/backup-*.txt ]] || { warn "No backups"; return 1; }
  b=$(ls -t "$CFG"/backup-*.txt | head -1)
  msg "Restoring: $b"
  [[ $PAC == pacman ]] && sudo pacman -S --needed - < "$b" || "$PAC" -S --needed - < "$b"
}
_info_sys(){
  cat <<EOF

${BD}=== System ===${D}
${BD}Host:${D}     $(hostname)
${BD}Kernel:${D}   $(uname -r)
${BD}Uptime:${D}   $(uptime -p)
${BD}Pkgs:${D}     $(pacman -Q | wc -l) total
${BD}Explicit:${D} $(pacman -Qe | wc -l)
${BD}Deps:${D}     $(pacman -Qd | wc -l)
${BD}Orphans:${D}  $(pacman -Qdttq 2>/dev/null | wc -l)
${BD}Foreign:${D}  $(pacman -Qm | wc -l)
${BD}Manager:${D}  $PAC
${BD}Finder:${D}   $FND

EOF
  has flatpak && printf '%bFlatpak:%b %d\n' "$BD" "$D" "$(flatpak list 2>/dev/null | wc -l)"
  has snap && printf '%bSnap:%b    %d\n' "$BD" "$D" "$(snap list 2>/dev/null | wc -l)"
  printf '\n'
}
_notify(){ has notify-send || { warn "Install libnotify"; return 1; }
  local pac aur
  pac=$(checkupdates 2>/dev/null | wc -l)
  aur=0; [[ $PAC != pacman ]] && aur=$("$PAC" -Qua 2>/dev/null | wc -l)
  if (( pac > 0 || aur > 0 )); then
    notify-send "pkgui: Updates" "Pacman: $pac, AUR: $aur" --icon=dialog-information
    msg "Notified: Pacman=$pac, AUR=$aur"
  else
    msg "Up to date"
  fi
}
_edit_cfg(){
  local c="$CFG/config"
  [[ -f $c ]] || cat > "$c" <<'EOF'
# pkgui config
PARUZ="paru yay pacman"
FINDER="sk fzf"
FZF_THEME="hl:italic:#FFFF00,hl+:bold:underline:#FF0000,fg:#98A0C5,fg+:bold:#FFFFFF,bg:#13172A,bg+:#0F1222"
EOF
  "${EDITOR:-nano}" "$c"
}
_edit_sys(){
  local -A files=(
    [/etc/pacman.conf]="Pacman config"
    [/etc/pacman.d/mirrorlist]="Mirrors"
    [/etc/makepkg.conf]="Makepkg"
    [/etc/mkinitcpio.conf]="Initramfs"
    [/etc/default/grub]="GRUB"
    [/etc/fstab]="Fstab"
    [/etc/locale.conf]="Locale"
    [/etc/vconsole.conf]="Console"
    [$HOME/.bashrc]="Bash"
    [$HOME/.zshrc]="Zsh"
  )
  local f desc choice=()
  for f in "${!files[@]}"; do
    [[ -f $f ]] && choice+=("$f|${files[$f]}")
  done
  f=$(printf '%s\n' "${choice[@]}" | column -ts'|' | \
    _fzf -h "Select config to edit" | awk '{print $1}')
  [[ -z $f ]] && return 0
  if [[ $f =~ ^/home/ ]]; then
    "${EDITOR:-nano}" "$f"
  elif [[ $f == /etc/fstab ]]; then
    sudo "${EDITOR:-nano}" "$f" && sudo mount -a
  elif [[ $f == /etc/mkinitcpio.conf ]]; then
    sudo "${EDITOR:-nano}" "$f" && sudo mkinitcpio -P
  elif [[ $f == /etc/default/grub ]]; then
    sudo "${EDITOR:-nano}" "$f" && sudo grub-mkconfig -o /boot/grub/grub.cfg
  else
    sudo "${EDITOR:-nano}" "$f"
  fi
}

# Main
[[ $# -eq 0 ]] && { _help; exit 0; }
case $1 in
  s) shift; _search "$@";;
  l) shift; _local "$@";;
  S) shift; _search "$@" | _inst;;
  D) shift; _search "$@" | _dl;;
  R) shift; _local "$@" | _rm;;
  A) _orphans | _rm;;
  O) _opt_deps | _rm;;
  U) _upd_check;;
  u) _upd_full;;
  F) _upd_flat;;
  N) _upd_snap;;
  M) _maint;;
  C) _clean;;
  V) _vulns;;
  W) _news;;
  m) _mirrors;;
  p) _pacdiff;;
  f) _fw;;
  k) _svc;;
  P) _gen_lists;;
  B) _backup;;
  T) _restore;;
  i) _info_sys;;
  n) _notify;;
  c) _edit_cfg;;
  e) _edit_sys;;
  h|--help) _help;;
  v|--version) _ver;;
  *) die "Invalid: $1";;
esac

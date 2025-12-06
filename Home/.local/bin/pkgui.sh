#!/usr/bin/env bash
# pkgui - Unified package manager TUI (merged: pacui + yayfzf + fuzzy-pkg-finder + paruse + pkgsync)
set -euo pipefail
shopt -s nullglob globstar
LC_ALL=C
LANG=C
SHELL="$(command -v bash)"
export HOME="/home/${SUDO_USER:-$USER}"
# Colors
readonly R='\e[31m' G='\e[32m' Y='\e[33m' B='\e[34m' C='\e[36m' M='\e[35m'
readonly BD='\e[1m' D='\e[0m' UL='\e[4m' IT='\e[3m'
# Paths
readonly CFG="${XDG_CONFIG_HOME:-$HOME/.config}/pkgui"
readonly CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/pkgui"
readonly HIST="${PKGUI_HISTORY:-$CACHE/history}"
readonly PKGLIST="${PKGUI_PKGLIST:-$CFG/packagelist}"
readonly FILE_NATIVE="$CFG/pkglist_native. txt"
readonly FILE_AUR="$CFG/pkglist_aur.txt"
declare -A _pkgui_cmd_cache
mkdir -p "$CFG" "$CACHE" "${HIST%/*}"
# Utils
_pkgui_has() {
  if [[ -n ${_pkgui_cmd_cache[$1]} ]]; then
    return "${_pkgui_cmd_cache[$1]}"
  fi
  if command -v "$1" &>/dev/null; then
    _pkgui_cmd_cache["$1"]=0
  else
    _pkgui_cmd_cache["$1"]=1
  fi
  return "${_pkgui_cmd_cache[$1]}"
}
_pkgui_die() {
  printf '%b[ERR]%b %s\n' "$R" "$D" "$*" >&2
  exit 1
}
_pkgui_msg() { printf '%b%s%b\n' "$G" "$*" "$D"; }
_pkgui_warn() { printf '%b[WARN]%b %s\n' "$Y" "$D" "$*" >&2; }
# Detect pkg mgr & fuzzy finder
for p in ${PARUZ:-paru pacman}; do _pkgui_has "$p" && PAC="$p" && break; done
[[ -z ${PAC:-} ]] && _pkgui_die "No pkg mgr (pacman/paru)"
for f in ${FINDER:-sk fzf}; do _pkgui_has "$f" && FND="$f" && break; done
[[ -z ${FND:-} ]] && _pkgui_die "No fuzzy finder (sk/fzf)"
# FZF theme
FZF_THEME="${FZF_THEME:-hl:italic:#FFFF00,hl+:bold:underline:#FF0000,fg:#98A0C5,fg+:bold:#FFFFFF,bg:#13172A,bg+:#0F1222,border:#75A2F7,label:bold:#75A2F7,preview-fg:#C0CAF5,preview-bg:#0F1222,marker:#7AA2F7,spinner:#7AA2F7,prompt:#7DCFFF,info:#7AA2F7,pointer:#7DCFFF,header:#FF9E64}"
# Cache
declare -A _CI _CQ _CL _CLO _CUPD
_CUPD_TIME=0
_pkgui_ver() { printf '%b%s%b v4.3.0 - Unified pacman/AUR TUI\n' "$BD" "${0##*/}" "$D"; }
_pkgui_help() {
  cat <<'EOF'
USAGE  pkgui [CMD|FLAG] [ARGS]

FLAGS (skip menu)
  -s TERM  Search packages    -l       List local
  -S TERM  Search & install   -R       Remove packages
  -u       System update       -i       System info
  -h       Show this help      -v       Show version

PACKAGE OPS
  s   Search packages           S   Search & install
  l   List local packages       D   Download only
  R   Remove packages           A   Remove orphans
  O   Remove optional deps      U   Check updates
  u   System update (full)      F   Update flatpak
  b   Browse AUR (PKGBuild)     H   Install history

SYSTEM MAINT
  M   Maintenance scan          C   Clean cache
  V   Vulnerable pkgs (CVE)     W   Arch news
  m   Mirror management         p   pacdiff (. pacnew)
  f   Firmware updates          k   Check failed services
  N   Server status check

PKG LISTS
  P   Generate pkg lists        B   Backup list
  T   Restore from backup       L   Sync packagelist
  X   Export (native+AUR)       I   Import (native+AUR)

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
  ?          Show keys           Esc/Ctrl-c Exit
EOF
}
_pkgui_fzf() {
  local -a o=(--ansi --cycle --reverse --inline-info --no-scrollbar)
  o+=(--color="$FZF_THEME" --history="$HIST")
  if [[ $FND == sk ]]; then o+=(--no-hscroll); fi
  while (($#)); do
    case $1 in
    -m)
      o+=(-m)
      shift
      ;;
    -h)
      o+=(--header "$2")
      shift 2
      ;;
    -p)
      o+=(--preview "$2" --preview-window='down:60%:wrap')
      shift 2
      ;;
    -l)
      o+=(--preview-label "$2")
      shift 2
      ;;
    -b)
      o+=(--bind "$2")
      shift 2
      ;;
    *) shift ;;
    esac
  done
  "$FND" "${o[@]}"
}
_pkgui_info() {
  if [[ -n ${_CI[$1]:-} ]]; then
    printf '%s\n' "${_CI[$1]}"
    return 0
  fi
  local r
  r=$("$PAC" --color=always -Si "$1" 2>/dev/null | grep -v '^ ')
  _CI[$1]=$r
  printf '%s\n' "$r"
}
_pkgui_infoq() {
  if [[ -n ${_CQ[$1]:-} ]]; then
    printf '%s\n' "${_CQ[$1]}"
    return 0
  fi
  local r
  r=$("$PAC" -Qi --color=always "$1" 2>/dev/null)
  _CQ[$1]=$r
  printf '%s\n' "$r"
}
_pkgui_list() {
  if [[ -n ${_CL[$*]:-} ]]; then
    printf '%s\n' "${_CL[$*]}"
    return 0
  fi
  local r
  r=$("$PAC" -Ss --quiet "$@" 2>/dev/null || :)
  _CL[$*]=$r
  printf '%s\n' "$r"
}
_pkgui_listq() {
  if [[ -n ${_CLO[$*]:-} ]]; then
    printf '%s\n' "${_CLO[$*]}"
    return 0
  fi
  local r
  r=$("$PAC" -Qs --quiet "$@" 2>/dev/null || :)
  _CLO[$*]=$r
  printf '%s\n' "$r"
}
_pkgui_prev_pkg() {
  local pkg=$1 mode=${2:-repo}
  if [[ $mode == aur ]]; then
    printf "=== Package Info ===\n"
    "$PAC" --color=always -Si "$pkg" 2>/dev/null || echo "No info"
    printf "\n=== PKGBUILD ===\n"
    if _pkgui_has curl; then curl -fsSL "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$pkg" 2>/dev/null || :; fi
    printf "\n=== Source Tree ===\n"
    if _pkgui_has curl; then
      curl -fsSL "https://aur.archlinux.org/cgit/aur.git/tree/? h=$pkg" 2>/dev/null |
        grep 'tree/' | sed -n 's/.*tree\/\([^?"]*\). */\1/p' | sort -u |
        while read -r f; do printf 'https://aur.archlinux.org/cgit/aur.git/plain/%s? h=%s\n' "$f" "$pkg"; done || :
    fi
  else
    _pkgui_info "$pkg"
  fi
}
_pkgui_search() {
  export -f _pkgui_info _pkgui_fzf _pkgui_prev_pkg
  export PAC FND FZF_THEME HIST
  declare -gA _CI
  _pkgui_list "$@" | _pkgui_fzf -m \
    -h $'Enter:install  Ctrl-i:install  Ctrl-r:remove  Ctrl-p:PKGBUILD  Ctrl-s:info\nCtrl-u:update  Ctrl-/:layout  Ctrl-v:preview  ? :keys' \
    -l '[package info]' \
    -p "bash -c '_pkgui_info {}'" \
    -b "ctrl-i:execute($PAC -S {} </dev/tty >/dev/tty 2>&1)" \
    -b "ctrl-s:execute(_pkgui_info {} | less -R)" \
    -b "ctrl-p:execute(_pkgui_prev_pkg {} aur | less -R)" \
    -b "ctrl-u:execute($PAC -Syu </dev/tty >/dev/tty 2>&1)" \
    -b "alt-p:toggle-preview" \
    -b "ctrl-/:change-preview-window(down,60%|right,60%|hidden)"
}
_pkgui_local() {
  export -f _pkgui_infoq _pkgui_fzf
  export PAC FND FZF_THEME HIST
  declare -gA _CQ
  _pkgui_listq "$@" | _pkgui_fzf -m \
    -h $'Enter:remove  Ctrl-r:remove  Ctrl-s:info  Ctrl-/:layout  ?:keys' \
    -l '[installed package]' \
    -p "bash -c '_pkgui_infoq {}'" \
    -b "ctrl-r:execute($PAC -Rns {} </dev/tty >/dev/tty 2>&1)" \
    -b "ctrl-s:execute(_pkgui_infoq {} | less -R)" \
    -b "ctrl-/:change-preview-window(down,60%|right,60%|hidden)"
}
_pkgui_browse_aur() {
  export -f _pkgui_prev_pkg _pkgui_fzf
  export PAC FND FZF_THEME HIST
  _pkgui_msg "Loading AUR packages..."
  "$PAC" -Slq 2>/dev/null | _pkgui_fzf -m \
    -h $'Ctrl-p:PKGBUILD  Ctrl-i:install  Ctrl-s:info  Enter:install' \
    -l '[AUR browser]' \
    -p "bash -c '_pkgui_prev_pkg {} aur'" \
    -b "ctrl-p:execute(_pkgui_prev_pkg {} aur | less -R)" \
    -b "ctrl-i:execute($PAC -S {} </dev/tty >/dev/tty 2>&1)" \
    -b "ctrl-s:execute($PAC -Si {} | less -R)"
}
_pkgui_orphans() {
  export -f _pkgui_infoq _pkgui_fzf
  export PAC FND FZF_THEME HIST
  declare -gA _CQ
  "$PAC" -Qdttq 2>/dev/null | _pkgui_fzf -m \
    -h $'Enter:remove  Ctrl-r:remove  Ctrl-s:info' \
    -l '[orphan]' \
    -p "bash -c '_pkgui_infoq {}'" \
    -b "ctrl-r:execute($PAC -Rns {} </dev/tty >/dev/tty 2>&1)"
}
_pkgui_opt_deps() {
  export -f _pkgui_infoq _pkgui_fzf
  export PAC FND FZF_THEME HIST
  declare -gA _CQ
  "$PAC" -Qttdq 2>/dev/null | _pkgui_fzf -m \
    -h $'Enter:remove optional deps' \
    -l '[optional dep]' \
    -p "bash -c '_pkgui_infoq {}'"
}
_pkgui_inst() {
  local -a p
  mapfile -t p
  if ((${#p[@]} == 0)); then return 0; fi
  if [[ $PAC == pacman ]]; then sudo pacman -S "${p[@]}"; else "$PAC" -S "${p[@]}"; fi
}
_pkgui_dl() {
  local -a p
  mapfile -t p
  if ((${#p[@]} == 0)); then return 0; fi
  if [[ $PAC == pacman ]]; then sudo pacman -Syw "${p[@]}"; else "$PAC" -Syw "${p[@]}"; fi
}
_pkgui_rm() {
  local -a p
  mapfile -t p
  if ((${#p[@]} == 0)); then return 0; fi
  if [[ $PAC == pacman ]]; then sudo pacman -Rns --nosave "${p[@]}"; else "$PAC" -Rns --nosave "${p[@]}"; fi
}
_pkgui_upd_check() {
  local now pac aur=0 flat=0
  now=$(printf '%(%s)T' -1)
  # Cache update checks for 300 seconds (5 minutes)
  if ((now - _CUPD_TIME < 300)) && [[ -n ${_CUPD[pac]:-} ]]; then
    pac=${_CUPD[pac]}
    aur=${_CUPD[aur]:-0}
    flat=${_CUPD[flat]:-0}
  else
    _pkgui_msg "Checking updates..."
    pac=$(checkupdates 2>/dev/null | wc -l)
    if [[ $PAC != pacman ]]; then aur=$("$PAC" -Qua 2>/dev/null | wc -l); fi
    if _pkgui_has flatpak; then flat=$(flatpak remote-ls --updates 2>/dev/null | wc -l); fi
    _CUPD[pac]=$pac
    _CUPD[aur]=$aur
    _CUPD[flat]=$flat
    _CUPD_TIME=$now
  fi
  printf '\n%bUpdate Summary:%b\n' "$BD" "$D"
  printf '  Pacman:  %b%d%b\n' "$C" "$pac" "$D"
  if ((aur > 0)); then printf '  AUR:     %b%d%b\n' "$C" "$aur" "$D"; fi
  if ((flat > 0)); then printf '  Flatpak: %b%d%b\n' "$C" "$flat" "$D"; fi
  printf '\n'
}
_pkgui_upd_full() {
  _pkgui_msg "Full system update..."
  if [[ $PAC == pacman ]]; then sudo pacman -Syu; else "$PAC" -Syu; fi
  if _pkgui_has flatpak; then
    _pkgui_msg "Updating flatpak..."
    flatpak update -y --noninteractive &>/dev/null
    sudo flatpak update -y --noninteractive &>/dev/null
  fi
  _pkgui_msg "Update complete!"
}
_pkgui_upd_flat() {
  if ! _pkgui_has flatpak; then
    _pkgui_warn "Flatpak not installed"
    return 1
  fi
  _pkgui_msg "Updating flatpak..."
  flatpak update -y --noninteractive
  sudo flatpak update -y --noninteractive
}
_pkgui_vulns() {
  if ! _pkgui_has arch-audit; then
    _pkgui_warn "Install: sudo pacman -S arch-audit"
    return 1
  fi
  _pkgui_msg "Checking vulnerabilities (CVE)..."
  arch-audit -u || echo "No vulnerable packages"
}
_pkgui_news() {
  if ! _pkgui_has curl; then
    _pkgui_warn "curl required"
    return 1
  fi
  _pkgui_msg "Arch News & Status..."
  printf '\n%bServer Status%b\n' "$BD" "$D"
  printf '  https://status.archlinux.org/\n\n'
  if ping -c 1 -W 2 archlinux.org &>/dev/null; then
    printf '  %b[✓]%b archlinux.org\n' "$G" "$D"
  else
    printf '  %b[✗]%b archlinux. org\n' "$R" "$D"
  fi
  if ping -c 1 -W 2 aur.archlinux.org &>/dev/null; then
    printf '  %b[✓]%b aur.archlinux.org\n\n' "$G" "$D"
  else
    printf '  %b[✗]%b aur.archlinux.org\n\n' "$R" "$D"
  fi
  printf '%bPhoronix - Arch Linux%b\n' "$BD" "$D"
  printf '  https://www.phoronix.com/linux/Arch+Linux\n\n'
  local awk_script
  read -r -d '' awk_script <<'AWK' || true
function pad2(n){
    return (n < 10 ? "0" n : n)
}
/<article>/ {
    in_article = 1; title = ""; date = ""
}
in_article {
    if ($0 ~ /<header>/){ in_header = 1 }
    if (in_header){
        if (match($0, /<header><a[^>]*>([^<]+)<\/a>/, t)){
            title = t[1]
        }
        if ($0 ~ /<\/header>/){ in_header = 0 }
    }
    if ($0 ~ /<div class="details">/){
        if (match($0, /([0-9]+) ([A-Za-z]+) ([0-9]+)/, d)){
            day = pad2(d[1]); month = d[2]; year = d[3];
            split("01 02 03 04 05 06 07 08 09 10 11 12",m_n);
            split("January February March April May June July August September October November December",m_s);
            for(i in m_s) months[m_s[i]]=m_n[i];
            month_num = months[month];
            printf "  [%s-%s-%s] %s\n", year, month_num, day, title;
            in_article = 0
        }
    }
}
AWK
  curl -s https://www.phoronix.com/linux/Arch+Linux 2>/dev/null | awk "$awk_script" | head -n 4 | tac
  printf '\n%bOfficial Arch News%b\n' "$BD" "$D"
  printf '  https://archlinux.org/feeds/news/\n\n'
  local awk_script_news
  read -r -d '' awk_script_news <<'AWK' || true
{
    printf "  %s\n    %s\n    %s\n\n", $1, $2, $3
}
AWK
  curl -fsSL 'https://archlinux.org/feeds/news/' 2>/dev/null |
    grep -E '<title>|<pubDate>|<link>' | sed -e 's/<[^>]*>//g' -e 's/^[[:space:]]*//' |
    paste - - - | head -n 5 | awk -F'	' "$awk_script_news"
}
_pkgui_status() {
  _pkgui_msg "Server status check..."
  printf '\n%bArchlinux. org:%b ' "$BD" "$D"
  if ping -c 1 -W 2 archlinux.org &>/dev/null; then
    printf '%b[✓] Online%b\n' "$G" "$D"
  else
    printf '%b[✗] Offline%b\n' "$R" "$D"
  fi
  printf '%bAUR:%b ' "$BD" "$D"
  if ping -c 1 -W 2 aur.archlinux.org &>/dev/null; then
    printf '%b[✓] Online%b\n\n' "$G" "$D"
  else
    printf '%b[✗] Offline%b\n\n' "$R" "$D"
  fi
}
_pkgui_mirrors() {
  if _pkgui_has reflector; then
    _pkgui_msg "Updating mirrors (reflector)..."
    sudo reflector --verbose --protocol https --age 6 --sort rate --save /etc/pacman.d/mirrorlist
    sudo pacman -Syy
  elif _pkgui_has pacman-mirrors; then
    _pkgui_msg "Updating mirrors (pacman-mirrors)..."
    sudo pacman-mirrors -f 0 && sudo pacman -Syy
  else
    _pkgui_warn "Install reflector (Arch) or pacman-mirrors (Manjaro)"
  fi
}
_pkgui_clean() {
  _pkgui_msg "Cleaning cache..."
  if [[ $PAC == pacman ]]; then sudo pacman -Sc; else "$PAC" -Sc; fi
  if _pkgui_has paccache; then sudo paccache -rk2; fi
  if [[ -d $HOME/.cache/yay ]]; then paccache -rk1 --cachedir "$HOME/.cache/yay" &>/dev/null; fi
  if [[ -d $HOME/.cache/paru ]]; then paccache -rk1 --cachedir "$HOME/.cache/paru" &>/dev/null; fi
}
_pkgui_pacdiff() {
  if ! _pkgui_has pacdiff; then
    _pkgui_warn "Install pacman-contrib"
    return 1
  fi
  _pkgui_msg "Running pacdiff..."
  if [[ -n ${DIFFPROG:-} ]]; then
    sudo pacdiff
  else
    sudo DIFFPROG="diff --side-by-side --suppress-common-lines --color=always" pacdiff
  fi
}
_pkgui_fw() {
  if ! _pkgui_has fwupdmgr; then
    _pkgui_warn "Install fwupd"
    return 1
  fi
  _pkgui_msg "Checking firmware updates..."
  fwupdmgr refresh --force &>/dev/null
  if fwupdmgr get-updates 2>/dev/null | grep -qE 'No updatable|No updates|updated successfully'; then
    echo "No firmware updates available"
  else
    fwupdmgr get-updates
    read -rp "Run fwupdmgr update?  [y/N] " ans
    if [[ ${ans,,} == y ]]; then fwupdmgr update; fi
  fi
}
_pkgui_svc() {
  _pkgui_msg "Checking failed systemd services..."
  local f
  f=$(systemctl --failed --no-pager --no-legend | wc -l)
  if ((f > 0)); then
    systemctl --failed --no-pager
  else
    echo "No failed services"
  fi
}
_pkgui_maint() {
  _pkgui_msg "System maintenance scan..."
  printf '\n%b=== Orphans ===%b\n' "$BD" "$D"
  "$PAC" -Qdttq 2>/dev/null | wc -l | xargs printf '%d orphans\n'
  printf '\n%b=== Optional Deps ===%b\n' "$BD" "$D"
  "$PAC" -Qettq 2>/dev/null | wc -l | xargs printf '%d packages\n'
  printf '\n%b=== Cache ===%b\n' "$BD" "$D"
  du -sh /var/cache/pacman/pkg/ 2>/dev/null || echo "N/A"
  printf '\n%b=== Failed Services ===%b\n' "$BD" "$D"
  systemctl --failed --no-pager --no-legend | wc -l | xargs printf '%d failed\n'
  if _pkgui_has arch-audit; then
    printf '\n%b=== Vulnerabilities ===%b\n' "$BD" "$D"
    arch-audit -u 2>/dev/null | wc -l | xargs printf '%d vulnerable\n'
  fi
  if _pkgui_has pacdiff; then
    printf '\n%b=== . pacnew/. pacsave Files ===%b\n' "$BD" "$D"
    pacdiff -o 2>/dev/null | wc -l | xargs printf '%d files need review\n'
  fi
  printf '\n'
}
_pkgui_gen_lists() {
  local d="$CFG/lists"
  mkdir -p "$d"
  _pkgui_msg "Generating lists in $d..."
  pacman -Qeq >"$d/explicit. txt"
  pacman -Qdq >"$d/deps.txt"
  pacman -Qnq >"$d/native.txt"
  pacman -Qmq >"$d/foreign.txt"
  pacman -Qtq >"$d/unrequired.txt"
  pacman -Qdttq 2>/dev/null >"$d/orphans.txt" || :
  expac -H M '%m	%n' | sort -h >"$d/by-size.txt"
  expac --timefmt='%Y-%m-%d %T' '%l	%n' | sort >"$d/by-install.txt"
  if _pkgui_has flatpak; then flatpak list >"$d/flatpak. txt"; fi
  _pkgui_msg "Generated: $d"
  find "$d" -name '*.txt' -printf '%p %s\n'
}
_pkgui_backup() {
  local b="$PKGLIST. $(date +%Y%m%d-%H%M%S)"
  pacman -Qeq >"$b"
  _pkgui_msg "Backup: $b"
}
_pkgui_restore() {
  export -f _pkgui_fzf
  export FND FZF_THEME HIST
  local b
  if ! compgen -G "$PKGLIST.*" >/dev/null; then
    _pkgui_warn "No backups"
    return 1
  fi
  b=$(find . -maxdepth 1 -name "$PKGLIST.*" -print0 | xargs -0 ls -t | _pkgui_fzf -h "Select backup to restore" -p "cat {}")
  if [[ -z $b ]]; then return 0; fi
  _pkgui_msg "Restoring: $b"
  if [[ $PAC == pacman ]]; then xargs -a "$b" sudo pacman -S --needed; else xargs -a "$b" "$PAC" -S --needed; fi
}
_pkgui_sync_list() {
  _pkgui_msg "Syncing packagelist..."
  pacman -Qeq | sort >"$PKGLIST"
  _pkgui_msg "Synced: $PKGLIST"
}
_pkgui_export() {
  _pkgui_msg "Exporting native packages..."
  pacman -Qqne >"$FILE_NATIVE"
  _pkgui_msg "Exported: $FILE_NATIVE ($(wc -l <"$FILE_NATIVE") packages)"

  _pkgui_msg "Exporting AUR packages..."
  pacman -Qqme >"$FILE_AUR"
  _pkgui_msg "Exported: $FILE_AUR ($(wc -l <"$FILE_AUR") packages)"

  printf '\n%bExport complete:%b\n' "$BD" "$D"
  printf '  Native: %s\n' "$FILE_NATIVE"
  printf '  AUR:    %s\n' "$FILE_AUR"
}
_pkgui_import() {
  if [[ -s $FILE_NATIVE ]]; then
    _pkgui_msg "Importing native packages ($(wc -l <"$FILE_NATIVE") packages)..."
    sudo pacman -S --needed - <"$FILE_NATIVE" || _pkgui_warn "Native import had issues"
  else
    _pkgui_warn "Skipping native (file empty/missing: $FILE_NATIVE)"
  fi

  if [[ -s $FILE_AUR ]]; then
    if [[ $PAC == pacman ]]; then
      _pkgui_warn "AUR packages require paru/yay.  Install manually from: $FILE_AUR"
    else
      _pkgui_msg "Importing AUR packages ($(wc -l <"$FILE_AUR") packages)..."
      "$PAC" -S --needed - <"$FILE_AUR" || _pkgui_warn "AUR import had issues"
    fi
  else
    _pkgui_warn "Skipping AUR (file empty/missing: $FILE_AUR)"
  fi

  _pkgui_msg "Import complete!"
}
_pkgui_history() {
  _pkgui_msg "Install history (last 200)..."
  grep -h '^\[.*\] \[ALPM\] \(installed\|removed\) ' /var/log/pacman. log* 2>/dev/null |
    tail -1000 | sort |
    sed -E 's/^\[([^T]+)T([^-]+)-[0-9:+]+]. * (installed|removed) ([^ ]+) \(([^)]+)\). */\1 \2 \3 \4 (\5)/' |
    awk -v g="$G" -v r="$R" -v d="$D" '{cmd="date -d \""$2"\" +\"%I:%M %p\" 2>/dev/null";cmd|getline t;close(cmd);if(t=="")t=substr($2,1,5);split(t,a,":");hour=a[1];minute=a[2];ampm=tolower(a[3]);if(hour=="")hour=substr(t,1,2);if(minute=="")minute=substr(t,4,2);if(hour~/^0/)hour=substr(hour,2);if($3=="installed")indicator=g"[+]"d;else indicator=r"[-]"d;printf"%s %02d:%s %s %s %s\n",$1,hour+0,minute,ampm,indicator,$4" "$5}' |
    grep -Fwf <(pacman -Qei | awk '/^Name/{name=$3}/^Install Reason/{if($4=="Explicitly")print name}') |
    tail -200 | less -R
}
_pkgui_info_sys() {
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
  if _pkgui_has flatpak; then printf '%bFlatpak:%b %d\n' "$BD" "$D" "$(flatpak list 2>/dev/null | wc -l)"; fi
  printf '\n'
}
_pkgui_notify() {
  if ! _pkgui_has notify-send; then
    _pkgui_warn "Install libnotify"
    return 1
  fi
  local pac aur=0
  pac=$(checkupdates 2>/dev/null | wc -l)
  if [[ $PAC != pacman ]]; then aur=$("$PAC" -Qua 2>/dev/null | wc -l); fi
  if ((pac > 0 || aur > 0)); then
    notify-send "pkgui: Updates" "Pacman: $pac, AUR: $aur" --icon=dialog-information
    _pkgui_msg "Notified: Pacman=$pac, AUR=$aur"
  else
    _pkgui_msg "Up to date"
  fi
}
_pkgui_edit_cfg() {
  local c="$CFG/config"
  if [[ ! -f $c ]]; then
    cat >"$c" <<'EOF'
# pkgui config
PARUZ="paru pacman"
FINDER="sk fzf"
FZF_THEME="hl:italic:#FFFF00,hl+:bold:underline:#FF0000,fg:#98A0C5,fg+:bold:#FFFFFF,bg:#13172A,bg+:#0F1222"
EOF
  fi
  "${EDITOR:-nano}" "$c"
}
_pkgui_edit_sys() {
  local -A files=(
    ["/etc/pacman.conf"]="Pacman config"
    ["/etc/pacman.d/mirrorlist"]="Mirrors"
    ["/etc/makepkg.conf"]="Makepkg config"
  )
  local -a choices
  for f in "${!files[@]}"; do
    choices+=("$f - ${files[$f]}")
  done
  printf '%s\n' "${choices[@]}" | "$FND" --prompt='Edit:' | awk '{print $1}' | xargs -r "${EDITOR:-nano}"
}
main() {
  case "${1:-}" in
  -s)
    shift
    _pkgui_search "$@"
    ;;
  -S)
    shift
    _pkgui_search "$@" | _pkgui_inst
    ;;
  -l) _pkgui_local ;;
  -R) _pkgui_local | _pkgui_rm ;;
  -u) _pkgui_upd_full ;;
  -i) _pkgui_info_sys ;;
  -v)
    _pkgui_ver
    exit 0
    ;;
  -h)
    _pkgui_help
    exit 0
    ;;
  "") ;;
  *) _pkgui_die "Invalid option: $1" ;;
  esac
  [[ $# -eq 0 ]] && _pkgui_menu
}
_pkgui_menu() {
  local choice
  while :; do
    choice=$(
      cat <<'MENU' | "$FND" --prompt='Action:' --height=40 --header="$BD pkgui $D" || exit 0
s - Search packages
S - Search & install
l - List local
R - Remove packages
A - Remove orphans
O - Remove optional deps
U - Check updates
u - System update
F - Update flatpak
b - Browse AUR
H - Install history
M - Maintenance scan
C - Clean cache
V - Vulnerabilities
W - Arch news
m - Mirrors
p - pacdiff
f - Firmware
k - Failed services
N - Server status
P - Generate pkg lists
B - Backup list
T - Restore backup
L - Sync packagelist
X - Export (native+AUR)
I - Import (native+AUR)
i - System info
c - Edit config
e - Edit system configs
n - Desktop notify
h - Help
v - Version
MENU
    )
    case "${choice%% *}" in
    s) _pkgui_search ;;
    S) _pkgui_search | _pkgui_inst ;;
    l) _pkgui_local ;;
    R) _pkgui_local | _pkgui_rm ;;
    A) _pkgui_orphans | _pkgui_rm ;;
    O) _pkgui_opt_deps | _pkgui_rm ;;
    U) _pkgui_upd_check ;;
    u) _pkgui_upd_full ;;
    F) _pkgui_upd_flat ;;
    b) _pkgui_browse_aur | _pkgui_inst ;;
    H) _pkgui_history ;;
    M) _pkgui_maint ;;
    C) _pkgui_clean ;;
    V) _pkgui_vulns ;;
    W) _pkgui_news ;;
    m) _pkgui_mirrors ;;
    p) _pkgui_pacdiff ;;
    f) _pkgui_fw ;;
    k) _pkgui_svc ;;
    N) _pkgui_status ;;
    P) _pkgui_gen_lists ;;
    B) _pkgui_backup ;;
    T) _pkgui_restore ;;
    L) _pkgui_sync_list ;;
    X) _pkgui_export ;;
    I) _pkgui_import ;;
    i) _pkgui_info_sys ;;
    c) _pkgui_edit_cfg ;;
    e) _pkgui_edit_sys ;;
    n) _pkgui_notify ;;
    h) _pkgui_help ;;
    v) _pkgui_ver ;;
    *) break ;;
    esac
  done
}
main "$@"


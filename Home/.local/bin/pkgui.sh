#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
export HOME="/home/${SUDO_USER:-$USER}" SHELL="$(command -v bash)"
readonly R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' C=$'\e[36m' M=$'\e[35m' BD=$'\e[1m' D=$'\e[0m' UL=$'\e[4m' IT=$'\e[3m'
readonly CFG="${XDG_CONFIG_HOME:-$HOME/.config}/pkgui" CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/pkgui" HIST="${PKGUI_HISTORY:-$CACHE/history}" PKGLIST="${PKGUI_PKGLIST:-$CFG/packagelist}" FILE_NATIVE="$CFG/pkglist_native.txt" FILE_AUR="$CFG/pkglist_aur.txt"
declare -A _pkgui_cmd_cache _CI _CQ _CL _CLO _CUPD
_CUPD_TIME=0
mkdir -p "$CFG" "$CACHE" "${HIST%/*}"
_pkgui_has(){
  [[ -n ${_pkgui_cmd_cache[$1]:-} ]] && return "${_pkgui_cmd_cache[$1]}"
  command -v "$1" &>/dev/null && _pkgui_cmd_cache["$1"]=0||_pkgui_cmd_cache["$1"]=1
  return "${_pkgui_cmd_cache[$1]}"
}
_pkgui_die(){ printf '%b[ERR]%b %s\n' "$R" "$D" "$*" >&2;exit 1;}
_pkgui_msg(){ printf '%b%s%b\n' "$G" "$*" "$D";}
_pkgui_warn(){ printf '%b[WARN]%b %s\n' "$Y" "$D" "$*" >&2;}
for p in ${PARUZ:-paru pacman};do _pkgui_has "$p" && PAC="$p" && break;done
[[ -z ${PAC:-} ]] && _pkgui_die "No pkg mgr (pacman/paru)"
for f in ${FINDER:-sk fzf};do _pkgui_has "$f" && FND="$f" && break;done
[[ -z ${FND:-} ]] && _pkgui_die "No fuzzy finder (sk/fzf)"
FZF_THEME="${FZF_THEME:-hl:italic:#FFFF00,hl+:bold:underline:#FF0000,fg:#98A0C5,fg+:bold:#FFFFFF,bg:#13172A,bg+:#0F1222,border:#75A2F7,label:bold:#75A2F7,preview-fg:#C0CAF5,preview-bg:#0F1222,marker:#7AA2F7,spinner:#7AA2F7,prompt:#7DCFFF,info:#7AA2F7,pointer:#7DCFFF,header:#FF9E64}"
_pkgui_ver(){ printf '%b%s%b v4.3.0 - Unified pacman/AUR TUI\n' "$BD" "${0##*/}" "$D";}
_pkgui_help(){
  cat <<'EOF'
USAGE: pkgui [CMD|FLAG] [ARGS]
FLAGS: -s TERM (search) -S TERM (install) -l (list) -R (remove) -u (update) -i (info) -h (help) -v (version)
PACKAGE: s/S/l/R/D/A/O/U/u/F/b/H  SYSTEM: M/C/V/W/m/p/f/k/N  LISTS: P/B/T/L/X/I  CONFIG: i/c/e/n/h/v
FZF KEYS: Tab(select) Ctrl-i(install) Ctrl-r(remove) Ctrl-u(update) Ctrl-p(PKGBUILD) Ctrl-s(info) Ctrl-/(layout) ?(help)
EOF
}
_pkgui_fzf(){
  local -a o=(--ansi --cycle --reverse --inline-info --no-scrollbar --color="$FZF_THEME" --history="$HIST")
  [[ $FND == sk ]] && o+=(--no-hscroll)
  while (($#));do
    case $1 in
      -m) o+=(-m);shift;;
      -h) o+=(--header "$2");shift 2;;
      -p) o+=(--preview "$2" --preview-window='down:60%:wrap');shift 2;;
      -l) o+=(--preview-label "$2");shift 2;;
      -b) o+=(--bind "$2");shift 2;;
      *) shift;;
    esac
  done
  "$FND" "${o[@]}"
}
_pkgui_info(){ [[ -n ${_CI[$1]:-} ]] && printf '%s\n' "${_CI[$1]}" && return;local r;r=$("$PAC" --color=always -Si "$1" 2>/dev/null|grep -v '^ ');_CI[$1]=$r;printf '%s\n' "$r";}
_pkgui_infoq(){ [[ -n ${_CQ[$1]:-} ]] && printf '%s\n' "${_CQ[$1]}" && return;local r;r=$("$PAC" -Qi --color=always "$1" 2>/dev/null);_CQ[$1]=$r;printf '%s\n' "$r";}
_pkgui_list(){ [[ -n ${_CL[$*]:-} ]] && printf '%s\n' "${_CL[$*]}" && return;local r;r=$("$PAC" -Ss --quiet "$@" 2>/dev/null||:);_CL[$*]=$r;printf '%s\n' "$r";}
_pkgui_listq(){ [[ -n ${_CLO[$*]:-} ]] && printf '%s\n' "${_CLO[$*]}" && return;local r;r=$("$PAC" -Qs --quiet "$@" 2>/dev/null||:);_CLO[$*]=$r;printf '%s\n' "$r";}
_pkgui_prev_pkg(){
  local pkg=$1 mode=${2:-repo}
  if [[ $mode == aur ]];then
    printf "=== Package Info ===\n";"$PAC" --color=always -Si "$pkg" 2>/dev/null||echo "No info"
    printf "\n=== PKGBUILD ===\n";_pkgui_has curl && curl -fsSL "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$pkg" 2>/dev/null||:
    printf "\n=== Source Tree ===\n";_pkgui_has curl && curl -fsSL "https://aur.archlinux.org/cgit/aur.git/tree/?h=$pkg" 2>/dev/null|grep 'tree/'|sed -n 's/.*tree\/\([^?"]*\).*/\1/p'|sort -u|while read -r f;do printf 'https://aur.archlinux.org/cgit/aur.git/plain/%s?h=%s\n' "$f" "$pkg";done||:
  else
    _pkgui_info "$pkg"
  fi
}
_pkgui_search(){
  export -f _pkgui_info _pkgui_fzf _pkgui_prev_pkg;export PAC FND FZF_THEME HIST;declare -gA _CI
  _pkgui_list "$@"|_pkgui_fzf -m -h $'Enter:install Ctrl-i:install Ctrl-r:remove Ctrl-p:PKGBUILD Ctrl-s:info Ctrl-u:update Ctrl-/:layout ?:keys' -l '[package info]' -p "bash -c '_pkgui_info {}'" -b "ctrl-i:execute($PAC -S {} </dev/tty >/dev/tty 2>&1)" -b "ctrl-s:execute(_pkgui_info {} | less -R)" -b "ctrl-p:execute(_pkgui_prev_pkg {} aur | less -R)" -b "ctrl-u:execute($PAC -Syu </dev/tty >/dev/tty 2>&1)" -b "alt-p:toggle-preview" -b "ctrl-/:change-preview-window(down,60%|right,60%|hidden)"
}
_pkgui_local(){
  export -f _pkgui_infoq _pkgui_fzf;export PAC FND FZF_THEME HIST;declare -gA _CQ
  _pkgui_listq "$@"|_pkgui_fzf -m -h $'Enter:remove Ctrl-r:remove Ctrl-s:info Ctrl-/:layout ?:keys' -l '[installed]' -p "bash -c '_pkgui_infoq {}'" -b "ctrl-r:execute($PAC -Rns {} </dev/tty >/dev/tty 2>&1)" -b "ctrl-s:execute(_pkgui_infoq {} | less -R)" -b "ctrl-/:change-preview-window(down,60%|right,60%|hidden)"
}
_pkgui_browse_aur(){
  export -f _pkgui_prev_pkg _pkgui_fzf;export PAC FND FZF_THEME HIST
  _pkgui_msg "Loading AUR packages..."
  "$PAC" -Slq 2>/dev/null|_pkgui_fzf -m -h $'Ctrl-p:PKGBUILD Ctrl-i:install Ctrl-s:info Enter:install' -l '[AUR]' -p "bash -c '_pkgui_prev_pkg {} aur'" -b "ctrl-p:execute(_pkgui_prev_pkg {} aur | less -R)" -b "ctrl-i:execute($PAC -S {} </dev/tty >/dev/tty 2>&1)" -b "ctrl-s:execute($PAC -Si {} | less -R)"
}
_pkgui_orphans(){
  export -f _pkgui_infoq _pkgui_fzf;export PAC FND FZF_THEME HIST;declare -gA _CQ
  "$PAC" -Qdttq 2>/dev/null|_pkgui_fzf -m -h $'Enter:remove Ctrl-r:remove Ctrl-s:info' -l '[orphan]' -p "bash -c '_pkgui_infoq {}'" -b "ctrl-r:execute($PAC -Rns {} </dev/tty >/dev/tty 2>&1)"
}
_pkgui_opt_deps(){
  export -f _pkgui_infoq _pkgui_fzf;export PAC FND FZF_THEME HIST;declare -gA _CQ
  "$PAC" -Qttdq 2>/dev/null|_pkgui_fzf -m -h $'Enter:remove optional deps' -l '[optional]' -p "bash -c '_pkgui_infoq {}'"
}
_pkgui_inst(){ local -a p;mapfile -t p;((${#p[@]}==0))&& return;[[ $PAC == pacman ]] && sudo pacman -S "${p[@]}"||"$PAC" -S "${p[@]}";}
_pkgui_dl(){ local -a p;mapfile -t p;((${#p[@]}==0))&& return;[[ $PAC == pacman ]] && sudo pacman -Syw "${p[@]}"||"$PAC" -Syw "${p[@]}";}
_pkgui_rm(){ local -a p;mapfile -t p;((${#p[@]}==0))&& return;[[ $PAC == pacman ]] && sudo pacman -Rns --nosave "${p[@]}"||"$PAC" -Rns --nosave "${p[@]}";}
_pkgui_upd_check(){
  local now pac aur=0 flat=0;now=$(printf '%(%s)T' -1)
  if ((now-_CUPD_TIME<300)) && [[ -n ${_CUPD[pac]:-} ]];then pac=${_CUPD[pac]};aur=${_CUPD[aur]:-0};flat=${_CUPD[flat]:-0}
  else
    _pkgui_msg "Checking updates...";pac=$(checkupdates 2>/dev/null|wc -l)
    [[ $PAC != pacman ]] && aur=$("$PAC" -Qua 2>/dev/null|wc -l)
    _pkgui_has flatpak && flat=$(flatpak remote-ls --updates 2>/dev/null|wc -l)
    _CUPD[pac]=$pac;_CUPD[aur]=$aur;_CUPD[flat]=$flat;_CUPD_TIME=$now
  fi
  printf '\n%bUpdate Summary:%b\nPacman: %b%d%b\n' "$BD" "$D" "$C" "$pac" "$D"
  ((aur>0)) && printf 'AUR:    %b%d%b\n' "$C" "$aur" "$D"
  ((flat>0)) && printf 'Flatpak:%b%d%b\n' "$C" "$flat" "$D"
  printf '\n'
}
_pkgui_upd_full(){
  _pkgui_msg "Full system update..."
  [[ $PAC == pacman ]] && sudo pacman -Syu||"$PAC" -Syu
  if _pkgui_has flatpak;then _pkgui_msg "Updating flatpak...";flatpak update -y --noninteractive &>/dev/null;sudo flatpak update -y --noninteractive &>/dev/null;fi
  _pkgui_msg "Update complete!"
}
_pkgui_upd_flat(){ _pkgui_has flatpak||{ _pkgui_warn "Flatpak not installed";return 1;};_pkgui_msg "Updating flatpak...";flatpak update -y --noninteractive;sudo flatpak update -y --noninteractive;}
_pkgui_vulns(){ _pkgui_has arch-audit||{ _pkgui_warn "Install: sudo pacman -S arch-audit";return 1;};_pkgui_msg "Checking vulnerabilities (CVE)...";arch-audit -u||echo "No vulnerable packages";}
_pkgui_news(){
  _pkgui_has curl||{ _pkgui_warn "curl required";return 1;}
  _pkgui_msg "Arch News & Status..."
  printf '\n%bServer Status%b\n  https://status.archlinux.org/\n' "$BD" "$D"
  ping -c 1 -W 2 archlinux.org &>/dev/null && printf '  %b[✓]%b archlinux.org\n' "$G" "$D"||printf '  %b[✗]%b archlinux.org\n' "$R" "$D"
  ping -c 1 -W 2 aur.archlinux.org &>/dev/null && printf '  %b[✓]%b aur.archlinux.org\n\n' "$G" "$D"||printf '  %b[✗]%b aur.archlinux.org\n\n' "$R" "$D"
  printf '%bPhoronix - Arch Linux%b\n  https://www.phoronix.com/linux/Arch+Linux\n\n' "$BD" "$D"
  curl -s https://www.phoronix.com/linux/Arch+Linux 2>/dev/null|awk 'function pad2(n){return(n<10?"0"n:n)}/<article>/{in_article=1;title="";date=""}in_article{if($0~/<header>/){in_header=1}if(in_header){if(match($0,/<header><a[^>]*>([^<]+)<\/a>/,t)){title=t[1]}if($0~/<\/header>/){in_header=0}}if($0~/<div class="details">/){if(match($0,/([0-9]+) ([A-Za-z]+) ([0-9]+)/,d)){day=pad2(d[1]);month=d[2];year=d[3];split("01 02 03 04 05 06 07 08 09 10 11 12",m_n);split("January February March April May June July August September October November December",m_s);for(i in m_s)months[m_s[i]]=m_n[i];month_num=months[month];printf"  [%s-%s-%s] %s\n",year,month_num,day,title;in_article=0}}}'|head -n 4|tac
  printf '\n%bOfficial Arch News%b\n  https://archlinux.org/feeds/news/\n\n' "$BD" "$D"
  curl -fsSL 'https://archlinux.org/feeds/news/' 2>/dev/null|grep -E '<title>|<pubDate>|<link>'|sed -e 's/<[^>]*>//g' -e 's/^[[:space:]]*//'|paste - - -|head -n 5|awk -F' ' '{printf"  %s\n    %s\n    %s\n\n",$1,$2,$3}'
}
_pkgui_status(){
  _pkgui_msg "Server status check..."
  printf '\n%bArchlinux.org:%b ' "$BD" "$D";ping -c 1 -W 2 archlinux.org &>/dev/null && printf '%b[✓] Online%b\n' "$G" "$D"||printf '%b[✗] Offline%b\n' "$R" "$D"
  printf '%bAUR:%b ' "$BD" "$D";ping -c 1 -W 2 aur.archlinux.org &>/dev/null && printf '%b[✓] Online%b\n\n' "$G" "$D"||printf '%b[✗] Offline%b\n\n' "$R" "$D"
}
_pkgui_mirrors(){
  if _pkgui_has reflector;then _pkgui_msg "Updating mirrors (reflector)...";sudo reflector --verbose --protocol https --age 6 --sort rate --save /etc/pacman.d/mirrorlist;sudo pacman -Syy
  elif _pkgui_has pacman-mirrors;then _pkgui_msg "Updating mirrors (pacman-mirrors)...";sudo pacman-mirrors -f 0 && sudo pacman -Syy
  else _pkgui_warn "Install reflector (Arch) or pacman-mirrors (Manjaro)";fi
}
_pkgui_clean(){
  _pkgui_msg "Cleaning cache..."
  [[ $PAC == pacman ]] && sudo pacman -Sc||"$PAC" -Sc
  _pkgui_has paccache && sudo paccache -rk2
  [[ -d $HOME/.cache/yay ]] && paccache -rk1 --cachedir "$HOME/.cache/yay" &>/dev/null
  [[ -d $HOME/.cache/paru ]] && paccache -rk1 --cachedir "$HOME/.cache/paru" &>/dev/null
}
_pkgui_pacdiff(){ _pkgui_has pacdiff||{ _pkgui_warn "Install pacman-contrib";return 1;};_pkgui_msg "Running pacdiff...";[[ -n ${DIFFPROG:-} ]] && sudo pacdiff||sudo DIFFPROG="diff --side-by-side --suppress-common-lines --color=always" pacdiff;}
_pkgui_fw(){
  _pkgui_has fwupdmgr||{ _pkgui_warn "Install fwupd";return 1;}
  _pkgui_msg "Checking firmware updates...";fwupdmgr refresh --force &>/dev/null
  if fwupdmgr get-updates 2>/dev/null|grep -qE 'No updatable|No updates|updated successfully';then echo "No firmware updates available"
  else fwupdmgr get-updates;read -rp "Run fwupdmgr update? [y/N] " ans;[[ ${ans,,} == y ]] && fwupdmgr update;fi
}
_pkgui_svc(){ _pkgui_msg "Checking failed systemd services...";local f;f=$(systemctl --failed --no-pager --no-legend|wc -l);((f>0)) && systemctl --failed --no-pager||echo "No failed services";}
_pkgui_maint(){
  _pkgui_msg "System maintenance scan..."
  printf '\n%b=== Orphans ===%b\n' "$BD" "$D";"$PAC" -Qdttq 2>/dev/null|wc -l|xargs printf '%d orphans\n'
  printf '\n%b=== Optional Deps ===%b\n' "$BD" "$D";"$PAC" -Qettq 2>/dev/null|wc -l|xargs printf '%d packages\n'
  printf '\n%b=== Cache ===%b\n' "$BD" "$D";du -sh /var/cache/pacman/pkg/ 2>/dev/null||echo "N/A"
  printf '\n%b=== Failed Services ===%b\n' "$BD" "$D";systemctl --failed --no-pager --no-legend|wc -l|xargs printf '%d failed\n'
  _pkgui_has arch-audit && { printf '\n%b=== Vulnerabilities ===%b\n' "$BD" "$D";arch-audit -u 2>/dev/null|wc -l|xargs printf '%d vulnerable\n';}
  _pkgui_has pacdiff && { printf '\n%b=== .pacnew/.pacsave ===%b\n' "$BD" "$D";pacdiff -o 2>/dev/null|wc -l|xargs printf '%d files need review\n';}
  printf '\n'
}
_pkgui_gen_lists(){
  local d="$CFG/lists";mkdir -p "$d";_pkgui_msg "Generating lists in $d..."
  pacman -Qeq >"$d/explicit.txt";pacman -Qdq >"$d/deps.txt";pacman -Qnq >"$d/native.txt";pacman -Qmq >"$d/foreign.txt";pacman -Qtq >"$d/unrequired.txt";pacman -Qdttq 2>/dev/null >"$d/orphans.txt"||:
  expac -H M '%m %n'|sort -h >"$d/by-size.txt";expac --timefmt='%Y-%m-%d %T' '%l %n'|sort >"$d/by-install.txt"
  _pkgui_has flatpak && flatpak list >"$d/flatpak.txt"
  _pkgui_msg "Generated: $d";find "$d" -name '*.txt' -printf '%p %s\n'
}
_pkgui_backup(){ local b="$PKGLIST.$(date +%Y%m%d-%H%M%S)";pacman -Qeq >"$b";_pkgui_msg "Backup: $b";}
_pkgui_restore(){
  export -f _pkgui_fzf;export FND FZF_THEME HIST;local b
  compgen -G "$PKGLIST.*" >/dev/null||{ _pkgui_warn "No backups";return 1;}
  b=$(find . -maxdepth 1 -name "$PKGLIST.*" -printf '%T@ %p\0'|sort -zrn|cut -zd' ' -f2-|tr '\0' '\n'|_pkgui_fzf -h "Select backup" -p "cat {}")
  [[ -z $b ]] && return
  _pkgui_msg "Restoring: $b"
  [[ $PAC == pacman ]] && xargs -a "$b" sudo pacman -S --needed||xargs -a "$b" "$PAC" -S --needed
}
_pkgui_sync_list(){ _pkgui_msg "Syncing packagelist...";pacman -Qeq|sort >"$PKGLIST";_pkgui_msg "Synced: $PKGLIST";}
_pkgui_export(){
  _pkgui_msg "Exporting native...";pacman -Qqne >"$FILE_NATIVE";_pkgui_msg "Exported: $FILE_NATIVE ($(wc -l <"$FILE_NATIVE") packages)"
  _pkgui_msg "Exporting AUR...";pacman -Qqme >"$FILE_AUR";_pkgui_msg "Exported: $FILE_AUR ($(wc -l <"$FILE_AUR") packages)"
  printf '\n%bExport complete:%b\nNative: %s\nAUR:    %s\n' "$BD" "$D" "$FILE_NATIVE" "$FILE_AUR"
}
_pkgui_import(){
  [[ -s $FILE_NATIVE ]] && { _pkgui_msg "Importing native ($(wc -l <"$FILE_NATIVE") packages)...";sudo pacman -S --needed - <"$FILE_NATIVE"||_pkgui_warn "Native import had issues";}||_pkgui_warn "Skipping native (file empty/missing: $FILE_NATIVE)"
  if [[ -s $FILE_AUR ]];then
    [[ $PAC == pacman ]] && _pkgui_warn "AUR requires paru/yay. Install from: $FILE_AUR"||{ _pkgui_msg "Importing AUR ($(wc -l <"$FILE_AUR") packages)...";"$PAC" -S --needed - <"$FILE_AUR"||_pkgui_warn "AUR import had issues";}
  else _pkgui_warn "Skipping AUR (file empty/missing: $FILE_AUR)";fi
  _pkgui_msg "Import complete!"
}
_pkgui_history(){
  _pkgui_msg "Install history (last 200)..."
  grep -h '^\[.*\] \[ALPM\] \(installed\|removed\) ' /var/log/pacman.log* 2>/dev/null|tail -1000|sort|sed -E 's/^\[([^T]+)T([^-]+)-[0-9:+]+].* (installed|removed) ([^ ]+) \(([^)]+)\).*/\1 \2 \3 \4 (\5)/'|awk -v g="$G" -v r="$R" -v d="$D" '{cmd="date -d \""$2"\" +\"%I:%M %p\" 2>/dev/null";cmd|getline t;close(cmd);if(t=="")t=substr($2,1,5);split(t,a,":");hour=a[1];minute=a[2];ampm=tolower(a[3]);if(hour=="")hour=substr(t,1,2);if(minute=="")minute=substr(t,4,2);if(hour~/^0/)hour=substr(hour,2);if($3=="installed")indicator=g"[+]"d;else indicator=r"[-]"d;printf"%s %02d:%s %s %s %s\n",$1,hour+0,minute,ampm,indicator,$4" "$5}'|grep -Fwf <(pacman -Qeq 2>/dev/null)|tail -200|less -R
}
_pkgui_info_sys(){
  local now total=0 explicit=0 deps=0 orphans=0 foreign=0 flatpak_count=0;now=$(printf '%(%s)T' -1)
  if ((now-${_CI[time]:-0}>60));then
    local -a pkg_all pkg_e pkg_d pkg_o pkg_m
    mapfile -t pkg_all < <(pacman -Qq 2>/dev/null);mapfile -t pkg_e < <(pacman -Qeq 2>/dev/null);mapfile -t pkg_d < <(pacman -Qdq 2>/dev/null);mapfile -t pkg_o < <(pacman -Qdttq 2>/dev/null);mapfile -t pkg_m < <(pacman -Qmq 2>/dev/null)
    _CI[total]=${#pkg_all[@]};_CI[explicit]=${#pkg_e[@]};_CI[deps]=${#pkg_d[@]};_CI[orphans]=${#pkg_o[@]};_CI[foreign]=${#pkg_m[@]};_CI[time]=$now
  fi
  total=${_CI[total]};explicit=${_CI[explicit]};deps=${_CI[deps]};orphans=${_CI[orphans]};foreign=${_CI[foreign]}
  _pkgui_has flatpak && flatpak_count=$(flatpak list 2>/dev/null|wc -l)
  printf '%b=== System ===%b\n%bHost:%b     %s\n%bKernel:%b   %s\n%bUptime:%b   %s\n%bPkgs:%b     %d total\n%bExplicit:%b %d\n%bDeps:%b     %d\n%bOrphans:%b  %d\n%bForeign:%b  %d\n%bManager:%b  %s\n%bFinder:%b   %s\n' "$BD" "$D" "$BD" "$D" "$(hostname)" "$BD" "$D" "$(uname -r)" "$BD" "$D" "$(uptime -p)" "$BD" "$D" "$total" "$BD" "$D" "$explicit" "$BD" "$D" "$deps" "$BD" "$D" "$orphans" "$BD" "$D" "$foreign" "$BD" "$D" "$PAC" "$BD" "$D" "$FND"
  ((flatpak_count>0)) && printf '%bFlatpak:%b %d\n' "$BD" "$D" "$flatpak_count"
  printf '\n'
}
_pkgui_notify(){
  _pkgui_has notify-send||{ _pkgui_warn "Install libnotify";return 1;}
  local pac aur=0;pac=$(checkupdates 2>/dev/null|wc -l)
  [[ $PAC != pacman ]] && aur=$("$PAC" -Qua 2>/dev/null|wc -l)
  ((pac>0||aur>0)) && { notify-send "pkgui: Updates" "Pacman: $pac, AUR: $aur" --icon=dialog-information;_pkgui_msg "Notified: Pacman=$pac, AUR=$aur";}||_pkgui_msg "Up to date"
}
_pkgui_edit_cfg(){
  local c="$CFG/config"
  [[ ! -f $c ]] && cat >"$c" <<'EOF'
# pkgui config
PARUZ="paru pacman"
FINDER="sk fzf"
FZF_THEME="hl:italic:#FFFF00,hl+:bold:underline:#FF0000,fg:#98A0C5,fg+:bold:#FFFFFF,bg:#13172A,bg+:#0F1222"
EOF
  "${EDITOR:-nano}" "$c"
}
_pkgui_edit_sys(){
  local -A files=(["/etc/pacman.conf"]="Pacman config" ["/etc/pacman.d/mirrorlist"]="Mirrors" ["/etc/makepkg.conf"]="Makepkg config")
  local -a choices;for f in "${!files[@]}";do choices+=("$f - ${files[$f]}");done
  printf '%s\n' "${choices[@]}"|"$FND" --prompt='Edit:'|awk '{print $1}'|xargs -r "${EDITOR:-nano}"
}
main(){
  case "${1:-}" in
    -s) shift;_pkgui_search "$@";;-S) shift;_pkgui_search "$@"|_pkgui_inst;;-l) _pkgui_local;;-R) _pkgui_local|_pkgui_rm;;-u) _pkgui_upd_full;;-i) _pkgui_info_sys;;-v) _pkgui_ver;exit 0;;-h) _pkgui_help;exit 0;;"");;*) _pkgui_die "Invalid option: $1";;
  esac
  [[ $# -eq 0 ]] && _pkgui_menu
}
_pkgui_menu(){
  local choice
  while :;do
    choice=$(cat <<'MENU'|"$FND" --prompt='Action:' --height=40 --header="$BD pkgui $D"||exit 0
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
      s) _pkgui_search;;S) _pkgui_search|_pkgui_inst;;l) _pkgui_local;;R) _pkgui_local|_pkgui_rm;;A) _pkgui_orphans|_pkgui_rm;;O) _pkgui_opt_deps|_pkgui_rm;;U) _pkgui_upd_check;;u) _pkgui_upd_full;;F) _pkgui_upd_flat;;b) _pkgui_browse_aur|_pkgui_inst;;H) _pkgui_history;;M) _pkgui_maint;;C) _pkgui_clean;;V) _pkgui_vulns;;W) _pkgui_news;;m) _pkgui_mirrors;;p) _pkgui_pacdiff;;f) _pkgui_fw;;k) _pkgui_svc;;N) _pkgui_status;;P) _pkgui_gen_lists;;B) _pkgui_backup;;T) _pkgui_restore;;L) _pkgui_sync_list;;X) _pkgui_export;;I) _pkgui_import;;i) _pkgui_info_sys;;c) _pkgui_edit_cfg;;e) _pkgui_edit_sys;;n) _pkgui_notify;;h) _pkgui_help;;v) _pkgui_ver;;*) break;;
    esac
  done
}
main "$@"

#!/usr/bin/env zsh
# shellcheck shell=bash
# ============================================================================
# Zsh Functions - Utilities & Workflows
# ============================================================================

# ---[ General Utilities ]---
mkcd(){ mkdir -p "$1" && cd "$1"; }
cdls(){ cd -- "$1" && ls -A; }

up(){
  local d="" i
  for ((i=1; i<=${1:-1}; i++)); d+=/..
  cd "${d#/}"
}

cpg(){ [[ -d $2 ]] && cp "$1" "$2" && cd "$2" || cp "$1" "$2"; }
mvg(){ [[ -d $2 ]] && mv -- "$1" "$2" && cd -- "$2" || mv -- "$1" "$2"; }

fs(){
  if has dust; then
    dust -r "${1:-.}"
  elif [[ $# -gt 0 ]]; then
    du -sbh -- "$@"
  else
    du -sbh -- .[!.]* ./* 2>/dev/null | sort -hr
  fi
}

catt(){
  for i in "$@"; do
    [[ -d $i ]] && ls "$i" || bat -p "$i" 2>/dev/null || cat "$i"
  done
}

# ---[ Archive Management ]---
extract(){
  [[ $# -eq 0 || ! -f $1 ]] && { echo "Usage: extract <file>"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.tar.zst) tar --zstd -xf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.zip) unzip "$1" ;;
    *.7z) 7z x "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.gz) gunzip "$1" ;;
    *.rar) unrar e "$1" ;;
    *.xz) unxz "$1" ;;
    *.Z) uncompress "$1" ;;
    *) echo "Unsupported format: $1"; return 1 ;;
  esac
}

cr(){
  [[ $# -eq 0 ]] && { echo "Usage: cr <file1> ..."; return 1; }
  echo "Format: 1)tar.gz 2)tar.xz 3)tar.zst 4)zip 5)7z"
  read -r "choice?[1-5]: " "out?Name: "
  case "$choice" in
    1) tar czf "$out.tar.gz" "$@" ;;
    2) tar cJf "$out.tar.xz" "$@" ;;
    3) tar --zstd -cf "$out.tar.zst" "$@" ;;
    4) zip -r "$out.zip" "$@" ;;
    5) 7z a "$out.7z" "$@" ;;
    *) echo "Invalid choice"; return 1 ;;
  esac
}

# ---[ File Operations ]---
ftext(){
  if has rg; then
    rg -i --hidden --color=always "$@" | bat --paging=always
  else
    grep -iIHrn --color=always "$1" . | bat --paging=always
  fi
}

fiximg(){
  local GM_CMD GM_IDENTIFY
  if has gm; then
    GM_CMD="gm convert"
    GM_IDENTIFY="gm identify"
  elif has magick; then
    GM_CMD="magick convert"
    GM_IDENTIFY="magick identify"
  else
    GM_CMD=convert
    GM_IDENTIFY=identify
  fi
  
  strip_file(){
    local f="$1" tmp
    if [[ -n $("$GM_IDENTIFY" -format "%[EXIF:*]" "$f" 2>/dev/null) ]] \
      || [[ -n $("$GM_IDENTIFY" -format "%[IPTC:*]" "$f" 2>/dev/null) ]] \
      || [[ -n $("$GM_IDENTIFY" -format "%[Comment]" "$f" 2>/dev/null) ]]; then
      tmp="${f}.strip.$$"
      "$GM_CMD" "$f" -strip "$tmp" && mv "$tmp" "$f"
    fi
  }
  
  if has fd; then
    fd -t f -e png -e jpg -e jpeg -e webp -e avif -e jxl -x zsh -c 'strip_file "$1"' _ {}
  else
    find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \
      -o -iname "*.webp" -o -iname "*.avif" -o -iname "*.jxl" \) \
      -exec zsh -c 'strip_file "$1"' _ {} \;
  fi
}

prune_empty(){
  read -q "?Prune empty dirs? [y/N]: " || return
  echo
  if has fd; then
    fd -t d --prune | while read -r dir; do rmdir "$dir" 2>/dev/null; done
  else
    find . -type d -empty -delete
  fi
}

# ---[ Process Management ]---
pk(){
  [[ $# -ne 1 ]] && { echo "Usage: pk <name>"; return 1; }
  local -a pids=($(pgrep -f "$1"))
  [[ ${#pids[@]} -eq 0 ]] && { echo "No processes found"; return 1; }
  pgrep -af "$1"
  read -q "?Kill? [y/N]: " && echo && kill -9 "${pids[@]}" && echo "Killed" || echo "Cancelled"
}

fkill(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  local pid=$(ps -ef | tail -n +2 | $fuzzy -m | awk '{print $2}')
  [[ -n $pid ]] && kill -"${1:-9}" $pid
}

bgd(){ (nohup "$@" &>/dev/null </dev/null & disown); }
bgd_full(){ (nohup setsid "$@" &>/dev/null </dev/null & disown); }

# ---[ Man Pages & Help ]---
fman(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  [[ $# -gt 0 ]] && { man "$@"; return; }
  man -k . | $fuzzy --reverse \
    --preview="echo {1,2} | sed 's/ (/./' | sed -E 's/\)\s*$//' | xargs man" \
    | awk '{print $1"."$2}' | tr -d '()' | xargs -r man
}

bathelp(){ "$@" --help 2>&1 | bat -plhelp; }

explain(){
  if [[ $# -eq 0 ]]; then
    while read -r "cmd?Command: "; do
      curl -sfG "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$cmd"
    done
    echo "Bye!"
  else
    curl -sfG "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$*"
  fi
}

# ---[ Fuzzy Navigation ]---
fz(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  local mode=dir path="${1:-.}"
  [[ $1 == -f ]] && { mode=file; shift; path="${1:-.}"; }
  [[ $1 == -p ]] && { mode=parent; shift; path="${1:-.}"; }
  case "$mode" in
    file)
      local file=$(fd -t f . "$path" 2>/dev/null | $fuzzy -m --preview 'bat --color=always {}')
      [[ -n $file ]] && ${EDITOR:-nano} $file ;;
    parent)
      get_parent_dirs(){
        [[ -d $1 ]] && echo "$1" || return
        [[ $1 == / ]] || get_parent_dirs "$(dirname "$1")"
      }
      local dir=$(get_parent_dirs "$(realpath "$path")" | $fuzzy --tac)
      [[ -n $dir ]] && cd "$dir" && ls ;;
    dir)
      local dir=$(fd -t d . "$path" 2>/dev/null | $fuzzy +m --preview 'ls -lah {}')
      [[ -n $dir ]] && cd "$dir" ;;
  esac
}

alias fe='fz -f'
alias fcd=fz

# ---[ Git Functions ]---
ghpatch(){
  local url="${1:?usage: ghpatch <url>}"
  local git_cmd=$(has gix && echo gix || echo git)
  local patch=$(mktemp) || return 1
  trap 'rm -f "$patch"' EXIT
  curl -sSfL "${url}.patch" -o "$patch" || return 1
  if $git_cmd apply "$patch"; then
    $git_cmd add -A && $git_cmd commit -m "Apply patch from $url"
  else
    echo "Patch failed"
    return 1
  fi
}

ghf(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  local git_cmd=$(has gix && echo gix || echo git)
  $git_cmd rev-parse --is-inside-work-tree &>/dev/null || return
  $git_cmd log --date=relative --format="%C(auto)%h%d %C(white)%s %C(cyan)%an %C(black)%C(bold)%cd%C(auto)" \
    --graph --color=always \
    | $fuzzy --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
      --header 'CTRL-S: toggle sort' \
      --preview="grep -o '[a-f0-9]\{7,\}' <<< {} | xargs $git_cmd show --color=always | delta" \
      --bind "enter:execute(grep -o '[a-f0-9]\{7,\}' <<< {} | xargs $git_cmd show --color=always | delta | less -R)"
}

fzf-git-status(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  local git_cmd=$(has gix && echo gix || echo git)
  $git_cmd rev-parse --git-dir &>/dev/null || { echo "Not in git repo"; return; }
  local selected
  if has sd; then
    selected=$($git_cmd -c color.status=always status --short \
      | $fuzzy --height 50% "$@" --border -m --ansi --nth 2..,.. \
        --preview "($git_cmd diff --color=always -- {-1} | tail -n +5; cat {-1}) | head -500" \
      | cut -c4- | sd '.* -> ' '')
  else
    selected=$($git_cmd -c color.status=always status --short \
      | $fuzzy --height 50% "$@" --border -m --ansi --nth 2..,.. \
        --preview "($git_cmd diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500" \
      | cut -c4- | sed 's/.* -> //')
  fi
  [[ -n $selected ]] && while IFS= read -r file; do $EDITOR "$file"; done <<<"$selected"
}

gdbr(){
  local git_cmd=$(has gix && echo gix || echo git)
  $git_cmd fetch --prune
  $git_cmd branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r $git_cmd branch -D
}

gbr(){
  local git_cmd=$(has gix && echo gix || echo git)
  $git_cmd branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate
}

git_maintain_max(){
  has gh && { gh tidy; gh poi; }
  git gc --prune=now --aggressive --cruft
  git repack -adfbm --threads=0 --depth=250 --window=250
  git maintenance run
  git add -A
}

update_git_pull(){
  local git_cmd=$(has gix && echo gix || echo git)
  has $git_cmd || return
  $git_cmd pull --rebase --autostash && $git_cmd submodule update --init --recursive
}

# ---[ Arch Package Management ]---
pacsize(){
  if has pacinfo; then
    pacman -Qqt | pacinfo --removable-size \
      | awk '/^Name:/{name=$2}/^Installed Size:/{size=$3$4}/^$/{print size" "name}' \
      | sort -uk2 | sort -rh | bat --paging=always
  else
    pacman -Qi | awk '/^Name/{name=$3}/^Installed Size/{print name,$4 substr($5,1,1)}' \
      | column -t | sort -rhk2 | cat -n | tac | bat --paging=always
  fi
}

fuzzy_paru(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  has $fuzzy || { echo "Fuzzy finder required"; return 1; }
  local fzf_input=$(awk '
    FNR==NR{i[$0]=1;next}
    {if($0 in i)printf "%s\t\033[32m[installed]\033[0m\n",$0;else print $0}
  ' <(paru -Qq) <(paru -Ssq '^'))
  local -a selections=(${(f)"$(<<<"$fzf_input" $fuzzy --ansi -m --cycle --layout=reverse-list \
    --preview 'paru -Si {1} 2>/dev/null | bat -plini --color=always' \
    --expect=ctrl-u --header 'ENTER: install, CTRL-U: uninstall')"})
  local key="${selections[1]}"
  shift selections
  [[ ${#selections[@]} -eq 0 ]] && { echo "No selection"; return; }
  local -a packages=("${selections[@]%% *}")
  if [[ $key == ctrl-u ]]; then
    printf '\e[31mUninstalling:\e[0m %s\n' "${packages[*]}"
    sudo pacman -Rns --noconfirm "${packages[@]}"
  else
    printf '\e[32mInstalling:\e[0m %s\n' "${packages[*]}"
    paru -S --needed --noconfirm "${packages[@]}"
  fi
}

search(){
  local jq_cmd=$(has jaq && echo jaq || echo jq)
  curl -s "https://aur.archlinux.org/rpc/?v=5&type=search&arg=$1" \
    | $jq_cmd '.results[] | {Name,Description,Version,URL,NumVotes,Popularity,Maintainer}' \
    || echo "Query failed"
}

# ---[ Docker Functions ]---
da(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  local cid=$(docker ps -a | tail -n +2 | $fuzzy -1 -q "$1" | awk '{print $1}')
  [[ -n $cid ]] && docker start "$cid" && docker attach "$cid"
}

ds(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  local cid=$(docker ps | tail -n +2 | $fuzzy -q "$1" | awk '{print $1}')
  [[ -n $cid ]] && docker stop "$cid"
}

drm(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  local cid=$(docker ps -a | tail -n +2 | $fuzzy -q "$1" | awk '{print $1}')
  [[ -n $cid ]] && docker rm "$cid"
}

drmm(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  docker ps -a | tail -n +2 | $fuzzy -q "$1" --no-sort -m --tac \
    | awk '{print $1}' | xargs -r docker rm
}

drmi(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  docker images | tail -n +2 | $fuzzy -q "$1" --no-sort -m --tac \
    | awk '{print $3}' | xargs -r docker rmi
}

# ---[ SSH & System Setup ]---
Setup-ssh(){
  local email="${email:-ven0m0.wastaken@gmail.com}"
  local key_path="$HOME/.ssh/id_ed25519"
  [[ -f $key_path ]] || ssh-keygen -t ed25519 -C "$email" -f "$key_path"
  eval "$(ssh-agent -s)" && ssh-add "$key_path"
  has gh && gh ssh-key add "${key_path}.pub" --type signing
  
  local -a hosts=(
    dietpi@192.168.178.81 root@192.168.178.81
    dietpi@192.168.178.86 root@192.168.178.86
  )
  for host in "${hosts[@]}"; do
    ssh-copy-id -i "${key_path}.pub" "$host"
  done
}

# ---[ Miscellaneous ]---
vid2gif(){
  [[ -z $1 ]] && { echo "Usage: vid2gif <video>"; return 1; }
  if has ffzap; then
    ffzap -i "$1" -r 15 -vf scale=512:-1 "$1.gif"
  else
    ffmpeg -i "$1" -r 15 -vf scale=512:-1 "$1.gif"
  fi
}

list_opened_apps(){
  ps axc | awk 'NR > 1 {print substr($0,index($0,$5))}' | sort -u
}

shlint(){
  shellcheck -a -x -s bash --source-path=SCRIPTDIR -f diff "$1" | patch -p1
  shellharden --replace "$1"
  shfmt -w -ln bash -bn -i 2 -s "$1"
}

zimupdate(){
  zimfw update && zimfw upgrade
}

# vim: set ft=zsh ts=2 sw=2 et:

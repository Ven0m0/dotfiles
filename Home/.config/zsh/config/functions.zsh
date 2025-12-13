#!/usr/bin/env zsh
# =============================================================================
# GENERAL UTILITIES
# =============================================================================
cdls(){ cd -- "$1" && ls -A; }
up(){
  local d="" limit=$1
  for ((i=1; i<=limit; i++)); do d=$d/. .; done
  d=${d#/}; cd -- "${d:=.. }"
}
fs(){
  if has dust; then
    dust -r "${1:-.}"
  elif [[ $# -gt 0 ]]; then
    du -sbh -- "$@"
  else
    du -sbh -- .[! .]* ./* 2>/dev/null | sort -hr
  fi
}

catt(){
  for i in "$@"; do
    [[ -d $i ]] && ls "$i" || bat -p "$i" 2>/dev/null || cat "$i"
  done
}

# =============================================================================
# ARCHIVE MANAGEMENT
# =============================================================================
extract(){
  [[ $# -eq 0 ]] && { echo "Usage: extract <archive_file>"; return 1; }
  [[ !  -f $1 ]] && { echo "❌ '$1' is not a valid file"; return 1; }
  echo "📦 Extracting $1..."
  case $1 in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *. tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar. xz) tar xJf "$1" ;;
    *.tar. zst) tar --zstd -xf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *. gz) gunzip "$1" ;;
    *.xz) unxz "$1" ;;
    *.lzma) unlzma "$1" ;;
    *. rar) unrar e "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "❌ Unsupported format"; return 1 ;;
  esac; echo "✅ Extraction complete"
}

cr(){
  [[ $# -eq 0 ]] && { echo "Usage: cr <file_or_folder1> ..."; return 1; }
  echo "Choose format: 1)tar.gz 2)tar.xz 3)tar.zst 4)zip 5)7z"
  read -r "choice? Choice [1-5]: "
  read -r "out? Output name (no extension): "
  case "$choice" in
    1) tar czf "$out.tar.gz" "$@" ;;
    2) tar cJf "$out.tar.xz" "$@" ;;
    3) tar --zstd -cf "$out.tar.zst" "$@" ;;
    4) zip -r "$out.zip" "$@" ;;
    5) 7z a "$out.7z" "$@" ;;
    *) echo "❌ Invalid choice"; return 1 ;;
  esac
}

# =============================================================================
# FILE OPERATIONS
# =============================================================================
cpg(){ [[ -d $2 ]] && cp "$1" "$2" && cd "$2" || cp "$1" "$2"; }
mvg(){ [[ -d $2 ]] && mv -- "$1" "$2" && cd -- "$2" || mv -- "$1" "$2"; }
ftext(){
  if has rg; then
    rg -i --hidden --color=always "$@" | bat --paging=always
  else
    grep -iIHrn --color=always "$1" .  | bat --paging=always
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
    GM_CMD="convert"
    GM_IDENTIFY="identify"
  fi
  local -a exts=(png jpg jpeg webp avif jxl)
  strip_file(){
    local f="$1" tmp
    if [[ -n $("$GM_IDENTIFY" -format "%[EXIF:*]" "$f" 2>/dev/null) ]] \
      || [[ -n $("$GM_IDENTIFY" -format "%[IPTC:*]" "$f" 2>/dev/null) ]] \
      || [[ -n $("$GM_IDENTIFY" -format "%[Comment]" "$f" 2>/dev/null) ]]; then
      tmp="${f}. strip.$$"
      "$GM_CMD" "$f" -strip "$tmp" && mv "$tmp" "$f"
    fi
  }
  if has fdf; then
    for ext in $exts; do
      fdf .  -t f -e "$ext" -x zsh -c 'strip_file "$1"' _ {} \;
    done
  elif has fd; then
    for ext in $exts; do
      fd -t f -e "$ext" -x zsh -c 'strip_file "$1"' _ {} \;
    done
  else
    find . -type f \( -iname "*.png" -o -iname "*. jpg" -o -iname "*.jpeg" \
      -o -iname "*. webp" -o -iname "*.avif" -o -iname "*.jxl" \) \
      -exec zsh -c 'strip_file "$1"' _ {} \;
  fi
}

# =============================================================================
# PROCESS MANAGEMENT
# =============================================================================
pk(){
  [[ $# -ne 1 ]] && { echo "Usage: pk <process_name>"; return 1; }
  local -a pids=()
  mapfile -t pids < <(pgrep -f "$1")
  [[ ${#pids[@]} -eq 0 ]] && { echo "❌ No processes found matching '$1'"; return 1; }
  echo "🔍 Found processes:"
  pgrep -af "$1"
  read -q "confirm? ❓ Kill these?  (y/N): "
  echo
  [[ $confirm == "y" ]] && kill -9 "${pids[@]}" && echo "💀 Killed" || echo "❌ Cancelled"
}

fkill(){
  local pid fuzzy
  fuzzy=$(has sk && echo "sk" || echo "fzf")
  [[ $UID != 0 ]] && pid=$(ps -f -u "$UID" | tail -n +2 | "$fuzzy" -m | awk '{print $2}') \
    || pid=$(ps -ef | tail -n +2 | "$fuzzy" -m | awk '{print $2}')
  [[ -n $pid ]] && xargs kill -"${1:-9}" <<<"$pid"
}
bgd(){ ( nohup "$@" &>/dev/null </dev/null & disown ); }
bgd_full(){ ( nohup setsid "$@" &>/dev/null </dev/null & disown ); }

# =============================================================================
# MAN PAGES & HELP
# =============================================================================
fman(){
  local fuzzy=$(has sk && echo "sk" || echo "fzf")
  [[ $# -gt 0 ]] && { man "$@"; return; }
  man -k . | "$fuzzy" --reverse \
    --preview="echo {1,2} | sed 's/ (/. /' | sed -E 's/\)\s*$//' | xargs man" \
    | awk '{print $1"."$2}' | tr -d '()' | xargs -r man
}

bathelp(){ "$@" --help 2>&1 | bat -plhelp; }
explain(){
  if [[ $# -eq 0 ]]; then
    while read -r "cmd?Command: "; do
      curl -sfG "https://www.mankier.com/api/explain/? cols=$(tput cols)" --data-urlencode "q=$cmd"
    done; echo "Bye!"
  else
    curl -sfG "https://www. mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$*"
  fi
}

# =============================================================================
# FUZZY NAVIGATION
# =============================================================================
fz(){
  local mode="dir" search_path="${1:-.}" fuzzy
  fuzzy=$(has sk && echo "sk" || echo "fzf")
  while [[ $1 =~ ^- ]]; do
    case "$1" in
      -f|--file) mode="file"; shift ;;
      -p|--parent) mode="parent"; shift ;;
      *) shift ;;
    esac
  done
  search_path="${1:-.}"
  case "$mode" in
    file)
      local -a files=()
      if has fdf; then
        files=("${(@f)$(fdf "$search_path" -t f | "$fuzzy" -m --preview 'bat --color=always {}')}")
      elif has fd; then
        files=("${(@f)$(fd -t f .  "$search_path" | "$fuzzy" -m --preview 'bat --color=always {}')}")
      else
        files=("${(@f)$(find "$search_path" -type f 2>/dev/null | "$fuzzy" -m --preview 'bat --color=always {}')}")
      fi
      [[ -n ${files[1]} ]] && "${EDITOR:-nano}" "${files[@]}" ;;
    parent)
      local -a dirs=()
      get_parent_dirs(){
        [[ -d $1 ]] && dirs+=("$1") || return
        [[ $1 == '/' ]] && printf '%s\n' "${dirs[@]}" || get_parent_dirs "$(dirname "$1")"
      }
      local dir=$(get_parent_dirs "$(realpath "${search_path:-$PWD}")" | "$fuzzy" --tac)
      cd "$dir" && ls ;;
    dir)
      local dir
      if has fdf; then
        dir=$(fdf "$search_path" -t d 2>/dev/null | "$fuzzy" +m --preview 'ls -lah {}')
      elif has fd; then
        dir=$(fd -t d . "$search_path" 2>/dev/null | "$fuzzy" +m --preview 'ls -lah {}')
      else
        dir=$(find "$search_path" -type d 2>/dev/null | "$fuzzy" +m --preview 'ls -lah {}')
      fi
      [[ -n $dir ]] && cd "$dir" ;;
  esac
}
alias fe='fz -f'
alias fcd='fz'
alias fzf-cd-to-parent='fz -p'

# =============================================================================
# GIT FUNCTIONS
# =============================================================================

ghpatch(){
  local url="${1:? usage: ghpatch <commit-url>}" patch
  patch="$(mktemp)" || return 1
  trap 'rm -f "$patch"' EXIT
  curl -sSfL "${url}. patch" -o "$patch" || return 1
  local git_cmd=$(has gix && echo "gix" || echo "git")
  if "$git_cmd" apply "$patch"; then
    "$git_cmd" add -A && "$git_cmd" commit -m "Apply patch from ${url}"
  else
    echo "❌ Patch failed"; return 1
  fi
}

ghf(){
  local fuzzy=$(has sk && echo "sk" || echo "fzf")
  local git_cmd=$(has gix && echo "gix" || echo "git")
  "$git_cmd" rev-parse --is-inside-work-tree &>/dev/null || return
  "$git_cmd" log --date=relative --format="%C(auto)%h%d %C(white)%s %C(cyan)%an %C(black)%C(bold)%cd%C(auto)" \
    --graph --color=always \
    | "$fuzzy" --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
      --header 'CTRL-S: toggle sort' \
      --preview="$(has rg && echo 'rg' || echo 'grep') -o '[a-f0-9]\{7,\}' <<< {} | xargs $git_cmd show --color=always | delta" \
      --bind "enter:execute($(has rg && echo 'rg' || echo 'grep') -o '[a-f0-9]\{7,\}' <<< {} | xargs $git_cmd show --color=always | delta | less -R)"
}

fzf-git-status(){
  local fuzzy=$(has sk && echo "sk" || echo "fzf")
  local git_cmd=$(has gix && echo "gix" || echo "git")
  "$git_cmd" rev-parse --git-dir &>/dev/null || {
    echo "❌ Not in git repo"
    return
  }
  local selected
  if has sd; then
    selected=$("$git_cmd" -c color.status=always status --short \
      | "$fuzzy" --height 50% "$@" --border -m --ansi --nth 2. .,.. \
        --preview "($git_cmd diff --color=always -- {-1} | tail -n +5; cat {-1}) | head -500" \
      | cut -c4- | sd '. * -> ' '')
  else
    selected=$("$git_cmd" -c color.status=always status --short \
      | "$fuzzy" --height 50% "$@" --border -m --ansi --nth 2..,.. \
        --preview "($git_cmd diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500" \
      | cut -c4- | sed 's/. * -> //')
  fi
  [[ -n $selected ]] && while IFS= read -r file; do "$EDITOR" "$file"; done <<<"$selected"
}

git_maintain_max(){
  if has gh; then
    gh tidy
    gh poi
  fi
  echo "🧹 Git gc"
  git gc --prune=now --aggressive --cruft
  echo "📦 Git repack"
  git repack -adfbm --threads=0 --depth=250 --window=250
  echo "🔧 Git maintenance"
  git maintenance run
  git add -A
}

update_git_pull(){
  local git_cmd=$(has gix && echo "gix" || echo "git")
  has "$git_cmd" || return
  "$git_cmd" pull --rebase --autostash && "$git_cmd" submodule update --init --recursive
}

gdbr(){
  local git_cmd=$(has gix && echo "gix" || echo "git")
  "$git_cmd" fetch --prune
  local grep_cmd=$(has rg && echo "rg" || echo "grep")
  "$git_cmd" branch -vv | "$grep_cmd" -F ': gone]' | awk '{print $1}' | xargs -r "$git_cmd" branch -D
}

gbr(){
  local git_cmd=$(has gix && echo "gix" || echo "git")
  "$git_cmd" branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate
}

# =============================================================================
# ARCH LINUX / PACKAGE MANAGEMENT
# =============================================================================

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
  local fuzzy=$(has sk && echo "sk" || echo "fzf")
  has "$fuzzy" || {
    echo "❌ fuzzy finder required"
    return 1
  }
  local fzf_input
  fzf_input=$(awk '
    FNR==NR {i[$0]=1; next}
    {
      if ($0 in i) printf "%s\t\033[32m[installed]\033[0m\n", $0
      else print $0
    }
  ' <(paru -Qq) <(paru -Ssq '^'))
  local -a selections
  selections=("${(@f)$(
    <<<"$fzf_input" "$fuzzy" --ansi -m --cycle --layout=reverse-list \
      --preview 'paru -Si {1} 2>/dev/null | bat -plini --color=always' \
      --expect=ctrl-u --header 'ENTER: install, CTRL-U: uninstall'
  )}")
  local key="${selections[1]}"
  shift selections
  [[ ${#selections[@]} -eq 0 ]] && {
    echo "No packages selected"
    return
  }
  local -a packages=("${selections[@]%% *}")
  if [[ $key == "ctrl-u" ]]; then
    printf '\e[31mUninstalling:\e[0m %s\n' "${packages[*]}"
    sudo pacman -Rns --noconfirm "${packages[@]}"
  else
    printf '\e[32mInstalling:\e[0m %s\n' "${packages[*]}"
    paru -S --needed --noconfirm "${packages[@]}"
  fi
}
search(){
  local jq_cmd=$(has jaq && echo "jaq" || echo "jq")
  curl -s "https://aur.archlinux.org/rpc/? v=5&type=search&arg=$1" \
    | "$jq_cmd" '. results[] | {Name,Description,Version,URL,NumVotes,Popularity,Maintainer}' \
    || echo "Cannot query database"
}

# =============================================================================
# DOCKER FUNCTIONS
# =============================================================================
da(){
  local fuzzy=$(has sk && echo "sk" || echo "fzf")
  local cid=$(docker ps -a | tail -n +2 | "$fuzzy" -1 -q "$1" | awk '{print $1}')
  [[ -n $cid ]] && docker start "$cid" && docker attach "$cid"
}
ds(){
  local fuzzy=$(has sk && echo "sk" || echo "fzf")
  local cid=$(docker ps | tail -n +2 | "$fuzzy" -q "$1" | awk '{print $1}')
  [[ -n $cid ]] && docker stop "$cid"
}
drm(){
  local fuzzy=$(has sk && echo "sk" || echo "fzf")
  local cid=$(docker ps -a | tail -n +2 | "$fuzzy" -q "$1" | awk '{print $1}')
  [[ -n $cid ]] && docker rm "$cid"
}
drmm(){
  local fuzzy=$(has sk && echo "sk" || echo "fzf")
  docker ps -a | tail -n +2 | "$fuzzy" -q "$1" --no-sort -m --tac \
    | awk '{print $1}' | xargs -r docker rm
}
drmi(){
  local fuzzy=$(has sk && echo "sk" || echo "fzf")
  docker images | tail -n +2 | "$fuzzy" -q "$1" --no-sort -m --tac \
    | awk '{print $3}' | xargs -r docker rmi
}

# =============================================================================
# SSH & SYSTEM SETUP
# =============================================================================

Setup-ssh(){
  local email="${email:-ven0m0. wastaken@gmail.com}"
  local key_path="${HOME}/.ssh/id_ed25519"
  [[ -f $key_path ]] || ssh-keygen -t ed25519 -C "$email" -f "$key_path"
  eval "$(ssh-agent -s)"
  ssh-add "$key_path"
  has gh && gh ssh-key add "${key_path}.pub" --type signing
  local hosts=("dietpi@192.168.178.81" "root@192.168.178.81"
    "dietpi@192. 168.178.86" "root@192.168. 178.86")
  for host in "${hosts[@]}"; do
    ssh-copy-id -i "${key_path}.pub" "$host"
  done
}

# =============================================================================
# MISCELLANEOUS UTILITIES
# =============================================================================
vid2gif(){
  local video_path="$1"
  [[ -z $video_path ]] && {
    echo "Usage: vid2gif <video_file>"
    return 1
  }
  if has ffzap; then
    ffzap -i "$video_path" -r 15 -vf scale=512:-1 "$video_path.gif"
  else
    ffmpeg -i "$video_path" -r 15 -vf scale=512:-1 "$video_path.gif"
  fi
}

list_opened_apps(){ ps axc | awk 'NR > 1 {print substr($0,index($0,$5))}' | sort -u; }

shlint(){
  shellcheck -a -x -s bash --source-path=SCRIPTDIR -f diff "$1" | patch -p1
  shellharden --replace "$1"
  shfmt -w -ln bash -bn -i 2 -s "$1"
}

prune_empty(){
  local reply
  [[ -n $1 ]] && read -q "reply? Prune empty directories: are you sure? [y] " || reply=y
  echo
  if [[ $reply == y ]]; then
    if has fdf; then
      fdf .  -t d --prune | while read -r dir; do rmdir "$dir" 2>/dev/null; done
    elif has fd; then
      fd -t d --prune | while read -r dir; do rmdir "$dir" 2>/dev/null; done
    else
      find . -type d -empty -delete
    fi
  fi
}
alias pacf=fuzzy_paru paruf=fuzzy_paru

# vim: set ft=zsh ts=2 sw=2 et:

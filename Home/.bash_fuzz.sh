#!/usr/bin/env bash

# 📖 Man pages
fzf-man(){
  [[ $# -gt 0 ]] && {man "$@";return;}
  man -k .|fzf --reverse --preview="echo {1,2}|sed 's/ (/./'|sed -E 's/\)\s*$//'|xargs man"|awk '{print $1"."$2}'|tr -d '()'|xargs -r man
}

manol(){
  [[ $# -eq 0 ]] && {echo "Usage: manol [section] <page>">&2;return 1;}
  local url="https://man.archlinux.org/man/${2:+$2.$1}"
  url="${url:-https://man.archlinux.org/man/$1}"
  curl -sfLZ --http3 --tlsv1.3 --compressed "$url"|bat -plman
}

explain(){
  if [[ $# -eq 0 ]];then
    while read -r -p "Command: " cmd;do
      curl -sfG "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$cmd"
    done
    echo "Bye!"
  elif [[ $# -eq 1 ]];then
    curl -sfG "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$1"
  else
    echo "Usage: explain ['cmd -o | ...'] or explain (interactive)"
  fi
}

fman(){
  local -a less_env=(LESS_TERMCAP_md=$'\e[01;31m' LESS_TERMCAP_me=$'\e[0m' LESS_TERMCAP_us=$'\e[01;32m' LESS_TERMCAP_ue=$'\e[0m' LESS_TERMCAP_so=$'\e[45;93m' LESS_TERMCAP_se=$'\e[0m')
  local -a bat_env=(LANG='C.UTF-8' MANROFFOPT='-c' BAT_STYLE='full' BAT_PAGER="less -RFQs --use-color --no-histdups --mouse --wheel-lines=2")
  if command -v batman &>/dev/null;then
    env "${bat_env[@]}" "${less_env[@]}" batman "$@"
  elif command -v bat &>/dev/null;then
    env "${bat_env[@]}" "${less_env[@]}" MANPAGER="sh -c 'col -bx|bat -splman --squeeze-limit 0 --tabs 2'" man "$@"
  else
    env "${less_env[@]}" PAGER="less -RFQs --use-color --no-histdups --mouse --wheel-lines=2" man "$@"
  fi
}

bathelp(){
  "$@" --help 2>&1|bat -splhelp --squeeze-limit 0
}

# 📁 Files & Dirs
fe(){
  local IFS=$'\n' files=()
  while IFS='' read -r line;do files+=("$line");done < <(fzf -q "$1" -m --inline-info -1 -0 --layout=reverse-list)
  [[ -n ${files[0]} ]] && ${EDITOR:-nano} "${files[@]}"
}

fcd(){
  local dir
  dir=$(find "${1:-.}" -path '*/\.*' -prune -o -type d -print 2>/dev/null|fzf +m) && cd "$dir"
}

fzf-cd-incl-hidden(){
  local dir
  dir=$(find "${1:-.}" -type d 2>/dev/null|fzf +m) && cd "$dir"
  ls
}

fzf-cd-to-file(){
  local file dir
  file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
  ls
}

fzf-cd-to-parent(){
  local dirs=()
  get_parent_dirs(){
    [[ -d $1 ]] && dirs+=("$1") || return
    [[ $1 == '/' ]] && printf '%s\n' "${dirs[@]}" || get_parent_dirs "$(dirname "$1")"
  }
  local DIR=$(get_parent_dirs "$(realpath "${1:-$PWD}")"|fzf-tmux --tac)
  cd "$DIR" && ls
}

catt(){
  for i in "$@";do
    [[ -d $i ]] && ls "$i" || cat "$i"
  done
}

# 🔍 Utilities
faf(){
  eval "$({alias;declare -F|grep -v '^_';}|fzf|cut -d= -f1)"
}

fzf-env(){
  local out=$(env|fzf)
  echo "${out#*=}"
}

fzf-kill(){
  local pid=$(ps -ef|sed 1d|fzf -m|awk '{print $2}')
  [[ -n $pid ]] && xargs kill -${1:-9} <<< "$pid"
}

fkill(){
  local pid
  if [[ $UID != 0 ]];then
    pid=$(ps -f -u $UID|sed 1d|fzf -m|awk '{print $2}')
  else
    pid=$(ps -ef|sed 1d|fzf -m|awk '{print $2}')
  fi
  [[ -n $pid ]] && xargs kill -${1:-9} <<< "$pid"
}

# 📦 Package Management
fuzzy_paru(){
  local fzf_input selections packages_to_install
  fzf_input=$(awk 'FNR==NR{i[$0]=1;next}{if($0 in i)printf "%s\t\033[32m[installed]\033[0m\n",$0;else print $0}' <(paru -Qq) <(paru -Ssq '^'))
  mapfile -t selections < <(
    <<<"$fzf_input" fzf --ansi -m --cycle --layout=reverse-list \
      --preview 'paru -Si {1} 2>/dev/null|bat -p --language=ini --color=always'
  )
  if (( ${#selections[@]} > 0 ));then
    packages_to_install=("${selections[@]%% *}")
    printf '\e[32mInstalling:\e[0m %s\n' "${packages_to_install[*]}"
    paru -S --needed "${packages_to_install[@]}"
  else
    echo "❌ None selected"
  fi
}

pacsize(){
  local pager="${PAGER:-less}"
  if command -v pacinfo &>/dev/null;then
    pacman -Qqt|pacinfo --removable-size|awk '/^Name:/{name=$2}/^Installed Size:/{size=$3$4}/^$/{print size" "name}'|sort -uk2|sort -rh|"$pager"
  else
    pacman -Qi|awk '/^Name/{name=$3}/^Installed Size/{print name,$4 substr($5,1,1)}'|column -t|sort -rhk2|cat -n|tac
  fi
}

# 🐳 Docker
da(){
  local cid=$(docker ps -a|sed 1d|fzf -1 -q "$1"|awk '{print $1}')
  [[ -n $cid ]] && docker start "$cid" && docker attach "$cid"
}

ds(){
  local cid=$(docker ps|sed 1d|fzf -q "$1"|awk '{print $1}')
  [[ -n $cid ]] && docker stop "$cid"
}

drm(){
  local cid=$(docker ps -a|sed 1d|fzf -q "$1"|awk '{print $1}')
  [[ -n $cid ]] && docker rm "$cid"
}

drmm(){
  docker ps -a|sed 1d|fzf -q "$1" --no-sort -m --tac|awk '{print $1}'|xargs -r docker rm
}

drmi(){
  docker images|sed 1d|fzf -q "$1" --no-sort -m --tac|awk '{print $3}'|xargs -r docker rmi
}

# 🌿 Git
fzf-git-status(){
  git rev-parse --git-dir &>/dev/null || {echo "❌ Not in git repo";return;}
  local selected=$(git -c color.status=always status --short|fzf --height 50% "$@" --border -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1}|sed 1,4d;cat {-1})|head -500'|cut -c4-|sed 's/.* -> //')
  if [[ -n $selected ]];then
    while IFS= read -r prog;do "$EDITOR" "$prog";done <<< "$selected"
  fi
}

ghf(){
  git rev-parse --is-inside-work-tree &>/dev/null || return
  git log --date=relative --format="%C(auto)%h%d %C(white)%s %C(cyan)%an %C(black)%C(bold)%cd%C(auto)" --graph --color=always|
  fzf --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview='grep -o "[a-f0-9]\{7,\}" <<< {}|xargs git show --color=always|delta -n' \
    --bind 'enter:execute(grep -o "[a-f0-9]\{7,\}" <<< {}|xargs git show --color=always|delta -n|less -R)'
}

ghpatch(){
  local url="${1:?usage: ghpatch <commit-url>}" patch
  patch="$(mktemp)" || return 1
  trap 'rm -f "$patch"' EXIT
  curl -sSfL "${url}.patch" -o "$patch" || return 1
  if git apply "$patch";then
    git add -A && git commit -m "Apply patch from ${url}"
  else
    echo "❌ Patch failed"
    return 1
  fi
}

git_maintain_max(){
  echo "🧹 Git gc"
  git gc --prune=now --aggressive --cruft
  echo "📦 Git repack"
  git repack -adfbm --threads=0 --depth=250 --window=250
  echo "🔧 Git maintenance"
  git maintenance run --task=prefetch --task=gc --task=loose-objects --task=incremental-repack --task=pack-refs --task=reflog-expire --task=rerere-gc --task=worktree-prune
}

# 🔗 Aliases
alias pacf=fuzzy_paru
alias paruf=fuzzy_paru

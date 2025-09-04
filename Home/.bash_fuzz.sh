#!/usr/bin/env bash

fzf-man(){
	MAN="/usr/bin/man"
	if [ -n "$1" ]; then
		$MAN "$@"
		return $?
	else
		$MAN -k . | fzf --reverse --preview="echo {1,2} | sed 's/ (/./' | sed -E 's/\)\s*$//' | xargs $MAN" | awk '{print $1 "." $2}' | tr -d '()' | xargs -r $MAN
		return $?
	fi
}

fzf-aliases-functions(){
    CMD=$(
        (
            (alias)
            (functions | grep "()" | cut -d ' ' -f1 | grep -v "^_" )
        ) | fzf | cut -d '=' -f1
    );

    eval $CMD
}

fzf-find-files(){
  local file=$(fzf --multi --reverse) #get file from fzf
  if [[ $file ]]; then
    for prog in $(echo $file); #open all the selected files
    do; $EDITOR $prog; done;
  else
    echo "cancelled fzf"
  fi
}
fzf-cd(){
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
  ls
}
fzf-cd-incl-hidden(){
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
  ls
}
fzf-cd-to-file(){
   local file
   local dir
   file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
   ls
}
fzf-cd-to-parent(){
  local declare dirs=()
  get_parent_dirs(){
    if [[ -d "${1}" ]]; then 
      dirs+=("$1") 
    else 
      return
    fi
    if [[ "${1}" == '/' ]]; then
      for _dir in "${dirs[@]}"; do echo $_dir; done
    else
      get_parent_dirs $(dirname "$1")
    fi
  }
  local DIR=$(get_parent_dirs $(realpath "${1:-$PWD}") | fzf-tmux --tac)
  command cd "$DIR"
  command ls
}
fzf-env(){ local out=$(env | fzf); echo $(echo $out | cut -d= -f2); }
fzf-kill(){ local pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}'); [[ "x$pid" != "x" ]] && echo $pid | xargs kill -${1:-9}; }

# fkill - kill processes - list only the ones you can kill. Modified the earlier script.
fkill(){
  local pid
  if [[ "$UID" != "0" ]]; then
    pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
  else
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  fi
  if [[ "x$pid" != "x" ]]; then
    echo $pid | xargs kill -${1:-9}
  fi
}


fzf-git-status(){
  LC_ALL=C git rev-parse --git-dir &>/dev/null || { echo "You are not in a git repository" && return }
  local selected=$(LC_ALL=C git -c color.status=always status --short | fzf --height 50% "$@" --border -m --ansi --nth 2..,.. \
      --preview '(LC_ALL=C git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' | cut -c4- | sed 's/.* -> //')
  [[ -z $selected ]] && for prog in $(echo $selected); do; $EDITOR $prog; done
}


# Select a docker container to start and attach to
da(){ cid=$(docker ps -a | sed 1d | fzf -1 -q "$1" | awk '{print $1}'); [[ -n $cid ]] && docker start "$cid" && docker attach "$cid"; }

# Select a running docker container to stop
ds(){ local cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}'); [[ -n $cid ]] && docker stop "$cid"; }

# Select a docker container to remove
drm(){ local cid=$(docker ps -a | sed 1d | fzf -q "$1" | awk '{print $1}'); [[ -n $cid ]] && docker rm "$cid"; }
# Same as above, but allows multi selection:
drmm(){ docker ps -a | sed 1d | fzf -q "$1" --no-sort -m --tac | awk '{ print $1 }' | xargs -r docker rm; }

# Select a docker image or images to remove
drmi(){ docker images | sed 1d | fzf -q "$1" --no-sort -m --tac | awk '{ print $3 }' | xargs -r docker rmi; }


fuzzy_pacman(){ 
  local sel SHELL=bash; sel=$(comm -23 <(command pacman -Slq | sort) <(command pacman -Qq | sort) |
    cat - <(command pacman -Qq | awk '{printf "%-30s \033[32m[installed]\033[0m\n", $1}') |
    fzf --ansi --multi --style=full --cycle --border --info=inline -0 --layout=reverse-list \
      --preview '
        command pacman -Si $(awk "{print \$1}" <<< {}) 2>/dev/null | \
        command bat -p --language=ini --color=always | \
        sed -r "s/(Installed Size|Name|Version|Depends On|Optional Deps|Maintainer|Repository|Licenses|URL)/\x1b[96;1m\1\x1b[0m/g"
      ' --preview-window=right:60%:wrap | awk '{print $1}' | paste -sd " " -)
  [[ -n $sel ]] && { printf '%b\n' "\e[32mInstalling packages:\e[0m $sel"; \
    sudo pacman -S ${sel// / } --noconfirm --needed; } || printf '%s\n' "No packages selected."
}
alias pacf='fuzzy_pacman'

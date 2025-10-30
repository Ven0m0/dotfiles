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

# View aliases
faf(){ eval "$({ alias; declare -F | grep -v '^_'; } | fzf | cut -d= -f1)"; }

fzf-find-files(){
  local file=$(fzf --multi --reverse) #get file from fzf
  if [[ $file ]]; then
    # Use read to properly handle files with spaces
    while IFS= read -r prog; do
      "$EDITOR" "$prog"
    done <<< "$file"
  else
    echo "cancelled fzf"
  fi
}
fzf-cd(){
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir" || return
  ls
}
fzf-cd-incl-hidden(){
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir" || return
  ls
}
fzf-cd-to-file(){
   local file
   local dir
   file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir" || return
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
      printf '%s\n' "${dirs[@]}"
    else
      get_parent_dirs "$(dirname "$1")"
    fi
  }
  local DIR=$(get_parent_dirs "$(realpath "${1:-$PWD}")" | fzf-tmux --tac)
  command cd "$DIR" || return
  command ls
}
fzf-env(){ local out=$(env | fzf); echo "${out#*=}"; }
fzf-kill(){ local pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}'); [[ -n $pid ]] && xargs kill -${1:-9} <<< "$pid"; }

# fkill - kill processes - list only the ones you can kill. Modified the earlier script.
fkill(){
  local pid
  if [[ "$UID" != "0" ]]; then
    pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
  else
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  fi
  if [[ -n $pid ]]; then
    xargs kill -${1:-9} <<< "$pid"
  fi
}


fzf-git-status(){
  LC_ALL=C git rev-parse --git-dir &>/dev/null || { echo "You are not in a git repository"; return; }
  local selected=$(LC_ALL=C git -c color.status=always status --short | fzf --height 50% "$@" --border -m --ansi --nth 2..,.. \
      --preview '(LC_ALL=C git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' | cut -c4- | sed 's/.* -> //')
  if [[ -n $selected ]]; then
    while IFS= read -r prog; do
      "$EDITOR" "$prog"
    done <<< "$selected"
  fi
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
    fzf --ansi -m --style=full --cycle --border --height=~100% --inline-info -0 --layout=reverse-list \
      --preview '
        command pacman -Si $(awk "{print \$1}" <<< {}) 2>/dev/null | \
        command bat -p --language=ini --color=always | \
        sed -r "s/(Installed Size|Name|Version|Depends On|Optional Deps|Maintainer|Repository|Licenses|URL)/\x1b[96;1m\1\x1b[0m/g"
      ' --preview-window=right:60%:wrap | awk '{print $1}' | paste -sd " " -)
  [[ -n $sel ]] && { printf '%b\n' "\e[32mInstalling packages:\e[0m $sel"; \
    sudo pacman -S ${sel// / } --noconfirm --needed; } || printf '%s\n' "No packages selected."
}
alias pacf='fuzzy_pacman'

fusky_pacman(){ 
  local sel SHELL=bash; sel=$(comm -23 <(command pacman -Slq | sort) <(command pacman -Qq | sort) |
    cat - <(command pacman -Qq | awk '{printf "%-30s \033[32m[installed]\033[0m\n", $1}') |
    sk --ansi -m --cycle --border --inline-info --height=~100% -0 --layout=reverse-list \
      --preview '
        command pacman -Si $(awk "{print \$1}" <<< {}) 2>/dev/null | \
        command bat -p --language=ini --color=always | \
        sed -r "s/(Installed Size|Name|Version|Depends On|Optional Deps|Maintainer|Repository|Licenses|URL)/\x1b[96;1m\1\x1b[0m/g"
      ' --preview-window=right:60%:wrap | awk '{print $1}' | paste -sd " " -)
  [[ -n $sel ]] && { printf '%b\n' "\e[32mInstalling packages:\e[0m $sel"; \
    sudo pacman -S ${sel// / } --noconfirm --needed; } || printf '%s\n' "No packages selected."
}
alias pacsk='fusky_pacman'

# Display online manpages using curl
manol(){
  [[ $# -eq 0 ]] && echo -e "Usage: manol [section] <page>\nExample: manol 3 printf" >&2; return 1
  local page section url base_url="https://man.archlinux.org/man"
  if [[ $# -eq 1 ]]; then
    page="$1"; url="${base_url}/${page}"
  else
    section="$1" page="$2"; url="${base_url}/${page}.${section}"
  fi
  curl -sfLZ --http3 --tlsv1.3 --compressed --tls-earlydata --tcp-fastopen --tcp-nodelay "$url" | bat -plman
}

# Explain any bash command via mankier.com manpage API
explain() {
  if [ "$#" -eq 0 ]; then
    while read -r -p "Command: " cmd; do
      curl -sfG "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$cmd"
    done
    echo "Bye!"
  elif [ "$#" -eq 1 ]; then
    curl -sfG "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$1"
  else
    echo "Usage"
    echo "explain                  interactive mode."
    echo "explain 'cmd -o | ...'   one quoted command to explain it."
  fi
}

# Fancy man pages with bat
fman() {
  local -a less_env=(LESS_TERMCAP_md=$'\e[01;31m' LESS_TERMCAP_me=$'\e[0m' LESS_TERMCAP_us=$'\e[01;32m' LESS_TERMCAP_ue=$'\e[0m' LESS_TERMCAP_so=$'\e[45;93m' LESS_TERMCAP_se=$'\e[0m')
  local -a bat_env=(LANG='C.UTF-8' MANROFFOPT='-c' BAT_STYLE='full' BAT_PAGER="less -RFQs --use-color --no-histdups --mouse --wheel-lines=2")
  if command -v batman &>/dev/null; then
    env "${bat_env[@]}" "${less_env[@]}" command batman "$@"
  elif command -v bat &>/dev/null; then
    env "${bat_env[@]}" "${less_env[@]}" MANPAGER="sh -c 'col -bx | bat -splman --squeeze-limit 0 --tabs 2'" command man "$@"
  else
    env "${less_env[@]}" PAGER="less -RFQs --use-color --no-histdups --mouse --wheel-lines=2" command man "$@"
  fi
}


# Get help for a command with bat
bathelp() {
  "$@" --help 2>&1 | command bat -splhelp --squeeze-limit 0
}


# Open the selected file in the default editor
fe() {
  local IFS=$'\n' line; local files=()
  while IFS='' read -r line; do files+=("$line"); done < <(fzf -q "$1" -m --inline-info -1 -0 --layout=reverse-list)
  [[ -n "${files[0]}" ]] && ${EDITOR:-nano} "${files[@]}"
}

# cd to the selected directory
fcd() {
  local dir
  dir=$(find "${1:-.}" -path '*/\.*' -prune \
      -o -type d -print 2> /dev/null | fzf +m) \
      && cd "$dir" || return 1
}

# Display installed package sizes
pacsize() {
  local pager="${PAGER:-less}"
  if command -v pacinfo &>/dev/null; then
    pacman -Qqt | pacinfo --removable-size | awk '/^Name:/ { name = $2 } /^Installed Size:/ { size = $3$4 } /^$/ { print size" "name } ' | sort -uk2 | sort -rh | "$pager"
  else
    pacman -Qi | awk '/^Name/ {name=$3} /^Installed Size/ {print name, $4 substr($5,1,1)}' | column -t | sort -rhk2 | cat -n | tac
  fi
}

# Fuzzy package installer/uninstaller
pac_fuzzy(){
  local fuzzy_cmd key lines packages
  local fzf_preview='
    command pacman -Si {1} 2>/dev/null || paru -Si {1} |
    command bat -p --language=ini --color=always |
    sed -r "s/(Installed Size|Name|Version|Depends On|Optional Deps|Maintainer|Repository|Licenses|URL)/\x1b[96;1m\1\x1b[0m/g"'
  if command -v fzf &>/dev/null; then
    fuzzy_cmd="fzf"
  elif command -v sk &>/dev/null; then
    fuzzy_cmd="sk"
  else
    printf "fzf or sk is required for this function.\n" >&2
    return 1
  fi
  readarray -t lines < <(
    cat <(comm -23 <(pacman -Slq | sort) <(pacman -Qq | sort)) \
        <(pacman -Qq | awk '{print $1 " \033[32m[installed]\033[0m"}') \
        <(paru -Ssqa | sort | comm -23 - <(pacman -Slq | sort) | awk '{print $1 " \033[33m[AUR]\033[0m"}') |
      "$fuzzy_cmd" --ansi -m --style=full --cycle --border --height=~100% \
        --inline-info -0 --layout=reverse-list \
        --preview "$fzf_preview" --preview-window=right:60%:wrap \
        --expect=ctrl-u --header 'ENTER: install, CTRL-U: uninstall'
  )
  key="${lines[0]}"
  unset "lines[0]"
  if [[ ${#lines[@]} -eq 0 ]]; then
    printf '%s\n' "No packages selected."
    return
  fi
  packages=("${lines[@]%% *}") # Remove everything after the first space
  if [[ "$key" == "ctrl-u" ]]; then
    printf '%b\n' "\e[31mUninstalling packages:\e[0m ${packages[*]}"
    sudo pacman -Rns --noconfirm "${packages[@]}"
  else
    printf '%b\n' "\e[32mInstalling packages:\e[0m ${packages[*]}"
    paru -S --noconfirm --needed "${packages[@]}"
  fi
}

# -----------------------------------------------------------------------------
# Git Related Functions
# -----------------------------------------------------------------------------

# Apply a patch from a GitHub commit URL
ghpatch() {
  local url="${1:?usage: ghpatch <commit-url>}" patch
  patch="$(mktemp)" || return 1
  trap 'rm -f "$patch"' EXIT
  curl -sSfL "${url}.patch" -o "$patch" || return 1
  if git apply "$patch"; then
    git add -A && git commit -m "Apply patch from ${url}"
  else
    echo "Patch failed"
    return 1
  fi
}

# Perform maximum git maintenance
git_maintain_max() {
  echo "Git gc"
  git gc --prune=now --aggressive --cruft
  echo "Git repack"
  git repack -adfbm --threads=0 --depth=250 --window=250
  echo "Git maintenance"
  git maintenance run --task=prefetch --task=gc --task=loose-objects --task=incremental-repack --task=pack-refs --task=reflog-expire --task=rerere-gc --task=worktree-prune
}


# -----------------------------------------------------------------------------
# File and Directory Management
# -----------------------------------------------------------------------------

# Open the selected file in the default editor
fe() {
  local IFS=$'\n' line; local files=()
  while IFS='' read -r line; do files+=("$line"); done < <(fzf -q "$1" -m --inline-info -1 -0 --layout=reverse-list)
  [[ -n "${files[0]}" ]] && ${EDITOR:-nano} "${files[@]}"
}

# cd to the selected directory
fcd() {
  local dir
  dir=$(find "${1:-.}" -path '*/\.*' -prune \
      -o -type d -print 2> /dev/null | fzf +m) \
      && cd "$dir" || return 1
}

# Cat^2 (cat for files and directories)
catt() {
  for i in "$@"; do
    if [[ -d "$i" ]]; then
      ls "$i"
    else
      cat "$i"
    fi
  done
}


gh() {
	[[ $( command git rev-parse --is-inside-work-tree ) ]] || return
	command git log --date=relative --format="%C(auto)%h%d %C(white)%s %C(cyan)%an %C(black)%C(bold)%cd%C(auto)" --graph --color=always | 
	command fzf --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
		--header 'Press CTRL-S to toggle sort' \
		--preview='grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | delta -n' \
		--bind 'enter:execute(grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | delta -n | less -R)'
		# --preview='grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' | grep -o "[a-f0-9]\{7,\}"
		# --preview="git show {1} --color=always" | grep -o "[a-f0-9]\{7,\}"
}

# Search for and install packages with an fzf preview
paruf() {
  if [[ -z "$1" ]]; then
    echo "Usage: paruf <package-query>"
    return 1
  fi
  paru -Ssq "$1" |
    fzf --multi --ansi --cycle --preview 'paru -Si {} | bat -p --color=always' |
    xargs -r paru -Sq --needed --skipreview
}

# An fzf wrapper for paru to search and install repo and AUR packages.
fuzzy_paru(){
  # Use an awk script to generate a single, tagged list in one pass.
  # This avoids redundant commands and sub-processes.
  local fzf_input
  fzf_input=$(
    awk '
      # Read the list of all installed packages (repo & AUR) into an array `i`
      FNR == NR { i[$0] = 1; next }
      # For the main package list, check if the package exists in the array `i`
      {
        # If it exists, print with the "[installed]" tag
        if ($0 in i) {
          printf "%s\t\033[32m[installed]\033[0m\n", $0
        } else {
        # Otherwise, print just the package name
          print $0
        }
      }
    ' <(paru -Qq) <(paru -Ssq '^') # Pass installed list, then all available repo/AUR packages
  )
  # Use mapfile to read fzf's output into a proper bash array.
  local -a selections
  mapfile -t selections < <(
    # Pass the generated list to fzf via a here-string
    <<<"$fzf_input" fzf \
      --ansi \
      --multi \
      --cycle \
      --layout=reverse-list \
      --preview '
        # `paru -Si` can show info for both repo and AUR packages.
        # Uses fzf'\''s fast built-in {1} field index placeholder.
        paru -Si {1} 2>/dev/null | bat -p --language=ini --color=always
      '
  )
  # Check if the array of selections is not empty.
  if (( ${#selections[@]} > 0 )); then
    # Strip the "[installed]" tag from the selections.
    local -a packages_to_install=("${selections[@]%% *}")
    printf '\e[32mInstalling packages:\e[0m %s\n' "${packages_to_install[*]}"
    # `paru` handles sudo elevation automatically.
    paru -S --needed "${packages_to_install[@]}"
  else
    printf 'No packages selected.\n'
  fi
}

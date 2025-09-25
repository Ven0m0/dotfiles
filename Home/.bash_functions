#!/usr/bin/env bash
# ~/.bash_functions

# -----------------------------------------------------------------------------
# General Purpose Functions
# -----------------------------------------------------------------------------

# Update dotfiles git repository
dotupdate() {
  if [[ -d "${HOME}/.dotfiles" ]]; then
    (
      cd "${HOME}/.dotfiles" &&
      git pull --rebase --autostash &&
      printf '%s\n' "Updated dotfiles"
    )
  else
    printf '%s\n' "Failed to update dotfiles"
  fi
}

# Setup SSH keys and add to ssh-agent and GitHub
Setup-ssh() {
  local email="${email:-ven0m0.wastaken@gmail.com}"
  local key_path="${HOME}/.ssh/id_ed25519"
  
  if [[ ! -f "$key_path" ]]; then
    ssh-keygen -t ed25519 -C "$email" -f "$key_path"
  fi
  
  eval "$(ssh-agent -s)"
  ssh-add "$key_path"
  
  if command -v gh &>/dev/null; then
    gh ssh-key add "${key_path}.pub" --type signing
  fi

  local hosts=("dietpi@192.168.178.81" "root@192.168.178.81" "dietpi@192.168.178.86" "root@192.168.178.86")
  for host in "${hosts[@]}"; do
    ssh-copy-id -i "${key_path}.pub" "$host"
  done
}

# Explain any bash command via mankier.com manpage API
explain() {
  if [ "$#" -eq 0 ]; then
    while read -r -p "Command: " cmd; do
      curl -Gs "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$cmd"
    done
    echo "Bye!"
  elif [ "$#" -eq 1 ]; then
    curl -Gs "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$1"
  else
    echo "Usage"
    echo "explain                  interactive mode."
    echo "explain 'cmd -o | ...'   one quoted command to explain it."
  fi
}

# Display online manpages using curl
manol() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: manol [section] <page>" >&2
    echo "Example: manol 3 printf" >&2
    return 1
  fi
  local page section url
  local base_url="https://man.archlinux.org/man"
  local pager="${PAGER:-less}"
  if [[ $# -eq 1 ]]; then
    page="$1"
    url="${base_url}/${page}"
  else
    section="$1"
    page="$2"
    url="${base_url}/${page}.${section}"
  fi
  curl --silent --location --user-agent "curl-manpage-viewer/1.0" --compressed "$url" | "$pager" -R
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

# -----------------------------------------------------------------------------
# Arch Linux Specific Functions
# -----------------------------------------------------------------------------

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
    sed -r "s/(Installed Size|Name|Version|Depends On|Optional Deps|Maintainer|Repository|Licenses|URL)/\x1b[96;1m\1\x1b[0m/g"
  '
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

# -----------------------------------------------------------------------------
# Miscellaneous
# -----------------------------------------------------------------------------

# Deduplicate an array
_bash-it-array-dedup() {
  printf '%s\n' "$@" | sort -u
}

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

alias _='sudo'
alias edit='${EDITOR:-${ALTERNATE_EDITOR:-nano}}'
alias pager='${PAGER:-less}'
alias q='exit'
alias h='history'
alias rd='rmdir'
alias md='mkdir -p'
alias rmd='rm -rf'
alias bhelp='bathelp'
alias g='git'

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








#!/usr/bin/env bash
#~/.bash_functions

dotupdate() {
  if [[ -d ${HOME}/.dotfiles ]]; then
    LC_ALL=C git -C "${HOME}/.dotfiles" pull --rebase --autostash
    printf '%s\n' "Updated dotfiles"
  else
    printf '%s\n' "Failed to update dotfiles"
  fi
}

Setup-ssh() {
  [[ ! -f "${HOME}/.ssh/id_ed25519" ]] && ssh-keygen -t ed25519 -C "${email:-ven0m0.wastaken@gmail.com}"
  eval "$(ssh-agent -s)"
  ssh-add "${HOME}/.ssh/id_ed25519"
  command -v gh &>/dev/null && gh ssh-key add "${HOME}/.ssh/id_ed25519.pub" --type signing
  ssh-copy-id -i "${HOME}/.ssh/id_ed25519.pub" dietpi@192.168.178.81 && ssh-copy-id -i "${HOME}/.ssh/id_ed25519.pub" root@192.168.178.81
  ssh-copy-id -i "${HOME}/.ssh/id_ed25519.pub" dietpi@192.168.178.86 && ssh-copy-id -i "${HOME}/.ssh/id_ed25519.pub" root@192.168.178.86
}

# Arch specific
pacsize() {
  PAGER="${PAGER:-less}"
  if command -v pacinfo &>/dev/null; then
    pacman -Qqt | pacinfo --removable-size | awk '/^Name:/ { name = $2 } /^Installed Size:/ { size = $3$4 } /^$/ { print size" "name } ' | sort -uk2 | sort -rh | "$PAGER"
  else
    pacman -Qi | awk '/^Name/ {name=$3} /^Installed Size/ {print name, $4 substr($5,1,1)}' | column -t | sort -rhk2 | cat -n | tac
  fi
}

pacf() {
  local sel SHELL=bash
  sel=$(comm -23 <(command pacman -Slq | sort) <(command pacman -Qq | sort) |
    cat - <(command pacman -Qq | awk '{printf "%-30s \033[32m[installed]\033[0m\n", $1}') |
    fzf --ansi -m --style=full --cycle --border --height=~100% --inline-info -0 --layout=reverse-list \
      --preview '
        command pacman -Si $(awk "{print \$1}" <<< {}) 2>/dev/null | \
        command bat -p --language=ini --color=always | \
        sed -r "s/(Installed Size|Name|Version|Depends On|Optional Deps|Maintainer|Repository|Licenses|URL)/\x1b[96;1m\1\x1b[0m/g"
      ' --preview-window=right:60%:wrap | awk '{print $1}' | paste -sd " " -)
  [[ -n $sel ]] && {
    printf '%b\n' "\e[32mInstalling packages:\e[0m $sel"
    sudo pacman -S "${sel// / }" --noconfirm --needed
  } || printf '%s\n' "No packages selected."
}

pacsk() {
  local sel SHELL=bash
  sel=$(comm -23 <(command pacman -Slq | sort) <(command pacman -Qq | sort) |
    cat - <(command pacman -Qq | awk '{printf "%-30s \033[32m[installed]\033[0m\n", $1}') |
    sk --ansi -m --cycle --border --inline-info --height=~100% -0 --layout=reverse-list \
      --preview '
        command pacman -Si $(awk "{print \$1}" <<< {}) 2>/dev/null | \
        command bat -p --language=ini --color=always | \
        sed -r "s/(Installed Size|Name|Version|Depends On|Optional Deps|Maintainer|Repository|Licenses|URL)/\x1b[96;1m\1\x1b[0m/g"
      ' --preview-window=right:60%:wrap | awk '{print $1}' | paste -sd " " -)
  [[ -n $sel ]] && {
    printf '%b\n' "\e[32mInstalling packages:\e[0m $sel"
    sudo pacman -S "${sel// / }" --noconfirm --needed
  } || printf '%s\n' "No packages selected."
}

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

# curl -sSfL 'https://man.archlinux.org/man/${1}.raw' | man -l -
# Display online manpages using curl
# Usage: manol [section] <page>
manol() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: manol [section] <page>" >&2
    echo "Example: manol 3 printf" >&2
    return 1
  fi
  local page section url
  local base_url="https://man.archlinux.org/man"
  local pager="${PAGER:-less}" # Use your default PAGER, or fall back to less
  # Handle arguments like the real `man` command
  if [[ $# -eq 1 ]]; then
    page="$1"
    url="${base_url}/${page}"
  else
    section="$1"
    page="$2"
    url="${base_url}/${page}.${section}"
  fi
  # Fetch the page and display it
  curl \
    --silent \
    --location \
    --user-agent "curl-manpage-viewer/1.0" \
    --compressed \
    "$url" | "$pager" -R
}

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

bathelp() { "$@" --help 2>&1 | command bat -splhelp --squeeze-limit 0; }
alias bhelp='bathelp'

git_maintain_max() {
  echo "Git gc"
  git gc --prune=now --aggressive --cruft
  echo "Git repack"
  git repack -adfbm --threads=0 --depth=250 --window=250
  echo "Git maintenance"
  git maintenance run --task=prefetch --task=gc --task=loose-objects --task=incremental-repack --task=pack-refs --task=reflog-expire --task=rerere-gc --task=worktree-prune
}
#!/usr/bin/env bash
#~/.bash_functions

dotupdate() {
  if [[ -d ${HOME}/.dotfiles ]]; then
    LC_ALL=C git -C "${HOME}/.dotfiles" pull --rebase --autostash
    printf '%s\n' "Updated dotfiles"
  else
    printf '%s\n' "Failed to update dotfiles"
  fi
}

Setup-ssh() {
  [[ ! -f "${HOME}/.ssh/id_ed25519" ]] && ssh-keygen -t ed25519 -C "${email:-ven0m0.wastaken@gmail.com}"
  eval "$(ssh-agent -s)"
  ssh-add "${HOME}/.ssh/id_ed25519"
  command -v gh &>/dev/null && gh ssh-key add "${HOME}/.ssh/id_ed25519.pub" --type signing
  ssh-copy-id -i "${HOME}/.ssh/id_ed25519.pub" dietpi@192.168.178.81 && ssh-copy-id -i "${HOME}/.ssh/id_ed25519.pub" root@192.168.178.81
  ssh-copy-id -i "${HOME}/.ssh/id_ed25519.pub" dietpi@192.168.178.86 && ssh-copy-id -i "${HOME}/.ssh/id_ed25519.pub" root@192.168.178.86
}

# Arch specific
pacsize() {
  PAGER="${PAGER:-less}"
  if command -v pacinfo &>/dev/null; then
    pacman -Qqt | pacinfo --removable-size | awk '/^Name:/ { name = $2 } /^Installed Size:/ { size = $3$4 } /^$/ { print size" "name } ' | sort -uk2 | sort -rh | "$PAGER"
  else
    pacman -Qi | awk '/^Name/ {name=$3} /^Installed Size/ {print name, $4 substr($5,1,1)}' | column -t | sort -rhk2 | cat -n | tac
  fi
}

pacf() {
  local sel SHELL=bash
  sel=$(comm -23 <(command pacman -Slq | sort) <(command pacman -Qq | sort) |
    cat - <(command pacman -Qq | awk '{printf "%-30s \033[32m[installed]\033[0m\n", $1}') |
    fzf --ansi -m --style=full --cycle --border --height=~100% --inline-info -0 --layout=reverse-list \
      --preview '
        command pacman -Si $(awk "{print \$1}" <<< {}) 2>/dev/null | \
        command bat -p --language=ini --color=always | \
        sed -r "s/(Installed Size|Name|Version|Depends On|Optional Deps|Maintainer|Repository|Licenses|URL)/\x1b[96;1m\1\x1b[0m/g"
      ' --preview-window=right:60%:wrap | awk '{print $1}' | paste -sd " " -)
  [[ -n $sel ]] && {
    printf '%b\n' "\e[32mInstalling packages:\e[0m $sel"
    sudo pacman -S "${sel// / }" --noconfirm --needed
  } || printf '%s\n' "No packages selected."
}

pacsk() {
  local sel SHELL=bash
  sel=$(comm -23 <(command pacman -Slq | sort) <(command pacman -Qq | sort) |
    cat - <(command pacman -Qq | awk '{printf "%-30s \033[32m[installed]\033[0m\n", $1}') |
    sk --ansi -m --cycle --border --inline-info --height=~100% -0 --layout=reverse-list \
      --preview '
        command pacman -Si $(awk "{print \$1}" <<< {}) 2>/dev/null | \
        command bat -p --language=ini --color=always | \
        sed -r "s/(Installed Size|Name|Version|Depends On|Optional Deps|Maintainer|Repository|Licenses|URL)/\x1b[96;1m\1\x1b[0m/g"
      ' --preview-window=right:60%:wrap | awk '{print $1}' | paste -sd " " -)
  [[ -n $sel ]] && {
    printf '%b\n' "\e[32mInstalling packages:\e[0m $sel"
    sudo pacman -S "${sel// / }" --noconfirm --needed
  } || printf '%s\n' "No packages selected."
}

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

# curl -sSfL 'https://man.archlinux.org/man/${1}.raw' | man -l -
# Display online manpages using curl
# Usage: manol [section] <page>
manol() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: manol [section] <page>" >&2
    echo "Example: manol 3 printf" >&2
    return 1
  fi
  local page section url
  local base_url="https://man.archlinux.org/man"
  local pager="${PAGER:-less}" # Use your default PAGER, or fall back to less
  # Handle arguments like the real `man` command
  if [[ $# -eq 1 ]]; then
    page="$1"
    url="${base_url}/${page}"
  else
    section="$1"
    page="$2"
    url="${base_url}/${page}.${section}"
  fi
  # Fetch the page and display it
  curl \
    --silent \
    --location \
    --user-agent "curl-manpage-viewer/1.0" \
    --compressed \
    "$url" | "$pager" -R
}

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

bathelp() { "$@" --help 2>&1 | command bat -splhelp --squeeze-limit 0; }
alias bhelp='bathelp'

git_maintain_max() {
  echo "Git gc"
  git gc --prune=now --aggressive --cruft
  echo "Git repack"
  git repack -adfbm --threads=0 --depth=250 --window=250
  echo "Git maintenance"
  git maintenance run --task=prefetch --task=gc --task=loose-objects --task=incremental-repack --task=pack-refs --task=reflog-expire --task=rerere-gc --task=worktree-prune
}

explain() {
	about 'explain any bash command via mankier.com manpage API'
	param '1: Name of the command to explain'
	example '$ explain                # interactive mode. Type commands to explain in REPL'
	example '$ explain '"'"'cmd -o | ...'"'"' # one quoted command to explain it.'
	group 'explain'

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

fe() {
	about "Open the selected file in the default editor"
	group "fzf"
	param "1: Search term"
	example "fe foo"

	local IFS=$'\n' line
	local files=()
	while IFS='' read -r line; do files+=("$line"); done < <(fzf-tmux --query="$1" --multi --select-1 --exit-0)
	[[ -n "${files[0]}" ]] && ${EDITOR:-vim} "${files[@]}"
}

fcd() {
	about "cd to the selected directory"
	group "fzf"
	param "1: Directory to browse, or . if omitted"
	example "fcd aliases"

	local dir
	dir=$(find "${1:-.}" -path '*/\.*' -prune \
		-o -type d -print 2> /dev/null | fzf +m) \
		&& cd "$dir" || return 1
}


function sudo-command-line() {
	[[ ${#READLINE_LINE} -eq 0 ]] && READLINE_LINE=$(fc -l -n -1 | xargs)
	if [[ $READLINE_LINE == sudo\ * ]]; then
		READLINE_LINE="${READLINE_LINE#sudo }"
	else
		READLINE_LINE="sudo $READLINE_LINE"
	fi
	READLINE_POINT=${#READLINE_LINE}
}
[ "${BASH_VERSINFO[0]}" -ge 4 ] && bind -x '"\e\e": sudo-command-line'

if _command_exists thefuck; then
	# shellcheck disable=SC2046
	eval $(thefuck --alias)
fi

# Dedupe an array (without embedded newlines).
function _bash-it-array-dedup() {
	printf '%s\n' "$@" | sort -u
}
# https://github.com/Bash-it/bash-it/blob/master/completion/available/aliases.completion.bash
if command -v rustc &>/dev/null; then
  source "$(rustc --print sysroot)"/etc/bash_completion.d/cargo
fi
if command -v rustup &>/dev/null; then
  eval "$(rustup completions bash rustup)"
fi
if command -v gh &>/dev/null; then
  eval "$(gh completion --shell=bash)"
fi


alias _='sudo'
alias edit='${EDITOR:-${ALTERNATE_EDITOR:-nano}}'
alias pager='${PAGER:-less}'
alias q='exit'
alias h='history'
alias rd='rmdir'
alias md='mkdir -p'
alias rmd='rm -rf'

function catt(){
  for i in "$@"; do
    if [[ -d "$i" ]]; then
	  ls "$i"
	else
	  cat "$i"
	fi
done
}
alias g='git'




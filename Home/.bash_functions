#!/usr/bin/env bash
# =============================================================================
# GENERAL UTILITIES
# =============================================================================
# Create directory and cd into it
mkcd(){ mkdir -p -- "$1" && cd -- "$1" || exit; }
# cd and list contents
cdls(){ cd -- "$1" && ls -A; }
# Go up N directories
up(){
  local d="" limit=$1
  for ((i = 1; i <= limit; i++)); do d=$d/..; done
  d=${d#/}; cd -- "${d:=..}" || exit
}
# Display file/directory sizes
fs(){
  if command -v dust &>/dev/null; then
    dust -r "${1:-.}"
  elif [[ $# -gt 0 ]]; then
    du -sbh -- "$@"
  else
    du -sbh -- .[!.]* ./* 2>/dev/null | sort -hr
  fi
}
# Cat for files, ls for directories
catt(){ for i in "$@"; do
  [[ -d $i ]] && ls "$i" || bat -p "$i" 2>/dev/null || cat "$i"
done; }

# Open files/URIs in VS Code
vcode() {
  [[ $# -eq 0 ]] && { echo "Usage: vcode FILE|URI..."; return 1; }
  { command -v code &>/dev/null || command -v vscode &>/dev/null; } || { echo "Error: 'code' not found" >&2; return 1; }
  for uri in "$@"; do
    local path="${uri#file://}"; path="${path//%20/ }"
    if code --new-window "$path"; then
      printf 'Opened: %s\n' "$path"
    elif vscode --new-window "$path"; then
      printf 'Opened: %s\n' "$path"
    else
      printf 'Failed to open: %s\n' "$path" >&2
    fi
  done
}

# =============================================================================
# ARCHIVE MANAGEMENT
# =============================================================================
# Extract various archive formats
extract() {
  [[ $# -lt 1 || $# -gt 2 ]] && { printf 'Usage: extract FILE [OUT_DIR]\n' >&2; return 1; }
  local f="$1" out="${2:-.}"
  [[ -f $f ]] || { printf 'File %s not found\n' "$f" >&2; return 1; }
  [[ -d $out ]] || { mkdir -p "$out" && printf 'Created %s\n' "$out"; }
  local has_cmd() { command -v "$1" &>/dev/null || { printf '%s required\n' "$1" >&2; return 1; }; }
  case "${f,,}" in
    *.tar.xz) has_cmd tar && tar -xf "$f" -C "$out" ;;
    *.tar.gz | *.tgz) has_cmd tar && tar -xzf "$f" -C "$out" ;;
    *.tar.bz2) has_cmd tar && tar -xjf "$f" -C "$out" ;;
    *.tar.zst) has_cmd tar && tar --zstd -xf "$f" -C "$out" ;;
    *.tar) has_cmd tar && tar -xf "$f" -C "$out" ;;
    *.bz | *.bz2) has_cmd bzip2 && bzip2 -dkc "$f" >"$out/${f%.bz*}" ;;
    *.gz) has_cmd gzip && gzip -dc "$f" >"$out/${f%.gz}" ;;
    *.xz) has_cmd xz && xz -dkc "$f" >"$out/${f%.xz}" ;;
    *.zst) has_cmd zstd && zstd -dco "$out/${f%.zst}" "$f" ;;
    *.zip | *.jar) has_cmd unzip && unzip -q "$f" -d "$out" ;;
    *.Z) has_cmd uncompress && uncompress -c "$f" | tar -xC "$out" ;;
    *.rar) has_cmd unrar && unrar x -inul "$f" "$out/" ;;
    *.7z) has_cmd 7z && 7z x -o"$out" "$f" >/dev/null ;;
    *) printf 'Unsupported format: %s\n' "$f" >&2; return 1 ;;
  esac; printf 'Extracted: %s -> %s\n' "$f" "$out"
}

# Create compressed archives
cr() {
  [[ $# -eq 0 ]] && { echo "Usage: cr <file_or_folder1> ..."; return 1; }
  echo "Choose format: 1)tar.gz 2)tar.xz 3)tar.zst 4)zip 5)7z"
  read -rp "Choice [1-5]: " choice
  read -rp "Output name (no extension): " out
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

# Copy/move and cd to destination
cpg(){ [[ -d $2 ]] && cp "$1" "$2" && cd "$2" || cp "$1" "$2"; }
mvg(){ [[ -d $2 ]] && mv -- "$1" "$2" && cd -- "$2" || mv -- "$1" "$2"; }

# Search for text in files (prefer rg)
ftext() {
  if command -v rg &>/dev/null; then
    rg -i --hidden --color=always "$@" | bat --paging=always
  else
    grep -iIHrn --color=always "$1" . | bat --paging=always
  fi
}

# Strip metadata from images (prefer GraphicsMagick)
fiximg(){
  local GM_CMD GM_IDENTIFY
  if command -v gm &>/dev/null; then
    GM_CMD="gm convert"; GM_IDENTIFY="gm identify"
  elif command -v magick &>/dev/null; then
    GM_CMD="magick convert"; GM_IDENTIFY="magick identify"
  else
    GM_CMD="convert"; GM_IDENTIFY="identify"
  fi
  local -a exts=(png jpg jpeg webp avif jxl)
  strip_file(){
    local f="$1" tmp
    if [[ -n $("$GM_IDENTIFY" -format "%[EXIF:*]" "$f" 2>/dev/null) ]] \
      || [[ -n $("$GM_IDENTIFY" -format "%[IPTC:*]" "$f" 2>/dev/null) ]] \
      || [[ -n $("$GM_IDENTIFY" -format "%[Comment]" "$f" 2>/dev/null) ]]; then
      tmp="${f}.strip.$$"
      "$GM_CMD" "$f" -strip "$tmp" && mv "$tmp" "$f"
    fi
  }; export -f strip_file; export GM_CMD GM_IDENTIFY
  if command -v fd &>/dev/null; then
    fd -t f "$(printf -- '-e %s ' "${exts[@]}")" -x bash -c 'strip_file "$1"' _
  else
    find . -type f \( "$(printf -- '-iname "*.%s" -o ' "${exts[@]}")" -false \) \
      -exec bash -c 'strip_file "$1"' _ {} \;
  fi; unset -f strip_file
}

# =============================================================================
# PROCESS MANAGEMENT
# =============================================================================

# Find and kill processes with confirmation (prefer rg)
pk(){
  [[ $# -ne 1 ]] && { echo "Usage: pk <process_name>"; return 1; }
  local pids
  # Use pgrep if available (faster, handles special chars), fallback to grep
  if command -v pgrep &>/dev/null; then
    pids=$(pgrep -f "$1" | xargs)
  elif command -v rg &>/dev/null; then
    pids=$(ps aux | rg -F "$1" | rg -v 'rg' | awk '{print $2}')
  else
    pids=$(ps aux | grep -F "$1" | grep -v grep | awk '{print $2}')
  fi
  [[ -z $pids ]] && { echo "❌ No processes found matching '$1'"; return 1; }
  echo "🔍 Found processes:"
  if command -v pgrep &>/dev/null; then
    pgrep -af "$1"
  elif command -v rg &>/dev/null; then
    ps aux | rg -F "$1" | rg -v 'rg'
  else
    ps aux | grep -F "$1" | grep -v grep
  fi
  read -rp "❓ Kill these? (y/N): " confirm
  [[ $confirm =~ ^[Yy]$ ]] && echo "$pids" | xargs kill -9 && echo "💀 Killed" || echo "❌ Cancelled"
}
# Fuzzy process killer (prefer sk if faster)
fkill(){
  local pid fuzzy
  # Use sk for large datasets, fzf for small ones
  fuzzy=$(command -v sk &>/dev/null && echo "sk" || echo "fzf")
  [[ $UID != 0 ]] && pid=$(ps -f -u "$UID" | tail -n +2 | fzf -m | awk '{print $2}') \
    || pid=$(ps -ef | tail -n +2 | fzf -m | awk '{print $2}')
  [[ -n $pid ]] && xargs kill -"${1:-9}" <<<"$pid"
}
# Run process in background
bgd(){ ( nohup "$@" &>/dev/null </dev/null &; disown ); }
bgd_full(){ ( nohup setsid "$@" &>/dev/null </dev/null &; disown ); }

# =============================================================================
# MAN PAGES & HELP
# =============================================================================
# Fuzzy man page search
fman(){

  [[ $# -gt 0 ]] && { man "$@"; return; }
  if command -v sd &>/dev/null; then
    man -k . | fzf --reverse \
      --preview="echo {1,2} | sd ' \\(' '.' | sd '\\)\\s*\$' '' | xargs man" \
      | awk '{print $1"."$2}' | tr -d '()' | xargs -r man
  else
    man -k . | fzf --reverse \
      --preview="echo {1,2} | sed 's/ (/./' | sed -E 's/\)\s*$//' | xargs man" \
      | awk '{print $1"."$2}' | tr -d '()' | xargs -r man
  fi
}
# Get help with bat syntax highlighting
bathelp(){ "$@" --help 2>&1 | bat -plhelp; }

# Explain commands via API
explain(){
  if [[ $# -eq 0 ]]; then
    while read -rp "Command: " cmd; do
      curl -sfG "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$cmd"
    done; echo "Bye!"
  else
    curl -sfG "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$*"
  fi
}

# =============================================================================
# FUZZY NAVIGATION (Unified)
# =============================================================================
# Unified fuzzy file/directory navigator
# Usage:
#   fz          - fuzzy find and cd to directory
#   fz -f       - fuzzy find and edit file
#   fz -p       - fuzzy cd to parent directory
#   fz <path>   - search within specific path
fz(){
  local mode="dir" search_path="${1:-.}" fuzzy
  fuzzy=$(command -v sk &>/dev/null && echo "sk" || echo "fzf")

  # Parse flags
  while [[ $1 =~ ^- ]]; do
    case "$1" in
      -f | --file) mode="file"; shift ;;
      -p | --parent) mode="parent"; shift ;;
      *) shift ;;
    esac
  done
  search_path="${1:-.}"
  case "$mode" in
    file)
      # Fuzzy file editor
      local IFS=$'\n' files=()
      if command -v fd &>/dev/null; then
        while IFS='' read -r line; do files+=("$line"); done < <(
          fd -t f . "$search_path" | fzf -m --preview 'bat --color=always {}'
        )
      else
        while IFS='' read -r line; do files+=("$line"); done < <(
          find "$search_path" -type f 2>/dev/null | fzf -m --preview 'bat --color=always {}'
        )
      fi; [[ -n ${files[0]} ]] && "${EDITOR:-nano}" "${files[@]}" ;;
    parent)
      # Fuzzy cd to parent directories
      local -a dirs=()
      get_parent_dirs(){
        [[ -d $1 ]] && dirs+=("$1") || return
        [[ $1 == '/' ]] && printf '%s\n' "${dirs[@]}" || get_parent_dirs "$(dirname "$1")"
      }
      local dir=$(get_parent_dirs "$(realpath "${search_path:-$PWD}")" | fzf --tac)
      cd "$dir" && ls ;;
    dir)
      # Fuzzy directory change
      local dir
      if command -v fdf &>/dev/null; then
        dir=$(fdf "$search_path" -t d 2>/dev/null | fzf +m --preview 'ls -lah {}')
      elif command -v fd &>/dev/null; then
        dir=$(fd -t d . "$search_path" 2>/dev/null | fzf +m --preview 'ls -lah {}')
      else
        dir=$(find "$search_path" -type d 2>/dev/null | fzf +m --preview 'ls -lah {}')
      fi; [[ -n $dir ]] && cd "$dir" || exit ;;
  esac
}
# Backward compatibility aliases
alias fe='fz -f'
alias fcd='fz'
alias fzf-cd-to-parent='fz -p'

# =============================================================================
# GIT FUNCTIONS (prefer gix where applicable)
# =============================================================================

# Apply patch from GitHub commit URL
ghpatch(){
  local url="${1:?usage: ghpatch <commit-url>}" patch
  patch="$(mktemp)" || return 1
  trap 'rm -f "$patch"' EXIT
  curl -sSfL "${url}.patch" -o "$patch" || return 1
  if git apply "$patch"; then
    git add -A && git commit -m "Apply patch from ${url}"
  else
    echo "❌ Patch failed"; return 1
  fi
}
# Fuzzy git log viewer
ghf(){
  git rev-parse --is-inside-work-tree &>/dev/null || return
  git log --date=relative --format="%C(auto)%h%d %C(white)%s %C(cyan)%an %C(black)%C(bold)%cd%C(auto)" \
    --graph --color=always \
    | fzf --ansi --no-sort --reverse -m --bind 'ctrl-s:toggle-sort' \
      --header 'CTRL-S: toggle sort' \
      --preview="$(command -v rg &>/dev/null && echo 'rg' || echo 'grep') -o '[a-f0-9]\{7,\}' <<< {} | xargs $git_cmd show --color=always | delta" \
      --bind "enter:execute($(command -v rg &>/dev/null && echo 'rg' || echo 'grep') -o '[a-f0-9]\{7,\}' <<< {} | xargs $git_cmd show --color=always | delta | less -R)"
}
# Fuzzy git status editor
fzf-git-status(){
  git rev-parse --git-dir &>/dev/null || { echo "❌ Not in git repo"; return; }
  local selected=$("$git_cmd" -c color.status=always status --short \
      | fzf --height 50% "$@" --border -m --ansi --nth 2..,.. \
        --preview "(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500" \
      | cut -c4- | sed 's/.* -> //')
  [[ -n $selected ]] && while IFS= read -r file; do "$EDITOR" "$file"; done <<<"$selected"
}
# Maximum git maintenance
git_maintain_max(){
  git gc --prune=now --aggressive --cruft
  git repack -adfbm --threads=0 --depth=250 --window=250
  git maintenance run --task=prefetch --task=gc --task=loose-objects \
    --task=incremental-repack --task=pack-refs --task=reflog-expire \
    --task=rerere-gc --task=worktree-prune
}
# Update git repo with submodules
update_git_pull(){
  git pull --rebase --autostash && git submodule update --init --recursive
}
# Delete merged/gone branches
gdbr(){
  git fetch --prune
  if command -v rg &>/dev/null; then
    git branch -vv | rg -F ': gone]' | awk '{print $1}' | xargs -r git branch -D
  else
    git branch -vv | grep -F ': gone]' | awk '{print $1}' | xargs -r git branch -D
  fi
}

# =============================================================================
# ARCH LINUX / PACKAGE MANAGEMENT
# =============================================================================
# Display installed package sizes
pacsize(){
  if command -v pacinfo &>/dev/null; then
    pacman -Qqt | pacinfo --removable-size \
      | awk '/^Name:/{name=$2}/^Installed Size:/{size=$3$4}/^$/{print size" "name}' \
      | sort -uk2 | sort -rh | bat --paging=always
  else
    pacman -Qi | awk '/^Name/{name=$3}/^Installed Size/{print name,$4 substr($5,1,1)}' \
      | column -t | sort -rhk2 | cat -n | tac | bat --paging=always
  fi
}

# Fuzzy package installer/uninstaller
fuzzy_paru(){
  local fzf_input
  fzf_input=$(awk '
    FNR==NR {i[$0]=1; next}
    {
      if ($0 in i) printf "%s\t\033[32m[installed]\033[0m\n", $0
      else print $0
    }
  ' <(paru -Qq) <(paru -Ssq '^'))
  local -a selections
  mapfile -t selections < <(
    <<<"$fzf_input" fzf --ansi -m --cycle --layout=reverse-list \
      --preview 'paru -Si {1} 2>/dev/null | bat -plini --color=always' \
      --expect=ctrl-u --header 'ENTER: install, CTRL-U: uninstall'
  )
  local key="${selections[0]}"; unset "selections[0]"
  [[ ${#selections[@]} -eq 0 ]] && { echo "No packages selected"; return; }
  local -a packages=("${selections[@]%% *}")
  if [[ $key == "ctrl-u" ]]; then
    printf '\e[31mUninstalling:\e[0m %s\n' "${packages[*]}"
    sudo pacman -Rns --noconfirm "${packages[@]}"
  else
    printf '\e[32mInstalling:\e[0m %s\n' "${packages[*]}"
    paru -S --needed --noconfirm "${packages[@]}"
  fi
}
# Search AUR packages (prefer jaq)
search(){
  local jq_cmd=$(command -v jaq &>/dev/null && echo "jaq" || echo "jq")
  curl -s "https://aur.archlinux.org/rpc/?v=5&type=search&arg=$1" \
    | "$jq_cmd" '.results[] | {Name,Description,Version,URL,NumVotes,Popularity,Maintainer}' \
    || echo "Cannot query database"
}

# =============================================================================
# DOCKER FUNCTIONS
# =============================================================================
da(){
  local cid=$(docker ps -a | tail -n +2 | fzf -1 -q "$1" | awk '{print $1}')
  [[ -n $cid ]] && docker start "$cid" && docker attach "$cid"
}

ds(){ local cid=$(docker ps | tail -n +2 | fzf -q "$1" | awk '{print $1}'); [[ -n $cid ]] && docker stop "$cid"; }
drm(){ local cid=$(docker ps -a | tail -n +2 | fzf -q "$1" | awk '{print $1}'); [[ -n $cid ]] && docker rm "$cid"; }
drmm(){ docker ps -a | tail -n +2 | fzf -q "$1" --no-sort -m --tac | awk '{print $1}' | xargs -r docker rm; }
drmi(){ docker images | tail -n +2 | fzf -q "$1" --no-sort -m --tac | awk '{print $3}' | xargs -r docker rmi; }

# =============================================================================
# MISCELLANEOUS UTILITIES
# =============================================================================
# List opened applications
list_opened_apps(){ ps axc | awk 'NR > 1 {print substr($0,index($0,$5))}' | sort -u; }
# Shell script linter combo
shlint(){
  shellcheck -a -x --shell=bash --source-path=SCRIPTDIR -f diff "$1" | patch -p1
  shellharden --replace "$1"
  shfmt -w -ln bash -bn -i 2 -s "$1"
}
# Delete empty subdirectories (prefer fd/fdf)
prune_empty(){
  local reply
  [[ -n $1 ]] && read -rp "Prune empty directories: are you sure? [y] " reply || reply=y
  if [[ $reply == y ]]; then
    find . -type d -empty -delete
  fi
}

# vim: set ft=bash ts=2 sw=2 et:

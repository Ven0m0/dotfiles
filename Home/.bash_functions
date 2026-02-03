#!/usr/bin/env bash
# =============================================================================
# GENERAL UTILITIES
# =============================================================================
# Create directory and cd into it (Safe: returns instead of exiting)
mkcd(){
  [[ -z "$1" ]] && { echo "Usage: mkcd <dir>"; return 1; }
  mkdir -p -- "$1" && cd -- "$1" || return 1
}
# cd and list contents
cdls(){
  cd -- "$1" && ls -A
}
# Go up N directories
up(){
  local count="${1:-1}"
  local d=""
  # Validate input is a number
  if ! [[ "$count" =~ ^[0-9]+$ ]]; then
    echo "Usage: up [N]"
    return 1
  fi
  for ((i = 1; i <= count; i++)); do
    d="../$d"
  done
  cd -- "$d" || return 1
}
# Display file/directory sizes
fs(){
  if command -v dust &>/dev/null; then
    dust -r "${1:-.}"
  else
    # Check if there are files to process to avoid 'du' errors
    local args=("$@")
    if [[ $# -eq 0 ]]; then
      # Use nullglob to handle empty directories gracefully
      shopt -s nullglob
      args=( .[!.]* ./* )
      shopt -u nullglob
    fi
    [[ ${#args[@]} -gt 0 ]] && du -sbh -- "${args[@]}" 2>/dev/null | sort -hr
  fi
}
# Cat for files, ls for directories
catt(){
  for i in "$@"; do
    if [[ -d "$i" ]]; then
      ls "$i"
    elif command -v bat &>/dev/null; then
      bat -p "$i" 2>/dev/null || cat "$i"
    else
      cat "$i"
    fi
  done
}

# Open files/URIs in VS Code or VSCodium
vcode(){
  [[ $# -eq 0 ]] && { echo "Usage: vcode FILE|URI..."; return 1; }
  local cmd
  if command -v code &>/dev/null; then cmd="code"
  elif command -v codium &>/dev/null; then cmd="codium"
  elif command -v vscode &>/dev/null; then cmd="vscode"
  else echo "Error: VS Code/Codium not found" >&2; return 1; fi
  for uri in "$@"; do
    local path="${uri#file://}"
    path="${path//%20/ }"
    "$cmd" --new-window "$path" && printf 'Opened: %s\n' "$path" || printf 'Failed: %s\n' "$path" >&2
  done
}
mounted(){
  mount | column -t
}

# =============================================================================
# ARCHIVE MANAGEMENT
# =============================================================================
# Extract various archive formats
extract(){
  if [[ $# -lt 1 ]]; then
    printf 'Usage: extract FILE [OUT_DIR]\n' >&2
    return 1
  fi
  local f="$1"
  local out="${2:-.}"
  if [[ ! -f "$f" ]]; then
    printf 'File %s not found\n' "$f" >&2
    return 1
  fi
  if [[ ! -d "$out" ]]; then
    mkdir -p "$out" && printf 'Created %s\n' "$out"
  fi
  local cmd_miss=0
  case "${f,,}" in
    *.tar.xz)    tar -xf "$f" -C "$out" ;;
    *.tar.gz|*.tgz) tar -xzf "$f" -C "$out" ;;
    *.tar.bz2)   tar -xjf "$f" -C "$out" ;;
    *.tar.zst)   tar --zstd -xf "$f" -C "$out" ;;
    *.tar)       tar -xf "$f" -C "$out" ;;
    *.bz2)       bunzip2 -dkc "$f" >"$out/${f%.bz2}" ;;
    *.gz)        gunzip -dc "$f" >"$out/${f%.gz}" ;;
    *.xz)        xz -dkc "$f" >"$out/${f%.xz}" ;;
    *.zst)       zstd -dco "$out/${f%.zst}" "$f" ;;
    *.zip|*.jar) unzip -q "$f" -d "$out" ;;
    *.rar)       unrar x -inul "$f" "$out/" ;;
    *.7z)        7z x -o"$out" "$f" >/dev/null ;;
    *)           printf 'Unsupported format: %s\n' "$f" >&2; return 1 ;;
  esac
  if [[ $? -eq 0 ]]; then
    printf 'Extracted: %s -> %s\n' "$f" "$out"
  else
    printf 'Extraction failed for %s\n' "$f" >&2
    return 1
  fi
}

# Create compressed archives
cr(){
  [[ $# -eq 0 ]] && { echo "Usage: cr <file_or_folder1> ..."; return 1; }
  echo "Choose format: 1)tar.gz 2)tar.xz 3)tar.zst 4)zip 5)7z"
  local choice out
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
cpg(){
  [[ -d "$2" ]] && cp "$1" "$2" && cd "$2" || cp "$1" "$2"
}
mvg(){
  [[ -d "$2" ]] && mv -- "$1" "$2" && cd -- "$2" || mv -- "$1" "$2"
}

# Search for text in files (prefer rg)
ftext(){
  if command -v rg &>/dev/null; then
    # --line-number ensures bat knows where to look if it supports it
    rg -i --hidden --color=always --line-number "$@" | bat --paging=always --color=always
  else
    grep -iIHrn --color=always "$1" . | bat --paging=always
  fi
}

# Strip metadata from images
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
  # Export for subshell
  export GM_CMD GM_IDENTIFY
  export -f _strip_file_internal 2>/dev/null
  _strip_file_internal(){
    local f="$1" tmp
    if [[ -n $("$GM_IDENTIFY" -format "%[EXIF:*]%[IPTC:*]%[Comment]" "$f" 2>/dev/null) ]]; then
      tmp="${f}.strip.$$"
      "$GM_CMD" "$f" -strip "$tmp" && mv "$tmp" "$f"
    fi
  }
  if command -v fd &>/dev/null; then
    fd -t f "$(printf -- '-e %s ' "${exts[@]}")" -x bash -c '_strip_file_internal "$1"' _
  else
    find . -type f \( "$(printf -- '-iname "*.%s" -o ' "${exts[@]}")" -false \) \
      -exec bash -c '_strip_file_internal "$1"' _ {} \;
  fi
}

# =============================================================================
# PROCESS MANAGEMENT
# =============================================================================
# Find and kill processes
pk(){
  [[ $# -ne 1 ]] && { echo "Usage: pk <process_name>"; return 1; }
  local pids
  if command -v pgrep &>/dev/null; then
    pids=$(pgrep -f "$1" | xargs)
  else
    pids=$(ps aux | grep -F "$1" | grep -v grep | awk '{print $2}')
  fi
  [[ -z $pids ]] && { echo "❌ No processes found matching '$1'"; return 1; }
  echo "🔍 Found processes:"
  if command -v pgrep &>/dev/null; then
    pgrep -af "$1"
  else
    ps aux | grep -F "$1" | grep -v grep
  fi
  local confirm
  read -rp "❓ Kill these? (y/N): " confirm
  [[ $confirm =~ ^[Yy]$ ]] && echo "$pids" | xargs kill -9 && echo "💀 Killed" || echo "❌ Cancelled"
}
# Fuzzy process killer
fkill(){
  local pid fuzzy
  fuzzy=$(command -v sk &>/dev/null && echo "sk" || echo "fzf")
  if [[ $UID != 0 ]]; then
    pid=$(ps -f -u "$UID" | tail -n +2 | $fuzzy -m | awk '{print $2}')
  else
    pid=$(ps -ef | tail -n +2 | $fuzzy -m | awk '{print $2}')
  fi
  [[ -n $pid ]] && echo "$pid" | xargs kill -"${1:-9}"
}
# Run process in background
bgd(){
  ( nohup "$@" &>/dev/null </dev/null & )
  disown
}

# =============================================================================
# MAN PAGES & HELP
# =============================================================================
fman(){
  [[ $# -gt 0 ]] && { man "$@"; return; }
  local cmd
  cmd='man -k . | fzf --reverse --preview="bash -c \"s={2}; man {1}.\${s//[()]/}\""'
  eval "$cmd" | awk '{print $1"."$2}' | tr -d '()' | xargs -r man
}
bathelp(){ "$@" --help 2>&1 | bat -plhelp; }

# =============================================================================
# FUZZY NAVIGATION
# =============================================================================
fz(){
  local mode="dir" search_path="${1:-.}"
  # Parse flags
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
      local files=()
      if command -v fd &>/dev/null; then
        mapfile -t files < <(fd -t f . "$search_path" | fzf -m --preview 'bat --color=always {}')
      else
        mapfile -t files < <(find "$search_path" -type f 2>/dev/null | fzf -m --preview 'bat --color=always {}')
      fi
      [[ ${#files[@]} -gt 0 ]] && "${EDITOR:-nano}" "${files[@]}"
      ;;
    parent)
      local dirs=()
      # Helper to build parent list
      _get_parents(){
        local p="$1"
        while [[ "$p" != "/" && "$p" != "." ]]; do
          dirs+=("$p")
          p=$(dirname "$p")
        done
        dirs+=("/")
      }
      _get_parents "$(realpath "${search_path:-$PWD}")"
      local dir
      dir=$(printf '%s\n' "${dirs[@]}" | fzf --tac)
      [[ -n "$dir" ]] && cd "$dir" && ls
      ;;
    dir|*)
      local dir
      if command -v fdf &>/dev/null; then
        dir=$(fdf "$search_path" -t d 2>/dev/null | fzf +m --preview 'ls -lah {}')
      elif command -v fd &>/dev/null; then
        dir=$(fd -t d . "$search_path" 2>/dev/null | fzf +m --preview 'ls -lah {}')
      else
        dir=$(find "$search_path" -type d 2>/dev/null | fzf +m --preview 'ls -lah {}')
      fi
      [[ -n "$dir" ]] && cd "$dir" || return 1
      ;;
  esac
}
alias fe='fz -f'
alias fcd='fz'
alias fzf-cd-to-parent='fz -p'

# =============================================================================
# GIT FUNCTIONS
# =============================================================================
ghpatch(){
  local url="${1:?usage: ghpatch <commit-url>}"
  local patch
  patch="$(mktemp)" || return 1
  trap 'rm -f "$patch"' EXIT
  if curl -sSfL "${url}.patch" -o "$patch"; then
    if git apply "$patch"; then
      git add -A && git commit -m "Apply patch from ${url}"
    else
      echo "❌ Patch failed"
      return 1
    fi
  else
    echo "❌ Failed to download patch"
    return 1
  fi
}

ghf(){
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local git_cmd="git"
  local grep_cmd=$(command -v rg &>/dev/null && echo "rg" || echo "grep")
  git log --date=relative --format="%C(auto)%h%d %C(white)%s %C(cyan)%an %C(black)%C(bold)%cd%C(auto)" \
    --graph --color=always |
  fzf --ansi --no-sort --reverse -m --bind 'ctrl-s:toggle-sort' \
      --header 'CTRL-S: toggle sort' \
      --preview="$grep_cmd -o '[a-f0-9]\{7,\}' <<< {} | xargs $git_cmd show --color=always | delta" \
      --bind "enter:execute($grep_cmd -o '[a-f0-9]\{7,\}' <<< {} | xargs $git_cmd show --color=always | delta | less -R)"
}
fzf-git-status(){
  git rev-parse --git-dir &>/dev/null || { echo "❌ Not in git repo"; return 1; }
  local selected
  selected=$(git -c color.status=always status --short |
    fzf --height 50% "$@" --border -m --ansi --nth 2..,.. \
      --preview "(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500" |
    cut -c4- | sed 's/.* -> //')
  if [[ -n $selected ]]; then
    while IFS= read -r file; do
      "$EDITOR" "$file"
    done <<<"$selected"
  fi
}
git_maintain_max(){
  git gc --prune=now --aggressive --cruft
  git repack -adfbm --threads=0 --depth=250 --window=250
  git maintenance run --task=prefetch --task=gc --task=loose-objects \
    --task=incremental-repack --task=pack-refs --task=reflog-expire \
    --task=rerere-gc --task=worktree-prune
}
update_git_pull(){
  git pull --rebase --autostash && git submodule update --init --recursive
}
gdbr(){
  git fetch --prune
  local grep_cmd=$(command -v rg &>/dev/null && echo "rg" || echo "grep")
  git branch -vv | $grep_cmd -F ': gone]' | awk '{print $1}' | xargs -r git branch -D
}

# =============================================================================
# PACKAGE MANAGEMENT (Arch)
# =============================================================================
pacsize(){
  if command -v pacinfo &>/dev/null; then
    pacman -Qqt | pacinfo --removable-size |
      awk '/^Name:/{name=$2}/^Installed Size:/{size=$3$4}/^$/{print size" "name}' |
      sort -uk2 | sort -rh | bat --paging=always
  else
    pacman -Qi | awk '/^Name/{name=$3}/^Installed Size/{print name,$4 substr($5,1,1)}' |
      column -t | sort -rhk2 | cat -n | tac | bat --paging=always
  fi
}

fuzzy_paru(){
  if ! command -v paru &>/dev/null; then echo "paru not found"; return 1; fi
  local fzf_input
  fzf_input=$(awk '
    FNR==NR {i[$0]=1; next}
    {
      if ($0 in i) printf "%s\t\033[32m[installed]\033[0m\n", $0
      else print $0
    }
  ' <(paru -Qq) <(paru -Ssq '^'))
  local selections=()
  mapfile -t selections < <(
    echo "$fzf_input" | fzf --ansi -m --cycle --layout=reverse-list \
      --preview 'paru -Si {1} 2>/dev/null | bat -plini --color=always' \
      --expect=ctrl-u --header 'ENTER: install, CTRL-U: uninstall'
  )
  [[ ${#selections[@]} -eq 0 ]] && return
  local key="${selections[0]}"
  unset "selections[0]"
  [[ ${#selections[@]} -eq 0 ]] && { echo "No packages selected"; return; }
  local packages=()
  for item in "${selections[@]}"; do
    packages+=("${item%% *}")
  done
  if [[ $key == "ctrl-u" ]]; then
    printf '\e[31mUninstalling:\e[0m %s\n' "${packages[*]}"
    sudo pacman -Rns --noconfirm "${packages[@]}"
  else
    printf '\e[32mInstalling:\e[0m %s\n' "${packages[*]}"
    paru -S --needed --noconfirm "${packages[@]}"
  fi
}
search(){
  local jq_cmd=$(command -v jaq &>/dev/null && echo "jaq" || echo "jq")
  curl -s "https://aur.archlinux.org/rpc/?v=5&type=search&arg=$1" |
    "$jq_cmd" '.results[] | {Name,Description,Version,URL,NumVotes,Popularity,Maintainer}' ||
    echo "Cannot query database"
}

# =============================================================================
# DOCKER FUNCTIONS
# =============================================================================
da(){
  local cid
  cid=$(docker ps -a | tail -n +2 | fzf -1 -q "$1" | awk '{print $1}')
  [[ -n $cid ]] && docker start "$cid" && docker attach "$cid"
}
ds(){
  local cid
  cid=$(docker ps | tail -n +2 | fzf -q "$1" | awk '{print $1}')
  [[ -n $cid ]] && docker stop "$cid"
}
drm(){
  local cid
  cid=$(docker ps -a | tail -n +2 | fzf -q "$1" | awk '{print $1}')
  [[ -n $cid ]] && docker rm "$cid"
}
drmm(){
  docker ps -a | tail -n +2 | fzf -q "$1" --no-sort -m --tac | awk '{print $1}' | xargs -r docker rm
}
drmi(){
  docker images | tail -n +2 | fzf -q "$1" --no-sort -m --tac | awk '{print $3}' | xargs -r docker rmi
}

# =============================================================================
# MISCELLANEOUS
# =============================================================================
list_opened_apps(){
  ps axc | awk 'NR > 1 {print substr($0,index($0,$5))}' | sort -u
}
shlint(){
  [[ -z "$1" ]] && { echo "Usage: shlint <script>"; return 1; }
  shellcheck -a -x --shell=bash --source-path=SCRIPTDIR -f diff "$1" | patch -p1
  shellharden --replace "$1"
  shfmt -w -ln bash -bn -i 2 -s "$1"
}
prune_empty(){
  local reply
  [[ -n $1 ]] && read -rp "Prune empty directories in $1: are you sure? [y/N] " reply || reply=y
  if [[ $reply =~ ^[Yy]$ ]]; then
    find "${1:-.}" -type d -empty -delete
  fi
}
ffwrap(){
  if command -v ffzap &>/dev/null; then
    ffzap "$@"
  elif command -v ffmpeg &>/dev/null; then
    ffmpeg -hide_banner "$@"
  else
    echo "neither ffzap nor ffmpeg found in PATH" >&2
    return 1
  fi
}
jqwrap(){
  if command -v jaq &>/dev/null; then
    jaq "$@"
  elif command -v jq &>/dev/null; then
    jq "$@"
  else
    echo "neither jq nor jaq found in PATH" >&2
    return 1
  fi
}

# vim: set ft=bash ts=2 sw=2 et:

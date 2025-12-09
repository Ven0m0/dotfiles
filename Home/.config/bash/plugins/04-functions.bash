# ~/.config/bash/plugins/04-functions.bash
#!/usr/bin/env bash
#============================== [Functions] ===================================
# --- Navigation & Directory
mkcd(){ [[ -z $1 ]] && { printf "Usage: mkcd <dir>\n"; return 1; }; mkdir -p -- "$1" && cd -- "$1" || return 1; }
cdls(){ cd -- "$1" && ls -A; }
up(){ local d="" c="${1:-1}"; [[ ! $c =~ ^[0-9]+$ ]] && { printf "Usage: up [N]\n"; return 1; }; for ((i=1;i<=c;i++)); do d="../$d"; done; cd -- "$d" || return 1; }
mounted(){ mount | column -t; }

# --- File Info & Display
fs(){
  if has dust; then dust -r "${1:-.}"
  else
    local -a args=("$@")
    [[ $# -eq 0 ]] && { shopt -s nullglob; args=(.[!.]* ./*); shopt -u nullglob; }
    [[ ${#args[@]} -gt 0 ]] && du -sbh -- "${args[@]}" &>/dev/null | sort -hr
  fi
}
catt(){
  for i in "$@"; do
    if [[ -d $i ]]; then ls "$i"
    elif has bat; then bat -p "$i" &>/dev/null || cat "$i"
    else cat "$i"; fi
  done
}
vcode(){
  [[ $# -eq 0 ]] && { printf "Usage: vcode FILE|URI...\n"; return 1; }
  local cmd
  if has code; then cmd="code"
  elif has codium; then cmd="codium"
  elif has vscode; then cmd="vscode"
  else printf "Error: VS Code/Codium not found\n" >&2; return 1; fi
  for uri in "$@"; do
    local path="${uri#file://}" && path="${path//%20/ }"
    "$cmd" --new-window "$path" && printf 'Opened: %s\n' "$path" || printf 'Failed: %s\n' "$path" >&2
  done
}

# --- Archive Management
extract(){
  [[ $# -lt 1 ]] && { printf 'Usage: extract FILE [OUT_DIR]\n' >&2; return 1; }
  local f="$1" out="${2:-.}"
  [[ ! -f $f ]] && { printf 'File %s not found\n' "$f" >&2; return 1; }
  [[ ! -d $out ]] && mkdir -p "$out" && printf 'Created %s\n' "$out"
  case "${f,,}" in
    *.tar.xz) tar -xf "$1" -C "$out" ;;
    *.tar.gz|*.tgz) tar -xzf "$f" -C "$out" ;;
    *.tar.bz2) tar -xjf "$f" -C "$out" ;;
    *.tar.zst) tar --zstd -xf "$f" -C "$out" ;;
    *.tar) tar -xf "$f" -C "$out" ;;
    *.bz2) bunzip2 -dkc "$f" >"$out/${f%.bz2}" ;;
    *.gz) gunzip -dc "$f" >"$out/${f%.gz}" ;;
    *.xz) xz -dkc "$f" >"$out/${f%.xz}" ;;
    *.zst) zstd -dco "$out/${f%.zst}" "$f" ;;
    *.zip|*.jar) unzip -q "$f" -d "$out" ;;
    *.rar) unrar x -inul "$f" "$out/" ;;
    *.7z) 7z x -o"$out" "$f" &>/dev/null ;;
    *.deb) ar x "$f" ;;
    *) printf 'Unsupported format: %s\n' "$f" >&2; return 1 ;;
  esac
  [[ $? -eq 0 ]] && printf 'Extracted: %s -> %s\n' "$f" "$out" || { printf 'Extraction failed for %s\n' "$f" >&2; return 1; }
}
cr(){
  [[ $# -eq 0 ]] && { printf "Usage: cr <file_or_folder1> ...\n"; return 1; }
  printf "Choose format: 1)tar.gz 2)tar.xz 3)tar.zst 4)zip 5)7z\n"
  local choice out
  read -rp "Choice [1-5]: " choice && read -rp "Output name (no extension): " out
  case "$choice" in
    1) tar czf "$out.tar.gz" "$@" ;;
    2) tar cJf "$out.tar.xz" "$@" ;;
    3) tar --zstd -cf "$out.tar.zst" "$@" ;;
    4) zip -r "$out.zip" "$@" ;;
    5) 7z a "$out.7z" "$@" ;;
    *) printf "❌ Invalid choice\n"; return 1 ;;
  esac
}

# --- File Operations
cpg(){ [[ -d $2 ]] && cp "$1" "$2" && cd "$2" || cp "$1" "$2"; }
mvg(){ [[ -d $2 ]] && mv -- "$1" "$2" && cd -- "$2" || mv -- "$1" "$2"; }
ftext(){
  if has rg; then rg -i --hidden --color=always --line-number "$@" | bat --paging=always --color=always
  else grep -iIHrn --color=always "$1" . | bat --paging=always; fi
}
fiximg(){
  local GM_CMD GM_IDENTIFY
  if has gm; then GM_CMD="gm convert"; GM_IDENTIFY="gm identify"
  elif has magick; then GM_CMD="magick convert"; GM_IDENTIFY="magick identify"
  else GM_CMD="convert"; GM_IDENTIFY="identify"; fi
  local -a exts=(png jpg jpeg webp avif jxl)
  export GM_CMD GM_IDENTIFY
  export -f _strip_file_internal &>/dev/null
  _strip_file_internal(){
    local f="$1" tmp
    if [[ -n $("$GM_IDENTIFY" -format "%[EXIF:*]%[IPTC:*]%[Comment]" "$f" &>/dev/null) ]]; then
      tmp="${f}.strip.$$" && "$GM_CMD" "$f" -strip "$tmp" && mv "$tmp" "$f"
    fi
  }
  if has fd; then fd -t f "$(printf -- '-e %s ' "${exts[@]}")" -x bash -c '_strip_file_internal "$1"' _
  else find . -type f \( "$(printf -- '-iname "*.%s" -o ' "${exts[@]}")" -false \) -exec bash -c '_strip_file_internal "$1"' _ {} \;; fi
}

# --- Process Management
pk(){
  [[ $# -ne 1 ]] && { printf "Usage: pk <process_name>\n"; return 1; }
  local pids
  if has pgrep; then pids=$(pgrep -f "$1" | xargs)
  else pids=$(ps aux | grep -F "$1" | grep -v grep | awk '{print $2}'); fi
  [[ -z $pids ]] && { printf "❌ No processes found matching '%s'\n" "$1"; return 1; }
  printf "🔍 Found processes:\n"
  has pgrep && pgrep -af "$1" || ps aux | grep -F "$1" | grep -v grep
  local confirm
  read -rp "❓ Kill these? (y/N): " confirm
  [[ $confirm =~ ^[Yy]$ ]] && printf "%s" "$pids" | xargs kill -9 && printf "💀 Killed\n" || printf "❌ Cancelled\n"
}
fkill(){
  local pid fuzzy=$(has sk && printf "sk" || printf "fzf")
  if [[ $UID != 0 ]]; then pid=$(ps -f -u "$UID" | tail -n +2 | $fuzzy -m | awk '{print $2}')
  else pid=$(ps -ef | tail -n +2 | $fuzzy -m | awk '{print $2}'); fi
  [[ -n $pid ]] && printf "%s" "$pid" | xargs kill -"${1:-9}"
}
bgd(){ ( nohup "$@" &>/dev/null </dev/null & ); disown; }

# --- Man & Help
fman(){
  [[ $# -gt 0 ]] && { man "$@"; return; }
  local cmd=$(has sd && printf "man -k . | fzf --reverse --preview=\"echo {1,2} | sd ' \\(' '.' | sd '\\)\\s*\$' '' | xargs man\"" || printf "man -k . | fzf --reverse --preview=\"echo {1,2} | sed 's/ (/./' | sed -E 's/\)\s*$//' | xargs man\"")
  eval "$cmd" | awk '{print $1"."$2}' | tr -d '()' | xargs -r man
}
bathelp(){ "$@" --help 2>&1 | bat -plhelp; }

# --- Fuzzy Navigation
fz(){
  local mode="dir" search_path="${1:-.}"
  while [[ $1 =~ ^- ]]; do
    case "$1" in -f|--file) mode="file"; shift ;; -p|--parent) mode="parent"; shift ;; *) shift ;; esac
  done
  search_path="${1:-.}"
  case "$mode" in
    file)
      local -a files=()
      if has fd; then mapfile -t files < <(fd -t f . "$search_path" | fzf -m --preview 'bat --color=always {}')
      else mapfile -t files < <(find "$search_path" -type f 2>/dev/null | fzf -m --preview 'bat --color=always {}'); fi
      [[ ${#files[@]} -gt 0 ]] && "${EDITOR:-nano}" "${files[@]}"
      ;;
    parent)
      local -a dirs=()
      _get_parents(){ local p="$1"; while [[ $p != "/" && $p != "." ]]; do dirs+=("$p"); p=$(dirname "$p"); done; dirs+=("/"); }
      _get_parents "$(realpath "${search_path:-$PWD}")"
      local dir=$(printf '%s\n' "${dirs[@]}" | fzf --tac)
      [[ -n $dir ]] && cd "$dir" && ls
      ;;
    dir|*)
      local dir
      if has fdf; then dir=$(fdf "$search_path" -t d &>/dev/null | fzf +m --preview 'ls -lah {}')
      elif has fd; then dir=$(fd -t d . "$search_path" &>/dev/null | fzf +m --preview 'ls -lah {}')
      else dir=$(find "$search_path" -type d &>/dev/null | fzf +m --preview 'ls -lah {}'); fi
      [[ -n $dir ]] && cd "$dir" || return 1
      ;;
  esac
}
alias fe='fz -f' fcd='fz' fzf-cd-to-parent='fz -p'

# --- Git
ghpatch(){
  local url="${1:?usage: ghpatch <commit-url>}" patch
  patch="$(mktemp)" || return 1
  trap 'rm -f "$patch"' EXIT
  if curl -sSfL "${url}.patch" -o "$patch"; then
    git apply "$patch" && git add -A && git commit -m "Apply patch from ${url}" || { printf "❌ Patch failed\n"; return 1; }
  else printf "❌ Failed to download patch\n"; return 1; fi
}
ghf(){
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local git_cmd="git" grep_cmd=$(has rg && printf "rg" || printf "grep")
  git log --date=relative --format="%C(auto)%h%d %C(white)%s %C(cyan)%an %C(black)%C(bold)%cd%C(auto)" --graph --color=always |
  fzf --ansi --no-sort --reverse -m --bind 'ctrl-s:toggle-sort' --header 'CTRL-S: toggle sort' \
    --preview="$grep_cmd -o '[a-f0-9]\{7,\}' <<< {} | xargs $git_cmd show --color=always | delta" \
    --bind "enter:execute($grep_cmd -o '[a-f0-9]\{7,\}' <<< {} | xargs $git_cmd show --color=always | delta | less -R)"
}
fzf-git-status(){
  git rev-parse --git-dir &>/dev/null || { printf "❌ Not in git repo\n"; return 1; }
  local selected=$(git -c color.status=always status --short | fzf --height 50% "$@" --border -m --ansi --nth 2..,.. --preview "(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500" | cut -c4- | sed 's/.* -> //')
  [[ -n $selected ]] && while IFS= read -r file; do "$EDITOR" "$file"; done <<<"$selected"
}
git_maintain_max(){
  git gc --prune=now --aggressive --cruft
  git repack -adfbm --threads=0 --depth=250 --window=250
  git maintenance run --task=prefetch --task=gc --task=loose-objects --task=incremental-repack --task=pack-refs --task=reflog-expire --task=rerere-gc --task=worktree-prune
}
update_git_pull(){ git pull --rebase --autostash && git submodule update --init --recursive; }
gdbr(){
  git fetch --prune
  local grep_cmd=$(has rg && printf "rg" || printf "grep")
  git branch -vv | $grep_cmd -F ': gone]' | awk '{print $1}' | xargs -r git branch -D
}

# --- Package Management (Arch)
pacsize(){
  if has pacinfo; then
    pacman -Qqt | pacinfo --removable-size | awk '/^Name:/{name=$2}/^Installed Size:/{size=$3$4}/^$/{print size" "name}' | sort -uk2 | sort -rh | bat --paging=always
  else
    pacman -Qi | awk '/^Name/{name=$3}/^Installed Size/{print name,$4 substr($5,1,1)}' | column -t | sort -rhk2 | cat -n | tac | bat --paging=always
  fi
}
fuzzy_paru(){
  has paru || { printf "paru not found\n"; return 1; }
  local fzf_input=$(awk 'FNR==NR {i[$0]=1; next} {if ($0 in i) printf "%s\t\033[32m[installed]\033[0m\n", $0; else print $0}' <(paru -Qq) <(paru -Ssq '^'))
  local -a selections=()
  mapfile -t selections < <(printf "%s" "$fzf_input" | fzf --ansi -m --cycle --layout=reverse-list --preview 'paru -Si {1} &>/dev/null | bat -plini --color=always' --expect=ctrl-u --header 'ENTER: install, CTRL-U: uninstall')
  [[ ${#selections[@]} -eq 0 ]] && return
  local key="${selections[0]}" && unset "selections[0]"
  [[ ${#selections[@]} -eq 0 ]] && { printf "No packages selected\n"; return; }
  local -a packages=()
  for item in "${selections[@]}"; do packages+=("${item%% *}"); done
  if [[ $key == "ctrl-u" ]]; then printf '\e[31mUninstalling:\e[0m %s\n' "${packages[*]}"; sudo pacman -Rns --noconfirm "${packages[@]}"
  else printf '\e[32mInstalling:\e[0m %s\n' "${packages[*]}"; paru -S --needed --noconfirm "${packages[@]}"; fi
}
search(){
  local jq_cmd=$(has jaq && printf "jaq" || printf "jq")
  curl -s "https://aur.archlinux.org/rpc/?v=5&type=search&arg=$1" | "$jq_cmd" '.results[] | {Name,Description,Version,URL,NumVotes,Popularity,Maintainer}' || printf "Cannot query database\n"
}

# --- Docker
da(){ local cid=$(docker ps -a | tail -n +2 | fzf -1 -q "$1" | awk '{print $1}'); [[ -n $cid ]] && docker start "$cid" && docker attach "$cid"; }
ds(){ local cid=$(docker ps | tail -n +2 | fzf -q "$1" | awk '{print $1}'); [[ -n $cid ]] && docker stop "$cid"; }
drm(){ local cid=$(docker ps -a | tail -n +2 | fzf -q "$1" | awk '{print $1}'); [[ -n $cid ]] && docker rm "$cid"; }
drmm(){ docker ps -a | tail -n +2 | fzf -q "$1" --no-sort -m --tac | awk '{print $1}' | xargs -r docker rm; }
drmi(){ docker images | tail -n +2 | fzf -q "$1" --no-sort -m --tac | awk '{print $3}' | xargs -r docker rmi; }

# --- Misc Utilities
list_opened_apps(){ ps axc | awk 'NR > 1 {print substr($0,index($0,$5))}' | sort -u; }
shlint(){
  [[ -z $1 ]] && { printf "Usage: shlint <script>\n"; return 1; }
  shellcheck -a -x --shell=bash --source-path=SCRIPTDIR -f diff "$1" | patch -p1
  shellharden --replace "$1"
  shfmt -w -ln bash -bn -i 2 -s "$1"
}
prune_empty(){
  local reply
  [[ -n $1 ]] && read -rp "Prune empty directories in $1: are you sure? [y/N] " reply || reply=y
  [[ $reply =~ ^[Yy]$ ]] && find "${1:-.}" -type d -empty -delete
}
ffwrap(){
  if has ffzap; then ffzap "$@"
  elif has ffmpeg; then ffmpeg -hide_banner "$@"
  else printf "neither ffzap nor ffmpeg found in PATH\n" >&2; return 1; fi
}
jqwrap(){
  if has jaq; then jaq "$@"
  elif has jq; then jq "$@"
  else printf "neither jq nor jaq found in PATH\n" >&2; return 1; fi
}

# vim: set ft=bash ts=2 sw=2 et:

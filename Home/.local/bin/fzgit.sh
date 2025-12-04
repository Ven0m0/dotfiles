#!/usr/bin/env bash
# fzgit - Fuzzy Git TUI (gix→git, gh integration, forgit-inspired)
set -euo pipefail
shopt -s lastpipe nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C SHELL="$(command -v bash)" HOME="/home/${SUDO_USER:-$USER}"

# Colors (trans palette)
readonly BLK=$'\e[30m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m'
readonly BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' WHT=$'\e[37m'
readonly LBLU=$'\e[38;5;117m' PNK=$'\e[38;5;218m' BWHT=$'\e[97m'
readonly DEF=$'\e[0m' BLD=$'\e[1m' UL=$'\e[4m'

# Core helpers
has(){ command -v "$1" &> /dev/null; }
err(){ printf '%b[ERR]%b %s\n' "$RED" "$DEF" "$*" >&2; }
die(){ err "$@"; exit 1; }

# Version
_ver(){ printf '%b%s%b -- %bv1.0.0%b fuzzy git TUI (gix/gh/forgit)\n' "$BLD" "${0##*/}" "$DEF" "$UL" "$DEF"; }

# Help
_help(){
  cat << EOF
${BLD}USAGE${DEF}  ${0##*/} ${UL}CMD${DEF} [${UL}ARGS${DEF}]

${BLD}GIT COMMANDS${DEF}
  a, add        Interactive git add
  d, diff       Interactive git diff
  D, difftool   Interactive difftool
  l, log        Interactive git log
  s, show       Interactive commit show
  S, status     Interactive git status
  b, branch     Interactive branch checkout
  B, branches   Interactive branch delete
  t, tag        Interactive tag checkout
  c, commit     Interactive commit checkout
  r, revert     Interactive commit revert
  R, reset      Interactive reset HEAD
  f, file       Interactive file checkout
  st, stash     Interactive stash viewer
  sp, stashpush Interactive stash push
  clean         Interactive git clean
  cp, cherry    Interactive cherry-pick
  rb, rebase    Interactive rebase
  rl, reflog    Interactive reflog
  bl, blame     Interactive blame viewer
  fx, fixup     Interactive fixup commit
  sq, squash    Interactive squash commit

${BLD}GITHUB (gh) COMMANDS${DEF}
  pr            Interactive PR viewer
  issue         Interactive issue viewer
  run           Interactive workflow run viewer
  repo          Interactive repo browser

${BLD}UTILITIES${DEF}
  ig, ignore    Generate .gitignore
  clone         Interactive clone from GitHub
  -h, h         Show this help
  -v, v         Show version

${BLD}KEYS${DEF}
  Tab           Multi-select
  Enter         Confirm
  ?             Toggle preview
  Ctrl-Y        Copy hash/ref
  Ctrl-S        Toggle sort
  Ctrl-R        Toggle selection
  Alt-E         Edit in \$EDITOR
  Alt-W         Toggle wrap
  Ctrl-J/K      Navigate selection
  Alt-J/K       Navigate preview

${BLD}EXAMPLES${DEF}
  ${0##*/} a                 # Interactive add
  ${0##*/} l --all           # Log all branches
  ${0##*/} d HEAD~           # Diff against HEAD~
  ${0##*/} b main            # Checkout branch (fuzzy)
  ${0##*/} pr                # Browse PRs (requires gh)
  ${0##*/} ig rust python    # Generate .gitignore
EOF
}

# Tool detection
for g in "${GIT_CMD:-gix git}"; do has "$g" && GIT="$g" && break; done
[[ -z ${GIT:-} ]] && die "No git/gix found"
for f in "${FINDER:-sk fzf}"; do has "$f" && FZF="$f" && break; done
[[ -z ${FZF:-} ]] && die "No fuzzy finder found (sk/fzf)"

# Optional tools
DELTA=$(command -v delta || :)
BAT=$(command -v bat || command -v batcat || :)
GH=$(command -v gh || :)
TREE=$(command -v tree || :)

# Clipboard detection
if [[ ${XDG_SESSION_TYPE:-} == wayland || -n ${WAYLAND_DISPLAY:-} ]]; then
  CLIP=$(command -v wl-copy || :)
elif [[ ${XDG_SESSION_TYPE:-} == x11 ]]; then
  CLIP=$(command -v xclip || :)
  [[ -n ${CLIP} ]] && CLIP="${CLIP} -selection clipboard"
else
  CLIP=
fi

# Git wrapper (prefers gix)
_git(){
  if [[ ${GIT##*/} == gix ]]; then
    case "$1" in
      log) gix log "$@" ;;
      diff) gix diff "$@" ;;
      status) gix status "$@" ;;
      *) git "$@" ;;
    esac
  else
    git "$@"
  fi
}

# Check if in git repo
_check_repo(){
  _git rev-parse --git-dir &> /dev/null || die "Not a git repository"
}

# FZF wrapper with defaults
_fzf(){
  local -a opts=(
    --ansi --cycle --no-mouse --reverse --inline-info
    --color='pointer:green,marker:green'
    --bind='?:toggle-preview'
    --bind='alt-w:toggle-preview-wrap'
    --bind='ctrl-s:toggle-sort'
    --bind='ctrl-r:toggle-all'
  )
  [[ ${FZF} == sk ]] && opts+=(--no-hscroll) || opts+=(--no-scrollbar)

  while (($#)); do
    case "$1" in
      -m)
        opts+=(-m)
        shift
        ;;
      -h)
        opts+=(--header "$2")
        shift 2
        ;;
      -p)
        opts+=(--preview "$2")
        shift 2
        ;;
      -w)
        opts+=(--preview-window "$2")
        shift 2
        ;;
      -l)
        opts+=(--preview-label "$2")
        shift 2
        ;;
      -b)
        opts+=(--bind "$2")
        shift 2
        ;;
      --)
        shift
        break
        ;;
      *) shift ;;
    esac
  done

  "$FZF" "${opts[@]}" "$@"
}

# Copy to clipboard
_copy(){
  [[ -z ${CLIP} ]] && return 0
  printf '%s' "$1" | "$CLIP"
}

# Get pager (delta > bat > less > cat)
_pager(){
  if [[ -n ${DELTA} ]]; then
    printf '%s' "${DELTA} --paging=never --side-by-side"
  elif [[ -n ${BAT} ]]; then
    printf '%s' "${BAT} --style=plain --color=always --paging=never"
  else
    printf '%s' "less -R"
  fi
}

# Extract hash from fzf selection
_extract_hash(){
  grep -Eo '[a-f0-9]{7,40}' | head -1
}

# Interactive git add
_add(){
  _check_repo
  local pager=$(_pager)
  local files
  files=$(_git diff --name-only --diff-filter=ACDMRTUXB "$@" | _fzf -m \
    -h $'Tab:select  Enter:add  Ctrl-Y:copy\nAlt-E:edit  ?:toggle preview' \
    -l '[git add]' \
    -w 'down:70%:wrap' \
    -p "git diff --color=always {} | ${pager}" \
    -b "ctrl-y:execute-silent(echo {} | tr '\n' ' ' | ${CLIP:-:})" \
    -b "alt-e:execute(${EDITOR:-vim} {})")
  [[ -z ${files} ]] && return 0
  _git add "$(xargs <<< "$files")"
}

# Interactive git diff
_diff(){
  _check_repo
  local pager=$(_pager)
  local target=${1:-HEAD}
  local files
  files=$(_git diff --name-only "$target" | _fzf -m \
    -h $'Tab:select  Enter:confirm  ?:preview\nCtrl-Y:copy filename' \
    -l '[git diff]' \
    -w 'down:70%:wrap' \
    -p "git diff --color=always ${target} {} | ${pager}" \
    -b "ctrl-y:execute-silent(echo {} | ${CLIP:-:})")
  [[ -n ${files} ]] && printf '%s\n' "$files"
}

# Interactive git log
_log(){
  _check_repo
  local pager=$(_pager)
  local format='%C(auto)%h%d %s %C(black)%C(bold)%cr%Creset'
  local preview="git show --color=always {1} | ${pager}"

  _git log --color=always --graph --format="$format" "$@" | _fzf \
    -h $'Enter:show  Ctrl-Y:copy hash  Alt-E:edit\n?:toggle preview  Ctrl-S:sort' \
    -l '[git log]' \
    -w 'down:70%:wrap' \
    -p "$preview" \
    -b "ctrl-y:execute-silent(echo {1} | ${CLIP:-:})" \
    -b "alt-e:execute(git show {1} | ${EDITOR:-vim} -)" \
    -b "enter:execute(git show {1} | ${pager} | less -R)"
}

# Interactive git show
_show(){
  _check_repo
  local pager=$(_pager)
  local format='%C(auto)%h%d %s %C(black)%C(bold)%cr%Creset'

  _git log --color=always --format="$format" "$@" | _fzf \
    -h $'Enter:confirm  Ctrl-Y:copy hash\n?:toggle preview' \
    -l '[git show]' \
    -w 'down:70%:wrap' \
    -p "git show --color=always {1} | ${pager}" \
    -b "ctrl-y:execute-silent(echo {1} | ${CLIP:-:})" | _extract_hash
}

# Interactive git status
_status(){
  _check_repo
  local pager=$(_pager)

  _git status --short --untracked-files=all | _fzf -m \
    -h $'Tab:select  Enter:add  Ctrl-Y:copy\nAlt-E:edit  ?:preview' \
    -l '[git status]' \
    -w 'down:70%:wrap' \
    -p "git diff --color=always {2} | ${pager}" \
    -b "ctrl-y:execute-silent(echo {2} | ${CLIP:-:})" \
    -b "alt-e:execute(${EDITOR:-vim} {2})"
}

# Interactive branch checkout
_branch(){
  _check_repo
  local branch
  branch=$(_git branch --all --color=always --sort=-committerdate "$@" \
    | grep -v HEAD | _fzf \
    -h $'Enter:checkout  Ctrl-Y:copy name\n?:toggle preview' \
    -l '[git branch]' \
    -w 'down:70%:wrap' \
    -p 'git log --oneline --graph --color=always {1}' \
    -b "ctrl-y:execute-silent(echo {1} | ${CLIP:-:})" \
    | sed 's/^[* ]*//' | awk '{print $1}')
  [[ -z ${branch} ]] && return 0
  _git checkout "${branch#remotes/origin/}"
}

# Interactive branch delete
_branch_delete(){
  _check_repo
  local branches
  branches=$(_git branch --color=always --sort=-committerdate "$@" \
    | grep -v '^\*' | _fzf -m \
    -h $'Tab:select  Enter:delete  Ctrl-Y:copy\n?:toggle preview' \
    -l '[git branch -D]' \
    -w 'down:70%:wrap' \
    -p 'git log --oneline --graph --color=always {1}' \
    -b "ctrl-y:execute-silent(echo {1} | ${CLIP:-:})" \
    | awk '{print $1}')
  [[ -z ${branches} ]] && return 0
  _git branch -D "$(xargs <<< "$branches")"
}

# Interactive tag checkout
_tag(){
  _check_repo
  local tag
  tag=$(_git tag --sort=-version:refname | _fzf \
    -h $'Enter:checkout  Ctrl-Y:copy tag\n?:toggle preview' \
    -l '[git tag]' \
    -w 'down:70%:wrap' \
    -p 'git show --color=always {}' \
    -b "ctrl-y:execute-silent(echo {} | ${CLIP:-:})")
  [[ -z ${tag} ]] && return 0
  _git checkout "$tag"
}

# Interactive commit checkout
_commit(){
  _check_repo
  local hash
  hash=$(_show "$@")
  [[ -z ${hash} ]] && return 0
  _git checkout "$hash"
}

# Interactive revert
_revert(){
  _check_repo
  local hash
  hash=$(_show "$@")
  [[ -z ${hash} ]] && return 0
  _git revert "$hash"
}

# Interactive reset HEAD
_reset(){
  _check_repo
  local pager=$(_pager)
  local files
  files=$(_git diff --cached --name-only --diff-filter=ACDMRTUXB | _fzf -m \
    -h $'Tab:select  Enter:reset  ?:preview' \
    -l '[git reset HEAD]' \
    -w 'down:70%:wrap' \
    -p "git diff --cached --color=always {} | ${pager}" \
    -b "ctrl-y:execute-silent(echo {} | ${CLIP:-:})")
  [[ -z ${files} ]] && return 0
  _git reset HEAD "$(xargs <<< "$files")"
}

# Interactive file checkout
_file(){
  _check_repo
  local pager=$(_pager)
  local files
  files=$(_git diff --name-only "$@" | _fzf -m \
    -h $'Tab:select  Enter:checkout  ?:preview' \
    -l '[git checkout]' \
    -w 'down:70%:wrap' \
    -p "git diff --color=always {} | ${pager}" \
    -b "ctrl-y:execute-silent(echo {} | ${CLIP:-:})")
  [[ -z ${files} ]] && return 0
  _git checkout -- "$(xargs <<< "$files")"
}

# Interactive stash viewer
_stash(){
  _check_repo
  local pager=$(_pager)
  local stash
  stash=$(_git stash list | _fzf \
    -h $'Enter:apply  Ctrl-D:drop  Ctrl-Y:copy\n?:toggle preview' \
    -l '[git stash]' \
    -w 'down:70%:wrap' \
    -p "git stash show -p {1} | ${pager}" \
    -b "ctrl-y:execute-silent(echo {1} | cut -d: -f1 | ${CLIP:-:})" \
    -b "ctrl-d:reload(git stash drop {1} && git stash list)" \
    | cut -d: -f1)
  [[ -z ${stash} ]] && return 0
  _git stash apply "$stash"
}

# Interactive stash push
_stash_push(){
  _check_repo
  local pager=$(_pager)
  local files
  files=$(_git diff --name-only --diff-filter=ACDMRTUXB | _fzf -m \
    -h $'Tab:select  Enter:stash  ?:preview' \
    -l '[git stash push]' \
    -w 'down:70%:wrap' \
    -p "git diff --color=always {} | ${pager}")
  [[ -z ${files} ]] && return 0
  _git stash push -m "fzgit stash" -- "$(xargs <<< "$files")"
}

# Interactive git clean
_clean(){
  _check_repo
  local files
  files=$(_git clean -xdffn | sed 's/^Would remove //' | _fzf -m \
    -h $'Tab:select  Enter:clean  ?:preview' \
    -l '[git clean]' \
    -w 'down:70%:wrap' \
    -p "${TREE:-find} {}" \
    -b "ctrl-y:execute-silent(echo {} | ${CLIP:-:})")
  [[ -z ${files} ]] && return 0
  printf '%bClean these files? [y/N]%b ' "$YLW" "$DEF"
  read -r ans
  [[ ${ans} =~ ^[Yy] ]] || return 0
  _git clean -xdff "$(xargs <<< "$files")"
}

# Interactive cherry-pick
_cherry(){
  _check_repo
  local hash
  hash=$(_show "$@")
  [[ -z ${hash} ]] && return 0
  _git cherry-pick "$hash"
}

# Interactive rebase
_rebase(){
  _check_repo
  local hash
  hash=$(_show "$@")
  [[ -z ${hash} ]] && return 0
  _git rebase -i "$hash"
}

# Interactive reflog
_reflog(){
  _check_repo
  local pager=$(_pager)

  _git reflog --color=always | _fzf \
    -h $'Enter:show  Ctrl-Y:copy hash  ?:preview' \
    -l '[git reflog]' \
    -w 'down:70%:wrap' \
    -p "git show --color=always {1} | ${pager}" \
    -b "ctrl-y:execute-silent(echo {1} | ${CLIP:-:})" \
    -b "enter:execute(git show {1} | ${pager} | less -R)"
}

# Interactive blame
_blame(){
  _check_repo
  [[ -z $1 ]] && die "Usage: ${0##*/} blame <file>"
  local pager=$(_pager)

  _git blame --color-by-age --color-lines "$1" | _fzf \
    -h $'Enter:show  Ctrl-Y:copy hash  ?:preview' \
    -l "[git blame $1]" \
    -w 'down:70%:wrap' \
    -p "git show --color=always {1} | ${pager}" \
    -b "ctrl-y:execute-silent(echo {1} | ${CLIP:-:})" \
    -b "enter:execute(git show {1} | ${pager} | less -R)"
}

# Interactive fixup commit
_fixup(){
  _check_repo
  local hash
  hash=$(_show "$@")
  [[ -z ${hash} ]] && return 0
  _git commit --fixup="$hash"
  _git rebase -i --autosquash "${hash}~1"
}

# Interactive squash commit
_squash(){
  _check_repo
  local hash
  hash=$(_show "$@")
  [[ -z ${hash} ]] && return 0
  _git commit --squash="$hash"
  _git rebase -i --autosquash "${hash}~1"
}

# Interactive difftool
_difftool(){
  _check_repo
  local files
  files=$(_diff "$@")
  [[ -z ${files} ]] && return 0
  _git difftool "${1:-HEAD}" -- "$(xargs <<< "$files")"
}

# GitHub PR viewer (requires gh)
_pr(){
  [[ -z ${GH} ]] && die "gh (GitHub CLI) not found"
  _check_repo

  gh pr list --color=always | _fzf \
    -h $'Enter:view  Ctrl-O:checkout  Ctrl-Y:copy URL\n?:toggle preview' \
    -l '[GitHub PRs]' \
    -w 'down:70%:wrap' \
    -p 'gh pr view {1} --comments' \
    -b "ctrl-y:execute-silent(gh pr view {1} --json url -q .url | ${CLIP:-:})" \
    -b 'ctrl-o:execute(gh pr checkout {1})+abort' \
    -b 'enter:execute(gh pr view {1} | less -R)'
}

# GitHub issue viewer (requires gh)
_issue(){
  [[ -z ${GH} ]] && die "gh (GitHub CLI) not found"
  _check_repo

  gh issue list --color=always | _fzf \
    -h $'Enter:view  Ctrl-Y:copy URL  ?:preview' \
    -l '[GitHub Issues]' \
    -w 'down:70%:wrap' \
    -p 'gh issue view {1} --comments' \
    -b "ctrl-y:execute-silent(gh issue view {1} --json url -q .url | ${CLIP:-:})" \
    -b 'enter:execute(gh issue view {1} | less -R)'
}

# GitHub workflow run viewer (requires gh)
_run(){
  [[ -z ${GH} ]] && die "gh (GitHub CLI) not found"
  _check_repo

  gh run list --color=always | _fzf \
    -h $'Enter:view  Ctrl-Y:copy URL  ?:preview' \
    -l '[GitHub Workflow Runs]' \
    -w 'down:70%:wrap' \
    -p 'gh run view {1}' \
    -b "ctrl-y:execute-silent(gh run view {1} --json url -q .url | ${CLIP:-:})" \
    -b 'enter:execute(gh run view {1} | less -R)'
}

# GitHub repo browser (requires gh)
_repo(){
  [[ -z ${GH} ]] && die "gh (GitHub CLI) not found"

  gh repo list --color=always | _fzf \
    -h $'Enter:view  Ctrl-C:clone  Ctrl-Y:copy URL\n?:toggle preview' \
    -l '[GitHub Repos]' \
    -w 'down:70%:wrap' \
    -p 'gh repo view {1}' \
    -b "ctrl-y:execute-silent(echo https://github.com/{1} | ${CLIP:-:})" \
    -b 'ctrl-c:execute(gh repo clone {1})+abort' \
    -b 'enter:execute(gh repo view {1} | less -R)'
}

# Generate .gitignore (gitignore.io)
_ignore(){
  local api="https://www.toptal.com/developers/gitignore/api"
  local list

  if (($# == 0)); then
    list=$(curl -fsSL "${api}/list" | tr ',' '\n' | _fzf -m \
      -h 'Tab:select  Enter:generate' \
      -l '[.gitignore templates]')
    [[ -z ${list} ]] && return 0
    set -- "$(xargs <<< "$list")"
  fi

  curl -fsSL "${api}/$(
    IFS=,
    printf '%s' "$*"
  )"
}

# Interactive clone from GitHub (requires gh)
_clone(){
  [[ -z ${GH} ]] && die "gh (GitHub CLI) not found"

  local repo
  repo=$(gh repo list --color=always --limit 1000 | _fzf \
    -h $'Enter:clone  Ctrl-Y:copy URL  ?:preview' \
    -l '[GitHub Clone]' \
    -w 'down:70%:wrap' \
    -p 'gh repo view {1}' \
    -b "ctrl-y:execute-silent(echo https://github.com/{1} | ${CLIP:-:})" \
    | awk '{print $1}')
  [[ -z ${repo} ]] && return 0
  gh repo clone "$repo"
}

# Main dispatcher
[[ $# -eq 0 ]] && {
  _help
  exit 1
}
case "${1,,}" in
  a | add)
    shift
    _add "$@"
    ;;
  d | diff)
    shift
    _diff "$@"
    ;;
  D | difftool)
    shift
    _difftool "$@"
    ;;
  l | log)
    shift
    _log "$@"
    ;;
  s | show)
    shift
    _show "$@"
    ;;
  S | status)
    shift
    _status "$@"
    ;;
  b | branch)
    shift
    _branch "$@"
    ;;
  B | branches)
    shift
    _branch_delete "$@"
    ;;
  t | tag)
    shift
    _tag "$@"
    ;;
  c | commit)
    shift
    _commit "$@"
    ;;
  r | revert)
    shift
    _revert "$@"
    ;;
  R | reset)
    shift
    _reset "$@"
    ;;
  f | file)
    shift
    _file "$@"
    ;;
  st | stash)
    shift
    _stash "$@"
    ;;
  sp | stashpush)
    shift
    _stash_push "$@"
    ;;
  clean)
    shift
    _clean "$@"
    ;;
  cp | cherry)
    shift
    _cherry "$@"
    ;;
  rb | rebase)
    shift
    _rebase "$@"
    ;;
  rl | reflog)
    shift
    _reflog "$@"
    ;;
  bl | blame)
    shift
    _blame "$@"
    ;;
  fx | fixup)
    shift
    _fixup "$@"
    ;;
  sq | squash)
    shift
    _squash "$@"
    ;;
  pr)
    shift
    _pr "$@"
    ;;
  issue)
    shift
    _issue "$@"
    ;;
  run)
    shift
    _run "$@"
    ;;
  repo)
    shift
    _repo "$@"
    ;;
  ig | ignore)
    shift
    _ignore "$@"
    ;;
  clone)
    shift
    _clone "$@"
    ;;
  -h | h | --help) _help ;;
  -v | v | --version) _ver ;;
  *) die "Invalid command: $1" ;;
esac

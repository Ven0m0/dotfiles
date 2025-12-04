#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C

have(){ command -v "$1" &>/dev/null; }
die(){ printf 'ERROR: %s\n' "$*" >&2; exit "${2:-1}"; }

for f in sk fzf; do have "$f" && FZF="$f" && break; done
[[ -z ${FZF:-} ]] || die "No fuzzy finder (fzf/sk) found"

batcmd(){ have batcat && printf 'batcat' || have bat && printf 'bat' || printf 'cat'; }

usage(){
  cat <<'EOF'
fzf-tools - Unified fuzzy finder utilities

USAGE:
  fzf-tools COMMAND [ARGS...]

COMMANDS:
  preview PATH[:LINE]    Preview files with syntax highlighting
  git CMD [ARGS]         Interactive git operations
  grep [QUERY]           Fuzzy grep search
  man [QUERY]            Fuzzy man page search

PREVIEW COMMANDS:
  preview FILE           Show file with highlighting and images

GIT COMMANDS:
  git add                Interactive git add
  git diff [REF]         Interactive git diff
  git log [ARGS]         Interactive git log
  git status             Interactive git status
  git branch             Interactive branch checkout
  git stash              Interactive stash viewer
  (see git -h for full list)

GREP:
  grep [INITIAL_QUERY]   Live ripgrep search with fzf

MAN:
  man [INITIAL_QUERY]    Fuzzy search man pages

EXAMPLES:
  fzf-tools preview file.sh
  fzf-tools git add
  fzf-tools grep "function"
  fzf-tools man ssh

DEPENDENCIES:
  Required: fzf or sk
  Optional: bat/batcat, ripgrep, git, gix, gh, delta
EOF
}

# ============================================================================
# PREVIEW COMMAND
# ============================================================================
cmd_preview(){
  cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/fzf"
  mkdir -p "$cache_dir" || :

  mime_of(){ file --mime-type -b -- "$1"; }
  ext_of(){ local b="${1##*/}"; b="${b##*.}"; printf '%s' "${b,,}"; }
  
  preview_text(){
    local file="$1" center="${2:-0}" ext
    ext="$(ext_of "$file")"
    case "$ext" in
      md) have glow && { glow --style=auto --width "$((${FZF_PREVIEW_COLUMNS:-80}-1))" -- "$file"; return; } ;;
      htm|html) have w3m && { w3m -T text/html -dump -- "$file"; return; } ;;
    esac
    local b=$(batcmd)
    if [[ $b == "cat" ]]; then
      sed -n '1,400p' -- "$file"
    else
      "$b" --style="${BAT_STYLE:-numbers}" --color=always --pager=never --highlight-line="${center:-0}" -- "$file"
    fi
  }

  preview_file(){
    local loc="$1" center="${2:-0}" mime
    mime="$(mime_of "$loc" || printf '')"
    case "$mime" in
      text/*) preview_text "$loc" "$center" ;;
      application/json) have jq && "$(batcmd)" -p --color=always -- "$loc" | jq .  || preview_text "$loc" "$center" ;;
      inode/directory) have eza && eza -T -L 2 -- "$loc" || find -- "$loc" -maxdepth 2 -printf '%y %p\n' ;;
      *) file --brief --dereference -- "$loc" ;;
    esac
  }

  parse_arg(){
    local in="$1" file="$1" center=0
    if [[ !  -r $file ]]; then
      if [[ $file =~ ^(. +):([0-9]+)\ *$ ]] && [[ -r ${BASH_REMATCH[1]} ]]; then
        file="${BASH_REMATCH[1]}"
        center="${BASH_REMATCH[2]}"
      fi
    fi
    printf '%s\n%s\n' "${file/#\~\//$HOME/}" "$center"
  }

  [[ $# -ge 1 ]] || { printf 'usage: fzf-tools preview PATH[:LINE]\n'; return 1; }
  local file center
  read -r file center < <(parse_arg "$1")
  [[ -r $file ]] || { printf 'not readable: %s\n' "$file" >&2; return 2; }
  preview_file "$file" "$center"
}

# ============================================================================
# GIT COMMAND
# ============================================================================
cmd_git(){
  for g in gix git; do have "$g" && GIT="$g" && break; done
  [[ -z ${GIT:-} ]] && die "No git/gix found"

  _git(){ "$GIT" "$@"; }
  _check_repo(){ _git rev-parse --git-dir &>/dev/null || die "Not a git repository"; }
  _pager(){ have delta && printf 'delta --paging=never' || have bat && printf 'bat --style=plain --color=always --paging=never' || printf 'less -R'; }
  _extract_hash(){ grep -Eo '[a-f0-9]{7,40}' | head -1; }

  _fzf_git(){
    local -a opts=(--ansi --cycle --reverse --bind='? :toggle-preview' --bind='alt-w:toggle-preview-wrap')
    [[ ${FZF} == sk ]] && opts+=(--no-hscroll) || opts+=(--no-scrollbar)
    "$FZF" "${opts[@]}" "$@"
  }

  git_add(){
    _check_repo
    local pager=$(_pager)
    local files
    files=$(_git diff --name-only --diff-filter=ACDMRTUXB "$@" | _fzf_git -m \
      --header='Tab:select Enter:add' \
      --preview="git diff --color=always {} | ${pager}")
    [[ -z ${files} ]] && return 0
    _git add $(xargs <<< "$files")
  }

  git_log(){
    _check_repo
    local pager=$(_pager)
    local format='%C(auto)%h%d %s %C(black)%C(bold)%cr%Creset'
    _git log --color=always --graph --format="$format" "$@" | _fzf_git \
      --header='Enter:show Ctrl-Y:copy-hash' \
      --preview="git show --color=always {1} | ${pager}"
  }

  git_status(){
    _check_repo
    local pager=$(_pager)
    _git status --short --untracked-files=all | _fzf_git -m \
      --header='Tab:select Enter:add' \
      --preview="git diff --color=always {2} | ${pager}"
  }

  git_branch(){
    _check_repo
    local branch
    branch=$(_git branch --all --color=always --sort=-committerdate "$@" | grep -v HEAD | _fzf_git \
      --header='Enter:checkout' \
      --preview='git log --oneline --graph --color=always {1}' \
      | sed 's/^[* ]*//' | awk '{print $1}')
    [[ -z ${branch} ]] && return 0
    _git checkout "${branch#remotes/origin/}"
  }

  git_stash(){
    _check_repo
    local pager=$(_pager)
    local stash
    stash=$(_git stash list | _fzf_git \
      --header='Enter:apply' \
      --preview="git stash show -p {1} | ${pager}" | cut -d: -f1)
    [[ -z ${stash} ]] && return 0
    _git stash apply "$stash"
  }

  local subcmd="${1:-}"
  shift || :
  case "$subcmd" in
    add|a) git_add "$@" ;;
    log|l) git_log "$@" ;;
    status|s|st) git_status "$@" ;;
    branch|b) git_branch "$@" ;;
    stash) git_stash "$@" ;;
    -h|--help|help) printf 'fzf-tools git: add log status branch stash\n' ;;
    *) die "Unknown git command: $subcmd" ;;
  esac
}

# ============================================================================
# GREP COMMAND
# ============================================================================
cmd_grep(){
  have rg || die "ripgrep required"
  local PREVIEW='bat --style=full --color=always --highlight-line {2} {1} 2>/dev/null || cat {1}'
  local RELOAD='reload:rg --vimgrep --color=always --smart-case {q} || :'
  local OPEN='if [ "$FZF_SELECT_COUNT" -eq 0 ]; then "${EDITOR:-vim}" "+call cursor({2},{3})" {1}; else "${EDITOR:-vim}" +cw -q {+f}; fi'

  "$FZF" \
    --disabled -m --delimiter=":" --ansi \
    --bind "start:$RELOAD" --bind "change:$RELOAD" \
    --bind "enter:become:$OPEN" \
    --bind 'ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-preview' \
    --preview="$PREVIEW" --preview-label="[file preview]" \
    --with-nth="1,4" \
    --query="$*"
}

# ============================================================================
# MAN COMMAND
# ============================================================================
cmd_man(){
  local PREVIEW='man {1}'
  man -k .  | "$FZF" \
    --prompt='manual: ' \
    --header='enter:open' \
    --delimiter=' ' \
    --with-nth='1,2' \
    --preview="$PREVIEW" \
    --bind="enter:become:$PREVIEW"
}

# ============================================================================
# MAIN ROUTER
# ============================================================================
main(){
  local cmd="${1:-}"
  shift || :
  case "$cmd" in
    preview|prev|p) cmd_preview "$@" ;;
    git|g) cmd_git "$@" ;;
    grep|rg) cmd_grep "$@" ;;
    man|m) cmd_man "$@" ;;
    -h|--help|help|"") usage ;;
    *) die "Unknown command: $cmd" ;;
  esac
}

main "$@"

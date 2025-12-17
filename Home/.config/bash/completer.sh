#!/usr/bin/env bash
[[ $- != *i* ]] && return
#=============================== [Completions] ================================
# Lazy-load completion function
load_completion(){
  local name="$1" cmd="$2" kind="$3" src="$4"
  has "$cmd" || return
  declare -F "$name" &>/dev/null && return
  case "$kind" in
    eval) eval "$src" &>/dev/null ;;
    source | .) [[ -r ${src/#\~\//${HOME}/} ]] && . "${src/#\~\//${HOME}/}" &>/dev/null ;;
    *) return 1 ;;
  esac
}
# --- System Completions
load_completion _git git source /usr/share/bash-completion/completions/git
# --- Tool Completions
if has gh; then
  load_completion _gh gh eval "$(gh completion -s bash)"
fi
if has rustup; then
  load_completion _rustup rustup eval "$(rustup completions bash rustup)"
  load_completion _cargo cargo eval "$(rustup completions bash cargo)"
fi
# --- Editor FZF Completion
if has fzf; then
  _editor_completion(){
    bind '"\e[0n": redraw-current-line' &>/dev/null
    local selected
    if selected=$(compgen -f -- "${COMP_WORDS[COMP_CWORD]}" | fzf --prompt='❯ ' \
      --height=~100% --tiebreak=begin,index -1 -0 --exact \
      --layout=reverse-list --bind=tab:down,btab:up --cycle); then
      [[ -d $selected ]] && selected="${selected}/" || selected="${selected} "
      COMPREPLY=("$selected")
    fi
    printf '\e[5n'
  }
  # Register editor commands
  for _cmd in "${EDITOR:-}" nano micro vi vim nvim code; do
    has "$_cmd" && complete -o nospace -F _editor_completion "$_cmd"
  done
  unset _cmd
fi
# --- Custom Completions
# Add your custom completions below
# Example:
# has kubectl && load_completion _kubectl kubectl eval "$(kubectl completion bash)"
# has docker && load_completion _docker docker source /usr/share/bash-completion/completions/docker

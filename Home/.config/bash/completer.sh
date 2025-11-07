#!/usr/bin/bash
# Completion loader - lazy-load system/tool completions

has(){ command -v "$1" &>/dev/null; }

load_completion(){
  local name=$1 cmd=$2 kind=$3 src=$4
  has "$cmd" || return
  declare -F "$name" &>/dev/null && return
  case $kind in
    eval) eval "$src" ;;
    source) [[ -r ${src/#\~\//${HOME}/} ]] && . "${src/#\~\//${HOME}/}" &>/dev/null ;;
  esac
}

# System completions - extend below
load_completion _git git source /usr/share/bash-completion/completions/git
# Tool completions - add your own
has gh && load_completion _gh gh eval "$(gh completion -s bash)"
has rustup && {
  load_completion _rustup rustup eval "$(rustup completions bash rustup)"
  load_completion _cargo cargo eval "$(rustup completions bash cargo)"
}

# Editor completions - specialized fullscreen picker
_editor_completion(){
  bind '"\e[0n": redraw-current-line' 2>/dev/null
  local selected
  if selected=$(compgen -f -- "${COMP_WORDS[COMP_CWORD]}" | fzf \
    --prompt='❯ ' --height=~100% \
    --tiebreak=begin,index \
    -1 -0--exact --layout=reverse \
    --bind=tab:down,btab:up --cycle); then
    [[ -d $selected ]] && selected="${selected}/" || selected="${selected} "
    COMPREPLY=( "$selected" )
  fi
  printf '\e[5n'
}

# Register editors - extend array as needed
declare -a EDITOR_CMDS=( "${EDITOR:-}" nano micro vi vim code)
for _cmd in "${EDITOR_CMDS[@]}"; do
  has "$_cmd" && complete -o nospace -F _editor_completion "$_cmd"
done
unset _cmd

# Custom completions - add below
# Example:
# has kubectl && load_completion _kubectl kubectl source <(kubectl completion bash)
# has docker && load_completion _docker docker source /usr/share/bash-completion/completions/docker

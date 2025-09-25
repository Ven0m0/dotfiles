# ╭─────────────────╮
# │ Tab Completions │
# ╰─────────────────╯
# FZF-powered file completion for editors
# https://github.com/CodesOfRishi/dotfiles

editor_completion(){
  bind '"\e[0n": redraw-current-line' 2>/dev/null
  local selected
  if selected="$(compgen -f -- "${COMP_WORDS[COMP_CWORD]}" | command fzf \
    --prompt='❯ ' \
    --height=~100% \
    --tiebreak=begin,index \
    --select-1 \
    --exit-0 \
    --exact \
    --layout=reverse \
    --bind=tab:down,btab:up \
    --cycle)"; then
    # Append slash if directory, space if file
    if [ -d "$selected" ]; then
      selected="${selected}/"
    else
      selected="${selected} "
    fi
    COMPREPLY=( "$selected" )
  fi
  printf '\e[5n'
}

# Helper: register completion if command exists
register_editor_completion() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || continue
    complete -o nospace -F editor_completion "$cmd"
  done
}

# Register for common editors
register_editor_completion "$EDITOR" nano micro mi

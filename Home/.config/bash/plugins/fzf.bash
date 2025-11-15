#=================================== [FZF] ====================================
if ! has fzf; then
  return 0
fi

# --- FZF Configuration
has fd && export FZF_DEFAULT_COMMAND='fd -tf -HI -S +10k --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Base options for all FZF instances
FZF_BASE_OPTS='--height=~90% --layout=reverse-list --border --cycle'
FZF_BASE_OPTS+=' --preview-window=wrap --inline-info -0 -1 --marker=*'
export FZF_DEFAULT_OPTS="$FZF_BASE_OPTS"

# Ctrl-T: File selection with preview
if has bat; then
  export FZF_CTRL_T_OPTS="$FZF_BASE_OPTS --preview 'bat -p --color=always -r :250 {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
fi

# Ctrl-R: Command history search
export FZF_CTRL_R_OPTS="$FZF_BASE_OPTS --preview 'echo {}' --preview-window=down:3:wrap --bind '?:toggle-preview'"

# Alt-C: Directory navigation with tree preview
if has eza; then
  export FZF_ALT_C_OPTS="$FZF_BASE_OPTS --walker-skip='.git,node_modules' --preview 'eza -T {}'"
elif has tree; then
  export FZF_ALT_C_OPTS="$FZF_BASE_OPTS --walker-skip='.git,node_modules' --preview 'tree -C {} | head -200'"
fi

# Source key bindings and completion
ifsource /usr/share/fzf/key-bindings.bash
ifsource /usr/share/fzf/completion.bash

unset FZF_BASE_OPTS

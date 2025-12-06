#=================================== [FZF] ====================================
has fzf || return

# --- FZF Configuration
has fd && export FZF_DEFAULT_COMMAND='fd -tf -HI -S +10k --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Base options for all FZF instances
export FZF_DEFAULT_OPTS='--height=~90% --layout=reverse-list --border --cycle --preview-window=wrap --inline-info -0 -1 --marker=*'
# Ctrl-T: File selection with preview
has bat && export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS --preview 'bat -p --color=always -r :250 {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
# Ctrl-R: Command history search
export FZF_CTRL_R_OPTS="$FZF_DEFAULT_OPTS --preview 'echo {}' --preview-window=down:3:wrap --bind '?:toggle-preview'"
# Alt-C: Directory navigation with tree preview
if has eza; then
  export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS --walker-skip='.git,node_modules' --preview 'eza -T {}'"
elif has tree; then
  export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS --walker-skip='.git,node_modules' --preview 'tree -C {} | head -200'"
fi
# Source key bindings and completion
ifsource /usr/share/fzf/key-bindings.bash
ifsource /usr/share/fzf/completion.bash
# --- RGA integration
if has rga && has fzf; then
  rga-fzf() {
    RG_PREFIX="rga --files-with-matches"
    local file="$(
      FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
        LC_ALL=C fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
        --phony -q "$1" --bind "change:reload:$RG_PREFIX {q}" --preview-window="70%:wrap"
    )" && echo "opening $file" && xdg-open "$file"
  }
fi

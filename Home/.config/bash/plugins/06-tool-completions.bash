#!/usr/bin/env bash
#=========================== [Tool Completions] ===============================

# --- Cheat
has cheat && has fzf && export CHEAT_USE_FZF=true

# --- fclones
has fclones && eval "$(fclones complete bash 2>/dev/null)" &>/dev/null

# --- vx
if has vx; then
  eval "$(vx shell completions bash --use-system-path 2>/dev/null)" || :
  eval "$(vx shell init bash --use-system-path 2>/dev/null)" || :
fi

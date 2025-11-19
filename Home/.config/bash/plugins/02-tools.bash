#!/usr/bin/env bash
#======================== [Shell Enhancement Tools] ===========================

# --- Zoxide (smart cd)
if has zoxide; then
  export _ZO_EXCLUDE_DIRS="$HOME" _ZO_FZF_OPTS='--cycle --inline-info --no-multi'
  eval "$(zoxide init --cmd cd bash)" || :
fi

# --- Zellij (terminal multiplexer)
if has zellij; then
  eval "$(zellij setup --generate-auto-start bash 2>/dev/null)" || :
  ifsource "$HOME/.config/bash/completions/zellij.bash"
fi

# --- Command correction/enhancement
has thefuck && eval "$(thefuck --alias)" || :
has pay-respects && eval "$(pay-respects bash)" || :
has ast-grep && eval "$(ast-grep completions bash)" || :

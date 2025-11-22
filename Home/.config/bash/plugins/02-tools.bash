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

if has yazi; then
  y(){ local cwd tmp_file="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp_file"
    if IFS= read -r -d '' cwd < "$tmp_file" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
      cd "$cwd" || return 1
    fi; rm -f "$tmp_file"
  }
fi

# --- Command correction/enhancement
has thefuck && eval "$(thefuck --alias)" || :
has pay-respects && eval "$(pay-respects bash)" || :
has ast-grep && eval "$(ast-grep completions bash)" || :

alias startintent="adb devices | tail -n +2 | cut -sf 1 | xargs -I X adb -s X shell am start $1"
alias apkinstall="adb devices | tail -n +2 | cut -sf 1 | xargs -I X adb -s X install -r $1"
alias rmapp="adb devices | tail -n +2 | cut -sf 1 | xargs -I X adb -s X uninstall $1"
alias clearapp="adb devices | tail -n +2 | cut -sf 1 | xargs -I X adb -s X shell pm clear $1"

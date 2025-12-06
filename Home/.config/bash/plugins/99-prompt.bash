#!/usr/bin/env bash
#================================= [Prompt] ===================================

# Configure prompt (starship or fallback)
if has starship; then
  export STARSHIP_LOG=error
  eval "$(starship init bash 2>/dev/null)" || :
else
  # Fallback prompt with exit status
  c_red='\[\e[31m\]' c_grn='\[\e[32m\]' c_blu='\[\e[34m\]'
  c_cyn='\[\e[36m\]' c_def='\[\e[0m\]'
  uc="$c_blu"
  [[ $EUID -eq 0 ]] && uc="$c_red"
  exit_status='$(ret=$?; (( ret == 0 )) && printf "%s:)" "$c_grn" || printf "%s%d" "$c_red" "$ret")'
  PS1="[$uc\u@\h$c_def:$c_cyn\w$c_def] $exit_status$c_def > "
  PS2="> "
fi

# === [Prompt] ===
configure_prompt(){
  has starship && { eval "$(starship init bash)"; return; }
  local c_red='\[\e[31m\]' c_grn='\[\e[32m\]' c_blu='\[\e[34m\]' c_cyn='\[\e[36m\]' c_def='\[\e[0m\]'
  local uc="$c_blu"; [[ $EUID -eq 0 ]] && uc="$c_red"
  local exit_status='$(ret=$?; if (( ret == 0 )); then printf "%s:)" "$c_grn"; else printf "%s%d" "$c_red" "$ret"; fi)'
  PS1="[$uc\u@\h$c_def:$c_cyn\w$c_def] $exit_status$c_def > "; PS2="> "
}
configure_prompt &>/dev/null
# === Fetch ===
if [[ $SHLVL -eq 1 && -z $DISPLAY ]]; then
  if has hyfetch; then
    hyfetch 2>/dev/null
  elif has fastfetch; then
    fastfetch 2>/dev/null
  fi
fi
unset -f configure_prompt

pip(){ 
  if command uv &>/dev/null && [[ "install uninstall list show freeze check" =~ "$1" ]]; then
    uv pip "$@"
  else 
    command python -m pip "$@"
  fi
}

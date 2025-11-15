# Use uv for pip operations when available
pip() {
  if command -v uv &>/dev/null && [[ " install uninstall list show freeze check " =~ " $1 " ]]; then
    uv pip "$@"
  else
    command python -m pip "$@"
  fi
}

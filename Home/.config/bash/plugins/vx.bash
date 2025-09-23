if command -v vx &>/dev/null; then
  eval "$(vx shell completions bash --use-system-path)"
  eval "$(vx shell init bash --use-system-path)"
fi

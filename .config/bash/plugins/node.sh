if command -v bun &>/dev/null; then
  alias npx=bunx npm=bun
  if [[ -n "$BUN_INSTALL" ]]; then
    export BUN_INSTALL "$HOME/.bun"
    prependpath "$BUN_INSTALL/bin"
fi
export NODE_OPTIONS="--no-warnings --max-old-space-size=4096"

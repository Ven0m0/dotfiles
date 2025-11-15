if command -v bun &>/dev/null; then
  alias npx=bunx
fi

export NODE_OPTIONS="--no-warnings --max-old-space-size=4096"

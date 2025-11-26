#!/usr/bin/env bash
#========================== [Language Runtimes] ===============================

# --- Multi-language Manager
if has mise; then
  # Ensure command hashing is off for mise
  set +h
  eval "$(mise activate -yq bash)" || :
  alias mx="mise x --"
fi

# --- Rust/Cargo
if has cargo || has rustup; then
  exportif RUSTUP_HOME "$HOME/.rustup"
  exportif CARGO_HOME "$HOME/.cargo"
  ifsource "${CARGO_HOME:-$HOME/.cargo}/env"
  prependpath "${CARGO_HOME:-$HOME/.cargo}/bin"
  export CARGO_HTTP_MULTIPLEXING=true CARGO_NET_GIT_FETCH_WITH_CLI=true
  export RUST_LOG=off BINSTALL_DISABLE_TELEMETRY=1 FIGNORE=Cargo.lock
  has sccache && export RUSTC_WRAPPER=sccache
fi

# --- Go
has go && export GOOS=linux GOARCH=amd64 GOFLAGS="-ldflags=-s -w -trimpath -modcacherw -gcflags=all=-c=4 -buildvcs=false" CGO_ENABLED=1

# --- Python
export PYTHONOPTIMIZE=2 PYTHONIOENCODING='UTF-8' PYTHON_JIT=1
export PYTHON_DISABLE_REMOTE_DEBUG=1 PYTORCH_ENABLE_MPS_FALLBACK=1
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# Use uv for pip operations when available
pip(){
  if has uv && [[ "install uninstall list show freeze check" =~ "$1" ]]; then
    command uv pip "$@"
  else
    command python -m pip "$@"
  fi
}

# --- Node/Bun
if has bun; then
  alias npx=bunx npm=bun
  [[ -z "$BUN_INSTALL" ]] && export BUN_INSTALL="$HOME/.bun"
  prependpath "$BUN_INSTALL/bin"
fi
export NODE_OPTIONS="--no-warnings --max-old-space-size=4096"

# --- SDKMAN (Java/JVM)
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
ifsource "${SDKMAN_DIR}/bin/sdkman-init.sh"

# AppImages
export URUNTIME_PRELOAD=1
# https://github.com/pkgforge-dev/Citron-AppImage/issues/50
export QT_QPA_PLATFORM=xcb

#!/usr/bin/env bash
#========================== [Language Runtimes] ===============================

# --- Multi-language Manager (Mise)
if has mise; then
  set +h
  # Cache mise activation to improve startup time
  MISE_CACHE="${BASH_CACHE_DIR}/mise_init.bash"
  if [[ ! -f $MISE_CACHE || $(which mise) -nt $MISE_CACHE ]]; then
    mise activate bash > "$MISE_CACHE"
  fi
  source "$MISE_CACHE"
  alias mx="mise x --"
fi

# --- Rust/Cargo
if has cargo || has rustup; then
  exportif RUSTUP_HOME "$HOME/.rustup"
  exportif CARGO_HOME "$HOME/.cargo"
  ifsource "${CARGO_HOME:-$HOME/.cargo}/env"
  prependpath "${CARGO_HOME:-$HOME/.cargo}/bin"
  export CARGO_HTTP_MULTIPLEXING=true CARGO_NET_GIT_FETCH_WITH_CLI=true RUST_LOG=off BINSTALL_DISABLE_TELEMETRY=1 FIGNORE=Cargo.lock
  has sccache && export RUSTC_WRAPPER=sccache
fi

# --- Go
has go && export GOOS=linux GOARCH=amd64 GOFLAGS="-ldflags=-s -w -trimpath -modcacherw -gcflags=all=-c=4 -buildvcs=false" CGO_ENABLED=1

# --- Python
export PYTHONOPTIMIZE=2 PYTHONIOENCODING='UTF-8' PYTHON_JIT=1
export PYTHON_DISABLE_REMOTE_DEBUG=1 PYTORCH_ENABLE_MPS_FALLBACK=1 PYENV_VIRTUALENV_DISABLE_PROMPT=1

# Use uv for pip operations when available
pip() {
  if has uv && [[ "install uninstall list show freeze check" =~ $1 ]]; then
    command uv pip "$@"
  else
    command python -m pip "$@"
  fi
}
# Create and activate Python virtual environment using uv
alias py-venv="[ -d .venv ] || uv venv .venv && source .venv/bin/activate"
alias py-server='python3 -m SimpleHTTPServer 8000'
# --- Node/Bun
if has bun; then
  alias npx=bunx npm=bun
  [[ -z $BUN_INSTALL ]] && export BUN_INSTALL="$HOME/.bun"
  prependpath "$BUN_INSTALL/bin"
  export ELECTRON_IS_DEV=0 ELECTRON_DISABLE_SECURITY_WARNINGS=true NODE_ENV=production
fi
export NODE_OPTIONS="--no-warnings --max-old-space-size=4096"

# --- SDKMAN (Java/JVM)
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
ifsource "${SDKMAN_DIR}/bin/sdkman-init.sh"
export JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(which java)")")")" && prependpath "${JAVA_HOME}/bin"

# AppImages | https://github.com/pkgforge-dev/Citron-AppImage/issues/50
export URUNTIME_PRELOAD=1 QT_QPA_PLATFORM=xcb

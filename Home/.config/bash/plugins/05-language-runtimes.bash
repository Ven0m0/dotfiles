#!/usr/bin/env bash
#========================== [Language Runtimes] ===============================

# --- Multi-language Manager (Mise)
if has mise; then
  set +h
  # Cache mise activation to improve startup time
  MISE_CACHE="${BASH_CACHE_DIR}/mise_init.bash"
  if [[ ! -f $MISE_CACHE || $(which mise) -nt $MISE_CACHE ]]; then
    mise activate bash >"$MISE_CACHE"
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
if has uv; then
  alias py-venv="[[ -d .venv ]] || uv venv .venv && . .venv/bin/activate"
else
  alias py-venv="[[ -d .venv ]] || python3 -m venv && . .venv/bin/activate"
fi
alias py-server='python3 -m SimpleHTTPServer 8000'
alias pdb="python3 -m pdb"
alias serve="python3 -m http.server"
# Script to format JSON files using Python JSON Tool
_pj() {
  [[ -z $1 ]] && {
    printf "%s\n" "No file path"
    return
  }
  if [[ $1 == "." ]]; then
    for json_file_path in $(find . -name *.json); do
      pretty_json=$(python3 -m json.tool "$json_file_path") && echo "$pretty_json" >"$json_file_path"
    done
  else
    pretty_json=$(python3 -m json.tool "$1") && echo "$pretty_json" >"$1"
  fi
}
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
# Only compute JAVA_HOME if java exists and JAVA_HOME not already set
if [[ -z ${JAVA_HOME:-} ]] && has java; then
  JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
  export JAVA_HOME
  prependpath "${JAVA_HOME}/bin"
fi

# AppImages | https://github.com/pkgforge-dev/Citron-AppImage/issues/50
export URUNTIME_PRELOAD=1 QT_QPA_PLATFORM=xcb

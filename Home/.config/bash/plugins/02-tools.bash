#============================== [Tooling Init] ================================
# --- Language & Runtimes
if has mise; then
  eval "$(mise activate -yq bash)" || :
  alias mx="mise x --"
fi

ifsource "$HOME/.sdkman/bin/sdkman-init.sh"

if has cargo || has rustup; then
  exportif RUSTUP_HOME "$HOME/.rustup"
  exportif CARGO_HOME "$HOME/.cargo"
  ifsource "${CARGO_HOME:-$HOME/.cargo}/env"
  prependpath "${CARGO_HOME:-$HOME/.cargo}/bin"
  export CARGO_HTTP_MULTIPLEXING=true CARGO_NET_GIT_FETCH_WITH_CLI=true
  export RUST_LOG=off BINSTALL_DISABLE_TELEMETRY=1
fi

has sccache && export RUSTC_WRAPPER=sccache
has go && export GOOS=linux GOARCH=amd64 GOFLAGS="-ldflags=-s -w -trimpath -modcacherw"

# --- Shell Enhancement Tools
if has gh; then
  eval "$(gh completion -s bash 2>/dev/null)" || :
fi

if has zoxide; then
  export _ZO_EXCLUDE_DIRS="$HOME" _ZO_FZF_OPTS='--cycle --inline-info --no-multi'
  eval "$(zoxide init --cmd cd bash)" || :
fi

if has zellij; then
  eval "$(zellij setup --generate-auto-start bash 2>/dev/null)" || :
  ifsource "$HOME/.config/bash/completions/zellij.bash"
fi

has thefuck && eval "$(thefuck --alias)"
has pay-respects && eval "$(pay-respects bash)"
has ast-grep && eval "$(ast-grep completions bash)"

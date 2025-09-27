# Rust
if command -v cargo &>/dev/null; then
  export CARGO_HOME="${HOME}/.cargo" RUSTUP_HOME="${HOME}/.rustup"
  export CARGO_HTTP_MULTIPLEXING=true CARGO_NET_GIT_FETCH_WITH_CLI=true
  export CARGO_HTTP_SSL_VERSION=tlsv1.3 CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
fi

export FIGNORE=argo.lock
export RUST_LOG=off

if [ -e "$HOME/.cargo/bin" ]; then
  PATH="${HOME}/.cargo/bin:${PATH}"
fi


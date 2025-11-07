#============================== [Tooling Init] ================================
# --- Language & Runtimes
has mise && eval "$(mise activate -yq bash)"
ifsource "$HOME/.sdkman/bin/sdkman-init.sh"
has cargo && {
  exportif RUSTUP_HOME "$HOME/.rustup"
  exportif CARGO_HOME "$HOME/.cargo"
  ifsource "$CARGO_HOME/env"
  prependpath "$CARGO_HOME/bin"
}

# --- Shell Enhancement Tools
has gh && eval "$(gh completion -s bash)"
has zoxide && {
  export _ZO_EXCLUDE_DIRS="$HOME"
  eval "$(zoxide init --cmd cd bash)"
}
has zellij && eval "$(zellij setup --generate-auto-start bash)"
[[ "$TERM" == "xterm-ghostty" ]] && ifsource "${GHOSTTY_RESOURCES_DIR:-}/shell-integration/bash/ghostty.bash"

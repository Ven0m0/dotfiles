#============================== [Tooling Init] ================================
# --- Language & Runtimes
has mise && eval "$(mise activate -yq bash)"
ifsource "$HOME/.sdkman/bin/sdkman-init.sh"
if has cargo; then
  exportif RUSTUP_HOME "$HOME/.rustup"
  exportif CARGO_HOME "$HOME/.cargo"
  ifsource "$CARGO_HOME/env"
  prependpath "$CARGO_HOME/bin"
fi
has sccache && export RUSTC_WRAPPER=sccache

has go && export CGO_ENABLED=0 GOOS=linux GOARCH=amd64

export HOMEBREW_NO_ANALYTICS=true

export JAVA_OPTIONS="${JAVA_OPTIONS:-'-Dfile.encoding=UTF-8 -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true'}"

# --- Shell Enhancement Tools
has gh && eval "$(gh completion -s bash)"
has zoxide && {
  export _ZO_EXCLUDE_DIRS="$HOME"
  eval "$(zoxide init --cmd cd bash)"
}
has zellij && eval "$(zellij setup --generate-auto-start bash)"
[[ "$TERM" == "xterm-ghostty" ]] && ifsource "${GHOSTTY_RESOURCES_DIR:-}/shell-integration/bash/ghostty.bash"

has thefuck && eval "$(thefuck --alias)"
has pay-respects && eval "$(pay-respects bash)"

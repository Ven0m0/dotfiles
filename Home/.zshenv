# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
export ZDOTDIR="$HOME/.config/zsh"
export KEYTIMEOUT=1 SHELL_SESSIONS_DISABLE=1
skip_global_compinit=1
setopt no_global_rcs
export EDITOR="${EDITOR:-micro}"
export BROWSER="${BROWSER:-firefox}"
export FZF_DEFAULT_OPTS_FILE="${HOME}/.fzfrc"
export PYTHONDONTWRITEBYTECODE=1
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
typeset -U path
path=(
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    $path
)

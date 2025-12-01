# linking ~/.zshenv to $ZDOTDIR/.zshenv
#export ZDOTDIR="${${(%):-%x}:P:h}"
export ZDOTDIR="$HOME/.config/zsh"
export KEYTIMEOUT=1 SHELL_SESSIONS_DISABLE=1
skip_global_compinit=1
setopt no_global_rcs
export EDITOR="${EDITOR:-micro}"
export BROWSER="${BROWSER:-firefox}"
export FZF_DEFAULT_OPTS_FILE="${HOME}/.fzfrc"

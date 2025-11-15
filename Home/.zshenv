# linking ~/.zshenv to $ZDOTDIR/.zshenv
ZDOTDIR="${${(%):-%x}:P:h}"
export KEYTIMEOUT=1 SHELL_SESSIONS_DISABLE=1
skip_global_compinit=1
setopt no_global_rcs

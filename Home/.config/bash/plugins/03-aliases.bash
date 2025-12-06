#================================= [Aliases] ==================================
# Keep aliases enabled after sudo
alias sudo='sudo ' sudo-rs='sudo-rs ' doas='doas '

# Editor shortcuts
alias e="$EDITOR" se="sudo $EDITOR"

# Quick navigation
alias c='clear' q='exit'
alias ..='cd ..' ...='cd ../..' ....='cd ../../..'
alias bd='cd "$OLDPWD"'

# File operations with safety
alias cp='cp -iv --strip-trailing-slashes'
alias mv='mv -iv --strip-trailing-slashes'
alias rm='rm -Iv --preserve-root'
alias grep='grep --color=auto'

# SSH with proper terminal settings
alias ssh='TERM=xterm-256color LC_ALL=C.UTF-8 command ssh'

# Modern tool replacements
has wget2 && alias wget='wget2'
has btm && alias top='btm'
has duf && alias df='duf'
has dust && alias du='dust'
has procs && alias ps='procs'

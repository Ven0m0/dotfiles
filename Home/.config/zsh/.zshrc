#!/usr/bin/env zsh
# ~/.zshrc - Optimized Zsh configuration with Zinit plugin manager
# =========================================================
# EARLY INITIALIZATION - POWERLEVEL10K INSTANT PROMPT
# =========================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =========================================================
# CORE CONFIGURATION
# =========================================================

setopt EXTENDED_GLOB NULL_GLOB GLOB_DOTS
export LANG=C.UTF-8 LANGUAGE=C.UTF-8

# Skip if not interactive
[[ $- != *i* ]] && return

# =========================================================
# PLATFORM DETECTION
# =========================================================
# TERMUX and ANDROID variables should be set in .zshenv
if (( TERMUX )); then
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
  PREFIX="/data/data/com.termux/files/usr"
else
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
  PREFIX="/usr"
fi

# =========================================================
# ENVIRONMENT VARIABLES
# =========================================================
export SHELL=zsh
export EDITOR=micro VISUAL=micro
export PAGER='bat'
export TERM="xterm-256color" 
export CLICOLOR=1 MICRO_TRUECOLOR=1
export HISTCONTROL=ignoreboth
export HISTIGNORE="&:[bf]g:c:clear:history:exit:q:pwd:* --help"
export KEYTIMEOUT=1
export TZ='Europe/Berlin'
export TIME_STYLE='+%d-%m %H:%M'

# Less/Man colors
export LESS='-g -i -M -R -S -w -z-4'
export LESSHISTFILE=- LESSCHARSET=utf-8
export MANPAGER="sh -c 'col -bx | bat -lman -ps --squeeze-limit 0'" 
export MANROFFOPT="-c"

# FZF configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
export FZF_DEFAULT_COMMAND='fd -tf -gH -c always -strip-cwd-prefix -E ".git"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd -td -gH -c always"
export FZF_BASE=${PREFIX}/share/fzf

# =========================================================
# ZSH OPTIONS
# =========================================================

# History
setopt APPEND_HISTORY           # Append to history file
setopt EXTENDED_HISTORY         # Save timestamp and duration
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicates first
setopt HIST_FIND_NO_DUPS        # Don't show duplicates in search
setopt HIST_IGNORE_ALL_DUPS     # Remove older duplicate entries
setopt HIST_IGNORE_DUPS         # Don't record duplicates
setopt HIST_IGNORE_SPACE        # Don't record commands starting with space
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks
setopt HIST_SAVE_NO_DUPS        # Don't save duplicates
setopt HIST_VERIFY              # Don't execute immediately upon history expansion
setopt INC_APPEND_HISTORY       # Write to history file immediately
setopt SHARE_HISTORY            # Share history between sessions

# Directory navigation
setopt AUTO_CD                  # cd by typing directory name
setopt AUTO_PUSHD               # Push directories onto stack
setopt PUSHD_IGNORE_DUPS        # Don't push duplicates
setopt PUSHD_MINUS              # Exchange meaning of + and -
setopt PUSHD_SILENT             # Don't print directory stack
setopt PUSHD_TO_HOME            # Push to home if no arguments

# Completion
setopt ALWAYS_TO_END            # Move cursor to end after completion
setopt AUTO_LIST                # List choices on ambiguous completion
setopt AUTO_MENU                # Show completion menu on tab
setopt AUTO_PARAM_SLASH         # Add slash after completing directories
setopt COMPLETE_IN_WORD         # Complete from both ends of word
setopt LIST_PACKED              # Compact completion lists
setopt NO_BEEP                  # Don't beep on errors
setopt NO_LIST_BEEP             # Don't beep on ambiguous completion

# Globbing
setopt EXTENDED_GLOB            # Extended globbing
setopt GLOB_DOTS                # Include dotfiles in globbing
setopt NUMERIC_GLOB_SORT        # Sort filenames numerically
setopt NO_CASE_GLOB             # Case insensitive globbing

# Job control
setopt AUTO_CONTINUE            # Automatically continue stopped jobs
setopt AUTO_RESUME              # Resume jobs on name match
setopt LONG_LIST_JOBS           # List jobs in long format
setopt NOTIFY                   # Report job status immediately

# I/O
setopt CORRECT                  # Command correction
setopt INTERACTIVE_COMMENTS     # Allow comments in interactive shell
setopt NO_CLOBBER               # Don't overwrite files with >
setopt RC_QUOTES                # Allow '' to represent '

# -------------------------------

# Directory navigation
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME
setopt PUSHD_MINUS CD_SILENT

# Globbing and completion
setopt EXTENDED_GLOB GLOB_DOTS NULL_GLOB GLOB_STAR_SHORT
setopt NUMERIC_GLOB_SORT HASH_EXECUTABLES_ONLY

# History
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS INC_APPEND_HISTORY EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS SHARE_HISTORY HIST_IGNORE_SPACE
setopt HIST_VERIFY HIST_EXPIRE_DUPS_FIRST HIST_FCNTL_LOCK

# Input/Output behavior
setopt INTERACTIVE_COMMENTS RC_QUOTES NO_BEEP NO_FLOW_CONTROL
setopt NO_CLOBBER AUTO_RESUME COMBINING_CHARS NO_MAIL_WARNING
setopt CORRECT CORRECT_ALL LONG_LIST_JOBS TRANSIENT_RPROMPT

# ============ Key Bindings ============

# Use emacs-style key bindings (can change to 'bindkey -v' for vi mode)
bindkey -e

# History search
bindkey '^[[A' history-substring-search-up    # Up arrow
bindkey '^[[B' history-substring-search-down  # Down arrow
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# Better word navigation
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^[[H' beginning-of-line    # Home
bindkey '^[[F' end-of-line          # End
bindkey '^[[3~' delete-char         # Delete

# Alt+Backspace to delete word
bindkey '^H' backward-kill-word

# Ctrl+U to delete to beginning of line
bindkey '^U' backward-kill-line

# =========================================================
# PATH CONFIGURATION
# =========================================================
# Ensure path arrays do not contain duplicates
typeset -gU cdpath fpath mailpath path

# Set the list of directories that Zsh searches for programs
if [[ ! -v prepath ]]; then
  typeset -ga prepath
  prepath=(
    $HOME/{,s}bin(N)
    $HOME/.local/{,s}bin(N)
  )
fi
path=(
  $prepath
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

# =========================================================
# HISTORY CONFIGURATION
# =========================================================
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
HISTTIMEFORMAT="%F %T "

# =========================================================
# ZINIT PLUGIN MANAGER SETUP
# =========================================================
# Install Zinit if it's not already installed
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# Load annexes
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# Fast loading essential plugins
zinit wait lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

# Load powerlevel10k theme
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Additional plugins
zinit wait lucid for \
  zsh-users/zsh-history-substring-search \
  hlissner/zsh-autopair \
  MichaelAquilina/zsh-you-should-use

# Load zoxide if available
zinit wait'0' lucid as'program' from'gh-r' for ajeetdsouza/zoxide

autoload -Uz colors && colors

# =========================================================
# COMPLETION SYSTEM CONFIGURATION
# =========================================================
autoload -Uz compinit

# Load completion only once a day for performance
if [[ -n "${ZSH_COMPDUMP}"(#qN.mh+24) ]]; then
  compinit -d "${ZSH_COMPDUMP}"
else
  compinit -C -d "${ZSH_COMPDUMP}"
fi

# Completion styles
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZSH_CACHE_DIR}/zcompcache"
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# Process completion
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# Process completion
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always

# SSH/SCP/RSYNC completion
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Ignore completion functions for commands you don't have
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Colorize completions using LS_COLORS
if (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid generate molokai)"
elif (( $+commands[dircolors] )); then
  eval "$(dircolors -b)" &>/dev/null
fi
LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# FZF tab completion if available
if (( $+commands[fzf] )); then
  if [[ -f ${PREFIX}/share/fzf-tab-completion/zsh/fzf-zsh-completion.sh ]]; then
    source ${PREFIX}/share/fzf-tab-completion/zsh/fzf-zsh-completion.sh
    bindkey '^I' fzf_completion
  fi
fi

# ============ Prompt Configuration ============
# Enable parameter expansion in prompts
setopt PROMPT_SUBST

# Git prompt function
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{green}●%f'
zstyle ':vcs_info:*' unstagedstr '%F{yellow}●%f'
zstyle ':vcs_info:git:*' formats ' %F{blue}(%f%F{red}%b%f%c%u%F{blue})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}(%f%F{red}%b%f|%F{cyan}%a%f%c%u%F{blue})%f'

precmd() { vcs_info; }

# Build prompt
PROMPT='%F{cyan}╭=%f'                           # Top corner
PROMPT+='%F{green}%n%f'                         # Username
PROMPT+='%F{white}@%f'                          # @
PROMPT+='%F{blue}%m%f'                          # Hostname
PROMPT+=' %F{yellow}%~%f'                       # Working directory
PROMPT+='${vcs_info_msg_0_}'                    # Git info
PROMPT+=$'\n'                                   # Newline
PROMPT+='%F{cyan}╰=%f'                          # Bottom corner
PROMPT+='%(?.%F{green}.%F{red})❯%f '           # Prompt symbol (green if success, red if error)

# Right prompt with time
RPROMPT='%F{242}%*%f'                           # Time

# =========================================================
# UTILITY FUNCTIONS
# =========================================================
# Check if command exists
has() { command -v -- "$1" >/dev/null 2>&1; }

# Create directory and cd into it
mkcd() {
  mkdir -p -- "$1" && cd -- "$1" || return
}

# Extract various archive formats
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2|*.tbz2) tar -xjf "$1" ;;
      *.tar.gz|*.tgz) tar -xzf "$1" ;;
      *.tar.xz|*.txz) tar -xJf "$1" ;;
      *.tar) tar -xf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.gz) gunzip "$1" ;;
      *.zip) unzip "$1" ;;
      *.rar) unrar x "$1" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "Unknown archive format: $1" ;;
    esac
  else
    echo "File does not exist: $1"
  fi
}

# Find and cd with fzf
fcd() {
  local dir
  dir=$(find "${1:-.}" -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf --preview 'eza --tree --color=always {}' ) &&
  cd "$dir" || return
}

# Search and edit file with fzf
fe() {
  local files
  files=($(fzf --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-micro} "${files[@]}"
}

# Help function using cheat.sh
h() { curl cheat.sh/${@:-cheat}; }

# Dot expansion for quick navigation upwards
dot-expansion() {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N dot-expansion

# List largest directories
dsort() {
  du -shx -- * | sort -rh | head -n "${1:-20}"
}
# Quick backup
bak() {
  cp -r "$1" "${1}.bak.$(date +%Y%m%d-%H%M%S)"
}

# Prepend sudo
prepend-sudo() {
  if [[ "$BUFFER" != su(do|)\ * ]]; then
    BUFFER="sudo $BUFFER"
    (( CURSOR += 5 ))
  fi
}
zle -N prepend-sudo

# Find and kill processes by name
pskill() {
  ps aux | grep "$1" | grep -v grep | awk '{print $2}' | xargs kill
}

# =========================================================
# ALIASES
# =========================================================

# Preferred tools
if command -v eza &>/dev/null; then
  alias ls='eza --group-directories-first --color=auto --icons=auto --no-git --smart-group'
  alias ll='eza -l --group-directories-first --icons --smart-group'
  alias la='eza -lA --group-directories-first --icons --smart-group'
  alias lt='eza -AT --level=2 --icons'
else
  alias ls='ls --color=auto --group-directories-first'
  alias ll='ls -ABhLgGo --color=auto --group-directories-first'
  alias la='ls -ABhLgGoC --color=auto --group-directories-first'
fi

if command -v bat &>/dev/null; then
  alias cat='bat -p'
fi

if command -v rg &>/dev/null; then
  alias grep='rg'
else
  alias grep='grep --color=auto'
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# General aliases
alias ls='eza --git --icons --classify --group-directories-first --time-style=long-iso --group --color-scale'
alias l='ls --git-ignore'
alias ll='eza --all --header --long --git --icons --classify --group-directories-first --group --color-scale'
alias llm='ll --sort=modified'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree'
alias tree='eza --tree'
alias grep='grep --color=auto'

alias pip='python -m pip'

# Python aliases
alias pip=pip3
alias python=python3

# Build aliases
alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
alias mkdir='mkdir -p'

# Suffix aliases
alias -s {css,gradle,html,js,json,md,patch,properties,txt,xml,yml}=$PAGER
alias -s gz='gzip -l'
alias -s {log,out}='tail -F'

# Misc aliases
alias e="$EDITOR"
alias r='bat -p'
alias which='command -v'
alias dirs='dirs -v'

# Global aliases for pipelines
alias -g -- -h='-h 2>&1 | bat -plhelp'
alias -g -- --help='--help 2>&1 | bat -plhelp'
alias -g L="| ${PAGER:-less}"
alias -g G="| rg -i"
alias -g NE="2>/dev/null"
alias -g NUL=">/dev/null 2>&1"

# =========================================================
# KEYBINDINGS
# =========================================================
bindkey -e  # Emacs mode

# Better history search with up/down arrows
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Navigation
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[Z' reverse-menu-complete    # Shift-Tab to go backward in menu

# Custom bindings
bindkey '\e\e' prepend-sudo  # Alt+Alt to prepend sudo
bindkey '^R' history-incremental-pattern-search-backward

# =========================================================
# TOOL INTEGRATIONS
# =========================================================
# Initialize Powerlevel10k theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Load history substring search if available
if [[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

# Load syntax highlighting if available (should be loaded last)
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Load autosuggestions if available
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

# Load zoxide if available
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# Load zellij if available 
(( $+commands[zellij] )) && eval "$(zellij setup --generate-auto-start zsh)"

# Load Intelli-shell if available
(( $+commands[intelli-shell] )) && eval "$(intelli-shell init zsh)"

# Load thefuck if available
if (( $+commands[thefuck] )); then
  local thefuck_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/thefuck"
  mkdir -p "${thefuck_cache:h}"
  [[ ! -f "$thefuck_cache" ]] && thefuck --alias > "$thefuck_cache"
  source "$thefuck_cache"
fi

# Load theshit if available
(( $+commands[theshit] )) && eval "$($HOME/.cargo/bin/theshit alias shit)"

# Load mise if available
[[ -f $HOME/.local/bin/mise ]] && eval "$($HOME/.local/bin/mise activate zsh)"

# Optional: Carapace completions
if (( $+commands[carapace] )); then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
fi

# =========================================================
# SYSTEM SPECIFIC CONFIGURATION 
# =========================================================
# Termux-specific settings
if (( TERMUX )); then
  # Load Termux API integration
  if has termux-clipboard-set; then
    copy_to_clipboard() { termux-clipboard-set < "$1"; }
  else
    copy_to_clipboard() { echo "Clipboard not available"; }
  fi
  
  # Add Termux-specific tools
  alias reload='termux-reload-settings'
  alias battery='termux-battery-status'
  alias clipboard='termux-clipboard-get'
  alias copy='termux-clipboard-set'
  alias share='termux-share'
  alias notify='termux-notification'

fi

# Display system information on login
if [[ -o INTERACTIVE && -t 2 ]]; then
  if (( $+commands[fastfetch] )); then
    fastfetch
  fi
fi >&2

# =========================================================
# FINAL OPTIMIZATIONS
# =========================================================
# Recompile zsh files for faster startup if needed
autoload -Uz zrecompile
for file in ~/.zshrc ~/.zshenv ~/.p10k.zsh; do
  if [[ -f "$file" && ( ! -f "${file}.zwc" || "$file" -nt "${file}.zwc" ) ]]; then
    zrecompile -pq "$file" &>/dev/null
  fi
done
unset file

# Clean and optimize environment
typeset -gU cdpath fpath mailpath path

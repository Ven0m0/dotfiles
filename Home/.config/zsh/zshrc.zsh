#!/usr/bin/env zsh
# ~/.zshrc - Optimized Zsh configuration with Zinit plugin manager

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# Skip if not interactive
[[ $- != *i* ]] && return

# =========================================================
# CORE CONFIGURATION
# =========================================================
setopt EXTENDED_GLOB NULL_GLOB GLOB_DOTS

# Export LC settings early for consistency
export LC_ALL=C.UTF-8 LANG=C.UTF-8 LANGUAGE=C.UTF-8

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

# =========================================================
# ZSH OPTIONS
# =========================================================
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
  /usr/local/{,s}bin(N)
  "$HOME/.{cargo,local}/bin"
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

# =========================================================
# COMPLETION SYSTEM CONFIGURATION
# =========================================================
# Fast compinit with caching
() {
  local zdump_loc="${XDG_CACHE_HOME:-$HOME/.cache}/.zcompdump"
  local skip=0
  
  # Only rebuild zcompdump once per day
  if [[ -f "$zdump_loc" ]]; then
    local now=$(date +%s)
    local mtime=$(stat -c %Y "$zdump_loc" 2>/dev/null || stat -f %m "$zdump_loc" 2>/dev/null)
    [[ -n "$mtime" ]] && (( now - mtime < 86400 )) && skip=1
  fi
  
  # Run compinit appropriately
  if (( skip )); then
    compinit -C -d "$zdump_loc"
  else
    compinit -d "$zdump_loc"
    # Background compilation
    { zcompile "$zdump_loc" } &!
  fi
}

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' squeeze-slashes false # explicit disable to allow /*/ expansion
zstyle ':completion:*' special-dirs true # force . and .. to show in cmp menu
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:match:*' original only

# Group matches and provide descriptions
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{red}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{purple}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{green} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{yellow}-- no matches found --%f'
zstyle ':completion:*' format ' %F{blue}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

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

stty stop undef # disable accidental ctrl s

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

extract(){
  [[ -f $1 ]] || { printf 'File not found: %s\n' "$1" >&2; return 1; }
  case "${1##*.}" in
    tar|tgz) tar -xf "$1" ;;
    tar.gz) tar -xzf "$1" ;;
    tar.bz2|tbz2) tar -xjf "$1" ;;
    tar.xz|txz) tar -xJf "$1" ;;
    zip) unzip -q "$1" ;;
    rar) unrar x "$1" ;;
    gz) gunzip "$1" ;;
    bz2) bunzip2 "$1" ;;
    7z) 7z x "$1" ;;
    *) printf 'Unsupported archive: %s\n' "$1" >&2; return 2 ;;
  esac
}

# Find and cd with fzf
fcd() {
  local dir
  if has fd; then
    dir=$(fd -t d . "${1:-.}" 2>/dev/null | fzf --preview 'eza --tree --color=always {}' --height=40%)
  else
    dir=$(find "${1:-.}" -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf --preview 'eza --tree --color=always {}' --height=40%)
  fi
  [[ -n $dir ]] && cd -- "$dir" || return
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
dot-expansion(){ if [[ $LBUFFER = *.. ]]; then LBUFFER+='/..'; else LBUFFER+='.'; fi; }
zle -N dot-expansion

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
# General aliases
alias ls='eza --git --icons --classify --group-directories-first --time-style=long-iso --group --color-scale'
alias ll='eza --all --header --long --git --icons --classify --group-directories-first --time-style=long-iso --group --color-scale'
alias llm='ll --sort=modified'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias tree='eza -T'
alias grep='grep --color=auto'

# Platform-specific aliases
alias open='xdg-open'
alias copy='wl-copy'
alias paste='wl-paste'

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
# End
# =========================================================
# Recompile zsh files for faster startup if needed
autoload -Uz zrecompile
for f in ~/.zshrc ~/.zshenv ~/.p10k.zsh; do
  [[ -f $f && ( ! -f ${f}.zwc || $f -nt ${f}.zwc ) ]] && zrecompile -pq "$f" &>/dev/null 
done; unset f

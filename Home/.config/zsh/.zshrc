#!/usr/bin/env zsh
[[ $- != *i* ]] && return
has(){ command -v -- "$1" &>/dev/null; }
ifsource(){ [[ -r $1 ]] && source "$1"; }
ifsource "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
export PS4='+%N:%i> '

# =================== CORE / ENV ===================
setopt EXTENDED_GLOB NULL_GLOB GLOB_DOTS no_global_rcs
skip_global_compinit=1
SHELL=zsh
export EDITOR=micro VISUAL=${VISUAL:-code}
export PAGER=bat GIT_PAGER=delta BAT_STYLE=auto BATDIFF_USE_DELTA=true BATPIPE=color
export LESSCHARSET='utf-8' LESSHISTFILE=- LESSQUIET=1
export TERM=xterm-256color CLICOLOR=1 MICRO_TRUECOLOR=1 KEYTIMEOUT=1
export TZ=Europe/Berlin TIME_STYLE='+%d-%m %H:%M'
export LC_ALL=C.UTF-8 LANG=C.UTF-8 LANGUAGE=C.UTF-8
WORDCHARS='*?_-[]~&;!#$%^(){}<>|'
export LESS='-g -i -M -R -S -w -z-4' LESSHISTFILE=- LESSCHARSET=utf-8
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
export FZF_DEFAULT_COMMAND='fd -tf -gH -c always -strip-cwd-prefix -E ".git"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd -td -gH -c always'
export GPG_TTY=$TTY
if has mise; then eval "$(mise activate zsh)"; fi
alias mx="mise x --"
if has fzf; then eval "$(fzf --zsh)"; fi
if has zoxide; then eval "$(zoxide init zsh)"; fi
if has mise; then eval "$(mise activate zsh)"; fi

# =================== ZSH OPTIONS ===================
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME PUSHD_MINUS CD_SILENT path_dirs
setopt EXTENDED_GLOB GLOB_DOTS NULL_GLOB GLOB_STAR_SHORT NUMERIC_GLOB_SORT HASH_EXECUTABLES_ONLY
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS INC_APPEND_HISTORY EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS SHARE_HISTORY HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST HIST_FCNTL_LOCK
setopt INTERACTIVE_COMMENTS RC_QUOTES NO_BEEP NO_FLOW_CONTROL
setopt NO_CLOBBER AUTO_RESUME COMBINING_CHARS NO_MAIL_WARNING
setopt LONG_LIST_JOBS TRANSIENT_RPROMPT prompt_subst
setopt NOTIFY no_beep NO_hist_beep
setopt magic_equal_subst auto_resume
unsetopt menu_complete
setopt list_packed auto_list auto_menu auto_param_keys complete_in_word nonomatch
setopt short_loops long_list_jobs rm_star_wait
stty stop undef &>/dev/null || :

# =================== PATHS ===================
typeset -gaU cdpath fpath mailpath path prepath
if [[ ! -v prepath ]]; then
  typeset -ga prepath
  prepath=($HOME/{.local/,.}bin(N) $HOME/.cargo/bin)
fi
path=($prepath /usr/local/{,s}bin(N) "$HOME/.{cargo,local}/bin"(N) /usr/local/{s}bin /usr/{s}bin /{s}bin $path)
export PATH
cdpath=("$HOME" .. $HOME/*(N-/) $HOME/.config)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
export XDG_PROJECTS_DIR="${XDG_PROJECTS_DIR:-$HOME/Projects}"
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
export ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump"

# =================== HISTORY ===================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000 SAVEHIST=10000
HISTTIMEFORMAT="%F %T "

# =================== Antidote plugin manager ===================
antidote_dir=${XDG_DATA_HOME:-$HOME/.local/share}/antidote
[[ -d $antidote_dir ]] || git clone --depth 1 https://github.com/mattmc3/antidote "$antidote_dir" &>/dev/null || :
antidote_bin="$antidote_dir/bin/antidote"
bundle=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zsh_plugins.zsh
list=${XDG_CONFIG_HOME:-$HOME/.config}/zsh/config/plugins.txt
[[ -f $bundle && $list -ot $bundle ]] || "$antidote_bin" bundle <"$list" >"$bundle"
source "$bundle"

# Post-load plugin tunables
typeset -g ZSH_AUTOSUGGEST_STRATEGY=(history completion)
typeset -g ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
# OMZ ssh-agent plugin config
zstyle ':omz:plugins:ssh-agent' agent-forwarding yes
zstyle ':omz:plugins:ssh-agent' lazy yes
zstyle ':omz:plugins:ssh-agent' quiet yes
# fzf-tab keybinding (keep Tab for zsh-autocomplete if used)
(( $+functions[fzf_completion] )) && bindkey '^T' fzf_completion
# f-sy-h: disable buggy chromas
unset 'FAST_HIGHLIGHT[chroma-man]' 2>/dev/null || :
unset 'FAST_HIGHLIGHT[chroma-ssh]' 2>/dev/null || :

# =================== COMPLETION (fast + styled) ===================
autoload -Uz compinit
(){
  local zdump="${XDG_CACHE_HOME:-$HOME/.cache}/.zcompdump" now mtime skip=0
  if [[ -f $zdump ]]; then
    now=$(date +%s); mtime=$(stat -c %Y "$zdump" 2>/dev/null || stat -f %m "$zdump" 2>/dev/null)
    [[ -n $mtime && $((now - mtime)) -lt 86400 ]] && skip=1
  fi
  if (( skip )); then compinit -C -d "$zdump"; else compinit -d "$zdump"; { zcompile "$zdump" } &!; fi
}
# Styles
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:match:*' original only
zstyle ':completion:*' squeeze-slashes false special-dirs true
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{red}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{purple}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{green} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{yellow}-- no matches found --%f'
zstyle ':completion:*' format ' %F{blue}-- %d --%f'
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
# zsh-autocomplete tuning (optional)
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' insert-unambiguous yes
# fzf-tab previews
zstyle ':fzf-tab:complete:pacman:*' fzf-preview 'pacman -Si $word'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
# Colors for completion lists
if has vivid; then LS_COLORS="$(vivid generate molokai)"; elif has dircolors; then eval "$(dircolors -b)" &>/dev/null; fi
LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# =================== SSH AGENT ===================
if [[ -z "$SSH_AUTH_SOCK" ]] && has ssh-agent; then
  eval "$(ssh-agent -s -a "${XDG_RUNTIME_DIR}/ssh-agent.socket" 2>/dev/null)" >/dev/null
fi

# =================== PROMPT ===================
[[ -f $HOME/.p10k.zsh ]] && source "$HOME/.p10k.zsh"

# =================== FUNCTIONS ===================
mkcd(){ mkdir -p -- "$1" && cd -- "$1" || return; }
touchf(){ mkdir -p -- "${1:h}"; command touch -- "$1"; }
extract(){ local f=$1; [[ -f $f ]] || { print -r -- "File does not exist: $f" >&2; return 1; }
  case "$f" in
    *.tar.bz2|*.tbz2) tar -xjf "$f" ;;
    *.tar.gz|*.tgz) tar -xzf "$f" ;;
    *.tar.xz|*.txz) tar -xJf "$f" ;;
    *.tar) tar -xf "$f" ;;
    *.bz2) bunzip2 "$f" ;;
    *.gz)  gunzip "$f" ;;
    *.zip) unzip -q "$f" ;;
    *.rar) unrar x "$f" ;;
    *.Z)   uncompress "$f" ;;
    *.7z) 7z x "$f" ;;
    *) print -r -- "Unsupported archive: $f" >&2; return 2 ;;
  esac
}
fcd(){ local root="." q sel preview; [[ $# -gt 0 && -d $1 ]] && { root="$1"; shift; }; q="${*:-}"
  if has eza; then preview='eza -T -L2 --color=always {}'; else preview='ls -la --color=always {}'; fi
  if has fd; then sel="$(fd -HI -t d . "$root" 2>/dev/null | fzf --ansi --height ${FZF_HEIGHT:-60%} --layout=reverse --border --select-1 --exit-0 --preview "$preview" ${q:+--query "$q"})"
  else sel="$(find "$root" -type d -not -path '*/.git/*' -print 2>/dev/null | fzf --ansi --height ${FZF_HEIGHT:-60%} --layout=reverse --border --select-1 --exit-0 --preview "$preview" ${q:+--query "$q"})"; fi
  [[ -n $sel ]] && cd -- "$sel"
}
fe(){ local -a files; local q="${*:-}" preview; if has bat; then preview='bat -n --style=plain --color=always --line-range=:500 {}'; else preview='head -n 500 {}'; fi
  if has fzf; then files=("${(@f)$(fzf --multi --select-1 --exit-0 ${q:+--query="$q"} --preview "$preview")}"); else print -r -- "fzf not found" >&2; return 127; fi
  [[ ${#files} -gt 0 ]] && "${EDITOR:-micro}" "${files[@]}"
}
h(){ curl "cheat.sh/${@:-cheat}"; }

# =================== KEYBINDINGS ===================
bindkey -e
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[Z' reverse-menu-complete
bindkey '\e\e' prepend-sudo
bindkey '^Z' undo
bindkey '^Y' redo
zmodload zsh/complist
bindkey '^[[Z' reverse-menu-complete
bindkey -M menuselect '^[[Z' reverse-menu-complete
dot-expansion(){ if [[ $LBUFFER = *.. ]]; then LBUFFER+='/..'; else LBUFFER+='.'; fi; }
zle -N dot-expansion
prepend-sudo(){ if [[ $BUFFER != su(do|)\ * ]]; then BUFFER="sudo $BUFFER"; (( CURSOR += 5 )); fi; }
zle -N prepend-sudo
qc-word-widgets(){ local wordpat='[[:WORD:]]##|[[:space:]]##|[^[:WORD:][:space:]]##' words=(${(Z:n:)BUFFER}) lwords=(${(Z:n:)LBUFFER}); case $WIDGET {
  (*sub-l)   local move=-${(N)LBUFFER%%$~wordpat} ;;
  (*sub-r)   local move=+${(N)RBUFFER##$~wordpat} ;;
  (*shell-l) local move=-${(N)LBUFFER%$lwords[-1]*} ;;
  (*shell-r) local move=+${(N)RBUFFER#*${${words[$#lwords]#$lwords[-1]}:-$words[$#lwords+1]}} ;;
}; case $WIDGET {
  (*kill*) (( MARK = CURSOR + move )); zle -f kill; zle .kill-region ;;
  (*) (( CURSOR += move )) ;;
}}; for w in qc{,-kill}-{sub,shell}-{l,r}; zle -N $w qc-word-widgets
bindkey '\E[1;5D' qc-sub-l; bindkey '\E[1;5C' qc-sub-r; bindkey '\E[1;3D' qc-shell-l; bindkey '\E[1;3C' qc-shell-r
bindkey '^H' qc-kill-sub-l; bindkey '^W' qc-kill-sub-l; bindkey '\E[3;5~' qc-kill-sub-r; bindkey '\E^?' qc-kill-shell-l; bindkey '\E[3;3~' qc-kill-shell-r
WORDCHARS='*?[]~&;!#$%^(){}<>'
qc-trim-paste(){ zle .$WIDGET && LBUFFER=${LBUFFER%%[[:space:]]#}; }
zle -N bracketed-paste qc-trim-paste
qc-rationalize-dot(){ if [[ $LBUFFER == *.. ]]; then LBUFFER+='/..'; else LBUFFER+='.'; fi; }
zle -N qc-rationalize-dot; bindkey '.' qc-rationalize-dot; bindkey '\E.' self-insert-unmeta
qc-clear-screen(){ local prompt_height=$(print -n ${(%%)PS1} | wc -l) lines=$((LINES - prompt_height)); printf "$terminfo[cud1]%.0s" {1..$lines}; printf "$terminfo[cuu1]%.0s" {1..$lines}; zle .reset-prompt; }
zle -N qc-clear-screen; bindkey '^L' qc-clear-screen
autoload -Uz add-zsh-hook; _qc-reset-cursor(){ print -n '\E[5 q'; }; add-zsh-hook precmd _qc-reset-cursor

# =================== SMARTCACHE + LAZYLOAD ===================
if (( $+functions[lazyload] )); then
  lazyload gh 'source =(smartcache 7d gh completion -s zsh)'
  lazyload docker 'source =(smartcache 7d docker completion zsh)'
  lazyload carapace 'export CARAPACE_BRIDGES="zsh,fish,bash,inshellisense"; source =(smartcache 7d carapace _carapace)'
  lazyload mise 'eval "$($HOME/.local/bin/mise activate zsh)"'
  lazyload pyenv 'eval "$(smartcache 7d pyenv init -)"'
  lazyload zellij 'eval "$(zellij setup --generate-auto-start zsh)"'
  lazyload z 'eval "$(zoxide init zsh)"; alias cd=z'
  lazyload fuck 'local f="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/thefuck"; mkdir -p -- "${f:h}"; [[ -f $f ]] || smartcache 30d thefuck --alias >"$f"; source "$f"'
  lazyload shit '(( $+commands[theshit] )) && eval "$($HOME/.cargo/bin/theshit alias shit)"'
fi
if (( $+functions[zsh-defer] )); then
  zsh-defer -c '(( $+functions[smartcache] )) || return 0; smartcache 7d vivid generate molokai &>/dev/null || :'
  zsh-defer -c '(( $+functions[smartcache] )) || return 0; has gh && smartcache 7d gh completion -s zsh &>/dev/null || :'
  zsh-defer -c '(( $+functions[smartcache] )) || return 0; has carapace && smartcache 7d carapace _carapace &>/dev/null || :'
else
  (( $+commands[zellij] )) && eval "$(zellij setup --generate-auto-start zsh)"
  eval "$(zoxide init zsh)"; alias cd=z
  [[ -f $HOME/.local/bin/mise ]] && eval "$($HOME/.local/bin/mise activate zsh)"
  if (( $+commands[carapace] )); then export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'; source <(carapace _carapace); fi
  if (( $+commands[thefuck] )); then f="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/thefuck"; mkdir -p -- "${f:h}"; [[ -f $f ]] || thefuck --alias >"$f"; source "$f"; fi
  (( $+commands[theshit] )) && eval "$($HOME/.cargo/bin/theshit alias shit)"
fi

# =================== LOGIN INFO ===================
if [[ -o INTERACTIVE && -t 2 && $+commands[fastfetch] -ne 0 ]]; then fastfetch; fi >&2

# =================== FINAL OPTIMIZATIONS ===================
autoload -Uz zrecompile
for f in ~/.zshrc ~/.zshenv ~/.p10k.zsh; do [[ -f $f && ( ! -f ${f}.zwc || $f -nt ${f}.zwc ) ]] && zrecompile -pq "$f" &>/dev/null; done; unset f

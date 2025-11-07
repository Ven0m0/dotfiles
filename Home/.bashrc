#============================== [Initial Guard] ===============================
[[ $- != *i* ]] && return

#================================ [Helpers] ===================================
has(){ command -v -- "$1" &>/dev/null; }
ifsource(){ [[ -r "${1/#\~\//${HOME}/}" ]] && . "${1/#\~\//${HOME}/}"; }
exportif(){ [[ -e "$2" ]] && export "$1=$2"; }
prepend_var(){ local -n p="$1"; [[ -d "$2" && ":$p:" != *":$2:"* ]] && p="$2${p:+:$p}"; }
prependpath(){ prepend_var PATH "$1"; }

#============================ [Core Configuration] ============================
# --- History
HISTCONTROL="erasedups:ignoreboth" HISTSIZE=5000 HISTFILESIZE=10000
HISTIGNORE="&:bg:fg:clear:cls:exit:history:?"
HISTTIMEFORMAT="%F %T " HISTFILE="$HOME/.bash_history"
PROMPT_DIRTRIM=3
shopt -s histappend cmdhist

# --- Shell Behavior
shopt -s autocd cdable_vars cdspell checkwinsize dirspell extglob globstar hostcomplete no_empty_cmd_completion nullglob
set -o noclobber
bind -r '\C-s'
stty -ixon -ixoff -ixany
export IGNOREEOF=10

# --- Environment
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config} XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share} XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$UID} XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-$HOME/Projects}

export EDITOR='micro' VISUAL="$EDITOR" GIT_EDITOR="$EDITOR" SUDO_EDITOR="$EDITOR"
export BROWSER='firefox' TERMINAL='ghostty' SUDO='doas'
export LANG='C.UTF-8' LC_COLLATE='C'
export TZ='Europe/Berlin' TIME_STYLE='+%d-%m %H:%M'
export GPG_TTY="$(tty)"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export NODE_OPTIONS='--max-old-space-size=4096'

#=============================== [Sourcing] =================================
dotfiles=(
  /etc/bashrc
  "$HOME/.bash_aliases"
  "$HOME/.bash_functions"
  "$HOME/.bash_completions"
  /usr/share/doc/pkgfile/command-not-found.bash
  "${XDG_CONFIG_HOME}/bash/init.bash"
)
for p in "${dotfiles[@]}"; do ifsource "$p"; done

ifsource /usr/share/bash-preexec/bash-preexec.sh

#================================ [PATH Setup] ================================
prependpath "$HOME/.local/bin"
prependpath "$HOME/.bin"
prependpath "$HOME/bin"
prependpath "$HOME/.cargo/bin"
exportif BUN_INSTALL "$HOME/.bun"
prependpath "$BUN_INSTALL/bin"

#=============================== [Tooling Init] ===============================
# --- Language & Runtimes
has mise && eval "$(mise activate -yq bash)"
ifsource "$HOME/.sdkman/bin/sdkman-init.sh"

has cargo && {
  exportif RUSTUP_HOME "$HOME/.rustup"
  exportif CARGO_HOME "$HOME/.cargo"
  ifsource "$CARGO_HOME/env"
}

# --- Shell Enhancement Tools
has gh && eval "$(gh completion -s bash)"
has zoxide && {
  export _ZO_EXCLUDE_DIRS="$HOME"
  export _ZO_FZF_OPTS='--cycle --inline-info --no-multi --no-sort'
  eval "$(zoxide init --cmd cd bash)"
}
has zellij && {
  eval "$(zellij setup --generate-auto-start bash)"
  ifsource "$HOME/.config/bash/completions/zellij.bash"
}

# --- Graphics & Session
if [[ "${XDG_SESSION_TYPE-}" == "wayland" ]]; then
  export GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland SDL_VIDEODRIVER=wayland
  export MOZ_ENABLE_WAYLAND=1
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  export _JAVA_AWT_WM_NONREPARENTING=1
  export NVD_BACKEND=direct LIBVA_DRIVER_NAME=nvidia VDPAU_DRIVER=nvidia
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
  export __GL_THREADED_OPTIMIZATIONS=1 __GL_VRR_ALLOWED=1
  export __GL_SHADER_DISK_CACHE=1
  exportif __GL_SHADER_DISK_CACHE_PATH "$HOME/.cache/nvidia/GLCache"
fi
has dbus-launch && export "$(dbus-launch 2>/dev/null)"
[[ "$TERM" == "xterm-ghostty" ]] && ifsource "${GHOSTTY_RESOURCES_DIR:-}/shell-integration/bash/ghostty.bash"

#================================ [Functions] =================================
y() {
  local tmp_file cwd
  tmp_file="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp_file"
  if IFS= read -r -d '' cwd < "$tmp_file" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp_file"
}

gclone() {
  command git clone --filter=blob:none --depth 1 --no-tags \
    -c protocol.version=2 -c http.sslVersion=tlsv1.3 \
    -c http.version=HTTP/2 "$@"
}

gpush() {
  command git add . && command git commit -m "${1:-Update}" && command git push
}

#================================ [Aliases] ===================================
alias sudo='sudo '
alias e="$EDITOR"
alias c='clear'
alias q='exit'
alias ..='cd ..'
alias ...='cd ../..'
alias bd='cd "$OLDPWD"'
alias ls='eza -F --color=auto --group-directories-first --icons=auto'
alias la='eza -AF --color=auto --group-directories-first --icons=auto'
alias ll='eza -AlF --color=auto --group-directories-first --icons=auto --git --header'
alias lt='eza -AlT -L 2 --color=auto --group-directories-first --icons=auto'
alias grep='grep --color=auto'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv --preserve-root'
alias ssh='TERM=xterm-256color command ssh'
has wget2 && alias wget='wget2'
has btm && alias top='btm'
pip() { if has uv && [[ " install uninstall list show freeze check " =~ " $1 " ]]; then uv pip "$@"; else command python -m pip "$@"; fi; }

#============================== [FZF & Prompt] ================================
configure_fzf() {
  local find_cmd='fd --type f --hidden --no-ignore --exclude .git'
  export FZF_DEFAULT_COMMAND="$find_cmd"
  export FZF_CTRL_T_COMMAND="$find_cmd"

  local base_opts='--height=90% --layout=reverse --border --cycle'
  base_opts+=' --preview-window=wrap --inline-info --marker=*'
  export FZF_DEFAULT_OPTS="$base_opts"
  export FZF_CTRL_T_OPTS="$base_opts --preview 'bat --color=always -p -r :250 {}'"
  export FZF_CTRL_R_OPTS="$base_opts --preview 'echo {}' --preview-window=down:3:wrap"
  export FZF_ALT_C_OPTS="$base_opts --preview 'eza -T {}'"

  ifsource /usr/share/fzf/key-bindings.bash
  ifsource /usr/share/fzf/completion.bash
}
has fzf && has bat && has eza && configure_fzf

# --- Prompt
configure_prompt() {
  if has starship; then
    eval "$(starship init bash)"
    return
  fi
  local c_red='\[\e[31m\]' c_grn='\[\e[32m\]' c_blu='\[\e[34m\]' c_cyn='\[\e[36m\]' c_def='\[\e[0m\]'
  local user_color="$c_blu"
  [[ $EUID -eq 0 ]] && user_color="$c_red"
  local exit_status='$(ret=$?; if [[ $ret -eq 0 ]]; then echo -e "$c_grn:)$c_def"; else echo -e "$c_red$ret$c_def"; fi)'
  PS1="[$user_color\u@\h$c_def:$c_cyn\w$c_def] $exit_status > "
  PS2="> "
}
configure_prompt
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

#============================== [Finalization] ================================
# --- Asynchronous Path Deduplication
(
  new_path=""
  declare -A seen
  IFS=:
  for p in $PATH; do
    [[ -z "$p" || -n "${seen[$p]}" ]] && continue
    seen[$p]=1
    new_path="${new_path:+$new_path:}$p"
  done
  [[ -n "$new_path" ]] && export PATH="$new_path"
) &>/dev/null &

# --- Welcome Fetch
if [[ $SHLVL -eq 1 && -z "${DISPLAY}" ]]; then
  fetch_cmd=""
  if has hyfetch && has fastfetch; then
    fetch_cmd='hyfetch -b fastfetch -p transgender'
  elif has fastfetch; then
    fetch_cmd='fastfetch'
  fi
  [[ -n "$fetch_cmd" ]] && eval "$fetch_cmd"
fi

unset -f ifsource exportif prepend_var prependpath configure_fzf configure_prompt

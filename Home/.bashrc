# .bashrc - Minimal Bootstrap Configuration
# Skip if non-interactive
[[ $- != *i* ]] && return

#================================ [Helpers] ===================================
has(){ command -v -- "$1" &>/dev/null; }
ifsource(){ [[ -r "${1/#\~\//${HOME}/}" ]] && . "${1/#\~\//${HOME}/}"; }
exportif(){ [[ -e "$2" ]] && export "$1=$2"; }
prepend_var(){ local -n p="$1"; [[ -d "$2" && ":$p:" != *":$2:"* ]] && p="$2${p:+:$p}"; }
prependpath(){ prepend_var PATH "$1"; }

#============================ [Core Configuration] ============================
# === History ===
HISTCONTROL="erasedups:ignoreboth" HISTSIZE=10000 HISTFILESIZE=10000
HISTIGNORE="&:bg:fg:clear:cls:exit:history:?"
HISTTIMEFORMAT="%F %T " HISTFILE="${HOME}/.bash_history"

# === Shell Behavior ===
shopt -s autocd cdable_vars cdspell checkwinsize dirspell globstar nullglob \
         hostcomplete no_empty_cmd_completion histappend cmdhist
bind -r '\C-s' 2>/dev/null
stty -ixon -ixoff -ixany 2>/dev/null
export IGNOREEOF=10 
export GIT_PS1_SHOWUNTRACKEDFILES=1 GIT_PS1_SHOWDIRTYSTATUS=1 GIT_PS1_SHOWCOLORHINTS=1

# Ensure command hashing is off for mise
set +h

# https://github.com/pkgforge-dev/Citron-AppImage/issues/50
export QT_QPA_PLATFORM=xcb

# === XDG Base Directories ===
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
XDG_PROJECTS_DIR="${XDG_PROJECTS_DIR:-${HOME}/Projects}"
XDG_BIN_HOME="${XDG_BIN_HOME:-${HOME}/.local/bin}"
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_RUNTIME_DIR XDG_PROJECTS_DIR XDG_BIN_HOME

#=============================== [Sourcing] ===================================
# Source legacy dotfiles for compatibility
ifsource /etc/bashrc
ifsource "${HOME}/.bash_aliases"
ifsource "${HOME}/.bash_functions"
ifsource "${HOME}/.bash_completions"
ifsource /usr/share/doc/pkgfile/command-not-found.bash
ifsource /usr/share/bash-preexec/bash-preexec.sh

# Load modular bash configuration framework
ifsource "${XDG_CONFIG_HOME}/bash/init.bash"

# Ble.sh integration (if available)
[[ -r "/usr/share/blesh/ble.sh" ]] && . -- "/usr/share/blesh/ble.sh" --attach=none

#============================== [Finalization] ================================
# Cleanup helper functions
unset -f ifsource exportif prepend_var prependpath

# Attach ble.sh if loaded
[[ ! ${BLE_VERSION-} ]] || ble-attach

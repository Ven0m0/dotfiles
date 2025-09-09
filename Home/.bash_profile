# ~/.bash_profile
#
#prependpath(){ [[ -d "${1/#\~\//${HOME}/}" ]] && [[ ":$PATH:" != *":${1/#\~\//${HOME}/}:"* ]] && PATH="${1/#\~\//${HOME}/}${PATH:+:$PATH}"; }

#prependpath "${HOME}/.bashrc"
#prependpath "${HOME}/.profile"
#prependpath "${HOME}/.cargo/env"
#prependpath "$HOME/.local/bin"
#prependpath "$HOME/bin"
#export PATH

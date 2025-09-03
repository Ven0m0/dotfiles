# ~/.bashrc

[[ $- != *i* ]] && return
LC_ALL=C
#============ Helpers ============
# Check for command
has(){ command -v -- "$1" &>/dev/null || return; }
# Basename of command
hasname(){ local x=$(type -P -- "$1") && printf '%s\n' "${x##*/}"; }
# 'echo' as printf
#xprintf(){ printf '%s\n' "$*"; }
# 'echo -e' as printf for color
#xeprintf(){ printf '%b\n' "$*"; }
# Source file if it exists
_ifsource(){ [[ -r "$1" ]] && . -- "$1" 2>/dev/null; } 
# Only prepend if not already in PATH
_prependpath(){ [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && PATH="$1${PATH:+:$PATH}"; } 
#============ Sourcing ============
_ifsource "/etc/bashrc"
_for_each_source=(
  "${HOME}/.bash_aliases"
  "${HOME}/.bash_functions"
  "${HOME}/.bash_fuzz"
  "${HOME}/.fns"
  "${HOME}/.funcs"
)
for _src in "${_for_each_source[@]}"; do
  _ifsource "$_src"
done; unset _src
# completions (quiet)
_ifsource "/usr/share/bash-completion/bash_completion" || _ifsource "/etc/bash_completion"

# https://github.com/akinomyoga/ble.sh
if [[ -r $HOME/.local/share/blesh/ble.sh ]]; then
  . -- "${HOME}/.local/share/blesh/ble.sh" --attach=none 2>/dev/null
  bleopt complete_auto_complete=1; bleopt complete_auto_delay=1; bleopt complete_menu_complete=1
  bleopt complete_menu_filter=1; bleopt complete_ambiguous=1; bleopt complete_skip_matched=on
  bleopt complete_contract_function_names=1; bleopt prompt_command_changes_layout=1
elif [[ -r /usr/share/blesh/ble.sh ]]; then
  . -- "/usr/share/blesh/ble.sh" --attach=none 2>/dev/null
  bleopt complete_auto_complete=1; bleopt complete_auto_delay=1; bleopt complete_menu_complete=1
  bleopt complete_menu_filter=1; bleopt complete_ambiguous=1; bleopt complete_skip_matched=on
  bleopt complete_contract_function_names=1; bleopt prompt_command_changes_layout=1
fi
# https://wiki.archlinux.org/title/Bash#Command_not_found
_ifsource "/usr/share/doc/pkgfile/command-not-found.bash"

if [[ -d $HOME/.dotbare ]]; then
  [[ -f $HOME/.dotbare/dotbare ]] && alias dotbare="$HOME/.dotbare/dotbare"
  _ifsource "$HOME/.dotbare/dotbare.plugin.bash"
fi
#============ Stealth ============
stealth=${stealth:-0} # stealth=1
#============ History / Prompt basics ============
# PS1='[\u@\h|\w] \$' # bash-prompt-generator.org
HISTSIZE=1000
HISTFILESIZE="$HISTSIZE"
HISTCONTROL="erasedups:ignoreboth"
HISTIGNORE="&:ls:[bf]g:help:clear:exit:shutdown:reboot:history:fish:?:??"
export HISTTIMEFORMAT="%F %T " IGNOREEOF=100
HISTFILE="$HOME/.bash_history"
PROMPT_DIRTRIM=2
PROMPT_COMMAND="history -a"
#============ Core ============
CDPATH=".:$HOME:/"
ulimit -c 0 &>/dev/null # disable core dumps
shopt -s histappend cmdhist checkwinsize dirspell cdable_vars \
         cdspell autocd hostcomplete no_empty_cmd_completion \
         globstar nullglob force_fignore &>/dev/null
export FIGNORE="argo.lock"
# Disable Ctrl-s, Ctrl-q
stty -ixon -ixoff -ixany &>/dev/null
set +H  &>/dev/null # disable history expansion that breaks some scripts
# set -o vi
#============ Env ============
_prependpath "$HOME/.local/bin"
_prependpath "$HOME/bin"
_prependpath "$HOME/.bin"

# Editor selection: prefer micro, fallback to nano
_editor_cmd="$(command -v micro 2>/dev/null || :)"; _editor_cmd="${_editor_cmd##*/}"; EDITOR="${_editor_cmd:-nano}"
export EDITOR VISUAL="$EDITOR" VIEWER="$EDITOR" GIT_EDITOR="$EDITOR" SYSTEMD_EDITOR="$EDITOR" FCEDIT="$EDITOR" SUDO_EDITOR="$EDITOR"
unset _editor_cmd 2>/dev/null
# https://wiki.archlinux.org/title/Locale
export LANG="${LANG:=C.UTF-8}" \
       LANGUAGE="en_US:en:C" \
       LC_MEASUREMENT=C \
       LC_COLLATE=C \
       LC_CTYPE=C \
       TZ="Europe/Berlin"

SHELL="${BASH:-/bin/bash}"
has dbus-launch && export "$(dbus-launch 2>/dev/null)"

# Mimalloc & Jemalloc
# https://github.com/microsoft/mimalloc/blob/main/docs/environment.html
export MALLOC_CONF="metadata_thp:auto,tcache:true,background_thread:true,percpu_arena:percpu"
export _RJEM_MALLOC_CONF="$MALLOC_CONF" MIMALLOC_VERBOSE=0 MIMALLOC_SHOW_ERRORS=0 MIMALLOC_SHOW_STATS=0 MIMALLOC_ALLOW_LARGE_OS_PAGES=1 MIMALLOC_PURGE_DELAY=25 MIMALLOC_ARENA_EAGER_COMMIT=2

# Delta / bat integration
if has delta; then
  export GIT_PAGER=delta
  if has batdiff || has batdiff.sh; then
    export BATDIFF_USE_DELTA=true
  fi
fi
if has bat; then
  export PAGER=bat BAT_THEME=ansi BATPIPE=color BAT_STYLE=auto
  alias cat='\bat -pp'
  alias bat='\bat --color auto'
  has batman && eval "$(LC_ALL=C batman --export-env 2>/dev/null)" 2>/dev/null || true
  has batgrep && alias batgrep='batgrep --rga -S --color 2>/dev/null' || true
elif has less; then
  export PAGER=less
fi
if has less; then
  LESS_TERMCAP_md=$'\e[01;31m' LESS_TERMCAP_me=$'\e[0m' LESS_TERMCAP_us=$'\e[01;32m' LESS_TERMCAP_ue=$'\e[0m' LESS_TERMCAP_so=$'\e[45;93m' LESS_TERMCAP_se=$'\e[0m'
  LESSHISTFILE="-" LESS='-FrXnsi --mouse --use-color --no-edit-warn --no-vbell --no-histdups'
  export LESSHISTFILE LESS ESS_TERMCAP_md LESS_TERMCAP_me LESS_TERMCAP_us LESS_TERMCAP_ue LESS_TERMCAP_so LESS_TERMCAP_se
  has lesspipe && eval "$(SHELL=/bin/sh lesspipe 2>/dev/null)" 2>/dev/null || true
fi
export GIT_PAGER="${GIT_PAGER:-$PAGER}"
# XDG + misc
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=${HOME}/.config}" \
       XDG_DATA_HOME="${XDG_DATA_HOME:=${HOME}/.local/share}" \
       XDG_STATE_HOME="${XDG_STATE_HOME:=${HOME}/.local/state}" \
       XDG_CACHE_HOME="${XDG_CACHE_HOME:=${HOME}/.cache}"

# https://www.reddit.com/r/programming/comments/109rjuj/how_setting_the_tz_environment_variable_avoids
export INPUTRC="$HOME/.inputrc"
export CURL_HOME="$HOME"
export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc"
export GPG_TTY="$(tty)"

_ifsource "$HOME/.cargo/env"
if has cargo; then
  export CARGO_HOME="${HOME}/.cargo" RUSTUP_HOME="${HOME}/.rustup"
  _prependpath "${CARGO_HOME}/bin"
fi
cargo_run() {
  local bins=(gg mommy clicker) cmd=(cargo) b
  for b in "${bins[@]}"; do
    command -v "cargo-$b" &>/dev/null && cmd+=("$b")
  done
  "${cmd[@]}" "$@"
}
alias cargo="cargo_run"

export PYTHONOPTIMIZE=2 PYTHONIOENCODING='UTF-8' PYTHON_JIT=1 PYENV_VIRTUALENV_DISABLE_PROMPT=1
export FD_IGNORE_FILE="${HOME}/.ignore"
export ZSTD_NBTHREADS=0 ELECTRON_OZONE_PLATFORM_HINT=auto _JAVA_AWT_WM_NONREPARENTING=1 GTK_USE_PORTAL=1
export FLATPAK_FANCY_OUTPUT=1 FLATPAK_TTY_PROGRESS=0 FLATPAK_FORCE_TEXT_AUTH=1
# Wayland
if has qt6ct; then
  export QT_QPA_PLATFORMTHEME='qt6ct'
elif has qt5ct; then
  export QT_QPA_PLATFORMTHEME='qt5ct'
fi
if [[ ${XDG_SESSION_TYPE:-} == "wayland" ]]; then
  export GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland SDL_VIDEODRIVER=wayland CLUTTER_BACKEND=wayland \
    MOZ_ENABLE_WAYLAND=1 MOZ_ENABLE_XINPUT2=1 MOZ_DBUS_REMOTE=1 QT_WAYLAND_DISABLE_WINDOWDECORATION=1 QT_AUTO_SCREEN_SCALE_FACTOR=1
fi

if has dircolors; then
  eval "$(dircolors -b)" &>/dev/null
else
  export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.7z=01;31:*.ace=01;31:*.alz=01;31:*.apk=01;31:*.arc=01;31:*.arj=01;31:*.bz=01;31:*.bz2=01;31:*.cab=01;31:*.cpio=01;31:*.crate=01;31:*.deb=01;31:*.drpm=01;31:*.dwm=01;31:*.dz=01;31:*.ear=01;31:*.egg=01;31:*.esd=01;31:*.gz=01;31:*.jar=01;31:*.lha=01;31:*.lrz=01;31:*.lz=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.lzo=01;31:*.pyz=01;31:*.rar=01;31:*.rpm=01;31:*.rz=01;31:*.sar=01;31:*.swm=01;31:*.t7z=01;31:*.tar=01;31:*.taz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tgz=01;31:*.tlz=01;31:*.txz=01;31:*.tz=01;31:*.tzo=01;31:*.tzst=01;31:*.udeb=01;31:*.war=01;31:*.whl=01;31:*.wim=01;31:*.xz=01;31:*.z=01;31:*.zip=01;31:*.zoo=01;31:*.zst=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.jxl=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:'
fi
### LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.tga=01;35:*.tiff=01;35:*.png=01;35:*.mpeg=01;35:*.avi=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
export CLICOLOR=1 SYSTEMD_COLORS=1
#============ Fuzzy finders ============
fuzzy_finders(){
  local FIND_CMD
  if has fd; then
    FIND_CMD='LC_ALL=C fd -tf --hidden --exclude .git --exclude node_modules --exclude target'
  elif has rg; then
    FIND_CMD='LC_ALL=C rg --files --hidden --glob "!.git" --glob "!node_modules" --glob "!target"'
  else
    FIND_CMD='LC_ALL=C find . -type f ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/target/*"'
  fi
  declare -x FZF_DEFAULT_COMMAND="$FIND_CMD"
  declare -x FZF_CTRL_T_COMMAND="$FIND_CMD"
  declare -x FZF_DEFAULT_OPTS='-1 -0 --cycle --border --preview-window="wrap" --smart-case --marker="*" --info=inline --layout=reverse-list --tiebreak=index --height=70%'
  declare -x FZF_CTRL_T_OPTS="-1 -0 --tiebreak=index --preview 'bat -n --color=auto --line-range=:250 -- {} 2>/dev/null || cat -- {} 2>/dev/null'"
  declare -x FZF_CTRL_R_OPTS='-1 -0 --tiebreak=index --no-sort --exact --preview 'echo {}' --preview-window="down:3:hidden:wrap" --bind "?:toggle-preview"'
  declare -x FZF_ALT_C_OPTS='-1 -0 --tiebreak=index --walker-skip .git,node_modules,target --preview "tree -C {} 2>/dev/null | head -200"'
  declare -x FZF_COMPLETION_OPTS='--border --info=inline --tiebreak=index'
  declare -x FZF_COMPLETION_PATH_OPTS='--info=inline --tiebreak=index --walker file,dir,follow,hidden'
  declare -x FZF_COMPLETION_DIR_OPTS='--info=inline --tiebreak=index --walker dir,follow'
  command mkdir -p -- "$HOME/.config/bash/completions" 2>/dev/null
  if has fzf; then
    [[ -f /usr/share/fzf/key-bindings.bash ]] && . "/usr/share/fzf/key-bindings.bash" 2>/dev/null || :
    if [[ -f $HOME/.config/bash/completions/fzf_completion.bash ]]; then
      LC_ALL=C fzf --bash 2>/dev/null >| "$HOME/.config/bash/completions/fzf_completion.bash"
    fi
    . "$HOME/.config/bash/completions/fzf_completion.bash" 2>/dev/null || :
  fi
  if has sk; then
    declare -x SKIM_DEFAULT_COMMAND="$FIND_CMD"
    declare -x SKIM_DEFAULT_OPTIONS="${FZF_DEFAULT_OPTS:-}"
    alias fzf='sk ' 2>/dev/null || true
    [[ -f /usr/share/skim/key-bindings.bash ]] && . "/usr/share/skim/key-bindings.bash" 2>/dev/null || :
    if [[ ! -f $HOME/.config/bash/completions/sk_completion.bash ]]; then
      LC_ALL=C sk --shell bash 2>/dev/null >| "$HOME/.config/bash/completions/sk_completion.bash"
    fi
    . "$HOME/.config/bash/completions/sk_completion.bash" 2>/dev/null || :
  fi
}
fuzzy_finders

fman(){
  man -k . | fzf -q "$1" --prompt='man> '  --preview $'echo {} | tr -d \'()\' | awk \'{printf "%s ", $2} {print $1}\' | xargs -r man | col -bx | bat -l man -p --color always' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
}
export MANPAGER="sh -c 'col -bx | bat -l man -p --paging always'"

#============ Completions ============
complete -cf sudo 2>/dev/null
command -v pay-respects &>/dev/null && eval "$(LC_ALL=C pay-respects bash 2>/dev/null)" 2>/dev/null || :
# Ghostty
[[ $TERM == xterm-ghostty && -e "${GHOSTTY_RESOURCES_DIR:-}/shell-integration/bash/ghostty.bash" ]] && . "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash" 2>/dev/null || :
# Wikiman
[[ command -v wikiman &>/dev/null && -f /usr/share/wikiman/widgets/widget.bash ]] && . "/usr/share/wikiman/widgets/widget.bash" 2>/dev/null
#============ Functions ============
# Having to set a new script as executable always annoys me.
runch(){
  shopt -u nullglob nocaseglob; local s; s="$1"
  if [[ -z $s ]]; then
    printf 'runch: missing script argument\nUsage: runch <script>\n' >&2; return 2
  fi
  if [[ ! -f $s ]]; then
    printf 'runch: file not found: %s\n' "$s" >&2; return 1
  fi
  if ! command chmod +x -- "$s" 2>/dev/null; then
    printf 'runch: cannot make executable: %s\n' "$s" >&2; return 1    
  fi
  if [[ $s == */* ]]; then
    "$s"
  else
    "./$s"
  fi
}
sel(){
  local p="${1:-.}"
  [[ -e "$p" ]] || { printf 'sel: not found: %s\n' "$p" >&2; return 1; }
  if [[ -d "$p" ]]; then
    if has eza; then
      LC_ALL=C command eza -al --color=auto --group-directories-first --icons=auto --no-time --no-git --smart-group --no-user --no-permissions -- "$p"
    else
      LC_ALL=C command ls -a --color=auto --group-directories-first -- "$p"
    fi
  elif [[ -f "$p" ]]; then
    if has bat; then
      local bn
      bn=$(basename -- "$p")
      LC_ALL=C LANG=C.UTF-8 command bat -sp --color auto --file-name="$bn" -- "$p"
    else
      LC_ALL=C LANG=C.UTF-8 command cat -s -- "$p"
    fi
  else
    printf 'sel: not a file/dir: %s\n' "$p" >&2; return 1
  fi
}
# Function to run cargo commands dynamically
cargo_run(){
  local bins=(gg mommy clicker) cmd=(cargo) b
  for b in "${bins[@]}"; do
    command -v "cargo-$b" &>/dev/null && cmd+=("$b")
  done
  (( ${#cmd[@]} > 1 )) || { echo "No cargo binaries available: ${bins[*]}" >&2; return 1; }
  "${cmd[@]}" "$@"
}
sudo-command-line(){
  printf 'toggle sudo at the beginning of the current or the previous command by hitting ESC twice\n'
  [[ ${#READLINE_LINE} -eq 0 ]] && READLINE_LINE=$(fc -l -n -1 | xargs)
  if [[ $READLINE_LINE == sudo\ * ]]; then
    READLINE_LINE="${READLINE_LINE#sudo }"
  else
    READLINE_LINE="sudo $READLINE_LINE"
  fi
  READLINE_POINT="${#READLINE_LINE}"
}
bind -x '"\e\e": sudo-command-line'

gcom(){ LC_ALL=C command git add . && LC_ALL=C command git commit -m "$1"; }
gpush(){ LC_ALL=C command git add . && LC_ALL=C command git commit -m "${1:-Update}" && LC_ALL=C command git push; }
symbreak(){ LC_ALL=C command find -L "${1:-.}" -type l; }
command -v hyperfine &>/dev/null && hypertest(){ LC_ALL=C LANG=C command hyperfine -w 25 -m 50 -i -S bash -- "$@"; }
touchf(){ command mkdir -p -- "$(dirname -- "$1")" && command touch -- "$1"; }
cht(){
  # join all arguments with '/', so “topic sub topic” → “topic/sub/topic”
  local query="${*// /\/}"
  # try to fetch the requested cheat‑sheet; on HTTP errors (e.g. 404), fall back to :help
  if ! curl -sf4 "cht.sh/$query"; then
    curl -sf4 "cht.sh/:help"
  fi
}
extract(){
    local c e i
    (($#)) || return
    for i; do
        c=''
        e=1
        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: \`$i'" >&2
            continue
        fi
        case $i in
            *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz|zst)))))
                   c=(bsdtar xvf);;
            *.7z)  c=(7z x);;
            *.Z)   c=(uncompress);;
            *.bz2) c=(bunzip2);;
            *.exe) c=(cabextract);;
            *.gz)  c=(gunzip);;
            *.rar) c=(unrar x);;
            *.xz)  c=(unxz);;
            *.zip) c=(unzip);;
            *.zst) c=(unzstd);;
            *)     echo "$0: unrecognized file extension: \`$i'" >&2
                   continue;;
        esac
        command "${c[@]}" "$i"
        ((e = e || $?))
    done
    return "$e"
}
#============ Aliases ============
# Enable aliases to be sudo’ed
alias sudo='sudo ' sudo-rs='sudo-rs ' doas='doas '
alias mkdir='mkdir -p'
alias ed='$EDITOR' mi='$EDITOR' smi='sudo $EDITOR'
alias please='sudo !!'
alias pacman='LC_ALL=C LANG=C.UTF-8 sudo pacman --noconfirm --needed --color=auto'
alias paru='LC_ALL=C LANG=C.UTF-8 paru --skipreview --noconfirm --needed'
alias ssh='LC_ALL=C LANG=C.UTF-8 TERM=xterm-256color command ssh'
# ssh(){ TERM=xterm-256color command ssh "$@"; }
alias cls='clear' c='clear'
alias q='exit'
alias h='history'
alias ptch='patch -p1 <'
alias cleansh='curl -fsSL4 https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Clean.sh | bash'
alias updatesh='curl -fsSL4 https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Updates.sh | bash'
curlsh(){ 
  local shellx="$(command -v bash 2>/dev/null || command -v dash 2>/dev/null)"
  local shellx="${shellx##*/}"
  LC_ALL=C LANG=C command curl -fsSL4 "$1" | $shellx
}
if has eza; then
  alias ls='eza -F --color=auto --group-directories-first --icons=auto'
  alias la='eza -AF --color=auto --group-directories-first --icons=auto'
  alias ll='eza -AlF --color=auto --group-directories-first --icons=auto --no-time --no-git --smart-group --no-user --no-permissions'
  alias lt='eza -ATF -L 3 --color=auto --group-directories-first --icons=auto --no-time --no-git --smart-group --no-user --no-permissions'
else
  alias ls='ls --color=auto --group-directories-first -C'
  alias la='ls --color=auto --group-directories-first -A'
  alias ll='ls --color=auto --group-directories-first -oh'
  alias lt='ls --color=auto --group-directories-first -oghAt'
fi
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -iv'
alias rm='rm -Iv --preserve-root'
alias rmd='rm -rf --preserve-root'
alias chmod='chmod --preserve-root' 
alias chown='chown --preserve-root' 
alias chgrp='chgrp --preserve-root'
alias histl="history | LC_ALL=C grep -i"
alias findl="LC_ALL=C find . | LC_ALL=C grep -i"
alias psl="ps aux | LC_ALL=C grep -i"
alias topcpu="ps -eo pcpu,pid,user,args | LC_ALL=C sort -k 1 -r | head -10"
alias diskl='LC_ALL=C lsblk -o NAME,SIZE,TYPE,MOUNTPOINT'

# DIRECTORY NAVIGATION
if has zoxide; then
  alias ..='z -- ..'
  alias ...='z -- ../..'
  alias ....='z -- ../../..'
  alias .....='z -- ../../../..'
  alias ......='z -- ../../../../..'
  alias ~="z -- $HOME"
  alias cd-="cd -- -"
  alias cd='z'
else
  alias ..='cd -- ..'
  alias ...='cd -- ../..'
  alias ....='cd -- ../../..'
  alias .....='cd -- ../../../..'
  alias ......='cd -- ../../../../..'
  alias ~="cd -- $HOME"
  alias cd-="cd -- -"
  unalias cd 2>/dev/null
fi
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias y='yazi'

# Common use
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias big="expac -H M '%m\t%n' | LC_ALL=C sort -h | nl"                      # Sort installed packages according to size in MB
alias gitpkg='sudo pacman -Q | LC_ALL=C grep -i "\-git" | LC_ALL=C wc -l'    # List amount of -git packages

alias cleanup='LC_ALL=C sudo pacman -Rns (pacman -Qtdq)'
alias dmesg="sudo /bin/dmesg -L=always"

# https://snarky.ca/why-you-should-use-python-m-pip/
alias pip='python -m pip' py3='python3' py='python'

alias speedt='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# Dotfiles
# LC_ALL=C git clone --bare git@github.com:Ven0m0/dotfiles.git $HOME/.dotfiles
alias dotfiles='LC_ALL=C git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

#============ Bindings (readline) ============
bind 'set completion-query-items 150'
bind 'set page-completions off'
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set menu-complete-display-prefix on'
bind "set completion-ignore-case on"
bind "set completion-map-case on"
bind 'set mark-directories on'
bind "set mark-symlinked-directories on"
bind "set bell-style none"
bind 'set skip-completed-text on'
bind 'set colored-stats on'
bind 'set colored-completion-prefix on'
bind 'set expand-tilde on'
bind '"Space": magic-space'
bind '"\C-o": kill-whole-line'
bind '"\C-a": beginning-of-line'
bind '"\C-e": end-of-line'
bind '"\e[1;5D": backward-word'
bind '"\e[1;5C": forward-word'
bind 'set enable-bracketed-paste off'
# prefixes the line with sudo , if Alt+s is pressed
bind '"\es": "\C-asudo \C-e"'
# https://wiki.archlinux.org/title/Bash
run-help(){ help "$READLINE_LINE" 2>/dev/null || man "$READLINE_LINE"; }
bind -m vi-insert -x '"\eh": run-help'
bind -m emacs -x     '"\eh": run-help'
#============ Prompt 2 ============
PROMPT_COMMAND="history -a"
configure_prompt(){
  local LC_ALL=C LANG=C
  if command -v starship &>/dev/null; then
    eval "$(LC_ALL=C starship init bash 2>/dev/null)" &>/dev/null; return
  fi
  local C_USER='\[\e[35m\]' C_HOST='\[\e[34m\]' YLW='\[\e[33m\]' \
        C_PATH='\[\e[36m\]' C_RESET='\[\e[0m\]' C_ROOT='\[\e[31m\]'
  local USERN HOSTL

  [[ "$EUID" -eq 0 ]] && USERN="${C_ROOT}\u${C_RESET}"
  [[ -n "$SSH_CONNECTION" ]] && HOSTL="${YLW}\h${C_RESET}"
  PS1="[${C_USER}\u${C_RESET}@${HOSTL}|${C_PATH}\w${C_RESET}]>\s>\A|\$? \$ "
  PS2='> ' 
  # Git
  export GIT_PS1_OMITSPARSESTATE=1 GIT_PS1_HIDE_IF_PWD_IGNORED=1
  unset GIT_PS1_SHOWDIRTYSTATE GIT_PS1_SHOWSTASHSTATE GIT_PS1_SHOWUPSTREAM GIT_PS1_SHOWUNTRACKEDFILES
  if command -v __git_ps1 &>/dev/null && [[ ${GIT_PROMPT:-0} -ge 1 ]] && [[ ${PROMPT_COMMAND:-} != *git_ps1* ]]; then
    PROMPT_COMMAND="LC_ALL=C LANG=C __git_ps1 2>/dev/null; ${PROMPT_COMMAND:-}"
  fi
  # Only add if not in stealth mode and not already present in PROMPT_COMMAND
  if command -v mommy &>/dev/null && [[ "${stealth:-0}" -ne 1 ]] && [[ ${PROMPT_COMMAND:-} != *mommy* ]]; then
    PROMPT_COMMAND="LC_ALL=C LANG=C mommy -1 -s \$?; ${PROMPT_COMMAND:-}" # mommy https://github.com/fwdekker/mommy
    # PROMPT_COMMAND="LC_ALL=C LANG=C mommy \$?; ${PROMPT_COMMAND:-}" # Shell-mommy https://github.com/sleepymincy/mommy
  fi
}
configure_prompt
#============ End ============
dedupe_path(){
  local IFS=: dir s; declare -A seen
  for dir in $PATH; do
    [[ -n $dir && -z ${seen[$dir]} ]] && seen[$dir]=1 && s="${s:+$s:}$dir"
  done
  [[ -n $s ]] && export PATH="$s"
  command -v systemctl &>/dev/null && LC_ALL=C command systemctl --user import-environment PATH &>/dev/null
}
dedupe_path
#============ Fetch ============
if [[ $SHLVL -le 2 ]]; then
  if [ "${stealth:-0}" -eq 1 ]; then
    if has fastfetch; then
      fetch='LC_ALL=C fastfetch --ds-force-drm --thread --detect-version false'
      "$fetch"
    fi
  else
    if has hyfetch; then
      fetch='LC_ALL=C hyfetch -b fastfetch -m rgb -p transgender'
      "$fetch"
    elif has fastfetch; then
      fetch='LC_ALL=C fastfetch --ds-force-drm --thread'
      "$fetch"
    else
      fetch='LC_ALL=C curl -sf4 https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Scripts/shell-tools/vnfetch.sh | bash'
      "$fetch"
    fi
  fi
fi
# fetch='LC_ALL=C command hostnamectl 2>/dev/null'
#============ Jumping ============
if has zoxide; then
  export _ZO_DOCTOR='0' _ZO_ECHO='0' _ZO_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}" _ZO_EXCLUDE_DIRS="$HOME:*.git"
  eval "$(LC_ALL=C zoxide init bash 2>/dev/null)" 2>/dev/null
fi
#============ Ble.sh final ============
[[ ! ${BLE_VERSION-} ]] || ble-attach
unset LC_ALL


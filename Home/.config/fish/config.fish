#!/usr/bin/env fish
status -i; or return

# ─── Core Environment ────────────────────────────────────────────────────────
set -gx GPG_TTY (tty)
set -gx COLORTERM truecolor

# ─── FZF ─────────────────────────────────────────────────────────────────────
set -gx FZF_DEFAULT_COMMAND 'fd -tf -H --size +1k --exclude .git'

# ─── Paths ───────────────────────────────────────────────────────────────────
fish_add_path -g ~/.bun/bin ~/.local/bin /usr/local/bin ~/bin ~/.cargo/bin /usr/lib/ccache/bin
test -d ~/.basher/bin; and fish_add_path -g ~/.basher/bin

# ─── SSH Agent (cached) ──────────────────────────────────────────────────────
set -gx SSH_AUTH_SOCK ~/.ssh/ssh-agent.sock
if not test -S $SSH_AUTH_SOCK
    eval (ssh-agent -c -s) >/dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
end

# Docker compatibility aliases
alias docker '/usr/bin/docker'
alias docker-compose '/usr/bin/docker compose'
# Podman socket for Docker API compatibility (Fish syntax)
# Force docker CLI to use Docker daemon
set -gx DOCKER_HOST "unix:///var/run/docker.sock"
#export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# ─── Greeting (cached, skip if terminal not interactive) ─────────────────────
function fish_greeting
    set -l cache "$XDG_CACHE_HOME/fish-greeting-shown"
    if command -q hyfetch; and not test -f $cache
        hyfetch -m 8bit; touch $cache &
    else if command -q fastfetch; and not test -f $cache
        fastfetch --thread true --detect-version false; touch $cache &
    end
end

# ─── Tool Init (lazy via evalcache) ──────────────────────────────────────────
function init_tool
    command -q $argv[1]; or return
    if type -q _evalcache
        _evalcache $argv[2..-1] >/dev/null 2>&1
    else
        eval "$argv[2..-1]" >/dev/null 2>&1
    end
end

init_tool fzf "fzf --fish"
init_tool starship "starship init fish" && enable_transience
init_tool zoxide "zoxide init --cmd cd fish"
init_tool mise "mise activate fish"
init_tool vivid "set -gx LS_COLORS (vivid generate dracula)"
init_tool pay-respects "pay-respects fish --alias"
test -d ~/.basher; and init_tool basher "basher init - fish"

# ─── Python venv ─────────────────────────────────────────────────────────────
test -r ~/.venv/bin/activate.fish; and source ~/.venv/bin/activate.fish

# ─── x-cmd ───────────────────────────────────────────────────────────────────
test -r "$HOME/.x-cmd.root/X.fish"; and source "$HOME/.x-cmd.root/X.fish"

# ─── Ghostty ─────────────────────────────────────────────────────────────────
if test "$TERM" = xterm-ghostty
    set -l ghostty_fish "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
    test -e "$ghostty_fish"; and source "$ghostty_fish"
end

# ─── CachyOS ─────────────────────────────────────────────────────────────────
test -r /usr/share/cachyos-fish-config/cachyos-config.fish; and source /usr/share/cachyos-fish-config/cachyos-config.fish >/dev/null 2>&1

# ─── Abbreviations ───────────────────────────────────────────────────────────
abbr -a py python3
abbr -a mv mv -iv
abbr -a rm rm -iv
abbr -a cp cp -iv
abbr -a c clear
abbr -a e $EDITOR
abbr -a --position anywhere -- --help '--help | bat -plhelp'
abbr -a --position anywhere -- -h '-h | bat -plhelp'

# ─── Aliases ─────────────────────────────────────────────────────────────────
alias cat='bat -pp'
alias sudo='sudo-rs '
alias doas='doas '
alias ed="$EDITOR "
alias sued="sudo-rs $EDITOR "
alias which='command -v'
alias yay='paru'
alias pip='python3 -m pip'
alias npm='bun'
alias npx='bunx'
alias mkdir='mkdir -pv'
alias ping='ping -c 4'
alias cls='clear'
alias ptch='command -q mpatch && mpatch || patch -Np1 <'
alias update='sudo-rs rm -f /var/lib/pacman/db.lck && paru -Syu --skipreview --noconfirm'

# ─── eza/ls ──────────────────────────────────────────────────────────────────
alias ls='eza -G --color --icons --group-directories-first --no-time --no-user --no-permissions --git-repos-no-status'
alias la='eza -a --color --icons --group-directories-first --smart-group'
alias ll='eza -l --color --icons --group-directories-first --smart-group'
alias lt='eza -aT --color --icons --group-directories-first --smart-group'
alias l.="eza -a | rg --color=auto -e '^\.'"

# ─── Keybinds ────────────────────────────────────────────────────────────────
functions -q toggle_sudo; and bind \cs toggle_sudo

# ─── Stealth Mode (disable mommy) ────────────────────────────────────────────
if test "$stealth" = 1
    functions -q __call_mommy; and functions -e __call_mommy
    function __disable_mommy --on-event fish_postexec
        functions -q __call_mommy; and functions -e __call_mommy
        functions -e __disable_mommy
    end
end

# ─── Done ────────────────────────────────────────────────────────────────────
set -U __done_notification_urgency_level low

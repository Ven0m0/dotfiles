#!/usr/bin/env fish
status -i; or return

# ─── Core Environment ────────────────────────────────────────────────────────
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"

set -gx EDITOR micro
set -gx VISUAL $EDITOR
set -gx VIEWER $EDITOR
set -gx GIT_EDITOR $EDITOR
set -gx SUDO_EDITOR $EDITOR
set -gx SYSTEMD_EDITOR $EDITOR

set -gx PAGER bat
set -gx GIT_PAGER delta
set -gx MANPAGER "env BATMAN_IS_BEING_MANPAGER=yes bash /usr/bin/batman"
set -gx MANROFFOPT "-c"
set -gx LESSOPEN "|/usr/bin/batpipe %s"
set -gx LESS "$LESS -R"
set -gx LESSHISTFILE -
set -gx BATPIPE color
set -e LESSCLOSE

set -gx GPG_TTY (tty)
set -gx COLORTERM truecolor
set -gx _JAVA_OPTIONS '-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true'

# ─── Wayland ─────────────────────────────────────────────────────────────────
if test "$XDG_SESSION_TYPE" = wayland
    set -gx WAYLAND 1
    set -gx SDL_VIDEODRIVER wayland
    set -gx QT_QPA_PLATFORM 'wayland;xcb'
    set -gx QT_QPA_PLATFORMTHEME qt6ct
    set -gx GDK_BACKEND 'wayland,x11'
    set -gx MOZ_DBUS_REMOTE 1
    set -gx MOZ_ENABLE_WAYLAND 1
    set -gx MOZ_ENABLE_XINPUT2 1
    set -gx _JAVA_AWT_WM_NONREPARENTING 1
    set -gx BEMENU_BACKEND wayland
    set -gx CLUTTER_BACKEND wayland
    set -gx ECORE_EVAS_ENGINE wayland_egl
    set -gx ELM_ENGINE wayland_egl
    set -gx ELECTRON_OZONE_PLATFORM_HINT wayland
end

# ─── FZF ─────────────────────────────────────────────────────────────────────
set -gx FZF_DEFAULT_COMMAND 'fd -tf -H --size +1k --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -Ux FZF_LEGACY_KEYBINDINGS 0
set -gx SKIM_DEFAULT_COMMAND 'fd -tf -F --exclude .git; or rg --files; or find -O3 .'
set -gx SKIM_DEFAULT_OPTIONS $FZF_DEFAULT_OPTS

# ─── Fish Options ────────────────────────────────────────────────────────────
set -U fish_prompt_pwd_dir_length 2
set -U fish_term24bit 1
set -U fish_autosuggestion_enabled 1
set -U __fish_git_prompt_show_informative_status 0
set -U __fish_git_prompt_showupstream none
set -g __fish_git_prompt_show_informative_status 0

# ─── Async Prompt ────────────────────────────────────────────────────────────
set -U async_prompt_enable 1
set -U async_prompt_functions fish_prompt

# ─── Paths ───────────────────────────────────────────────────────────────────
fish_add_path -g ~/.bun/bin ~/.local/bin /usr/local/bin ~/bin ~/.cargo/bin /usr/lib/ccache/bin

# ─── SSH Agent (cached) ──────────────────────────────────────────────────────
set -gx SSH_AUTH_SOCK ~/.ssh/ssh-agent.sock
if not test -S $SSH_AUTH_SOCK
    eval (ssh-agent -c -s) >/dev/null 2>&1
end

# ─── Greeting (cached, skip if terminal not interactive) ─────────────────────
function fish_greeting
    set -l cache "$XDG_CACHE_HOME/fish-greeting-shown"
    if command -q hyfetch; and not test -f $cache
        LC_CTYPE=C LC_COLLATE=C hyfetch -m 8bit
        touch $cache &
    else if command -q fastfetch; and not test -f $cache
        LC_CTYPE=C LC_COLLATE=C fastfetch --thread true --detect-version false
        touch $cache &
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
init_tool vivid "set -gx LS_COLORS (vivid generate molokai)"
init_tool pay-respects "pay-respects fish --alias"

# ─── Basher ──────────────────────────────────────────────────────────────────
if test -d ~/.basher
    fish_add_path ~/.basher/bin
    init_tool basher "basher init - fish"
end

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

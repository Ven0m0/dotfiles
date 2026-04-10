status -i >/dev/null 2>&1 || return
# ─── Fish Setup ─────────────────────────
set -g __fish_git_prompt_show_informative_status 0

# ─── Keybinds ─────────────────────────
functions -q toggle_sudo; and bind \cs toggle_sudo

# ─── Environment ──────────────────────
set -gx EDITOR micro
set -gx VISUAL $EDITOR
set -gx VIEWER $EDITOR
set -gx GIT_EDITOR $EDITOR
set -gx SYSTEMD_EDITOR $EDITOR
set -gx PAGER bat
abbr -a --position anywhere -- --help '--help | bat -plhelp'
abbr -a --position anywhere -- -h '-h | bat -plhelp'
set -gx GIT_PAGER delta
set -gx MANPAGER "env BATMAN_IS_BEING_MANPAGER=yes bash /usr/bin/batman"
set -gx MANROFFOPT "-c"
set -gx LESSOPEN "|/usr/bin/batpipe %s"
set -gx LESS "$LESS -R"
set -gx LESSHISTFILE -
set -gx BATPIPE color
set -e LESSCLOSE

# ─── Fuzzy Finders ───────────────────
_evalcache fzf --fish 2>/dev/null

# ─── Fetch Command ────────────────────
switch "$stealth"
    case 1
        # disable mommy plugin
        if functions -q __call_mommy
            functions -e __call_mommy
        end
        function __disable_mommy --on-event fish_postexec
            if functions -q __call_mommy
                functions -e __call_mommy
            end
            functions -e __disable_mommy
        end
    case 0
    case '*'
end

# Ghostty integration
if test "$TERM" = xterm-ghostty -a -e "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
end

# ─── Abbreviations & Aliases ─────────
abbr -a mv mv -iv
abbr -a rm rm -iv
abbr -a cp cp -iv
abbr -a sort sort -h
abbr -a df df -h
abbr -a free free -h
abbr -a ip ip --color=auto
abbr -a du du -hcsx
abbr -a c clear
abbr -a e $EDITOR

# https://www.reddit.com/r/fishshell/comments/1g3nh1u/any_way_to_create_functions_with_dynamic_names/
function qcd
    echo cd (string repeat -n (string length $argv) ../)
end
abbr -a qcd --position command --regex 'q+' --function qcd

set -gx SUDO sudo-rs
alias sudo='sudo-rs '
alias sudo-rs='sudo-rs '
alias doas='doas '
alias mkdir='mkdir -pv'
alias rmdir='rm -rf --preserve-root'
alias ping='ping -c 4'
alias cls='clear'

alias update='sudo rm -f /var/lib/pacman/db.lck && paru -Syu --skipreview --noconfirm'

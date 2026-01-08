status -i >/dev/null 2>&1 || return

test -r /usr/share/cachyos-fish-config/cachyos-config.fish && source /usr/share/cachyos-fish-config/cachyos-config.fish >/dev/null 2>&1

function fish_greeting
    LC_CTYPE=C LC_COLLATE=C hyfetch -m 8bit
end

function init_tool
    if command -qs $argv[1]
        if type -q _evalcache
            # Cache the init command output to avoid running binaries on every startup
            _evalcache "$argv[2]" >/dev/null 2>&1
        else
            eval "$argv[2]" >/dev/null 2>&1
        end
    end
end

set -U __done_notification_urgency_level low
set -gx GPG_TTY (tty)
set -gx COLORTERM truecolor
set -gx FZF_DEFAULT_COMMAND 'fd -tf -H --size +1k --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx EDITOR micro
set -gx SUDO_EDITOR micro
set -gx PAGER bat
set -gx GIT_PAGER delta
alias cat="bat -pp"
alias sudo="sudo-rs "
alias ed="$EDITOR "
alias sued="sudo-rs $EDITOR "

fish_add_path ~/bun/bin ~/.local/bin/ /usr/local/bin ~/bin /usr/lib/ccache/bin/ ~/.cargo/bin/

# Tool Initializations
init_tool fzf "fzf --fish"
init_tool starship "starship init fish" && enable_transience
init_tool zoxide "zoxide init --cmd cd fish"
init_tool mise "mise activate fish"
# init_tool zellij "zellij setup --generate-auto-start fish"
set -gx LS_COLORS "$(vivid generate molokai)"

# SSH agent
set -gx SSH_AUTH_SOCK ~/.ssh/ssh-agent.sock
test -e $SSH_AUTH_SOCK || eval (ssh-agent -c -s)

alias ls='eza -al --color --icons --group-directories-first --smart-group'
alias la='eza -a --color --icons --group-directories-first --smart-group'
alias ll='eza -l --color --icons --group-directories-first --smart-group'
alias lt='eza -aT --color --icons --group-directories-first --smart-group'
alias l.="eza -a | rg -. --color=auto -e '^\.'"

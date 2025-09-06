# ─── Only for Interactive Shells ────────────────────────────────────────────────
if status --is-interactive >/dev/null 2>&1
    # Aliases: safe & efficient defaults
    alias cat='\bat -pp'

    # My stuff
    alias ptch='patch -p1 <'
    alias updatesh='curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Updates.sh | bash'
    alias clearnsh='curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Clean.sh | bash'

    # Enable aliases to be sudo’ed
    alias sudo='sudo '
    alias doas='doas '
    alias sudo-rs='sudo-rs '

    # Creates parent directories on demand.
    alias mkdir='mkdir -p '
    alias ed='$EDITOR '

    # Stops ping after sending 4 ECHO_REQUEST packets.
    alias ping='ping -c 4'

    if type -qf rg
        functions -e grep; and alias grep="LC_ALL=C rg -S --color=auto"
        functions -e fgrep; and alias egrep="rg -SF --color=auto"
        functions -e egrep; and alias fgrep="rg -Se --color=auto"
        functions -e rg; and alias rg="LC_ALL=C rg -NFS --no-unicode --color=auto"
    else if type -q ugrep
        functions -e grep; and alias grep="LC_ALL=C ugrep --color=auto"
        functions -e fgrep; and alias egrep="ugrep -F --color=auto"
        functions -e egrep; and alias fgrep="ugrep -E --color=auto"
        functions -e ug; and alias ug='LC_ALL=C ug -sjFU -J $(nproc 2>/dev/null) --color=auto'
    else
        functions -e grep; and alias grep="LC_ALL=C grep --color=auto"
        functions -e fgrep; and alias fgrep="fgrep --color=auto"
        functions -e egrep; and alias egrep="egrep --color=auto"
    end

    # Reset
    alias clear='command clear; and fish_greeting 2>/dev/null'
    alias cls='command clear; and fish_greeting 2>/dev/null'
    abbr -a c clear

    abbr -a py 'python3'

    # Fix weird fish binding, restore ctrl+v
    #bind --erase \cv

    # Bind sudo to ESC ESC
    #.~/.config/fish/functions/toggle_sudo.fish
    bind \e\e toggle_sudo


    function mkdircd
        command mkdir -p -- $argv; and command cd $argv[-1]
    end
    function ip
        command ip --color=auto -- $argv
    end
end

# ─── Only for Interactive Shells ────────────────────────────────────────────────
if status -i >/dev/null 2>&1
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

    # Reset
    alias clear='command clear; and fish_greeting 2>/dev/null'
    alias cls='command clear; and fish_greeting 2>/dev/null'
    abbr -a c clear

    abbr -a py 'python3'

    # Fix weird fish binding, restore ctrl+v
    #bind --erase \cv

    function mkdircd
        command mkdir -p -- $argv; and command cd $argv[-1]
    end
    function ip
        command ip --color=auto -- $argv
    end
end

function fuck -d "Run last command with available privilege escalation"
    # Get the last command from history
    set -l last_cmd (history --max=1)
    # Detect available command for privilege escalation
    if type -q sudo-rs
        set -l runner 'sudo-rs'
    else if type -q doas
        set -l runner 'doas'
    else if type -q sudo
        set -l runner 'sudo'
    else
        echo "No privilege escalation command found (sudo-rs, doas, run0, sudo)."
        return 1
    end
    # Run the last command with the chosen runner
    eval "$runner $last_cmd"
end

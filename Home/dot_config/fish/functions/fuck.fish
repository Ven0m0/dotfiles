function fuck -d "Re-run last command with sudo/doas"
    set -l last_cmd (history --max=1)
    set -l runner (command -q sudo-rs && echo sudo-rs || command -q doas && echo doas || echo sudo)
    eval "$runner $last_cmd"
end

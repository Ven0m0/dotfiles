#!/usr/bin/env fish
status -i; or return

# ─── Lazy Completions ────────────────────────────────────────────────────────
set -l lazy_cmds fisher procs rg
for cmd in $lazy_cmds
    set -l compfile "$__fish_config_dir/completions/$cmd.fish"
    set -l disabled "$compfile.disabled"
    test -f $compfile; and not test -f $disabled; and mv $compfile $disabled
    set -l fn "__lazy_${cmd}_comp"
    functions -q $fn; and continue
    function $fn -V cmd -V disabled
        complete -c $cmd -e
        source $disabled 2>/dev/null
        functions -e $fn
        commandline -f repaint
    end
    complete -c $cmd -f -a "($fn)"
end

# ─── Lazy FZF ────────────────────────────────────────────────────────────────
function fzf
    functions -e fzf
    fzf --fish | source
    fzf $argv
end

# ─── Lazy pay-respects ───────────────────────────────────────────────────────
function pay-respects
    functions -e pay-respects
    pay-respects fish --alias | source
    pay-respects $argv
end

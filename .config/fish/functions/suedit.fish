function suedit -d 'Edit a file as root using $EDITOR'
    set -q EDITOR; or set EDITOR nano
    type -q sudo-rs; and sudo-rs $EDITOR $argv; or type -q doas; and doas $EDITOR $argv; or sudo $EDITOR $argv
end

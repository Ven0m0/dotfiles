function edit -d "alias edit $EDITOR"
    set -q EDITOR; or set EDITOR nano
    $EDITOR $argv
end

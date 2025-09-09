function edit -w "$EDITOR" -d "alias edit $EDITOR"
  if type -q "$EDITOR"
    $EDITOR $argv
  end
end

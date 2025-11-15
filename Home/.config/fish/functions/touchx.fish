function touchx --description="Touch and open in editor"
    if test (count $argv) -ne 1
        echo "Usage: touchx <file>"
        return 1
    end

    set file $argv[1]

    # Check if EDITOR is set
    if not set -q EDITOR
        echo "Error: \$EDITOR is not set. Please configure your preferred editor using 'set -Ux EDITOR your-editor'"
        return 1
    end

    # Check if the specified editor is executable
    if not command -q $EDITOR
        echo "Error: Editor '$EDITOR' not found. Please make sure it is installed and in your PATH."
        return 1
    end

    # Try to touch the file
    touch $file

    # Check if touch was successful
    if test $status -ne 0
        echo "Error: Unable to create or update file '$file'. Please check file permissions and try again."
        return 1
    end

    # Open the file in the editor
    $EDITOR $file
end

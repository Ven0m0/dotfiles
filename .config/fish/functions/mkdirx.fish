function mkdirx --description="mkdir and cd"
    # Check if an argument is provided
    if test (count $argv) -ne 1
        echo "Usage: mkdirx folder"
        return 1
    end

    set folder $argv[1]

    # Create the directory
    mkdir -p $folder

    # Check if mkdir was successful
    if test $status -ne 0
        echo "Error: Failed to create directory $folder"
        return $status
    end

    # Change to the newly created directory
    cd $folder

    # Check if cd was successful
    if test $status -ne 0
        echo "Error: Failed to change to directory $folder"
        return $status
    end
end

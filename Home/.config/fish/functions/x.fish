function x -a file -d "Extract archive by extension"
    not test -f "$file"; and echo "Usage: x file" && return 1
    switch "$file"
        case '*.tar.bz2' '*.tbz2'
            tar xjf $file
        case '*.tar.gz' '*.tgz'
            tar xzf $file
        case '*.tar'
            tar xf $file
        case '*.bz2'
            bunzip2 $file
        case '*.gz'
            gunzip $file
        case '*.zip'
            unzip $file
        case '*.rar'
            unrar x $file
        case '*.7z'
            7z x $file
        case '*.Z'
            uncompress $file
        case '*'
            echo "'$file' cannot be extracted"
            return 1
    end
end

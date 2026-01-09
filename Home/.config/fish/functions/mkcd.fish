function mkcd -d "Create dir(s) and cd to first"
    test (count $argv) -eq 0; and echo "Usage: mkcd dir [...]" && return 1
    mkdir -p $argv[1]; and cd $argv[1]
end

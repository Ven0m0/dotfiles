complete mkdirx --no-files

function __mkdirx_folder_complete
    set -l options
    for option in (command ls)
        if test -d $option
            set options $options $option
        end
    end
    echo $options
end

complete -c mkdirx -a "(__mkdirx_folder_complete)" -d "Directory name" -r
complete -c mkdirx -a "(__mkdirx_folder_complete)" -d "Directory name" -r -f

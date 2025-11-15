complete touchx --no-files

function __touchx_file_complete
    set -l options
    for option in (command ls)
        if test -f $option
            set options $options $option
        end
    end
    echo $options
end

complete -c touchx -a "(__touchx_file_complete)" -d "File name" -r
complete -c touchx -a "(__touchx_file_complete)" -d "File name" -r -f

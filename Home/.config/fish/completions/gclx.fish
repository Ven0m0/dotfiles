complete gclx --no-files

complete gclx -l bare --description "Clone as a bare repository" --condition "not __fish_seen_argument --bare"

function __gclx_owner_complete
    set -l options
    for option in (command ls)
        if string match -q "*/*" $option
            set owner (echo $option | cut -d '/' -f 1)
            set repo (echo $option | cut -d '/' -f 2)
            if not contains $owner $options
                set options $options $owner
            end
        end
    end
    echo $options
end

complete -c gclx -a "(__gclx_owner_complete)" -d "Owner/organization name" -r
complete -c gclx -a "(__gclx_owner_complete)" -d "Owner/organization name" -r -f

function __gclx_repo_complete
    set -l owner (status current-command | grep -o 'gclx [^ ]*' | cut -d ' ' -f 2)
    set -l options
    for option in (command ls)
        if string match -q "$owner/*" $option
            set repo (echo $option | sed "s|^$owner/||")
            if not contains $repo $options
                set options $options $repo
            end
        end
    end
    echo $options
end

complete -c gclx -a "(__gclx_repo_complete)" -d "Repository name" -r
complete -c gclx -a "(__gclx_repo_complete)" -d "Repository name" -r -f

function ls --wraps='eza -G --color --group-directories-first --icons --no-time --no-user --no-permissions --git-repos-no-status' --description 'alias ls=eza -G --color --group-directories-first --icons --no-time --no-user --no-permissions --git-repos-no-status'
    eza -G --color --group-directories-first --icons --no-time --no-user --no-permissions --git-repos-no-status $argv
end

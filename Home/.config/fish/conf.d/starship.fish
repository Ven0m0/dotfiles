status -i >/dev/null 2>&1 || return
command -qs starship || return
function starship_transient_prompt_func
    starship module character
end
if type -q _evalcache
    function my_async_prompt
        _evalcache starship prompt
    end
    set -g async_prompt_functions my_async_prompt
    _evalcache_async starship init fish
else
    starship init fish | source
end
enable_transience

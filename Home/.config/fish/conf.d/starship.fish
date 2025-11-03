status -i >/dev/null 2>&1 || return
type -q starship >/dev/null 2>&1 || return
function starship_transient_prompt_func
  starship module character
end
function starship_transient_rprompt_func
    starship module time
end
if type -q _evalcache
  _evalcache starship init fish
else
  starship init fish | source
end
enable_transience

status -i >/dev/null 2>&1 || return
type -q starship || return
function starship_transient_prompt_func
  starship module character 2>/dev/null
end
function starship_transient_rprompt_func
    starship module time 2>/dev/null
end
if type -q _evalcache
  _evalcache starship init fish 2>/dev/null
else
  starship init fish 2>/dev/null | source 2>/dev/null
end
enable_transience >/dev/null 2>&1

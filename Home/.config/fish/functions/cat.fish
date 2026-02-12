function cat --wraps='bat -pp' --description 'cat -> bat'
    if not command -q bat
        command cat -s $argv
        return $status
    end
    command bat -pp $argv
end

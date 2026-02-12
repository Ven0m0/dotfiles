function git --wraps=zagi --description 'better git for agents'
    if command -q zagi
        LC_ALL=C zagi $argv
    else
        LC_ALL=C git -c protocol.version=2 -c http.version="HTTP/2" -c index.version=4 $argv
    end
end

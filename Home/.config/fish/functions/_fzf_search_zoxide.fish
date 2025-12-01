function _fzf_search_zoxide --description "Start a zoxide interactive search. Replaces the current token with resulting selection"
    set -f zoxide_cmd (command -v zoxide || echo "zoxide")
    set --append zoxide_cmd query --interactive

    set -f token (commandline --current-token)

    set --append zoxide_cmd $token
    set -f selection ($zoxide_cmd 2> /dev/null)

    if test $status -eq 0
        commandline --current-token --replace -- (string escape -- $selection | string join ' ')
    end

    commandline --function repaint
end

_zoi() {
    local i cur prev opts cmd
    COMPREPLY=()
    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
        cur="$2"
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
    fi
    prev="$3"
    cmd=""
    opts=""

    for i in "${COMP_WORDS[@]:0:COMP_CWORD}"
    do
        case "${cmd},${i}" in
            ",$1")
                cmd="zoi"
                ;;
            zoi,about)
                cmd="zoi__about"
                ;;
            zoi,autoremove)
                cmd="zoi__autoremove"
                ;;
            zoi,check)
                cmd="zoi__check"
                ;;
            zoi,clean)
                cmd="zoi__clean"
                ;;
            zoi,create)
                cmd="zoi__create"
                ;;
            zoi,env)
                cmd="zoi__env"
                ;;
            zoi,exec)
                cmd="zoi__exec"
                ;;
            zoi,extension)
                cmd="zoi__extension"
                ;;
            zoi,files)
                cmd="zoi__files"
                ;;
            zoi,generate-completions)
                cmd="zoi__generate__completions"
                ;;
            zoi,generate-manual)
                cmd="zoi__generate__manual"
                ;;
            zoi,help)
                cmd="zoi__help"
                ;;
            zoi,helper)
                cmd="zoi__helper"
                ;;
            zoi,info)
                cmd="zoi__info"
                ;;
            zoi,install)
                cmd="zoi__install"
                ;;
            zoi,list)
                cmd="zoi__list"
                ;;
            zoi,man)
                cmd="zoi__man"
                ;;
            zoi,owner)
                cmd="zoi__owner"
                ;;
            zoi,package)
                cmd="zoi__package"
                ;;
            zoi,pgp)
                cmd="zoi__pgp"
                ;;
            zoi,pin)
                cmd="zoi__pin"
                ;;
            zoi,repo)
                cmd="zoi__repo"
                ;;
            zoi,rollback)
                cmd="zoi__rollback"
                ;;
            zoi,run)
                cmd="zoi__run"
                ;;
            zoi,search)
                cmd="zoi__search"
                ;;
            zoi,setup)
                cmd="zoi__setup"
                ;;
            zoi,shell)
                cmd="zoi__shell"
                ;;
            zoi,show)
                cmd="zoi__show"
                ;;
            zoi,sync)
                cmd="zoi__sync"
                ;;
            zoi,telemetry)
                cmd="zoi__telemetry"
                ;;
            zoi,uninstall)
                cmd="zoi__uninstall"
                ;;
            zoi,unpin)
                cmd="zoi__unpin"
                ;;
            zoi,update)
                cmd="zoi__update"
                ;;
            zoi,upgrade)
                cmd="zoi__upgrade"
                ;;
            zoi,version)
                cmd="zoi__version"
                ;;
            zoi,why)
                cmd="zoi__why"
                ;;
            zoi__extension,add)
                cmd="zoi__extension__add"
                ;;
            zoi__extension,help)
                cmd="zoi__extension__help"
                ;;
            zoi__extension,remove)
                cmd="zoi__extension__remove"
                ;;
            zoi__extension__help,add)
                cmd="zoi__extension__help__add"
                ;;
            zoi__extension__help,help)
                cmd="zoi__extension__help__help"
                ;;
            zoi__extension__help,remove)
                cmd="zoi__extension__help__remove"
                ;;
            zoi__help,about)
                cmd="zoi__help__about"
                ;;
            zoi__help,autoremove)
                cmd="zoi__help__autoremove"
                ;;
            zoi__help,check)
                cmd="zoi__help__check"
                ;;
            zoi__help,clean)
                cmd="zoi__help__clean"
                ;;
            zoi__help,create)
                cmd="zoi__help__create"
                ;;
            zoi__help,env)
                cmd="zoi__help__env"
                ;;
            zoi__help,exec)
                cmd="zoi__help__exec"
                ;;
            zoi__help,extension)
                cmd="zoi__help__extension"
                ;;
            zoi__help,files)
                cmd="zoi__help__files"
                ;;
            zoi__help,generate-completions)
                cmd="zoi__help__generate__completions"
                ;;
            zoi__help,generate-manual)
                cmd="zoi__help__generate__manual"
                ;;
            zoi__help,help)
                cmd="zoi__help__help"
                ;;
            zoi__help,helper)
                cmd="zoi__help__helper"
                ;;
            zoi__help,info)
                cmd="zoi__help__info"
                ;;
            zoi__help,install)
                cmd="zoi__help__install"
                ;;
            zoi__help,list)
                cmd="zoi__help__list"
                ;;
            zoi__help,man)
                cmd="zoi__help__man"
                ;;
            zoi__help,owner)
                cmd="zoi__help__owner"
                ;;
            zoi__help,package)
                cmd="zoi__help__package"
                ;;
            zoi__help,pgp)
                cmd="zoi__help__pgp"
                ;;
            zoi__help,pin)
                cmd="zoi__help__pin"
                ;;
            zoi__help,repo)
                cmd="zoi__help__repo"
                ;;
            zoi__help,rollback)
                cmd="zoi__help__rollback"
                ;;
            zoi__help,run)
                cmd="zoi__help__run"
                ;;
            zoi__help,search)
                cmd="zoi__help__search"
                ;;
            zoi__help,setup)
                cmd="zoi__help__setup"
                ;;
            zoi__help,shell)
                cmd="zoi__help__shell"
                ;;
            zoi__help,show)
                cmd="zoi__help__show"
                ;;
            zoi__help,sync)
                cmd="zoi__help__sync"
                ;;
            zoi__help,telemetry)
                cmd="zoi__help__telemetry"
                ;;
            zoi__help,uninstall)
                cmd="zoi__help__uninstall"
                ;;
            zoi__help,unpin)
                cmd="zoi__help__unpin"
                ;;
            zoi__help,update)
                cmd="zoi__help__update"
                ;;
            zoi__help,upgrade)
                cmd="zoi__help__upgrade"
                ;;
            zoi__help,version)
                cmd="zoi__help__version"
                ;;
            zoi__help,why)
                cmd="zoi__help__why"
                ;;
            zoi__help__extension,add)
                cmd="zoi__help__extension__add"
                ;;
            zoi__help__extension,remove)
                cmd="zoi__help__extension__remove"
                ;;
            zoi__help__helper,get-hash)
                cmd="zoi__help__helper__get__hash"
                ;;
            zoi__help__package,build)
                cmd="zoi__help__package__build"
                ;;
            zoi__help__package,install)
                cmd="zoi__help__package__install"
                ;;
            zoi__help__pgp,add)
                cmd="zoi__help__pgp__add"
                ;;
            zoi__help__pgp,list)
                cmd="zoi__help__pgp__list"
                ;;
            zoi__help__pgp,remove)
                cmd="zoi__help__pgp__remove"
                ;;
            zoi__help__pgp,search)
                cmd="zoi__help__pgp__search"
                ;;
            zoi__help__pgp,show)
                cmd="zoi__help__pgp__show"
                ;;
            zoi__help__pgp,verify)
                cmd="zoi__help__pgp__verify"
                ;;
            zoi__help__repo,add)
                cmd="zoi__help__repo__add"
                ;;
            zoi__help__repo,git)
                cmd="zoi__help__repo__git"
                ;;
            zoi__help__repo,list)
                cmd="zoi__help__repo__list"
                ;;
            zoi__help__repo,remove)
                cmd="zoi__help__repo__remove"
                ;;
            zoi__help__repo__git,list)
                cmd="zoi__help__repo__git__list"
                ;;
            zoi__help__repo__git,rm)
                cmd="zoi__help__repo__git__rm"
                ;;
            zoi__help__repo__list,all)
                cmd="zoi__help__repo__list__all"
                ;;
            zoi__help__sync,add)
                cmd="zoi__help__sync__add"
                ;;
            zoi__help__sync,list)
                cmd="zoi__help__sync__list"
                ;;
            zoi__help__sync,remove)
                cmd="zoi__help__sync__remove"
                ;;
            zoi__help__sync,set)
                cmd="zoi__help__sync__set"
                ;;
            zoi__helper,get-hash)
                cmd="zoi__helper__get__hash"
                ;;
            zoi__helper,help)
                cmd="zoi__helper__help"
                ;;
            zoi__helper__help,get-hash)
                cmd="zoi__helper__help__get__hash"
                ;;
            zoi__helper__help,help)
                cmd="zoi__helper__help__help"
                ;;
            zoi__package,build)
                cmd="zoi__package__build"
                ;;
            zoi__package,help)
                cmd="zoi__package__help"
                ;;
            zoi__package,install)
                cmd="zoi__package__install"
                ;;
            zoi__package__help,build)
                cmd="zoi__package__help__build"
                ;;
            zoi__package__help,help)
                cmd="zoi__package__help__help"
                ;;
            zoi__package__help,install)
                cmd="zoi__package__help__install"
                ;;
            zoi__pgp,add)
                cmd="zoi__pgp__add"
                ;;
            zoi__pgp,help)
                cmd="zoi__pgp__help"
                ;;
            zoi__pgp,list)
                cmd="zoi__pgp__list"
                ;;
            zoi__pgp,remove)
                cmd="zoi__pgp__remove"
                ;;
            zoi__pgp,search)
                cmd="zoi__pgp__search"
                ;;
            zoi__pgp,show)
                cmd="zoi__pgp__show"
                ;;
            zoi__pgp,verify)
                cmd="zoi__pgp__verify"
                ;;
            zoi__pgp__help,add)
                cmd="zoi__pgp__help__add"
                ;;
            zoi__pgp__help,help)
                cmd="zoi__pgp__help__help"
                ;;
            zoi__pgp__help,list)
                cmd="zoi__pgp__help__list"
                ;;
            zoi__pgp__help,remove)
                cmd="zoi__pgp__help__remove"
                ;;
            zoi__pgp__help,search)
                cmd="zoi__pgp__help__search"
                ;;
            zoi__pgp__help,show)
                cmd="zoi__pgp__help__show"
                ;;
            zoi__pgp__help,verify)
                cmd="zoi__pgp__help__verify"
                ;;
            zoi__repo,add)
                cmd="zoi__repo__add"
                ;;
            zoi__repo,git)
                cmd="zoi__repo__git"
                ;;
            zoi__repo,help)
                cmd="zoi__repo__help"
                ;;
            zoi__repo,list)
                cmd="zoi__repo__list"
                ;;
            zoi__repo,remove)
                cmd="zoi__repo__remove"
                ;;
            zoi__repo__git,help)
                cmd="zoi__repo__git__help"
                ;;
            zoi__repo__git,list)
                cmd="zoi__repo__git__list"
                ;;
            zoi__repo__git,rm)
                cmd="zoi__repo__git__rm"
                ;;
            zoi__repo__git__help,help)
                cmd="zoi__repo__git__help__help"
                ;;
            zoi__repo__git__help,list)
                cmd="zoi__repo__git__help__list"
                ;;
            zoi__repo__git__help,rm)
                cmd="zoi__repo__git__help__rm"
                ;;
            zoi__repo__help,add)
                cmd="zoi__repo__help__add"
                ;;
            zoi__repo__help,git)
                cmd="zoi__repo__help__git"
                ;;
            zoi__repo__help,help)
                cmd="zoi__repo__help__help"
                ;;
            zoi__repo__help,list)
                cmd="zoi__repo__help__list"
                ;;
            zoi__repo__help,remove)
                cmd="zoi__repo__help__remove"
                ;;
            zoi__repo__help__git,list)
                cmd="zoi__repo__help__git__list"
                ;;
            zoi__repo__help__git,rm)
                cmd="zoi__repo__help__git__rm"
                ;;
            zoi__repo__help__list,all)
                cmd="zoi__repo__help__list__all"
                ;;
            zoi__repo__list,all)
                cmd="zoi__repo__list__all"
                ;;
            zoi__repo__list,help)
                cmd="zoi__repo__list__help"
                ;;
            zoi__repo__list__help,all)
                cmd="zoi__repo__list__help__all"
                ;;
            zoi__repo__list__help,help)
                cmd="zoi__repo__list__help__help"
                ;;
            zoi__sync,add)
                cmd="zoi__sync__add"
                ;;
            zoi__sync,help)
                cmd="zoi__sync__help"
                ;;
            zoi__sync,list)
                cmd="zoi__sync__list"
                ;;
            zoi__sync,remove)
                cmd="zoi__sync__remove"
                ;;
            zoi__sync,set)
                cmd="zoi__sync__set"
                ;;
            zoi__sync__help,add)
                cmd="zoi__sync__help__add"
                ;;
            zoi__sync__help,help)
                cmd="zoi__sync__help__help"
                ;;
            zoi__sync__help,list)
                cmd="zoi__sync__help__list"
                ;;
            zoi__sync__help,remove)
                cmd="zoi__sync__help__remove"
                ;;
            zoi__sync__help,set)
                cmd="zoi__sync__help__set"
                ;;
            *)
                ;;
        esac
    done

    case "$cmd" in
        zoi)
            opts="-v -y -h --version --yes --help generate-completions generate-manual version about info check sync list show pin unpin update install uninstall run env upgrade autoremove why owner files search shell setup exec clean repo telemetry create extension rollback man package pgp helper help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__about)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__autoremove)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__check)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__clean)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__create)
            opts="-y -h --yes --help <SOURCE> [APP_NAME]"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__env)
            opts="-y -h --yes --help [ENV_ALIAS]"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__exec)
            opts="-y -h --upstream --cache --local --yes --help [ARGS]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__extension)
            opts="-y -h --yes --help add remove help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__extension__add)
            opts="-y -h --yes --help <NAME>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__extension__help)
            opts="add remove help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__extension__help__add)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__extension__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__extension__help__remove)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__extension__remove)
            opts="-y -h --yes --help <NAME>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__files)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__generate__completions)
            opts="-y -h --yes --help bash elvish fish powershell zsh"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__generate__manual)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help)
            opts="generate-completions generate-manual version about info check sync list show pin unpin update install uninstall run env upgrade autoremove why owner files search shell setup exec clean repo telemetry create extension rollback man package pgp helper help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__about)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__autoremove)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__check)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__clean)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__create)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__env)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__exec)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__extension)
            opts="add remove"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__extension__add)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__extension__remove)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__files)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__generate__completions)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__generate__manual)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__helper)
            opts="get-hash"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__helper__get__hash)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__info)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__install)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__man)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__owner)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__package)
            opts="build install"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__package__build)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__package__install)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__pgp)
            opts="add remove list search show verify"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__pgp__add)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__pgp__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__pgp__remove)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__pgp__search)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__pgp__show)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__pgp__verify)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__pin)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__repo)
            opts="add remove list git"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__repo__add)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__repo__git)
            opts="list rm"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__repo__git__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__repo__git__rm)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__repo__list)
            opts="all"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__repo__list__all)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__repo__remove)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__rollback)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__run)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__search)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__setup)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__shell)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__show)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__sync)
            opts="add remove list set"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__sync__add)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__sync__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__sync__remove)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__sync__set)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__telemetry)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__uninstall)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__unpin)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__update)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__upgrade)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__version)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__help__why)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__helper)
            opts="-y -h --yes --help get-hash help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__helper__get__hash)
            opts="-y -h --hash --yes --help <SOURCE>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --hash)
                    COMPREPLY=("$(compgen -W "sha512 sha256" -- "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__helper__help)
            opts="get-hash help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__helper__help__get__hash)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__helper__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__info)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__install)
            opts="-y -h --repo --force --all-optional --scope --local --global --save --type --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --repo)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --scope)
                    COMPREPLY=("$(compgen -W "user system project" -- "$cur")")
                    return 0
                    ;;
                --type)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__list)
            opts="-a -t -y -h --all --repo --type --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --repo)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --type)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                -t)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__man)
            opts="-y -h --upstream --raw --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__owner)
            opts="-y -h --yes --help <PATH>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__package)
            opts="-y -h --yes --help build install help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__package__build)
            opts="-p -y -h --type --platform --sign --yes --help <PACKAGE_FILE>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --type)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --platform)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                -p)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --sign)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__package__help)
            opts="build install help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__package__help__build)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__package__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__package__help__install)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__package__install)
            opts="-h --scope --yes --help <PACKAGE_FILE>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --scope)
                    COMPREPLY=("$(compgen -W "user system" -- "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp)
            opts="-y -h --yes --help add remove list search show verify help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__add)
            opts="-y -h --path --fingerprint --url --name --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --path)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --fingerprint)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --url)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --name)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__help)
            opts="add remove list search show verify help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__help__add)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__help__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__help__remove)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__help__search)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__help__show)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__help__verify)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__list)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__remove)
            opts="-y -h --fingerprint --yes --help [NAME]"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --fingerprint)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__search)
            opts="-y -h --yes --help <TERM>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__show)
            opts="-y -h --yes --help <NAME>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pgp__verify)
            opts="-y -h --file --sig --key --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --file)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --sig)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --key)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__pin)
            opts="-y -h --yes --help <VERSION>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo)
            opts="-y -h --yes --help add remove list git help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__add)
            opts="-y -h --yes --help [REPO_OR_URL]"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__git)
            opts="-y -h --yes --help list rm help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__git__help)
            opts="list rm help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__git__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__git__help__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__git__help__rm)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__git__list)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__git__rm)
            opts="-y -h --yes --help <REPO_NAME>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__help)
            opts="add remove list git help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__help__add)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__help__git)
            opts="list rm"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__help__git__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__help__git__rm)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__help__list)
            opts="all"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__help__list__all)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__help__remove)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__list)
            opts="-y -h --yes --help all help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__list__all)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__list__help)
            opts="all help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__list__help__all)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__list__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__repo__remove)
            opts="-y -h --yes --help <REPO_NAME>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__rollback)
            opts="-y -h --last-transaction --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__run)
            opts="-y -h --yes --help [CMD_ALIAS] [ARGS]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__search)
            opts="-t -y -h --repo --type --tag --yes --help <SEARCH_TERM>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --repo)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --type)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --tag)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                -t)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__setup)
            opts="-y -h --scope --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --scope)
                    COMPREPLY=("$(compgen -W "user system" -- "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__shell)
            opts="-y -h --yes --help bash elvish fish powershell zsh"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__show)
            opts="-y -h --raw --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__sync)
            opts="-v -y -h --verbose --fallback --no-pm --no-shell-setup --yes --help add remove list set help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__sync__add)
            opts="-y -h --yes --help <URL>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__sync__help)
            opts="add remove list set help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__sync__help__add)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__sync__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__sync__help__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__sync__help__remove)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__sync__help__set)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__sync__list)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__sync__remove)
            opts="-y -h --yes --help <HANDLE>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__sync__set)
            opts="-y -h --yes --help <URL>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__telemetry)
            opts="-y -h --yes --help status enable disable"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__uninstall)
            opts="-y -h --scope --local --global --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --scope)
                    COMPREPLY=("$(compgen -W "user system project" -- "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__unpin)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__update)
            opts="-y -h --all --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__upgrade)
            opts="-y -h --force --tag --branch --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                --tag)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                --branch)
                    COMPREPLY=("$(compgen -f "$cur")")
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__version)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
        zoi__why)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
                return 0
            fi
            case "$prev" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( "$(compgen -W "$opts" -- "$cur")" )
            return 0
            ;;
    esac
}

if [[ "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -ge 4 || "${BASH_VERSINFO[0]}" -gt 4 ]]; then
    complete -F _zoi -o nosort -o bashdefault -o default zoi
else
    complete -F _zoi -o bashdefault -o default zoi
fi

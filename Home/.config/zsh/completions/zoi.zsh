#compdef zoi

autoload -U is-at-least

_zoi() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    _arguments "${_arguments_options[@]}" : \
'-v[Print detailed version information]' \
'--version[Print detailed version information]' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
":: :_zoi_commands" \
"*::: :->zoi" \
&& ret=0
    case $state in
    (zoi)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-command-$line[1]:"
        case $line[1] in
            (generate-completions)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':shell -- The shell to generate completions for:(bash elvish fish powershell zsh)' \
&& ret=0
;;
(generate-manual)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(version)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(about)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(check)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(sync)
_arguments "${_arguments_options[@]}" : \
'-v[Show the full git output]' \
'--verbose[Show the full git output]' \
'--fallback[Fallback to other mirrors if the default one fails]' \
'--no-pm[Do not check for installed package managers]' \
'--no-shell-setup[Do not attempt to set up shell completions after syncing]' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_zoi__sync_commands" \
"*::: :->sync" \
&& ret=0

    case $state in
    (sync)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-sync-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':url -- URL of the registry to add:_default' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':handle -- Handle of the registry to remove:_default' \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(set)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':url -- URL or keyword (default, github, gitlab, codeberg):_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__sync__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-sync-help-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(set)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(list)
_arguments "${_arguments_options[@]}" : \
'--repo=[Filter by repository (e.g. '\''main'\'', '\''extra'\'')]:REPO:_default' \
'-t+[Filter by package type (package, app, collection, extension)]:PACKAGE_TYPE:_default' \
'--type=[Filter by package type (package, app, collection, extension)]:PACKAGE_TYPE:_default' \
'-a[List all packages from the database, not just installed ones]' \
'--all[List all packages from the database, not just installed ones]' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" : \
'--raw[Display the raw, unformatted package file]' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':package_name -- The name of the package to show:()' \
&& ret=0
;;
(pin)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':package -- The name of the package to pin:()' \
':version -- The version to pin the package to:_default' \
&& ret=0
;;
(unpin)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':package -- The name of the package to unpin:()' \
&& ret=0
;;
(update)
_arguments "${_arguments_options[@]}" : \
'()--all[Update all installed packages]' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
'*::package_names -- The name(s) of the package(s) to update:()' \
&& ret=0
;;
(install)
_arguments "${_arguments_options[@]}" : \
'()--repo=[Install from a git repository (e.g. '\''Zillowe/Hello'\'', '\''gl\:Zillowe/Hello'\'')]:REPO:_default' \
'(--local --global)--scope=[The scope to install the package to]:SCOPE:(user system project)' \
'--type=[The type of package to build if building from source (e.g. '\''source'\'', '\''pre-compiled'\'')]:TYPE:_default' \
'--force[Force re-installation even if the package is already installed]' \
'--all-optional[Accept all optional dependencies]' \
'(--global)--local[Install packages to the current project (alias for --scope=project)]' \
'--global[Install packages globally for the current user (alias for --scope=user)]' \
'--save[Save the package to the project'\''s zoi.yaml]' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
'*::sources -- Package names, local paths, or URLs to .pkg.lua files:()' \
&& ret=0
;;
(uninstall)
_arguments "${_arguments_options[@]}" : \
'(--local --global)--scope=[The scope to uninstall the package from]:SCOPE:(user system project)' \
'(--global)--local[Uninstall packages from the current project (alias for --scope=project)]' \
'--global[Uninstall packages globally for the current user (alias for --scope=user)]' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::packages -- One or more packages to uninstall:()' \
&& ret=0
;;
(run)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'::cmd_alias -- The alias of the command to execute:_default' \
'*::args -- Arguments to pass to the command:_default' \
&& ret=0
;;
(env)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'::env_alias -- The alias of the environment to set up:_default' \
&& ret=0
;;
(upgrade)
_arguments "${_arguments_options[@]}" : \
'--tag=[Upgrade to a specific git tag]:TAG:_default' \
'--branch=[Upgrade to the latest release of a specific branch (e.g. Prod, Pub)]:BRANCH:_default' \
'--force[Force a full download, skipping the patch-based upgrade]' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(autoremove)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(why)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':package_name -- The name of the package to inspect:()' \
&& ret=0
;;
(owner)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':path -- Path to the file:_files' \
&& ret=0
;;
(files)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':package -- The name of the package:()' \
&& ret=0
;;
(search)
_arguments "${_arguments_options[@]}" : \
'--repo=[Filter by repository (e.g. '\''main'\'', '\''extra'\'')]:REPO:_default' \
'--type=[Filter by package type (package, app, collection, extension)]:PACKAGE_TYPE:_default' \
'*-t+[Filter by tags (any match). Multiple via comma or repeated -t]:TAGS:_default' \
'*--tag=[Filter by tags (any match). Multiple via comma or repeated -t]:TAGS:_default' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':search_term -- The term to search for (e.g. '\''editor'\'', '\''cli'\''):_default' \
&& ret=0
;;
(shell)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':shell -- The shell to install completions for:(bash elvish fish powershell zsh)' \
&& ret=0
;;
(setup)
_arguments "${_arguments_options[@]}" : \
'--scope=[The scope to apply the setup to (user or system-wide)]:SCOPE:(user system)' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(exec)
_arguments "${_arguments_options[@]}" : \
'--upstream[Force execution from a fresh download, bypassing any cache]' \
'--cache[Force execution from the cache, failing if the package is not cached]' \
'--local[Force execution from the local project installation]' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':source -- Package name, local path, or URL to execute:()' \
'*::args -- Arguments to pass to the executed command:_default' \
&& ret=0
;;
(clean)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(repo)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_zoi__repo_commands" \
"*::: :->repo" \
&& ret=0

    case $state in
    (repo)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-repo-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
'::repo_or_url -- The name of the repository to add or a git URL to clone:_default' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':repo_name:_default' \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
":: :_zoi__repo__list_commands" \
"*::: :->list" \
&& ret=0

    case $state in
    (list)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-repo-list-command-$line[1]:"
        case $line[1] in
            (all)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__repo__list__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-repo-list-help-command-$line[1]:"
        case $line[1] in
            (all)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(git)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
":: :_zoi__repo__git_commands" \
"*::: :->git" \
&& ret=0

    case $state in
    (git)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-repo-git-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':repo_name:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__repo__git__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-repo-git-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__repo__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-repo-help-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__repo__help__list_commands" \
"*::: :->list" \
&& ret=0

    case $state in
    (list)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-repo-help-list-command-$line[1]:"
        case $line[1] in
            (all)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(git)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__repo__help__git_commands" \
"*::: :->git" \
&& ret=0

    case $state in
    (git)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-repo-help-git-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(telemetry)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':action:(status enable disable)' \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':source -- Package name, @repo/name, local .pkg.lua path, or URL:_default' \
'::app_name -- The application name to substitute into template commands:_default' \
&& ret=0
;;
(extension)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
":: :_zoi__extension_commands" \
"*::: :->extension" \
&& ret=0

    case $state in
    (extension)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-extension-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':name -- The name of the extension to add:_default' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':name -- The name of the extension to remove:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__extension__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-extension-help-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(rollback)
_arguments "${_arguments_options[@]}" : \
'()--last-transaction[Rollback the last transaction]' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
'::package -- The name of the package to rollback:()' \
&& ret=0
;;
(man)
_arguments "${_arguments_options[@]}" : \
'--upstream[Always look at the upstream manual even if it'\''s downloaded]' \
'--raw[Print the manual to the terminal raw]' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':package_name -- The name of the package to show the manual for:()' \
&& ret=0
;;
(package)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
":: :_zoi__package_commands" \
"*::: :->package" \
&& ret=0

    case $state in
    (package)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-package-command-$line[1]:"
        case $line[1] in
            (build)
_arguments "${_arguments_options[@]}" : \
'--type=[The type of package to build (e.g. '\''source'\'', '\''pre-compiled'\'')]:TYPE:_default' \
'*-p+[The platform to build for (e.g. '\''linux-amd64'\'', '\''windows-arm64'\'', '\''all'\'', '\''current'\''). Can be specified multiple times]:PLATFORM:_default' \
'*--platform=[The platform to build for (e.g. '\''linux-amd64'\'', '\''windows-arm64'\'', '\''all'\'', '\''current'\''). Can be specified multiple times]:PLATFORM:_default' \
'--sign=[Sign the package with the given PGP key (name or fingerprint)]:SIGN:_default' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':package_file -- Path to the package file (e.g. path/to/name.pkg.lua):_files' \
&& ret=0
;;
(install)
_arguments "${_arguments_options[@]}" : \
'--scope=[The scope to install the package to (user or system-wide)]:SCOPE:(user system)' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':package_file -- Path to the package archive file (e.g. path/to/name-os-arch.pkg.tar.zst):_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__package__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-package-help-command-$line[1]:"
        case $line[1] in
            (build)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(install)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(pgp)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
":: :_zoi__pgp_commands" \
"*::: :->pgp" \
&& ret=0

    case $state in
    (pgp)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-pgp-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
'--path=[Path to the PGP key file (.asc)]:PATH:_default' \
'--fingerprint=[Fingerprint of the PGP key to fetch from keys.openpgp.org]:FINGERPRINT:_default' \
'--url=[URL of the PGP key to import]:URL:_default' \
'--name=[Name to associate with the key (defaults to filename if adding from path/url)]:NAME:_default' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'--fingerprint=[Fingerprint of the key to remove]:FINGERPRINT:_default' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
'::name -- Name of the key to remove:_default' \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(search)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':term -- The user ID (name, email) or fingerprint to search for:_default' \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':name -- The name of the key to show:_default' \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
'--file=[Path to the file to verify]:FILE:_default' \
'--sig=[Path to the detached signature file]:SIG:_default' \
'--key=[Name of the key in the local store to use for verification]:KEY:_default' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__pgp__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-pgp-help-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(search)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(helper)
_arguments "${_arguments_options[@]}" : \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
":: :_zoi__helper_commands" \
"*::: :->helper" \
&& ret=0

    case $state in
    (helper)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-helper-command-$line[1]:"
        case $line[1] in
            (get-hash)
_arguments "${_arguments_options[@]}" : \
'--hash=[The hash algorithm to use]:HASH:(sha512 sha256)' \
'-y[Automatically answer yes to all prompts]' \
'--yes[Automatically answer yes to all prompts]' \
'-h[Print help]' \
'--help[Print help]' \
':source -- The local file path or URL to hash:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__helper__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-helper-help-command-$line[1]:"
        case $line[1] in
            (get-hash)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-help-command-$line[1]:"
        case $line[1] in
            (generate-completions)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(generate-manual)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(version)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(about)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(check)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(sync)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__help__sync_commands" \
"*::: :->sync" \
&& ret=0

    case $state in
    (sync)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-help-sync-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(set)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(pin)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(unpin)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(update)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(install)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(uninstall)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(run)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(env)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(upgrade)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(autoremove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(why)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(owner)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(files)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(search)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(shell)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(setup)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(exec)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(clean)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(repo)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__help__repo_commands" \
"*::: :->repo" \
&& ret=0

    case $state in
    (repo)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-help-repo-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__help__repo__list_commands" \
"*::: :->list" \
&& ret=0

    case $state in
    (list)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-help-repo-list-command-$line[1]:"
        case $line[1] in
            (all)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(git)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__help__repo__git_commands" \
"*::: :->git" \
&& ret=0

    case $state in
    (git)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-help-repo-git-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(telemetry)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(extension)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__help__extension_commands" \
"*::: :->extension" \
&& ret=0

    case $state in
    (extension)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-help-extension-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(rollback)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(man)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(package)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__help__package_commands" \
"*::: :->package" \
&& ret=0

    case $state in
    (package)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-help-package-command-$line[1]:"
        case $line[1] in
            (build)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(install)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(pgp)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__help__pgp_commands" \
"*::: :->pgp" \
&& ret=0

    case $state in
    (pgp)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-help-pgp-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(search)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(helper)
_arguments "${_arguments_options[@]}" : \
":: :_zoi__help__helper_commands" \
"*::: :->helper" \
&& ret=0

    case $state in
    (helper)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:zoi-help-helper-command-$line[1]:"
        case $line[1] in
            (get-hash)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
}

(( $+functions[_zoi_commands] )) ||
_zoi_commands() {
    local commands; commands=(
'generate-completions:Generates shell completion scripts' \
'generate-manual:Generates man pages for zoi' \
'version:Prints concise version and build information' \
'about:Shows detailed application information and credits' \
'info:Displays detected operating system and architecture information' \
'check:Checks for essential third-party command-line tools' \
'sync:Downloads or updates the package database from the remote repository' \
'list:Lists installed or all available packages' \
'show:Shows detailed information about a package' \
'pin:Pin a package to a specific version' \
'unpin:Unpin a package, allowing it to be updated' \
'update:Updates one or more packages to their latest versions' \
'install:Installs one or more packages from a name, local file, URL, or git repository' \
'uninstall:Uninstalls one or more packages previously installed by Zoi' \
'run:Execute a command defined in a local zoi.yaml file' \
'env:Manage and set up project environments from a local zoi.yaml file' \
'upgrade:Upgrades the Zoi binary to the latest version' \
'autoremove:Removes packages that were installed as dependencies but are no longer needed' \
'why:Explains why a package is installed' \
'owner:Find which package owns a file' \
'files:List all files owned by a package' \
'search:Searches for packages by name or description' \
'shell:Installs completion scripts for a given shell' \
'setup:Configures the shell environment for Zoi' \
'exec:Download and execute a binary package without installing it' \
'clean:Clears the cache of downloaded package binaries' \
'repo:Manage package repositories' \
'telemetry:Manage telemetry settings (opt-in analytics)' \
'create:Create an application using a package template' \
'extension:Manage Zoi extensions' \
'rollback:Rollback a package to the previously installed version' \
'man:Shows a package'\''s manual' \
'package:Build, create, and manage Zoi packages' \
'pgp:Manage PGP keys for package signature verification' \
'helper:Helper commands for various tasks' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi commands' commands "$@"
}
(( $+functions[_zoi__about_commands] )) ||
_zoi__about_commands() {
    local commands; commands=()
    _describe -t commands 'zoi about commands' commands "$@"
}
(( $+functions[_zoi__autoremove_commands] )) ||
_zoi__autoremove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi autoremove commands' commands "$@"
}
(( $+functions[_zoi__check_commands] )) ||
_zoi__check_commands() {
    local commands; commands=()
    _describe -t commands 'zoi check commands' commands "$@"
}
(( $+functions[_zoi__clean_commands] )) ||
_zoi__clean_commands() {
    local commands; commands=()
    _describe -t commands 'zoi clean commands' commands "$@"
}
(( $+functions[_zoi__create_commands] )) ||
_zoi__create_commands() {
    local commands; commands=()
    _describe -t commands 'zoi create commands' commands "$@"
}
(( $+functions[_zoi__env_commands] )) ||
_zoi__env_commands() {
    local commands; commands=()
    _describe -t commands 'zoi env commands' commands "$@"
}
(( $+functions[_zoi__exec_commands] )) ||
_zoi__exec_commands() {
    local commands; commands=()
    _describe -t commands 'zoi exec commands' commands "$@"
}
(( $+functions[_zoi__extension_commands] )) ||
_zoi__extension_commands() {
    local commands; commands=(
'add:Add an extension' \
'remove:Remove an extension' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi extension commands' commands "$@"
}
(( $+functions[_zoi__extension__add_commands] )) ||
_zoi__extension__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi extension add commands' commands "$@"
}
(( $+functions[_zoi__extension__help_commands] )) ||
_zoi__extension__help_commands() {
    local commands; commands=(
'add:Add an extension' \
'remove:Remove an extension' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi extension help commands' commands "$@"
}
(( $+functions[_zoi__extension__help__add_commands] )) ||
_zoi__extension__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi extension help add commands' commands "$@"
}
(( $+functions[_zoi__extension__help__help_commands] )) ||
_zoi__extension__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'zoi extension help help commands' commands "$@"
}
(( $+functions[_zoi__extension__help__remove_commands] )) ||
_zoi__extension__help__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi extension help remove commands' commands "$@"
}
(( $+functions[_zoi__extension__remove_commands] )) ||
_zoi__extension__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi extension remove commands' commands "$@"
}
(( $+functions[_zoi__files_commands] )) ||
_zoi__files_commands() {
    local commands; commands=()
    _describe -t commands 'zoi files commands' commands "$@"
}
(( $+functions[_zoi__generate-completions_commands] )) ||
_zoi__generate-completions_commands() {
    local commands; commands=()
    _describe -t commands 'zoi generate-completions commands' commands "$@"
}
(( $+functions[_zoi__generate-manual_commands] )) ||
_zoi__generate-manual_commands() {
    local commands; commands=()
    _describe -t commands 'zoi generate-manual commands' commands "$@"
}
(( $+functions[_zoi__help_commands] )) ||
_zoi__help_commands() {
    local commands; commands=(
'generate-completions:Generates shell completion scripts' \
'generate-manual:Generates man pages for zoi' \
'version:Prints concise version and build information' \
'about:Shows detailed application information and credits' \
'info:Displays detected operating system and architecture information' \
'check:Checks for essential third-party command-line tools' \
'sync:Downloads or updates the package database from the remote repository' \
'list:Lists installed or all available packages' \
'show:Shows detailed information about a package' \
'pin:Pin a package to a specific version' \
'unpin:Unpin a package, allowing it to be updated' \
'update:Updates one or more packages to their latest versions' \
'install:Installs one or more packages from a name, local file, URL, or git repository' \
'uninstall:Uninstalls one or more packages previously installed by Zoi' \
'run:Execute a command defined in a local zoi.yaml file' \
'env:Manage and set up project environments from a local zoi.yaml file' \
'upgrade:Upgrades the Zoi binary to the latest version' \
'autoremove:Removes packages that were installed as dependencies but are no longer needed' \
'why:Explains why a package is installed' \
'owner:Find which package owns a file' \
'files:List all files owned by a package' \
'search:Searches for packages by name or description' \
'shell:Installs completion scripts for a given shell' \
'setup:Configures the shell environment for Zoi' \
'exec:Download and execute a binary package without installing it' \
'clean:Clears the cache of downloaded package binaries' \
'repo:Manage package repositories' \
'telemetry:Manage telemetry settings (opt-in analytics)' \
'create:Create an application using a package template' \
'extension:Manage Zoi extensions' \
'rollback:Rollback a package to the previously installed version' \
'man:Shows a package'\''s manual' \
'package:Build, create, and manage Zoi packages' \
'pgp:Manage PGP keys for package signature verification' \
'helper:Helper commands for various tasks' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi help commands' commands "$@"
}
(( $+functions[_zoi__help__about_commands] )) ||
_zoi__help__about_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help about commands' commands "$@"
}
(( $+functions[_zoi__help__autoremove_commands] )) ||
_zoi__help__autoremove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help autoremove commands' commands "$@"
}
(( $+functions[_zoi__help__check_commands] )) ||
_zoi__help__check_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help check commands' commands "$@"
}
(( $+functions[_zoi__help__clean_commands] )) ||
_zoi__help__clean_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help clean commands' commands "$@"
}
(( $+functions[_zoi__help__create_commands] )) ||
_zoi__help__create_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help create commands' commands "$@"
}
(( $+functions[_zoi__help__env_commands] )) ||
_zoi__help__env_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help env commands' commands "$@"
}
(( $+functions[_zoi__help__exec_commands] )) ||
_zoi__help__exec_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help exec commands' commands "$@"
}
(( $+functions[_zoi__help__extension_commands] )) ||
_zoi__help__extension_commands() {
    local commands; commands=(
'add:Add an extension' \
'remove:Remove an extension' \
    )
    _describe -t commands 'zoi help extension commands' commands "$@"
}
(( $+functions[_zoi__help__extension__add_commands] )) ||
_zoi__help__extension__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help extension add commands' commands "$@"
}
(( $+functions[_zoi__help__extension__remove_commands] )) ||
_zoi__help__extension__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help extension remove commands' commands "$@"
}
(( $+functions[_zoi__help__files_commands] )) ||
_zoi__help__files_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help files commands' commands "$@"
}
(( $+functions[_zoi__help__generate-completions_commands] )) ||
_zoi__help__generate-completions_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help generate-completions commands' commands "$@"
}
(( $+functions[_zoi__help__generate-manual_commands] )) ||
_zoi__help__generate-manual_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help generate-manual commands' commands "$@"
}
(( $+functions[_zoi__help__help_commands] )) ||
_zoi__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help help commands' commands "$@"
}
(( $+functions[_zoi__help__helper_commands] )) ||
_zoi__help__helper_commands() {
    local commands; commands=(
'get-hash:Get a hash of a local file or a file from a URL' \
    )
    _describe -t commands 'zoi help helper commands' commands "$@"
}
(( $+functions[_zoi__help__helper__get-hash_commands] )) ||
_zoi__help__helper__get-hash_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help helper get-hash commands' commands "$@"
}
(( $+functions[_zoi__help__info_commands] )) ||
_zoi__help__info_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help info commands' commands "$@"
}
(( $+functions[_zoi__help__install_commands] )) ||
_zoi__help__install_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help install commands' commands "$@"
}
(( $+functions[_zoi__help__list_commands] )) ||
_zoi__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help list commands' commands "$@"
}
(( $+functions[_zoi__help__man_commands] )) ||
_zoi__help__man_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help man commands' commands "$@"
}
(( $+functions[_zoi__help__owner_commands] )) ||
_zoi__help__owner_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help owner commands' commands "$@"
}
(( $+functions[_zoi__help__package_commands] )) ||
_zoi__help__package_commands() {
    local commands; commands=(
'build:Build a package from a pkg.lua file' \
'install:Install a package from a local archive' \
    )
    _describe -t commands 'zoi help package commands' commands "$@"
}
(( $+functions[_zoi__help__package__build_commands] )) ||
_zoi__help__package__build_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help package build commands' commands "$@"
}
(( $+functions[_zoi__help__package__install_commands] )) ||
_zoi__help__package__install_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help package install commands' commands "$@"
}
(( $+functions[_zoi__help__pgp_commands] )) ||
_zoi__help__pgp_commands() {
    local commands; commands=(
'add:Add a PGP key from a file, URL, or a keyserver' \
'remove:Remove a PGP key' \
'list:List all imported PGP keys' \
'search:Search for a PGP key by user ID or fingerprint' \
'show:Show the public key of a stored PGP key' \
'verify:Verify a file'\''s detached signature' \
    )
    _describe -t commands 'zoi help pgp commands' commands "$@"
}
(( $+functions[_zoi__help__pgp__add_commands] )) ||
_zoi__help__pgp__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help pgp add commands' commands "$@"
}
(( $+functions[_zoi__help__pgp__list_commands] )) ||
_zoi__help__pgp__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help pgp list commands' commands "$@"
}
(( $+functions[_zoi__help__pgp__remove_commands] )) ||
_zoi__help__pgp__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help pgp remove commands' commands "$@"
}
(( $+functions[_zoi__help__pgp__search_commands] )) ||
_zoi__help__pgp__search_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help pgp search commands' commands "$@"
}
(( $+functions[_zoi__help__pgp__show_commands] )) ||
_zoi__help__pgp__show_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help pgp show commands' commands "$@"
}
(( $+functions[_zoi__help__pgp__verify_commands] )) ||
_zoi__help__pgp__verify_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help pgp verify commands' commands "$@"
}
(( $+functions[_zoi__help__pin_commands] )) ||
_zoi__help__pin_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help pin commands' commands "$@"
}
(( $+functions[_zoi__help__repo_commands] )) ||
_zoi__help__repo_commands() {
    local commands; commands=(
'add:Add a repository to the configuration or clone from a git URL' \
'remove:Remove a repository from the active configuration' \
'list:List repositories (active by default); use \`list all\` to show all' \
'git:Manage cloned git repositories' \
    )
    _describe -t commands 'zoi help repo commands' commands "$@"
}
(( $+functions[_zoi__help__repo__add_commands] )) ||
_zoi__help__repo__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help repo add commands' commands "$@"
}
(( $+functions[_zoi__help__repo__git_commands] )) ||
_zoi__help__repo__git_commands() {
    local commands; commands=(
'list:Show only cloned git repositories (~/.zoi/pkgs/git)' \
'rm:Remove a cloned git repository directory (~/.zoi/pkgs/git/<repo-name>)' \
    )
    _describe -t commands 'zoi help repo git commands' commands "$@"
}
(( $+functions[_zoi__help__repo__git__list_commands] )) ||
_zoi__help__repo__git__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help repo git list commands' commands "$@"
}
(( $+functions[_zoi__help__repo__git__rm_commands] )) ||
_zoi__help__repo__git__rm_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help repo git rm commands' commands "$@"
}
(( $+functions[_zoi__help__repo__list_commands] )) ||
_zoi__help__repo__list_commands() {
    local commands; commands=(
'all:Show all available repositories (active + discovered)' \
    )
    _describe -t commands 'zoi help repo list commands' commands "$@"
}
(( $+functions[_zoi__help__repo__list__all_commands] )) ||
_zoi__help__repo__list__all_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help repo list all commands' commands "$@"
}
(( $+functions[_zoi__help__repo__remove_commands] )) ||
_zoi__help__repo__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help repo remove commands' commands "$@"
}
(( $+functions[_zoi__help__rollback_commands] )) ||
_zoi__help__rollback_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help rollback commands' commands "$@"
}
(( $+functions[_zoi__help__run_commands] )) ||
_zoi__help__run_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help run commands' commands "$@"
}
(( $+functions[_zoi__help__search_commands] )) ||
_zoi__help__search_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help search commands' commands "$@"
}
(( $+functions[_zoi__help__setup_commands] )) ||
_zoi__help__setup_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help setup commands' commands "$@"
}
(( $+functions[_zoi__help__shell_commands] )) ||
_zoi__help__shell_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help shell commands' commands "$@"
}
(( $+functions[_zoi__help__show_commands] )) ||
_zoi__help__show_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help show commands' commands "$@"
}
(( $+functions[_zoi__help__sync_commands] )) ||
_zoi__help__sync_commands() {
    local commands; commands=(
'add:Add a new registry' \
'remove:Remove a configured registry by its handle' \
'list:List configured registries' \
'set:Set the default registry URL' \
    )
    _describe -t commands 'zoi help sync commands' commands "$@"
}
(( $+functions[_zoi__help__sync__add_commands] )) ||
_zoi__help__sync__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help sync add commands' commands "$@"
}
(( $+functions[_zoi__help__sync__list_commands] )) ||
_zoi__help__sync__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help sync list commands' commands "$@"
}
(( $+functions[_zoi__help__sync__remove_commands] )) ||
_zoi__help__sync__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help sync remove commands' commands "$@"
}
(( $+functions[_zoi__help__sync__set_commands] )) ||
_zoi__help__sync__set_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help sync set commands' commands "$@"
}
(( $+functions[_zoi__help__telemetry_commands] )) ||
_zoi__help__telemetry_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help telemetry commands' commands "$@"
}
(( $+functions[_zoi__help__uninstall_commands] )) ||
_zoi__help__uninstall_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help uninstall commands' commands "$@"
}
(( $+functions[_zoi__help__unpin_commands] )) ||
_zoi__help__unpin_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help unpin commands' commands "$@"
}
(( $+functions[_zoi__help__update_commands] )) ||
_zoi__help__update_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help update commands' commands "$@"
}
(( $+functions[_zoi__help__upgrade_commands] )) ||
_zoi__help__upgrade_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help upgrade commands' commands "$@"
}
(( $+functions[_zoi__help__version_commands] )) ||
_zoi__help__version_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help version commands' commands "$@"
}
(( $+functions[_zoi__help__why_commands] )) ||
_zoi__help__why_commands() {
    local commands; commands=()
    _describe -t commands 'zoi help why commands' commands "$@"
}
(( $+functions[_zoi__helper_commands] )) ||
_zoi__helper_commands() {
    local commands; commands=(
'get-hash:Get a hash of a local file or a file from a URL' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi helper commands' commands "$@"
}
(( $+functions[_zoi__helper__get-hash_commands] )) ||
_zoi__helper__get-hash_commands() {
    local commands; commands=()
    _describe -t commands 'zoi helper get-hash commands' commands "$@"
}
(( $+functions[_zoi__helper__help_commands] )) ||
_zoi__helper__help_commands() {
    local commands; commands=(
'get-hash:Get a hash of a local file or a file from a URL' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi helper help commands' commands "$@"
}
(( $+functions[_zoi__helper__help__get-hash_commands] )) ||
_zoi__helper__help__get-hash_commands() {
    local commands; commands=()
    _describe -t commands 'zoi helper help get-hash commands' commands "$@"
}
(( $+functions[_zoi__helper__help__help_commands] )) ||
_zoi__helper__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'zoi helper help help commands' commands "$@"
}
(( $+functions[_zoi__info_commands] )) ||
_zoi__info_commands() {
    local commands; commands=()
    _describe -t commands 'zoi info commands' commands "$@"
}
(( $+functions[_zoi__install_commands] )) ||
_zoi__install_commands() {
    local commands; commands=()
    _describe -t commands 'zoi install commands' commands "$@"
}
(( $+functions[_zoi__list_commands] )) ||
_zoi__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi list commands' commands "$@"
}
(( $+functions[_zoi__man_commands] )) ||
_zoi__man_commands() {
    local commands; commands=()
    _describe -t commands 'zoi man commands' commands "$@"
}
(( $+functions[_zoi__owner_commands] )) ||
_zoi__owner_commands() {
    local commands; commands=()
    _describe -t commands 'zoi owner commands' commands "$@"
}
(( $+functions[_zoi__package_commands] )) ||
_zoi__package_commands() {
    local commands; commands=(
'build:Build a package from a pkg.lua file' \
'install:Install a package from a local archive' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi package commands' commands "$@"
}
(( $+functions[_zoi__package__build_commands] )) ||
_zoi__package__build_commands() {
    local commands; commands=()
    _describe -t commands 'zoi package build commands' commands "$@"
}
(( $+functions[_zoi__package__help_commands] )) ||
_zoi__package__help_commands() {
    local commands; commands=(
'build:Build a package from a pkg.lua file' \
'install:Install a package from a local archive' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi package help commands' commands "$@"
}
(( $+functions[_zoi__package__help__build_commands] )) ||
_zoi__package__help__build_commands() {
    local commands; commands=()
    _describe -t commands 'zoi package help build commands' commands "$@"
}
(( $+functions[_zoi__package__help__help_commands] )) ||
_zoi__package__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'zoi package help help commands' commands "$@"
}
(( $+functions[_zoi__package__help__install_commands] )) ||
_zoi__package__help__install_commands() {
    local commands; commands=()
    _describe -t commands 'zoi package help install commands' commands "$@"
}
(( $+functions[_zoi__package__install_commands] )) ||
_zoi__package__install_commands() {
    local commands; commands=()
    _describe -t commands 'zoi package install commands' commands "$@"
}
(( $+functions[_zoi__pgp_commands] )) ||
_zoi__pgp_commands() {
    local commands; commands=(
'add:Add a PGP key from a file, URL, or a keyserver' \
'remove:Remove a PGP key' \
'list:List all imported PGP keys' \
'search:Search for a PGP key by user ID or fingerprint' \
'show:Show the public key of a stored PGP key' \
'verify:Verify a file'\''s detached signature' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi pgp commands' commands "$@"
}
(( $+functions[_zoi__pgp__add_commands] )) ||
_zoi__pgp__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp add commands' commands "$@"
}
(( $+functions[_zoi__pgp__help_commands] )) ||
_zoi__pgp__help_commands() {
    local commands; commands=(
'add:Add a PGP key from a file, URL, or a keyserver' \
'remove:Remove a PGP key' \
'list:List all imported PGP keys' \
'search:Search for a PGP key by user ID or fingerprint' \
'show:Show the public key of a stored PGP key' \
'verify:Verify a file'\''s detached signature' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi pgp help commands' commands "$@"
}
(( $+functions[_zoi__pgp__help__add_commands] )) ||
_zoi__pgp__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp help add commands' commands "$@"
}
(( $+functions[_zoi__pgp__help__help_commands] )) ||
_zoi__pgp__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp help help commands' commands "$@"
}
(( $+functions[_zoi__pgp__help__list_commands] )) ||
_zoi__pgp__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp help list commands' commands "$@"
}
(( $+functions[_zoi__pgp__help__remove_commands] )) ||
_zoi__pgp__help__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp help remove commands' commands "$@"
}
(( $+functions[_zoi__pgp__help__search_commands] )) ||
_zoi__pgp__help__search_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp help search commands' commands "$@"
}
(( $+functions[_zoi__pgp__help__show_commands] )) ||
_zoi__pgp__help__show_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp help show commands' commands "$@"
}
(( $+functions[_zoi__pgp__help__verify_commands] )) ||
_zoi__pgp__help__verify_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp help verify commands' commands "$@"
}
(( $+functions[_zoi__pgp__list_commands] )) ||
_zoi__pgp__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp list commands' commands "$@"
}
(( $+functions[_zoi__pgp__remove_commands] )) ||
_zoi__pgp__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp remove commands' commands "$@"
}
(( $+functions[_zoi__pgp__search_commands] )) ||
_zoi__pgp__search_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp search commands' commands "$@"
}
(( $+functions[_zoi__pgp__show_commands] )) ||
_zoi__pgp__show_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp show commands' commands "$@"
}
(( $+functions[_zoi__pgp__verify_commands] )) ||
_zoi__pgp__verify_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pgp verify commands' commands "$@"
}
(( $+functions[_zoi__pin_commands] )) ||
_zoi__pin_commands() {
    local commands; commands=()
    _describe -t commands 'zoi pin commands' commands "$@"
}
(( $+functions[_zoi__repo_commands] )) ||
_zoi__repo_commands() {
    local commands; commands=(
'add:Add a repository to the configuration or clone from a git URL' \
'remove:Remove a repository from the active configuration' \
'list:List repositories (active by default); use \`list all\` to show all' \
'git:Manage cloned git repositories' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi repo commands' commands "$@"
}
(( $+functions[_zoi__repo__add_commands] )) ||
_zoi__repo__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo add commands' commands "$@"
}
(( $+functions[_zoi__repo__git_commands] )) ||
_zoi__repo__git_commands() {
    local commands; commands=(
'list:Show only cloned git repositories (~/.zoi/pkgs/git)' \
'rm:Remove a cloned git repository directory (~/.zoi/pkgs/git/<repo-name>)' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi repo git commands' commands "$@"
}
(( $+functions[_zoi__repo__git__help_commands] )) ||
_zoi__repo__git__help_commands() {
    local commands; commands=(
'list:Show only cloned git repositories (~/.zoi/pkgs/git)' \
'rm:Remove a cloned git repository directory (~/.zoi/pkgs/git/<repo-name>)' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi repo git help commands' commands "$@"
}
(( $+functions[_zoi__repo__git__help__help_commands] )) ||
_zoi__repo__git__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo git help help commands' commands "$@"
}
(( $+functions[_zoi__repo__git__help__list_commands] )) ||
_zoi__repo__git__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo git help list commands' commands "$@"
}
(( $+functions[_zoi__repo__git__help__rm_commands] )) ||
_zoi__repo__git__help__rm_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo git help rm commands' commands "$@"
}
(( $+functions[_zoi__repo__git__list_commands] )) ||
_zoi__repo__git__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo git list commands' commands "$@"
}
(( $+functions[_zoi__repo__git__rm_commands] )) ||
_zoi__repo__git__rm_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo git rm commands' commands "$@"
}
(( $+functions[_zoi__repo__help_commands] )) ||
_zoi__repo__help_commands() {
    local commands; commands=(
'add:Add a repository to the configuration or clone from a git URL' \
'remove:Remove a repository from the active configuration' \
'list:List repositories (active by default); use \`list all\` to show all' \
'git:Manage cloned git repositories' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi repo help commands' commands "$@"
}
(( $+functions[_zoi__repo__help__add_commands] )) ||
_zoi__repo__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo help add commands' commands "$@"
}
(( $+functions[_zoi__repo__help__git_commands] )) ||
_zoi__repo__help__git_commands() {
    local commands; commands=(
'list:Show only cloned git repositories (~/.zoi/pkgs/git)' \
'rm:Remove a cloned git repository directory (~/.zoi/pkgs/git/<repo-name>)' \
    )
    _describe -t commands 'zoi repo help git commands' commands "$@"
}
(( $+functions[_zoi__repo__help__git__list_commands] )) ||
_zoi__repo__help__git__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo help git list commands' commands "$@"
}
(( $+functions[_zoi__repo__help__git__rm_commands] )) ||
_zoi__repo__help__git__rm_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo help git rm commands' commands "$@"
}
(( $+functions[_zoi__repo__help__help_commands] )) ||
_zoi__repo__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo help help commands' commands "$@"
}
(( $+functions[_zoi__repo__help__list_commands] )) ||
_zoi__repo__help__list_commands() {
    local commands; commands=(
'all:Show all available repositories (active + discovered)' \
    )
    _describe -t commands 'zoi repo help list commands' commands "$@"
}
(( $+functions[_zoi__repo__help__list__all_commands] )) ||
_zoi__repo__help__list__all_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo help list all commands' commands "$@"
}
(( $+functions[_zoi__repo__help__remove_commands] )) ||
_zoi__repo__help__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo help remove commands' commands "$@"
}
(( $+functions[_zoi__repo__list_commands] )) ||
_zoi__repo__list_commands() {
    local commands; commands=(
'all:Show all available repositories (active + discovered)' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi repo list commands' commands "$@"
}
(( $+functions[_zoi__repo__list__all_commands] )) ||
_zoi__repo__list__all_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo list all commands' commands "$@"
}
(( $+functions[_zoi__repo__list__help_commands] )) ||
_zoi__repo__list__help_commands() {
    local commands; commands=(
'all:Show all available repositories (active + discovered)' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi repo list help commands' commands "$@"
}
(( $+functions[_zoi__repo__list__help__all_commands] )) ||
_zoi__repo__list__help__all_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo list help all commands' commands "$@"
}
(( $+functions[_zoi__repo__list__help__help_commands] )) ||
_zoi__repo__list__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo list help help commands' commands "$@"
}
(( $+functions[_zoi__repo__remove_commands] )) ||
_zoi__repo__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi repo remove commands' commands "$@"
}
(( $+functions[_zoi__rollback_commands] )) ||
_zoi__rollback_commands() {
    local commands; commands=()
    _describe -t commands 'zoi rollback commands' commands "$@"
}
(( $+functions[_zoi__run_commands] )) ||
_zoi__run_commands() {
    local commands; commands=()
    _describe -t commands 'zoi run commands' commands "$@"
}
(( $+functions[_zoi__search_commands] )) ||
_zoi__search_commands() {
    local commands; commands=()
    _describe -t commands 'zoi search commands' commands "$@"
}
(( $+functions[_zoi__setup_commands] )) ||
_zoi__setup_commands() {
    local commands; commands=()
    _describe -t commands 'zoi setup commands' commands "$@"
}
(( $+functions[_zoi__shell_commands] )) ||
_zoi__shell_commands() {
    local commands; commands=()
    _describe -t commands 'zoi shell commands' commands "$@"
}
(( $+functions[_zoi__show_commands] )) ||
_zoi__show_commands() {
    local commands; commands=()
    _describe -t commands 'zoi show commands' commands "$@"
}
(( $+functions[_zoi__sync_commands] )) ||
_zoi__sync_commands() {
    local commands; commands=(
'add:Add a new registry' \
'remove:Remove a configured registry by its handle' \
'list:List configured registries' \
'set:Set the default registry URL' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi sync commands' commands "$@"
}
(( $+functions[_zoi__sync__add_commands] )) ||
_zoi__sync__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi sync add commands' commands "$@"
}
(( $+functions[_zoi__sync__help_commands] )) ||
_zoi__sync__help_commands() {
    local commands; commands=(
'add:Add a new registry' \
'remove:Remove a configured registry by its handle' \
'list:List configured registries' \
'set:Set the default registry URL' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'zoi sync help commands' commands "$@"
}
(( $+functions[_zoi__sync__help__add_commands] )) ||
_zoi__sync__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'zoi sync help add commands' commands "$@"
}
(( $+functions[_zoi__sync__help__help_commands] )) ||
_zoi__sync__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'zoi sync help help commands' commands "$@"
}
(( $+functions[_zoi__sync__help__list_commands] )) ||
_zoi__sync__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi sync help list commands' commands "$@"
}
(( $+functions[_zoi__sync__help__remove_commands] )) ||
_zoi__sync__help__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi sync help remove commands' commands "$@"
}
(( $+functions[_zoi__sync__help__set_commands] )) ||
_zoi__sync__help__set_commands() {
    local commands; commands=()
    _describe -t commands 'zoi sync help set commands' commands "$@"
}
(( $+functions[_zoi__sync__list_commands] )) ||
_zoi__sync__list_commands() {
    local commands; commands=()
    _describe -t commands 'zoi sync list commands' commands "$@"
}
(( $+functions[_zoi__sync__remove_commands] )) ||
_zoi__sync__remove_commands() {
    local commands; commands=()
    _describe -t commands 'zoi sync remove commands' commands "$@"
}
(( $+functions[_zoi__sync__set_commands] )) ||
_zoi__sync__set_commands() {
    local commands; commands=()
    _describe -t commands 'zoi sync set commands' commands "$@"
}
(( $+functions[_zoi__telemetry_commands] )) ||
_zoi__telemetry_commands() {
    local commands; commands=()
    _describe -t commands 'zoi telemetry commands' commands "$@"
}
(( $+functions[_zoi__uninstall_commands] )) ||
_zoi__uninstall_commands() {
    local commands; commands=()
    _describe -t commands 'zoi uninstall commands' commands "$@"
}
(( $+functions[_zoi__unpin_commands] )) ||
_zoi__unpin_commands() {
    local commands; commands=()
    _describe -t commands 'zoi unpin commands' commands "$@"
}
(( $+functions[_zoi__update_commands] )) ||
_zoi__update_commands() {
    local commands; commands=()
    _describe -t commands 'zoi update commands' commands "$@"
}
(( $+functions[_zoi__upgrade_commands] )) ||
_zoi__upgrade_commands() {
    local commands; commands=()
    _describe -t commands 'zoi upgrade commands' commands "$@"
}
(( $+functions[_zoi__version_commands] )) ||
_zoi__version_commands() {
    local commands; commands=()
    _describe -t commands 'zoi version commands' commands "$@"
}
(( $+functions[_zoi__why_commands] )) ||
_zoi__why_commands() {
    local commands; commands=()
    _describe -t commands 'zoi why commands' commands "$@"
}

if [ "$funcstack[1]" = "_zoi" ]; then
    _zoi "$@"
else
    compdef _zoi zoi
fi

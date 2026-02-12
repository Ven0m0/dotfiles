type -aq fish-lsp || exit
if status is-interactive
    # $fish_lsp_enabled_handlers <ARRAY>
    # Enables the fish-lsp handlers. By default, all stable handlers are enabled.
    # (Options: 'complete', 'hover', 'rename', 'definition', 'implementation',
    #           'reference', 'logger', 'formatting', 'formatRange',
    #           'typeFormatting', 'codeAction', 'codeLens', 'folding',
    #           'selectionRange', 'signature', 'executeCommand', 'inlayHint',
    #           'highlight', 'diagnostic', 'popups', 'semanticTokens')
    # (Default: [])
    # set -gx fish_lsp_enabled_handlers

    # $fish_lsp_disabled_handlers <ARRAY>
    # Disables the fish-lsp handlers. By default, non-stable handlers are disabled.
    # (Options: 'complete', 'hover', 'rename', 'definition', 'implementation',
    #           'reference', 'logger', 'formatting', 'formatRange',
    #           'typeFormatting', 'codeAction', 'codeLens', 'folding',
    #           'selectionRange', 'signature', 'executeCommand', 'inlayHint',
    #           'highlight', 'diagnostic', 'popups', 'semanticTokens')
    # (Default: [])
    # set -gx fish_lsp_disabled_handlers

    # $fish_lsp_commit_characters <ARRAY>
    # Array of the completion expansion characters.
    # Single letter values only.
    # Commit characters are used to select completion items, as shortcuts.
    # (Example Options: '.', ',', ';', ':', '(', ')', '[', ']', '{', '}', '<',
    #                   '>', ''', '"', '=', '+', '-', '/', '\', '|', '&', '%',
    #                   '$', '#', '@', '!', '?', '*', '^', '`', '~', '\t', ' ')
    # (Default: ['\t', ';', ' '])
    set -gx fish_lsp_commit_characters ''

    # $fish_lsp_log_file <STRING>
    # A path to the fish-lsp's logging file. Empty string disables logging.
    # (Example Options: '/tmp/fish_lsp.log', '~/path/to/fish_lsp/logs.txt')
    # (Default: '')
    set -gx fish_lsp_log_file

    # $fish_lsp_log_level <STRING>
    # The logging severity level for displaying messages in the log file.
    # (Options: 'debug', 'info', 'warning', 'error', 'log')
    # (Default: '')
    set -gx fish_lsp_log_level error

    # $fish_lsp_all_indexed_paths <ARRAY>
    # The fish file paths to include in the fish-lsp's startup indexing, as workspaces.
    # Order matters (usually place `$__fish_config_dir` before `$__fish_data_dir`).
    # (Example Options: '$HOME/.config/fish', '/usr/share/fish',
    #                   '$__fish_config_dir', '$__fish_data_dir')
    # (Default: ['$__fish_config_dir', '$__fish_data_dir'])
    # set -gx fish_lsp_all_indexed_paths

    # $fish_lsp_modifiable_paths <ARRAY>
    # The fish file paths, for workspaces where global symbols can be renamed by the user.
    # (Example Options: '/usr/share/fish', '$HOME/.config/fish',
    #                   '$__fish_data_dir', '$__fish_config_dir')
    # (Default: ['$__fish_config_dir'])
    # set -gx fish_lsp_modifiable_paths

    # $fish_lsp_diagnostic_disable_error_codes <ARRAY>
    # The diagnostics error codes to disable from the fish-lsp's diagnostics.
    # (Options: 1001, 1002, 1003, 1004, 1005, 2001, 2002, 2003, 2004, 3001, 3002,
    #           3003, 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008, 5001, 5555,
    #           6001, 7001, 8001, 9999)
    # (Default: [])
    # set -gx fish_lsp_diagnostic_disable_error_codes

    # $fish_lsp_max_diagnostics <NUMBER>
    # The maximum number of diagnostics to return per file.
    # Using value `0` means unlimited diagnostics.
    # To entirely disable diagnostics use `fish_lsp_disabled_handlers`
    # (Example Options: 0, 10, 25, 50, 100, 250)
    # (Default: 0)
    set -gx fish_lsp_max_diagnostics 250

    # $fish_lsp_enable_experimental_diagnostics <BOOLEAN>
    # Enables the experimental diagnostics feature, using `fish --no-execute`.
    # This feature will enable the diagnostic error code 9999 (disabled by default).
    # (Options: 'true', 'false')
    # (Default: 'false')
    set -gx fish_lsp_enable_experimental_diagnostics true

    # $fish_lsp_strict_conditional_command_warnings <BOOLEAN>
    # Diagnostic `3002` includes/excludes conditionally chained commands to explicitly check existence.
    # ENABLED EXAMPLE: `command -q ls && command ls || echo 'no ls'`
    # DISABLED EXAMPLE: `command ls || echo 'no ls'`
    # (Options: 'true', 'false')
    # (Default: 'false')
    # set -gx fish_lsp_strict_conditional_command_warnings

    # $fish_lsp_prefer_builtin_fish_commands <BOOLEAN>
    # Show diagnostic `2004` which warns the user when they are using a recognized external command that can be replaced by an equivalent fish builtin command.
    # (Options: 'true', 'false')
    # (Default: 'false')
    set -gx fish_lsp_prefer_builtin_fish_commands true

    # $fish_lsp_allow_fish_wrapper_functions <BOOLEAN>
    # Show warnings when `alias`, `export`, etc... are used instead of their equivalent fish builtin commands.
    # Some commands will provide quick-fixes to convert this diagnostic to its equivalent fish command.
    # Diagnostic `2002` is shown when this setting is false, and hidden when true.
    # (Options: 'true', 'false')
    # (Default: 'true')
    # set -gx fish_lsp_allow_fish_wrapper_functions

    # $fish_lsp_require_autoloaded_functions_to_have_description <BOOLEAN>
    # Show warning diagnostic `4008` when an autoloaded function definition does not have a description `function -d/--description '...'; end;`
    # (Options: 'true', 'false')
    # (Default: 'true')
    # set -gx fish_lsp_require_autoloaded_functions_to_have_description 

    # $fish_lsp_max_background_files <NUMBER>
    # The maximum number of background files to read into buffer on startup.
    # (Example Options: 100, 250, 500, 1000, 5000, 10000)
    # (Default: 10000)
    set -gx fish_lsp_max_background_files 1000

    # $fish_lsp_show_client_popups <BOOLEAN>
    # Should the client receive pop-up window notification requests from the fish-lsp server?
    # (Options: 'true', 'false')
    # (Default: 'false')
    # set -gx fish_lsp_show_client_popups

    # $fish_lsp_single_workspace_support <BOOLEAN>
    # Try to limit the fish-lsp's workspace searching to only the current workspace open.
    # (Options: 'true', 'false')
    # (Default: 'false')
    # set -gx fish_lsp_single_workspace_support

    # $fish_lsp_ignore_paths <ARRAY>
    # Glob paths to never search when indexing their parent folder
    # (Example Options: '**/.git/**', '**/node_modules/**', '**/vendor/**',
    #                   '**/__pycache__/**', '**/docker/**',
    #                   '**/containerized/**', '**/*.log', '**/tmp/**')
    # (Default: ['**/.git/**', '**/node_modules/**', '**/containerized/**',
    #           '**/docker/**'])
    set -gx fish_lsp_ignore_paths "['**/.git/**', '**/node_modules/**', '**/containerized/**', '**/vendor/**', '**/docker/**', '**/__pycache__/**', '**/*.log', '**/tmp/**']"

    # $fish_lsp_max_workspace_depth <NUMBER>
    # The maximum depth for the lsp to search when starting up.
    # (Example Options: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20)
    # (Default: 5)
    # set -gx fish_lsp_max_workspace_depth

    # $fish_lsp_fish_path <STRING>
    # A path to the fish executable to use exposing fish binary to use in server's spawned child_processes.
    # Typically, this is used in the language-client's `FishServer.initialize(connection, InitializeParams.initializationOptions)`, NOT as an environment variable
    # (Example Options: 'fish', '/usr/bin/fish', '/usr/.local/bin/fish',
    #                   '~/.local/bin/fish')
    # (Default: '')
    # set -gx fish_lsp_fish_path
end

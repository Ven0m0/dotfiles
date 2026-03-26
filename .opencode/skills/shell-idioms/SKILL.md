---
name: shell-idioms
description: Multi-shell awareness for this repo's Bash/Zsh/Fish configs. Covers Zimfw (Zsh), ble.sh (Bash readline), Fish functions, and Starship prompt. Use when editing shell init files, adding aliases, or working with shell-specific syntax.
---

# Multi-Shell Config Idioms

## Shell Config Locations

| Shell | Config Files | Framework |
|-------|-------------|-----------|
| Bash | `Home/.bashrc`, `.bash_functions`, `.bash_exports` | ble.sh |
| Zsh | `Home/.config/zsh/.zshrc`, `.zshenv`, `.zprofile` | Zimfw + P10k |
| Fish | `Home/.config/fish/config.fish`, `functions/` | Native |
| All | `Home/.config/starship.toml` | Starship |

## Bash (.bashrc / .bash_functions)

- ble.sh must be sourced first and last in `.bashrc` (blerc at top, ble-attach at bottom)
- `~/.bash_functions` (~470 LOC) contains reusable functions — check before adding new ones
- Export env vars in `.bash_exports` only, not `.bashrc`
- Use `has()` from AGENTS.md for optional-tool guards in functions

## Zsh (.config/zsh/)

- Zimfw handles plugins — add to `.zimrc`, not to `.zshrc`
- P10k prompt: do NOT edit `.p10k.zsh` directly unless user requests
- `*.local.zsh` files are gitignored (machine-specific overrides)
- Completion cache in `.zcompcache/` — gitignored

## Fish (.config/fish/)

- 4-space indentation (per `.editorconfig`)
- Functions go in `functions/funcname.fish` (auto-loaded)
- No `set -euo pipefail` equivalent in Fish — error handling is different
- Universal variables (`set -U`) survive shell restarts — use sparingly

## Starship (.config/starship.toml)

- Single config file serves all shells
- Test changes with: `starship prompt` (dry-run render)
- Catppuccin Mocha color palette — maintain consistency

## Cross-Shell Aliases

When adding a new alias/function, decide per shell:
- Bash: add to `.bash_functions` or `.bashrc`
- Zsh: add to `.config/zsh/aliases.zsh` or `.zshrc`
- Fish: create `functions/aliasname.fish`
- All: consider a script in `Home/.local/bin/` instead

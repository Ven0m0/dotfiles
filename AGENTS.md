# Repo Manual: Arch/Debian Dotfiles

**Purpose:** Claude AI operational directives for dotfiles repo
**Model:** claude-\* (all) **Tone:** Blunt, precise. `Result ∴ Cause`. Lists ≤7
**System:** YADM (`Home/`→`~/`) + Tuckr (`etc/`,`usr/`→`/`)
**Targets:** Arch (CachyOS), Debian, Termux
**Priority:** User>Rules. Verify>Assume. Edit>Create. Debt-First.

## Core Standards

### Bash
- **Header:** `#!/usr/bin/env bash` + `set -euo pipefail`
- **Idioms:** `[[ ]]`, `mapfile -t`, `local -n`, `printf`, `ret=$(fn)`, `${var}`
- **Ban:** `eval`, `ls` parse, backticks, unquoted vars
- **Packages:** `paru`→`yay` (Arch) | `apt` (Debian). Verify with `pacman -Q` first.

### Tools (Prefer Modern)
fd→find | rg→grep | bat→cat | sd→sed | aria2→curl | jaq→jq | rust-parallel

### Performance
Batch I/O. Parallel ops. Anchor regex (`grep -F`). Cache hot paths. Single-pass parsing.

### Protected Files (Read-Only)
`pacman.conf`, `.zshrc`, `.gitconfig`, `sysctl.d/*.conf`, `paru.conf`, `makepkg.conf`

## Git Workflow

### Branch Management
- **Develop on:** `claude/*` branches (e.g., `claude/optimize-claude-md-K4K9r`)
- **Never:** Push to `main`/`master` without explicit permission
- **Create:** `git checkout -b <branch>` if missing

### Commits
- **Message:** `<action>: <what> [why if non-obvious]` (e.g., `fix: quote vars in systool`)
- **Stage:** Selective (`git add <files>`). Never `-A` without review.
- **Verify:** `git status` + `git diff --staged` before commit

### Push Protocol
- **Command:** `git push -u origin <branch-name>`
- **Retry:** 4× with backoff (2s, 4s, 8s, 16s) on network errors only
- **Validation:** Branch must start with `claude/` and match session ID

### Fetch/Pull
- **Specific:** `git fetch origin <branch>` (avoid bare `git fetch`)
- **Retry:** 4× with backoff on network errors

## File Operations

### Tool Priority
1. **Read:** `Read` tool (NOT `cat`/`head`/`tail`)
2. **Search:** `Grep`/`Glob` tools (NOT `grep`/`find` commands)
3. **Edit:** `Edit` tool (NOT `sed`/`awk`)
4. **Write:** `Write` tool (NOT `echo >`/heredoc)
5. **Bash:** ONLY for git, package managers, system commands

### Edit Rules
- **Always:** Read file FIRST (Edit/Write tools require it)
- **Match:** Exact indentation/whitespace from Read output
- **Scope:** Minimum viable change (no refactoring unless requested)
- **Verify:** Shellcheck/syntax before save

## Quality Assurance

### Pre-Save Checks
1. Shellcheck (bash scripts)
2. Syntax validation (all code)
3. Protected file check
4. Git status (uncommitted changes)

### CI Pipeline
`lint-format` runs: shfmt, shellcheck, biome, ruff, actionlint

### Testing
- **Pattern:** TDD (Red→Green→Refactor)
- **Scripts:** Test with target shell + shellcheck
- **Configs:** Validate syntax before deployment

## Sync Operations

- **User configs:** `yadm-sync.sh` (commits & pushes `Home/`→`~/`)
- **System configs:** `tuckr set etc usr` (deploys `/etc`, `/usr`)
- **Bootstrap:** `yadm clone --bootstrap` (full deploy)

## Key Assets (88 configs total)

### Scripts (`~/.local/bin`)
- **Sys:** `pkgui`, `systool`, `dosudo`, `autostart`
- **Media:** `media-opt`, `ffwrap`, `wp`
- **File/Net:** `fzgrep`, `fzgit`, `netinfo`, `websearch`
- **Dev:** `yadm-sync`, `lint-format`

### Configs
- **Shells:** Bash, Zsh, Fish (+ Starship prompt)
- **Terminals:** Alacritty, Kitty, Wezterm
- **Dev:** VSCode, Git, Mise, Neovim
- **AI:** Claude (agents/cmds), Copilot, Gemini

## Decision Trees

### When to use Bash vs Tools?
- **Bash:** git, paru/apt, systemctl, service management
- **Tools:** All file/search operations, text processing

### When to create vs edit?
- **Edit:** File exists in repo (99% of cases)
- **Create:** New script/config explicitly requested + doesn't exist

### When to refactor?
- **Yes:** Technical debt blocks current task
- **No:** Code works, no user request, "while we're here"

## Examples

### Fix Shellcheck Error
```bash
# Task: systool has unquoted variable
# Before: log_path=$HOME/.cache/systool.log
# After:  log_path="${HOME}/.cache/systool.log"
# Result: Shellcheck passes ∴ Variables quoted per standards
```

### Add Feature to Script
```bash
# Task: Add verbose flag to pkgui
# 1. Read ~/.local/bin/pkgui (Read tool)
# 2. Search for flag parsing (line ~15-30)
# 3. Edit to add -v flag + verbose logic (Edit tool)
# 4. Verify shellcheck passes
# 5. Commit: "feat: add verbose flag to pkgui"
# Result: Feature added ∴ Min change, QA passed
```

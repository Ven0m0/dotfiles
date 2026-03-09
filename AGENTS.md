# Dotfiles Repository Manual

**Purpose:** AI operational directives for dotfiles repository
**Tone:** Blunt, precise. Result :: Cause. Lists ≤7
**System:** YADM (`Home/` → `~/`) + Tuckr (`etc/` → `/`)
**Targets:** Arch Linux (CachyOS), Debian, Termux
**Priority:** User > Rules. Verify > Assume. Edit > Create. Debt-First.

---

## 2-Minute Summary

```
Multi-platform dotfiles repo (Arch, Debian, Termux)
27 scripts + 65+ app configs + 89 system configs

Quick Start:
  ./setup.sh                  # First-time bootstrap
  yadm-sync pull             # Deploy repo → home
  yadm-sync push             # Update repo ← home
  sudo deploy-system-configs.sh  # Deploy /etc

Technologies:
  • Shell: Bash (ble.sh), Zsh (Zimfw), Fish, Starship
  • Deployment: YADM (user), Tuckr/stow (system)
  • CI/CD: GitHub Actions (6 workflows)
  • Hooks: Lefthook (8 pre-commit hooks)
  • Desktop: KDE Plasma (Wayland), Catppuccin Mocha
```

---

## Table of Contents

- [Quick Reference](#quick-reference) - Commands & paths (memorize these)
- [Development Workflows](#development-workflows) - Daily tasks
- [Core Standards](#core-standards) - Code quality gates
- [Decision Trees](#decision-trees) - When to do what
- [Reference Section](#reference-section) - Detailed inventories & guides

---

## Quick Reference

### Essential Commands

```bash
# Dotfile Synchronization
yadm-sync pull              # Deploy: Repo → Home → ~
yadm-sync push              # Update: ~ → Home → Repo
yadm-sync status            # Show file differences
lint-format.sh              # Run all linters/formatters

# System Configuration
sudo deploy-system-configs.sh  # Deploy /etc configs (auto-detect tuckr/stow)
sudo tuckr link -d ~/dotfiles -t / etc  # Manual tuckr deploy

# Package Management
pkgui.sh                    # Interactive package TUI
paru -S package             # Install (AUR + repos)
search flutter              # AUR RPC search (bash function)

# Media & Utilities
av1pack.sh -r dir/          # AV1 batch encode
media-opt.sh -r dir/        # Optimize images/video
yt_grab.sh "URL"            # YouTube download

# Git Operations
git add Home/.config/app/config  # Selective staging
git commit -m "feat: description"
git push -u origin claude/branch-name

# Testing
bash -n script.sh           # Syntax check
shellcheck -x script.sh     # Lint
shfmt -d -i 2 script.sh     # Format validation
```

### Essential Paths

| Type | Path |
|------|------|
| User configs | `Home/.config/` |
| Scripts | `Home/.local/bin/` |
| System configs | `etc/` |
| Bash config | `Home/.bashrc`, `.bash_functions` |
| Zsh config | `Home/.config/zsh/` |
| AI config | `Home/.claude/`, `Home/.gemini/` |
| GitHub config | `.github/copilot-instructions.md` |
| CI workflows | `.github/workflows/` |
| Documentation | `CLAUDE.md`, `TODO.md`, `docs/` |

---

## Project Structure

<details>
<summary><b>Repository Layout</b> (click to expand)</summary>

```
dotfiles/
├── Home/                    # User dotfiles (~/)          [YADM]
│   ├── .config/             # 65+ app configs (XDG)
│   │   ├── alacritty/       # Terminal emulator
│   │   ├── bash/            # Bash init scripts
│   │   ├── Code/            # VS Code settings
│   │   ├── fish/            # Fish shell
│   │   ├── ghostty/         # Terminal emulator
│   │   ├── gh/              # GitHub CLI
│   │   ├── lefthook.yml     # Git pre-commit hooks
│   │   ├── mpv/             # Media player
│   │   ├── starship.toml    # Cross-shell prompt
│   │   ├── yadm/            # YADM bootstrap
│   │   ├── yazi/            # File manager
│   │   ├── yt-dlp/          # YouTube downloader
│   │   ├── zsh/             # Zsh config (Zimfw + P10k)
│   │   └── [60+ more apps]
│   ├── .local/
│   │   ├── bin/             # 27 utility scripts
│   │   └── share/           # Desktop entries, icons, snippets
│   ├── .claude/             # Claude Code settings
│   ├── .bashrc              # Bash main config
│   ├── .bash_functions      # Bash utilities (~470 LOC)
│   ├── .bash_exports        # Environment variables
│   ├── .gitconfig           # Git configuration
│   └── [27 root dotfiles]
├── etc/                     # System configs (/etc)        [Tuckr]
│   ├── pacman.conf          # Package manager
│   ├── pacman.d/hooks/      # 13 automation hooks
│   ├── systemd/             # Services, timers, limits
│   ├── udev/rules.d/        # Device rules
│   ├── ssh/                 # SSH configuration
│   └── [89 files total]
├── .github/
│   ├── workflows/           # 6 GitHub Actions workflows
│   ├── instructions/        # Detailed standards
│   ├── copilot-instructions.md
│   └── README.md
├── CLAUDE.md                # This file (main manual)
├── setup.sh                 # Bootstrap installer
└── TODO.md                  # Task tracking
```

</details>

---

## Development Workflows

### Initial Setup

```bash
# Clone & bootstrap (first time)
git clone https://github.com/Ven0m0/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh

# Or manual YADM setup
yadm clone https://github.com/Ven0m0/dotfiles.git
yadm bootstrap

# Deploy system configs (requires sudo)
sudo deploy-system-configs.sh
```

### Daily Development

```bash
# 1. Pull latest from repo
yadm-sync pull

# 2. Edit configs in ~/
# ... modify files, test changes ...

# 3. Sync changes back to repo
yadm-sync push

# 4. Stage & commit specific files
git add Home/.config/app/config.toml
git commit -m "feat(app): description"

# 5. Push to your branch
git push -u origin claude/<branch-name>
```

### Testing & Validation

```bash
# Lint & format everything
./Home/.local/bin/lint-format.sh

# Individual tool validation
shellcheck Home/.local/bin/*.sh
yamllint Home/.config/**/*.yml
jaq empty Home/.config/**/*.json
```

---

## Core Standards

<details>
<summary><b>Bash Standards</b> (click to expand)</summary>

**Script Header:**
```bash
#!/usr/bin/env bash
set -euo pipefail

has() { command -v -- "$1" &>/dev/null; }
die() { printf '\e[31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
log() { printf '\e[34mINFO: %s\e[0m\n' "$*"; }
```

**Core Rules:**
- Header: `#!/usr/bin/env bash` + `set -euo pipefail`
- Conditionals: `[[ ]]` not `[ ]`
- Variables: Always quote `"${var}"`
- Strings: Use `$'string'` or `"string"` (no backticks)
- Ban: `eval`, `ls` parsing, unquoted vars

**Idioms:**
- File reading: `$(<file)` not `$(cat file)`
- Array reading: `mapfile -t lines < file`
- String ops: `${var%suffix}`, `${var^^}` (no sed)
- Color codes: Direct ANSI `$'\e[31m'` not `tput`
- Cache: Store `command -v` results outside loops

**Performance:**
- No pipes in loops (use arrays/redirections)
- Batch I/O, parallel jobs with `xargs -P $(nproc)`
- Use anchor regex `grep -F` for literals
- Use associative arrays for lookups

**Full Reference:** [`.github/instructions/bash.instructions.md`](.github/instructions/bash.instructions.md)

</details>

<details>
<summary><b>Python Standards</b> (click to expand)</summary>

- Header: `#!/usr/bin/env python3` + type hints
- Style: `dataclasses(slots=True)`, pathlib, f-strings
- Deps: Minimal (prefer stdlib), `concurrent.futures` for parallelism
- Reference: `vidconv.py`, `git-summmary.py` for patterns

</details>

<details>
<summary><b>Tool Preferences</b> (click to expand)</summary>

| Legacy | Modern | Reason |
|--------|--------|--------|
| find | fd | Faster, parallel, cleaner syntax |
| grep | rg | 10x+ faster, colored output |
| cat | bat | Syntax highlighting |
| sed | sd | Simpler regex, single-pass |
| curl | aria2 | Parallel downloads |
| jq | jaq | Faster JSON |
| ls | eza | Modern columns, icons |

**Pattern:** Try modern tool first, graceful fallback to legacy.

</details>

---

## Decision Trees

<details>
<summary><b>When to Edit vs Create?</b></summary>

- **Create?** Only if user explicitly requests new file AND it doesn't exist (rare)
- **Edit?** File exists in repo (99% of cases) → Edit it
- **Unsure?** Ask user for clarity

</details>

<details>
<summary><b>When to Refactor?</b></summary>

- **Yes:** Technical debt blocks current task → Fix the blocker
- **No:** Code works, no user request → Avoid scope creep
- **Maybe:** Code is adjacent/unrelated → Skip it

</details>

<details>
<summary><b>Which Package Manager?</b></summary>

```
Arch:   paru → yay → pacman (fallback chain)
Debian: apt
Termux: pkg
```

**Before installing:** Verify with `pacman -Q package` (Arch)

</details>

<details>
<summary><b>Which Deployment Tool?</b></summary>

```
User configs:   yadm-sync.sh (rsync-based)
System configs: tuckr (preferred) → stow (fallback)
Full setup:     setup.sh (one-shot bootstrap)
```

</details>

---

## Reference Section

<details>
<summary><b>Scripts Inventory (27 total)</b></summary>

**System & Package Management**

| Script | Purpose |
|--------|---------|
| `pkgui.sh` | Unified Arch package TUI (fzf + paru/yay + AUR RPC) |
| `systool.sh` | System maintenance (symlinks, swap, USB, parallel rsync) |
| `deploy-system-configs.sh` | Tuckr/stow deployment wrapper |
| `lint-format.sh` | Multi-language lint/format framework |

**Media & Video**

| Script | Purpose |
|--------|---------|
| `av1pack.sh` | AV1 batch encoding (SVT-AV1, single/recursive/smart-scan) |
| `av-tool.sh` | FFmpeg wrapper (GIF, frames, trim, loudnorm, fade) |
| `media-opt.sh` | Parallel image/video optimizer |
| `media-toolkit.sh` | Media ops (burn CD, flash USB, format, DVD rip) |
| `vidconv.py` | Multi-codec video converter (AV1/VP9/H.265/x264/Opus) |

**Git & Development**

| Script | Purpose |
|--------|---------|
| `yadm-sync.sh` | Bidirectional dotfile sync (pull/push/status) |
| `gh-tools.sh` | GitHub CLI wrapper (asset DL, interactive install) |
| `fzf-tools.sh` | Fuzzy finder integration (preview, git, grep, man) |
| `git-summmary.py` | Recursive git repo statistics |
| `shopt.sh` | Shell script compiler (concat, preprocess, minify) |

**Document & Office**

| Script | Purpose |
|--------|---------|
| `office.sh` | PDF/Office compression (deflate/zstd/lossy, batch) |
| `minify_font.py` | Font optimization (strip hints, bitmaps) |

**Utilities** (12 more)

| Script | Purpose |
|--------|---------|
| `cht.sh` | Cheat sheet TUI |
| `dedupe.sh` | File deduplication (fclones + czkawka) |
| `sanitize.sh` | Whitespace/filename cleanup |
| `speedtest.sh` | Curl-based network speed test |
| `optimal-mtu.sh` | MTU optimization via binary search |
| `yt_grab.sh` | YouTube DL (yt-dlp + aria2 + SVT-AV1) |
| `vnfetch.sh` | Minimal system info fetcher |
| `neko.sh` | Anime image fetcher |
| `mc_afk.sh` | Minecraft AFK automation |
| `xsudo` | GUI app privilege escalation |
| `xdg-open` | Custom xdg-open handler |

</details>

<details>
<summary><b>Configuration Catalog (65+ apps)</b></summary>

**Terminal & Shell**

| App | Config |
|-----|--------|
| Alacritty | `.config/alacritty/` |
| Ghostty | `.config/ghostty/` |
| Bash | `.bashrc`, `.bash_functions`, `.bash_exports` |
| Zsh | `.config/zsh/` (Zimfw + P10k) |
| Fish | `.config/fish/` |
| Starship | `.config/starship.toml` |

**Development Tools**

| Category | Configs |
|----------|---------|
| Editors | `.config/Code/`, `.config/kate/`, `.config/micro/` |
| Version Mgmt | `.config/mise/`, `.config/uv/` |
| Containers | `.config/docker/`, `.config/nix/` |
| Build Tools | `.config/ccache/`, `.config/sccache/` |

**Media & Downloads**

| App | Config |
|-----|--------|
| MPV | `.config/mpv/` |
| yt-dlp | `.config/yt-dlp/` |
| aria2 | `.config/aria2/` |

**Desktop/UI (KDE)**

| Category | Config |
|----------|--------|
| Theme | fontconfig/, gtk-3.0/, qt6ct/ |
| File Manager | `.config/yazi/` |
| Launchers | Walker, Anyrun settings |

**AI Integration**

| Tool | Config |
|------|--------|
| Claude Code | `Home/.claude/settings.json` |
| Gemini | `Home/.gemini/settings.json` |
| GitHub Copilot | `.github/copilot-instructions.md` |

</details>

<details>
<summary><b>Root Dotfiles (29 files)</b></summary>

| File | Purpose |
|------|---------|
| `.bashrc`, `.bash_functions`, `.bash_exports` | Bash configuration |
| `.zshenv`, `.zprofile` | Zsh environment |
| `.gitconfig`, `.gitignore`, `.gitattributes` | Git configuration |
| `.editorconfig` | Editor settings (2-space, UTF-8) |
| `.inputrc` | Readline config |
| `.curlrc` | cURL defaults |
| `.ripgreprc`, `.ignore` | Search tool configs |
| `.shellcheckrc` | ShellCheck config |
| `.pythonstartup` | Python REPL startup |
| `.blerc` | ble.sh configuration |
| `biome.json`, `eslint.config.js` | JS/TS linting |

</details>

<details>
<summary><b>System Config Categories</b></summary>

**Package Management** (14 files)
- `pacman.conf`, `paru.conf`, `makepkg.conf`
- `pacman.d/hooks/` - 13 automation hooks

**Kernel & Boot**
- `mkinitcpio.conf`, `sdboot-manage.conf`
- `sysctl.d/` - Kernel parameters

**Systemd & Services**
- System services & timers
- `system.conf.d/`, `journald.conf.d/`

**Hardware & Performance**
- `udev/rules.d/` - 16 device rules
- `modprobe.d/`, `zram-generator.conf`

**Security & Network**
- `sudoers.d/base`, `ssh/sshd_config`
- `NetworkManager/conf.d/`, `resolv.conf`

**Gaming Optimizations**
- `gamemode.ini`, Linux Steam Integration, DXVK

</details>

<details>
<summary><b>Dependencies</b></summary>

**Core Tools (Required)**

| Tool | Purpose |
|------|---------|
| yadm | User dotfile manager |
| tuckr | System config deployment |
| git | Version control |
| bash | Shell scripting |
| python3 | Python scripts |

**Development Tools**
- shellcheck, shfmt, yamlfmt, yamllint, jaq, lefthook

**Optional Modern Tools**
- fd (find), rg (grep), bat (cat), eza (ls)

**Runtime Dependencies** (script-specific)
- `ffmpeg`, `yt-dlp`, `mpv` (media)
- `fzf`, `gh`, `paru` (utilities)
- `rsync` (sync), image tools (optimization)

</details>

<details>
<summary><b>Examples & Patterns</b></summary>

### Fix Shellcheck Error

```bash
# Task: systool has unquoted variable
# Before:  log_path=$HOME/.cache/systool.log
# After:   log_path="${HOME}/.cache/systool.log"
# Result: Shellcheck passes :: Variables quoted per standards
```

### Add Feature to Script

```bash
# Task: Add verbose flag to pkgui
# 1. Read Home/.local/bin/pkgui.sh
# 2. Find flag parsing section
# 3. Add -v flag + verbose logic
# 4. Verify: shellcheck -x pkgui.sh
# 5. Commit: "feat(pkgui): add verbose flag"
```

### Deploy System Config

```bash
# Task: Add new udev rule
# 1. Create etc/udev/rules.d/99-custom.rules
# 2. Run: sudo tuckr link -d . -t / etc
# 3. Run: sudo udevadm control --reload-rules
```

### Sync Dotfiles

```bash
# Task: Update repo with local changes
# 1. Run yadm-sync push --dry-run (preview)
# 2. Run yadm-sync push
# 3. git add <specific files>
# 4. git commit -m "chore: sync local config updates"
```

</details>

---

## Git Workflow

### Branch Strategy

- **Develop on:** `claude/*` branches (e.g., `claude/fix-systool-K4K9r`)
- **Create branch:** `git checkout -b claude/<description>-<ID>`
- **Never:** Push to `main`/`master` without explicit permission

### Commit Protocol

1. **Stage selectively:** `git add Home/.config/app/config`
2. **Verify staged:** `git diff --staged`
3. **Commit:** `git commit -m "feat(scope): description"`
4. **Push:** `git push -u origin claude/<branch-name>`

**Format:** `<type>(scope): <description>`
**Types:** `fix` | `feat` | `refactor` | `perf` | `docs` | `chore` | `style`

### Pre-commit Hooks (Automatic)

Lefthook runs on every commit (parallel):
1. Shell format/lint (shfmt, shellcheck, shellharden)
2. YAML format/lint (yamlfmt, yamllint)
3. TOML format/lint (taplo)
4. JSON validation (jaq)
5. JavaScript/TypeScript (biome)
6. Markdown lint (markdownlint-cli2)
7. Whitespace cleanup
8. GitHub Actions lint (actionlint)

All hooks auto-fix and stage changes.

---

## Protected Files

These require explicit user approval before modification:

- `etc/pacman.conf`
- `Home/.config/zsh/.zshrc`
- `Home/.gitconfig`
- `etc/sysctl.d/`, `etc/paru.conf`, `etc/makepkg.conf`
- `etc/sudoers`, `etc/ssh/sshd_config`

---

## Quick Troubleshooting

<details>
<summary><b>Deployment Issues</b></summary>

```bash
# YADM sync fails
yadm-sync status            # Check differences
yadm diff                   # Detailed diff

# Tuckr deployment fails
sudo tuckr link -d ~/dotfiles -t / --verbose etc
# Fallback: sudo stow -t / -d ~/dotfiles etc

# Permission errors
sudo chown -R $USER:$USER ~/dotfiles/Home
chmod +x ~/dotfiles/Home/.local/bin/*
```

</details>

<details>
<summary><b>Pre-commit Hook Issues</b></summary>

```bash
# Hooks not running
lefthook install

# Run hook manually
lefthook run pre-commit

# Skip temporarily (emergency)
git commit --no-verify -m "message"
```

</details>

<details>
<summary><b>Script Errors</b></summary>

```bash
# ShellCheck errors
shellcheck -x script.sh

# Permission denied
chmod +x script.sh

# Syntax error
bash -n script.sh
```

</details>

---

## AI Agent Guidelines

### Task Priorities

1. **User requests** - Always highest priority
2. **Verify before acting** - Read files, check state, confirm assumptions
3. **Edit over create** - Modify existing unless explicitly creating new
4. **Debt-first** - Fix blockers before adding features
5. **Protected files** - Never modify without explicit permission

### Best Practices

- ✅ Read file contents before editing
- ✅ Use specific `git add`, not `git add -A`
- ✅ Test scripts with shellcheck before committing
- ✅ Follow existing patterns and conventions
- ✅ Keep changes minimal and focused
- ✅ Write clear, conventional commit messages
- ❌ Don't parse `ls` output
- ❌ Don't use `eval`
- ❌ Don't skip pre-commit hooks without reason
- ❌ Don't force push to main/master
- ❌ Don't commit secrets

---

## Helpful Links

| Topic | Reference |
|-------|-----------|
| Bash Standards | [`.github/instructions/bash.instructions.md`](.github/instructions/bash.instructions.md) |
| Copilot Instructions | [`.github/copilot-instructions.md`](.github/copilot-instructions.md) |
| Task Tracking | [`TODO.md`](TODO.md) |

---

**Last Updated:** 2026-03-09
**License:** MIT

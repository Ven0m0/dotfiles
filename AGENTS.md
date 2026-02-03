# Repo Manual: Arch/Debian Dotfiles

**Purpose:** AI operational directives for dotfiles repo (Claude, Gemini, Copilot)
**Tone:** Blunt, precise. `Result ∴ Cause`. Lists ≤7
**System:** YADM (`Home/`→`~/`) + Tuckr (`etc/`,`usr/`→`/`)
**Targets:** Arch (CachyOS), Debian, Termux
**Priority:** User>Rules. Verify>Assume. Edit>Create. Debt-First.

---

## Repository Structure

```
dotfiles/
├── Home/                    # User dotfiles (~/)         [YADM]
│   ├── .config/             # 66 app configs (XDG)
│   ├── .local/bin/          # 22 utility scripts
│   ├── .bashrc              # Bash config
│   ├── .bash_functions      # Bash utilities
│   └── .bash_exports        # Environment vars
├── etc/                     # System configs (/etc)      [Tuckr]
│   ├── pacman.conf          # Package manager
│   ├── systemd/             # Services & timers
│   ├── sysctl.d/            # Kernel parameters
│   ├── modprobe.d/          # Module configs
│   ├── udev/rules.d/        # Device rules
│   └── [89 files total]
├── setup.sh                 # Bootstrap installer
├── hooks.toml               # Tuckr hooks
├── AGENTS.md                # This file
├── YADM.md                  # Deployment guide
└── BASH_PERFORMANCE.md      # Perf patterns
```

**Stats:** 66 config dirs | 22 scripts | 89 system configs | ~4K LOC

---

## Core Standards

### Bash
- **Header:** `#!/usr/bin/env bash` + `set -euo pipefail`
- **Idioms:** `[[ ]]`, `mapfile -t`, `local -n`, `printf`, `ret=$(fn)`, `${var}`
- **Ban:** `eval`, `ls` parse, backticks, unquoted vars
- **Packages:** `paru`→`yay` (Arch) | `apt` (Debian). Verify `pacman -Q` first.

### Tools (Modern Preferred)
| Legacy | Modern | Reason |
|--------|--------|--------|
| find | fd | Faster, parallel |
| grep | rg | 10x+ faster |
| cat | bat | Syntax highlight |
| sed | sd | Simpler syntax |
| curl | aria2 | Parallel DL |
| jq | jaq | Faster JSON |

### Performance
- Batch I/O, parallel ops
- Anchor regex (`grep -F`)
- Cache hot paths
- Single-pass parsing
- `$(<file)` not `$(cat file)`
- Direct ANSI codes, not `tput`

### Protected Files (Read-Only)
`pacman.conf`, `.zshrc`, `.gitconfig`, `sysctl.d/*.conf`, `paru.conf`, `makepkg.conf`

---

## Deployment System

### YADM (User Configs)
Deploys `Home/` → `~/`

```bash
yadm-sync pull    # Repo → Home → ~
yadm-sync push    # ~ → Home → Repo
yadm bootstrap    # Full first-time deploy
```

**Alternate files:** `file##os.Linux`, `file##hostname.server`

### Tuckr (System Configs)
Deploys `etc/`, `usr/` → `/` (requires sudo)

```bash
sudo tuckr link -d $(yadm rev-parse --show-toplevel) -t / etc usr
```

**Fallback:** `sudo stow -t / -d . etc usr`

---

## Scripts Inventory (`~/.local/bin`)

### System & Package Management
| Script | Purpose |
|--------|---------|
| `pkgui.sh` | Unified Arch package TUI (fzf + paru/yay) |
| `systool.sh` | System maintenance utilities |
| `deploy-system-configs.sh` | Tuckr/stow deployment |
| `lint-format.sh` | Auto-lint framework |

### Media & Video
| Script | Purpose |
|--------|---------|
| `av1pack.sh` | AV1 codec encoding |
| `av-tool.sh` | Audio-video processing |
| `media-opt.sh` | Image/audio compression |
| `media-toolkit.sh` | Media utilities |

### Git & Development
| Script | Purpose |
|--------|---------|
| `yadm-sync.sh` | Bidirectional dotfile sync |
| `gh-tools.sh` | GitHub CLI wrapper |
| `fzf-tools.sh` | Fuzzy finder integration |

### Utilities
| Script | Purpose |
|--------|---------|
| `cht.sh` | Cheat sheet CLI |
| `dedupe.sh` | File deduplication |
| `sanitize.sh` | File/system cleanup |
| `speedtest.sh` | Network speed test |
| `optimal-mtu.sh` | MTU optimization |
| `yt_grab.sh` | YouTube downloader |
| `vnfetch.sh` | System info fetcher |

---

## Configuration Categories

### Shell Configs
| Shell | Config | Framework |
|-------|--------|-----------|
| Bash | `.bashrc` + modular | Native |
| Zsh | `.config/zsh/` | Zimfw + P10k |
| Fish | `.config/fish/` | Native |
| Prompt | `.config/starship.toml` | Starship |

### Terminal Emulators
- Alacritty, Kitty, Wezterm

### Development Tools
- VSCode/Codium, Neovim, Git, Mise, Docker

### AI Integration
- Claude (`.claude/`), Gemini (`.gemini/`), Copilot

### Desktop/UI
- Plasma/KDE, Yazi, Walker, Fontconfig, GTK/Qt

### Gaming
- Gamemode, DXVK, Proton, Steam, Heroic

### Media
- YT-DLP, FFmpeg, Dolphin Emulator, Borked3DS

---

## Git Workflow

### Branch Management
- **Develop on:** `claude/*` branches (e.g., `claude/fix-systool-K4K9r`)
- **Never:** Push to `main`/`master` without permission
- **Create:** `git checkout -b <branch>` if missing

### Commits
- **Format:** `<action>: <what> [why if non-obvious]`
- **Actions:** `fix`, `feat`, `refactor`, `docs`, `chore`, `perf`
- **Stage:** Selective (`git add <files>`). Never `-A` without review.
- **Verify:** `git status` + `git diff --staged` before commit

### Push Protocol
```bash
git push -u origin <branch-name>
# Retry: 4x with backoff (2s, 4s, 8s, 16s) on network errors
# Branch must match: claude/* + session ID
```

### Fetch/Pull
```bash
git fetch origin <branch>     # Specific branch
git pull origin <branch>      # With retry on network errors
```

---

## File Operations

### Tool Priority
1. **Read:** `Read` tool (NOT `cat`/`head`/`tail`)
2. **Search:** `Grep`/`Glob` tools (NOT `grep`/`find` bash)
3. **Edit:** `Edit` tool (NOT `sed`/`awk`)
4. **Write:** `Write` tool (NOT `echo >`/heredoc)
5. **Bash:** ONLY for git, package managers, system commands

### Edit Rules
- **Always:** Read file FIRST (Edit/Write tools require it)
- **Match:** Exact indentation/whitespace from Read output
- **Scope:** Minimum viable change (no refactoring unless requested)
- **Verify:** Shellcheck/syntax before save

---

## Quality Assurance

### Pre-Save Checks
1. Shellcheck (bash scripts)
2. Syntax validation (all code)
3. Protected file check
4. Git status (uncommitted changes)

### CI Pipeline
GitHub Actions runs: `shfmt`, `shellcheck`, `biome`, `ruff`, `actionlint`

### Testing
- **Pattern:** TDD (Red→Green→Refactor)
- **Scripts:** Test with target shell + shellcheck
- **Configs:** Validate syntax before deployment

---

## System Config Categories (`etc/`)

### Package Management
- `pacman.conf`, `paru.conf`, `makepkg.conf`
- `pacman.d/hooks/` (15 hooks for automation)

### Kernel & Modules
- `sysctl.d/` (kernel parameters)
- `modprobe.d/` (nvidia, bluetooth, nvme)
- `modules-load.d/` (module autoload)

### Systemd
- `systemd/system/` (custom services)
- `systemd/user.conf.d/` (user limits)
- `systemd/journald.conf.d/` (logging)

### Hardware & Performance
- `udev/rules.d/` (17 rules for devices)
- `tmpfiles.d/` (temp file management)
- `security/limits.d/` (audio, gaming limits)

### Network
- `NetworkManager/conf.d/`
- `resolv.conf`, `dnsmasq.conf`
- `ssh/sshd_config`

---

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

### Which package manager?
```
Arch: paru → yay → pacman (fallback chain)
Debian: apt
Termux: pkg
```

---

## XDG Base Directory

All configs follow XDG:
```bash
XDG_CONFIG_HOME=~/.config
XDG_CACHE_HOME=~/.cache
XDG_DATA_HOME=~/.local/share
XDG_STATE_HOME=~/.local/state
XDG_RUNTIME_DIR=/run/user/$UID
```

---

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
# 1. Read ~/.local/bin/pkgui.sh (Read tool)
# 2. Search for flag parsing (line ~15-30)
# 3. Edit to add -v flag + verbose logic (Edit tool)
# 4. Verify shellcheck passes
# 5. Commit: "feat(pkgui): add verbose flag"
# Result: Feature added ∴ Min change, QA passed
```

### Deploy System Config
```bash
# Task: Add new udev rule
# 1. Create etc/udev/rules.d/99-custom.rules
# 2. Run: sudo tuckr link -d . -t / etc
# 3. Run: sudo udevadm control --reload-rules
# Result: Rule deployed ∴ Tuckr symlinked, udev reloaded
```

### Sync Dotfiles
```bash
# Task: Update repo with local changes
# 1. yadm-sync push (dry-run first)
# 2. Review changes
# 3. git add <specific files>
# 4. git commit -m "chore: sync local config updates"
# Result: Repo updated ∴ Selective sync, no secrets leaked
```

---

## Quick Reference

### Common Paths
| Type | Path |
|------|------|
| User configs | `Home/.config/` |
| Scripts | `Home/.local/bin/` |
| System configs | `etc/` |
| Bash config | `Home/.bashrc` |
| Zsh config | `Home/.config/zsh/` |
| Fish config | `Home/.config/fish/` |

### Key Commands
```bash
yadm-sync pull           # Deploy from repo
yadm-sync push           # Update repo
lint-format.sh           # Run all linters
pkgui.sh                 # Package TUI
systool.sh               # System maintenance
deploy-system-configs.sh # Deploy /etc configs
```

### Commit Prefixes
| Prefix | Use |
|--------|-----|
| `fix:` | Bug fix |
| `feat:` | New feature |
| `refactor:` | Code restructure |
| `perf:` | Performance |
| `docs:` | Documentation |
| `chore:` | Maintenance |
| `style:` | Formatting |

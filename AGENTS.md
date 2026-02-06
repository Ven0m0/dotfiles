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
├── Home/                    # User dotfiles (~/)           [YADM]
│   ├── .config/             # 66 app configs (XDG)
│   ├── .local/bin/          # 27 utility scripts
│   ├── .bashrc              # Bash config
│   ├── .bash_functions      # Bash utilities
│   ├── .bash_exports        # Environment vars
│   └── [40+ root dotfiles]
├── etc/                     # System configs (/etc)        [Tuckr]
│   ├── pacman.conf          # Package manager
│   ├── pacman.d/hooks/      # 13 pacman hooks
│   ├── systemd/             # Services & timers
│   ├── sysctl.d/            # Kernel parameters
│   ├── modprobe.d/          # Module configs
│   ├── udev/rules.d/        # 16 device rules
│   └── [85 files total]
├── .github/                 # CI/CD & AI automation
│   ├── workflows/           # 3 GitHub Actions
│   ├── agents/              # 5 AI agent definitions
│   ├── commands/            # 4 Gemini commands
│   ├── instructions/        # 7 coding instructions
│   └── prompts/             # 2 prompt templates
├── setup.sh                 # Bootstrap installer
├── hooks.toml               # Tuckr hooks
├── CLAUDE.md                # This file
├── YADM.md                  # Deployment guide
└── BASH_PERFORMANCE.md      # Perf patterns
```

**Key Files:**
- @Home - User dotfiles root
- @etc - System configs root
- @setup.sh - Bootstrap installer
- @hooks.toml - Tuckr hooks
- @YADM.md - Deployment guide
- @BASH_PERFORMANCE.md - Performance patterns
- @Home/.config/yadm/bootstrap - YADM bootstrap script

**Stats:** 66 config dirs | 27 scripts | 85 system configs | ~5K LOC

---

## Core Standards

### Bash
- **Header:** `#!/usr/bin/env bash` + `set -euo pipefail`
- **Idioms:** `[[ ]]`, `mapfile -t`, `local -n`, `printf`, `ret=$(fn)`, `${var}`
- **Ban:** `eval`, `ls` parse, backticks, unquoted vars
- **Packages:** `paru`→`yay` (Arch) | `apt` (Debian). Verify `pacman -Q` first.
- **Reference:** @BASH_PERFORMANCE.md

### Python
- **Header:** `#!/usr/bin/env python3` + type hints
- **Style:** dataclasses, pathlib, f-strings, `Final` constants
- **Deps:** Minimal stdlib preference, concurrent.futures for parallelism

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
@etc/pacman.conf, @Home/.config/zsh/.zshrc, @Home/.gitconfig, @etc/sysctl.d, @etc/paru.conf, @etc/makepkg.conf, @etc/sudoers, @etc/ssh/sshd_config

---

## Deployment System

### YADM (User Configs)
Deploys @Home → `~/`

```bash
yadm-sync pull    # Repo → Home → ~
yadm-sync push    # ~ → Home → Repo
yadm bootstrap    # Full first-time deploy
```

**Alternate files:** `file##os.Linux`, `file##hostname.server`
**Reference:** @YADM.md

### Tuckr (System Configs)
Deploys @etc, `usr/` → `/` (requires sudo)

```bash
sudo tuckr link -d $(yadm rev-parse --show-toplevel) -t / etc usr
```

**Fallback:** `sudo stow -t / -d . etc usr`
**Hooks:** @hooks.toml

---

## Scripts Inventory

Scripts location: @Home/.local/bin (27 total)

### System & Package Management
| Script | Purpose |
|--------|---------|
| @Home/.local/bin/pkgui.sh | Unified Arch package TUI (fzf + paru/yay) |
| @Home/.local/bin/systool.sh | System maintenance utilities (symlinks, swap, USB) |
| @Home/.local/bin/deploy-system-configs.sh | Tuckr/stow deployment wrapper |
| @Home/.local/bin/lint-format.sh | Multi-language auto-lint framework |

### Media & Video
| Script | Purpose |
|--------|---------|
| @Home/.local/bin/av1pack.sh | AV1 codec batch encoding (SVT-AV1) |
| @Home/.local/bin/av-tool.sh | FFmpeg wrapper (GIF, trim, normalize, CD prep) |
| @Home/.local/bin/media-opt.sh | Parallel image/video optimizer |
| @Home/.local/bin/media-toolkit.sh | Media ops (burn CD, flash USB, convert) |
| @Home/.local/bin/vidconv.py | Multi-codec video converter (AV1/VP9/H.265/x264) |

### Git & Development
| Script | Purpose |
|--------|---------|
| @Home/.local/bin/yadm-sync.sh | Bidirectional dotfile sync |
| @Home/.local/bin/gh-tools.sh | GitHub CLI wrapper (assets, maintenance) |
| @Home/.local/bin/fzf-tools.sh | Fuzzy finder integration (preview, git, grep) |
| @Home/.local/bin/git-summmary.py | Recursive git repo statistics |
| @Home/.local/bin/shopt.sh | Shell script compiler (concat, minify, format) |

### Document & Office
| Script | Purpose |
|--------|---------|
| @Home/.local/bin/office.sh | PDF/Office doc compression & optimization |
| @Home/.local/bin/minify_font.py | Font file optimization (strip hints/bitmaps) |

### Utilities
| Script | Purpose |
|--------|---------|
| @Home/.local/bin/cht.sh | Cheat sheet CLI (cheat.sh TUI) |
| @Home/.local/bin/dedupe.sh | File deduplication (fclones + czkawka) |
| @Home/.local/bin/sanitize.sh | Whitespace/filename cleanup |
| @Home/.local/bin/speedtest.sh | Curl-based network speed test |
| @Home/.local/bin/optimal-mtu.sh | MTU optimization finder |
| @Home/.local/bin/yt_grab.sh | YouTube downloader (yt-dlp wrapper) |
| @Home/.local/bin/vnfetch.sh | Minimal system info fetcher |
| @Home/.local/bin/neko.sh | Anime image fetcher (nekos.best/waifu.im) |

### Automation & Gaming
| Script | Purpose |
|--------|---------|
| @Home/.local/bin/mc_afk.sh | Minecraft AFK automation (fishing, eating) |
| @Home/.local/bin/xsudo | Run GUI apps with root (pkexec wrapper) |
| @Home/.local/bin/xdg-open | Custom xdg-open handler |

---

## Configuration Categories

### Shell Configs
| Shell | Config | Framework |
|-------|--------|-----------|
| Bash | @Home/.bashrc + @Home/.bash_functions | Native + ble.sh |
| Zsh | @Home/.config/zsh | Zimfw + P10k |
| Fish | @Home/.config/fish | Native |
| Prompt | @Home/.config/starship.toml | Starship |

### Terminal Emulators
- @Home/.config/alacritty
- @Home/.config/ghostty
- @Home/.config/legcord (Discord)

### Development Tools
| Category | Configs |
|----------|---------|
| Editors | @Home/.config/Code, @Home/.config/VSCodium, @Home/.config/kate, @Home/.config/micro |
| Version Mgmt | @Home/.config/mise, @Home/.config/uv |
| Containers | @Home/.config/docker, @Home/.config/containers, @Home/.config/nix |
| Git | @Home/.gitconfig, @Home/.config/gh, @Home/.config/lefthook.yml |
| Build | @Home/.config/ccache, @Home/.config/sccache |

### AI Integration
- @Home/.claude
- @Home/.gemini
- @.github/copilot-instructions.md

### Desktop/UI
- @Home/.config/plasma-nm (KDE Plasma)
- @Home/.config/yazi (file manager)
- @Home/.config/walker, @Home/.config/anyrun, @Home/.config/ulauncher (launchers)
- @Home/.config/fontconfig, @Home/.config/gtk-3.0, @Home/.config/gtk-4.0, @Home/.config/qt6ct

### Gaming & Emulation
- @Home/.config/gamemode.ini
- @Home/.config/dxvk
- @Home/.config/heroic
- @Home/.config/dolphin-emu
- @Home/.config/linux-steam-integration.conf

### Media & Downloads
- @Home/.config/yt-dlp, @Home/.config/ytdlp-gui
- @Home/.config/mpv
- @Home/.config/aria2
- @Home/.config/rclone-browser

### Monitoring
- @Home/.config/bottom (htop alternative)
- @Home/.config/fastfetch, @Home/.config/neofetch, @Home/.config/hyfetch.json

---

## Root Dotfiles Inventory

Location: @Home/

| File | Purpose |
|------|---------|
| .bashrc, .bash_functions, .bash_exports | Bash configuration |
| .zshenv, .zprofile | Zsh environment |
| .profile | POSIX shell profile |
| .gitconfig, .gitignore, .gitattributes | Git configuration |
| .editorconfig | Editor settings |
| .inputrc | Readline config |
| .curlrc | cURL defaults |
| .ripgreprc, .ignore | Search tool configs |
| .shellcheckrc | ShellCheck config |
| .pythonstartup | Python REPL startup |
| .npmrc | npm configuration |
| .nanorc | Nano editor config |
| .blerc | ble.sh configuration |
| .dircolors | ls color scheme |
| biome.json, eslint.config.js | JS/TS linting |
| .oxlintrc.json, .prettierrc | Code formatting |

---

## GitHub Automation

Location: @.github/

### Workflows
| File | Purpose |
|------|---------|
| workflows/lint-format.yml | CI: shfmt, shellcheck, biome, ruff, actionlint |
| workflows/deps.yml | Auto-approve Dependabot PRs |
| workflows/img-opt.yml | Optimize images on commit (WebP conversion) |

### AI Agents
| File | Purpose |
|------|---------|
| agents/bash.agent.md | Bash programming agent |
| agents/python.agent.md | Python programming agent |
| agents/refactoring-expert.agent.md | Code refactoring |
| agents/github-issue-fixer.agent.md | Issue resolution |
| agents/critical-thinking.agent.md | Problem-solving |

### Gemini Commands
| File | Purpose |
|------|---------|
| commands/gemini-invoke.toml | Command execution |
| commands/gemini-review.toml | Code review |
| commands/gemini-triage.toml | Issue triage |
| commands/gemini-scheduled-triage.toml | Scheduled triage |

### Instructions
| File | Purpose |
|------|---------|
| instructions/bash.instructions.md | Bash coding standards |
| instructions/python.instructions.md | Python coding standards |
| instructions/javascript.instructions.md | JS/TS standards |
| instructions/actions.instructions.md | GitHub Actions |
| instructions/markdown.instructions.md | Markdown guidelines |
| instructions/prompt.instructions.md | Prompt engineering |
| instructions/token-efficient.instructions.md | Token optimization |

---

## System Config Categories

Location: @etc (85 files)

### Package Management
- @etc/pacman.conf - Main package manager
- @etc/paru.conf - AUR helper config
- @etc/makepkg.conf, @etc/makepkg-optimize.conf - Build flags
- @etc/pacman.d/hooks/ - 13 automation hooks:
  - `40-orphans.hook` - Auto-remove orphans
  - `95-systemd-boot.hook` - Boot updates
  - `99-localepurge.hook` - Remove unused locales
  - `reflector.hook` - Mirror updates
  - `pacman-cache-cleanup.hook` - Cache management

### Kernel & Boot
- @etc/mkinitcpio.conf - Initramfs builder
- @etc/sdboot-manage.conf - Systemd-boot manager
- @etc/sysctl.d/ - Kernel parameters:
  - `10-arch.conf` - Core Arch settings
  - `99-bore-scheduler.conf` - BORE scheduler tuning
  - `99-gaming.conf` - Gaming optimizations

### Systemd Services
- @etc/systemd/system/:
  - `ksm.service` - Kernel samepage merging
  - `nvidia_oc.service` - NVIDIA overclocking
  - `pci-latency.service` - PCI latency optimization
  - `etchdns.service` - DNS service
- @etc/systemd/system.conf.d/99-gaming.conf - Gaming limits
- @etc/systemd/user.conf.d/10-limits.conf - User limits
- @etc/systemd/journald.conf.d/ - Journal tuning

### Hardware & Performance
- @etc/udev/rules.d/ - 16 device rules:
  - NVIDIA, Steelseries, audio, SATA/NVMe power management
  - IO schedulers, fan control, Wake-on-LAN
- @etc/modprobe.d/ - Module configs (NVIDIA, Bluetooth, NVMe)
- @etc/modules-load.d/ - Module autoload (ntsync for gaming)
- @etc/zram-generator.conf - Compressed swap
- @etc/preload.conf, @etc/prelockd.conf - Preloading daemons

### Security & Limits
- @etc/sudoers, @etc/sudoers.d/base - Privilege escalation
- @etc/doas.conf - doas configuration
- @etc/security/limits.d/ - Audio/gaming realtime limits

### Network
- @etc/NetworkManager/conf.d/network.conf
- @etc/resolv.conf - DNS servers
- @etc/dnsmasq.conf - DNS/DHCP
- @etc/ssh/sshd_config - SSH daemon

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
Workflows: @.github/workflows

### Testing
- **Pattern:** TDD (Red→Green→Refactor)
- **Scripts:** Test with target shell + shellcheck
- **Configs:** Validate syntax before deployment

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
# File: @Home/.local/bin/systool.sh
# Before: log_path=$HOME/.cache/systool.log
# After:  log_path="${HOME}/.cache/systool.log"
# Result: Shellcheck passes ∴ Variables quoted per standards
```

### Add Feature to Script
```bash
# Task: Add verbose flag to pkgui
# 1. Read @Home/.local/bin/pkgui.sh
# 2. Search for flag parsing (line ~15-30)
# 3. Edit to add -v flag + verbose logic (Edit tool)
# 4. Verify shellcheck passes
# 5. Commit: "feat(pkgui): add verbose flag"
# Result: Feature added ∴ Min change, QA passed
```

### Deploy System Config
```bash
# Task: Add new udev rule
# 1. Create @etc/udev/rules.d/99-custom.rules
# 2. Run: sudo tuckr link -d . -t / etc
# 3. Run: sudo udevadm control --reload-rules
# Result: Rule deployed ∴ Tuckr symlinked, udev reloaded
```

### Sync Dotfiles
```bash
# Task: Update repo with local changes
# 1. Run @Home/.local/bin/yadm-sync.sh push (dry-run first)
# 2. Review changes
# 3. git add <specific files>
# 4. git commit -m "chore: sync local config updates"
# Result: Repo updated ∴ Selective sync, no secrets leaked
```

### Add Python Script
```python
# Task: Add new utility script
# 1. Create @Home/.local/bin/newscript.py
# 2. Use: #!/usr/bin/env python3, type hints, dataclasses
# 3. Follow patterns from vidconv.py or git-summmary.py
# 4. Commit: "feat: add newscript utility"
# Result: Script added ∴ Follows Python standards
```

---

## Quick Reference

### Common Paths
| Type | Path |
|------|------|
| User configs | @Home/.config |
| Scripts | @Home/.local/bin |
| System configs | @etc |
| Bash config | @Home/.bashrc |
| Zsh config | @Home/.config/zsh |
| Fish config | @Home/.config/fish |
| AI agents | @.github/agents |
| CI workflows | @.github/workflows |

### Key Commands
```bash
yadm-sync pull           # Deploy from repo
yadm-sync push           # Update repo
lint-format.sh           # Run all linters
pkgui.sh                 # Package TUI
systool.sh               # System maintenance
deploy-system-configs.sh # Deploy /etc configs
vidconv.py --help        # Video conversion
office.sh --help         # Document optimization
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

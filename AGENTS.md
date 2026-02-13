# Dotfiles Repository Manual

**Purpose:** AI operational directives for dotfiles repository (Claude, Gemini, Copilot)
**Tone:** Blunt, precise. `Result :: Cause`. Lists ≤7
**System:** YADM (`Home/` → `~/`) + Tuckr (`etc/` → `/`)
**Targets:** Arch Linux (CachyOS), Debian, Termux
**Priority:** User > Rules. Verify > Assume. Edit > Create. Debt-First.

---

## Project Overview

Multi-platform dotfiles repository for Arch Linux (CachyOS), Debian, and Termux environments. Managed via YADM for user configs and Tuckr/stow for system configs. Includes 25 utility scripts, 65+ application configs, and 89 system configuration files.

**Tech Stack:**
- **Languages:** Bash (primary), Python 3 (utilities), YAML/TOML/JSON (configs)
- **Deployment:** YADM, Tuckr, Stow
- **CI/CD:** GitHub Actions (6 workflows)
- **Pre-commit:** Lefthook (8 hooks: shell, yaml, toml, json, biome, markdown, normalize, actionlint)
- **Shells:** Bash (ble.sh), Zsh (Zimfw + P10k), Fish, Starship prompt
- **Desktop:** KDE Plasma (Wayland), Catppuccin Mocha theme
- **Package Managers:** paru/yay (Arch AUR), apt (Debian), pkg (Termux)

---

## Repository Structure

```
dotfiles/
├── Home/                    # User dotfiles (~/)           [YADM]
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
│   │   ├── bin/             # 25 utility scripts (22 bash + 3 python)
│   │   └── share/           # Desktop entries, icons, snippets
│   ├── .claude/             # Claude Code settings
│   ├── .gemini/             # Gemini settings
│   ├── .bashrc              # Bash config
│   ├── .bash_functions      # Bash utilities (~470 LOC)
│   ├── .bash_exports        # Environment vars
│   ├── .gitconfig           # Git configuration
│   ├── .blerc               # ble.sh config (~340 LOC)
│   └── [27 root dotfiles]
├── etc/                     # System configs (/etc)        [Tuckr]
│   ├── pacman.conf          # Package manager
│   ├── paru.conf            # AUR helper
│   ├── makepkg.conf         # Build config
│   ├── pacman.d/hooks/      # 13 pacman hooks
│   ├── systemd/             # Services, timers, limits
│   ├── sysctl.d/            # Kernel parameters (4 files)
│   ├── modprobe.d/          # Module configs (5 files)
│   ├── modules-load.d/      # Module autoload
│   ├── udev/rules.d/        # Device rules
│   ├── security/limits.d/   # Audio/gaming realtime limits
│   ├── NetworkManager/      # Network config
│   ├── ssh/                 # SSH config
│   ├── sudoers.d/           # Sudo rules
│   └── [89 files total]
├── .github/                 # CI/CD & AI automation
│   ├── workflows/           # 6 GitHub Actions workflows
│   ├── copilot-instructions.md  # GitHub Copilot directives
│   ├── dependabot.yml       # Dependency updates
│   ├── FUNDING.yml          # Sponsorship links
│   └── README.md            # GitHub overview
├── docs/                    # Reference documentation
├── AGENTS.md                # This file (symlink target)
├── CLAUDE.md → AGENTS.md    # Symlink for Claude
├── GEMINI.md → AGENTS.md    # Symlink for Gemini
├── setup.sh                 # Bootstrap installer
├── hooks.toml               # Tuckr deployment hooks
├── TODO.md                  # Task tracking
├── main.knsv                # KDE Plasma backup (konsave)
├── LICENSE                  # MIT License
├── .editorconfig            # Editor settings
├── .gitattributes           # Git attributes
├── .gitignore               # Git ignore patterns
├── .shellcheckrc → Home/.shellcheckrc
├── .yamlfmt.yml → Home/.config/yamlfmt/yamlfmt.yml
└── .yamllint.yml → Home/.config/yamllint/config
```

**Key Files:**
- `setup.sh` - One-shot bootstrap installer for new systems
- `Home/.local/bin/yadm-sync.sh` - Bidirectional dotfile sync utility
- `Home/.local/bin/deploy-system-configs.sh` - System config deployment wrapper
- `Home/.config/lefthook.yml` - Pre-commit hook configuration
- `Home/.config/yadm/bootstrap` - YADM post-clone setup script

**Stats:** 65 config dirs | 25 scripts (22 bash + 3 python) | 89 system configs | ~810 LOC (bash functions)

---

## Development Workflows

### Initial Setup

```bash
# Clone repository
git clone https://github.com/Ven0m0/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Bootstrap installation (first-time setup)
./setup.sh

# Or manual YADM setup
yadm clone https://github.com/Ven0m0/dotfiles.git
yadm bootstrap

# Deploy system configs (requires sudo)
sudo ./Home/.local/bin/deploy-system-configs.sh
# or manually:
sudo tuckr link -d ~/dotfiles -t / etc
```

### Daily Development

```bash
# Pull latest configs from repo
yadm-sync pull

# Make changes to configs in ~/
# Edit files, test changes...

# Push changes back to repo
yadm-sync push              # Sync ~ -> Home/ -> commit

# Stage and commit
git add Home/.config/app/config.toml
git commit -m "feat(app): add new feature"

# Push to remote (on claude/* branch)
git push -u origin <branch-name>
```

### Testing & Validation

```bash
# Run all linters/formatters
./Home/.local/bin/lint-format.sh

# Test shell scripts
shellcheck Home/.local/bin/*.sh
shfmt -d Home/.local/bin/*.sh

# Test YAML configs
yamllint Home/.config/**/*.yml
yamlfmt -lint Home/.config/**/*.yml

# Validate JSON
jaq empty Home/.config/**/*.json

# Test Python scripts
python3 -m py_compile Home/.local/bin/*.py
```

### Deployment

**User Configs (YADM):**
```bash
yadm-sync pull              # Deploy: Repo -> Home/ -> ~/
yadm-sync push              # Update: ~/ -> Home/ -> Repo
yadm-sync status            # Show differences
yadm-sync diff              # Detailed diff
```

**System Configs (Tuckr):**
```bash
# Deploy /etc configs (preferred)
sudo tuckr link -d ~/dotfiles -t / etc

# With hooks execution
sudo tuckr link -d ~/dotfiles -t / -h hooks.toml etc

# Fallback (stow)
sudo stow -t / -d ~/dotfiles etc

# Helper script (auto-detects best tool)
sudo deploy-system-configs.sh
```

### CI/CD Pipeline

GitHub Actions runs on every push/PR:
1. **lint-format** - Validates all code (shellcheck, biome, ruff, yamllint, actionlint)
2. **img-opt** - Optimizes images automatically
3. **deps** - Auto-approves Dependabot updates
4. **jules-performance-improver** - Weekly performance analysis
5. **jules-weekly-cleanup** - Automated code maintenance

Local pre-commit hooks (Lefthook) run before each commit.

---

## Core Standards

### Bash

- **Header:** `#!/usr/bin/env bash` + `set -euo pipefail`
- **Idioms:** `[[ ]]`, `mapfile -t`, `local -n`, `printf`, `ret=$(fn)`, `${var}`
- **Ban:** `eval`, `ls` parse, backticks, unquoted vars
- **Packages:** `paru`->`yay` (Arch) | `apt` (Debian). Verify `pacman -Q` first.
- **Performance:** `$(<file)` not `$(cat)`, ANSI codes not `tput`, cache `command -v` outside loops
- **Helpers pattern** (used across all scripts):

```bash
has(){ command -v -- "$1" &>/dev/null; }
die(){ printf '\e[31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
log(){ printf '\e[34mINFO: %s\e[0m\n' "$*"; }
```

### Python

- **Header:** `#!/usr/bin/env python3` + type hints
- **Style:** dataclasses (`slots=True`), pathlib, f-strings, `Final` constants
- **Deps:** Minimal stdlib preference, `concurrent.futures` for parallelism
- **Reference:** `vidconv.py`, `git-summmary.py` for patterns

### Tools (Modern Preferred)

| Legacy | Modern | Reason |
|--------|--------|--------|
| find | fd | Faster, parallel |
| grep | rg | 10x+ faster |
| cat | bat | Syntax highlight |
| sed | sd | Simpler syntax |
| curl | aria2 | Parallel DL |
| jq | jaq | Faster JSON |

All scripts implement graceful fallback: try modern tool first, fall back to legacy.

### Performance Patterns

- Batch I/O, parallel ops (`xargs -P`, `parallel`)
- Anchor regex (`grep -F` for literals)
- Cache hot paths (associative arrays for repeated lookups)
- Single-pass parsing
- `$(<file)` not `$(cat file)`
- Direct ANSI codes, not `tput`
- `nproc` for job count detection

### Protected Files (Read-Only)

These files must not be modified by AI agents without explicit user request:

`etc/pacman.conf`, `Home/.config/zsh/.zshrc`, `Home/.gitconfig`, `etc/sysctl.d/`,
`etc/paru.conf`, `etc/makepkg.conf`, `etc/sudoers`, `etc/ssh/sshd_config`

---

## Dependencies

### Core Tools (Required)

| Tool | Purpose | Install |
|------|---------|---------|
| yadm | User dotfile manager | `paru -S yadm` or `apt install yadm` |
| tuckr | System config deployment | `paru -S tuckr` or `cargo install tuckr` |
| stow | Symlink manager (fallback) | `paru -S stow` or `apt install stow` |
| git | Version control | `paru -S git` or `apt install git` |
| bash | Shell scripting | Built-in |
| python3 | Python scripts | `paru -S python` or `apt install python3` |

### Development Tools

| Tool | Purpose | Install |
|------|---------|---------|
| shfmt | Shell formatter | `paru -S shfmt` or `go install mvdan.cc/sh/v3/cmd/shfmt@latest` |
| shellcheck | Shell linter | `paru -S shellcheck` or `apt install shellcheck` |
| shellharden | Shell hardener | `paru -S shellharden` or `cargo install shellharden` |
| yamlfmt | YAML formatter | `paru -S yamlfmt` or `go install github.com/google/yamlfmt/cmd/yamlfmt@latest` |
| yamllint | YAML linter | `paru -S yamllint` or `apt install yamllint` |
| taplo | TOML formatter/linter | `paru -S taplo-cli` or `cargo install taplo-cli` |
| jaq | JSON query tool | `paru -S jaq` or `cargo install jaq` |
| actionlint | GitHub Actions linter | `paru -S actionlint` or `go install github.com/rhysd/actionlint/cmd/actionlint@latest` |
| lefthook | Git hooks manager | `paru -S lefthook` or `go install github.com/evilmartians/lefthook@latest` |

### Optional Modern Tools

| Legacy | Modern | Purpose | Install |
|--------|--------|---------|---------|
| find | fd | Fast file finder | `paru -S fd` or `apt install fd-find` |
| grep | rg (ripgrep) | Fast text search | `paru -S ripgrep` or `apt install ripgrep` |
| cat | bat | Syntax highlighting cat | `paru -S bat` or `apt install bat` |
| sed | sd | Simple find/replace | `paru -S sd` or `cargo install sd` |
| curl | aria2 | Parallel downloader | `paru -S aria2` or `apt install aria2` |
| ls | eza | Modern ls | `paru -S eza` or `cargo install eza` |
| du | dust | Disk usage | `paru -S dust` or `cargo install du-dust` |

### Runtime Dependencies (Script-Specific)

**Media Tools:**
- `ffmpeg` - Video/audio processing (av1pack, vidconv, av-tool, media-opt)
- `svt-av1` - AV1 encoding (av1pack, vidconv)
- `yt-dlp` - YouTube downloads (yt_grab)
- `mpv` - Media playback

**System Tools:**
- `fzf` or `skim` - Fuzzy finder (pkgui, fzf-tools)
- `gh` - GitHub CLI (gh-tools)
- `paru` or `yay` - AUR helpers (pkgui)
- `rsync` - File sync (yadm-sync, systool)

**Optimization Tools:**
- `jpegoptim`, `oxipng`, `cwebp` - Image optimization (media-opt)
- `fclones`, `czkawka` - Deduplication (dedupe)
- `fontforge` - Font optimization (minify_font)

---

## Deployment System

### YADM (User Configs)

Deploys `Home/` -> `~/`

```bash
yadm-sync pull    # Repo -> Home -> ~
yadm-sync push    # ~ -> Home -> Repo
yadm bootstrap    # Full first-time deploy (install deps, deploy, configure shell)
```

**Alternate files:** `file##os.Linux`, `file##hostname.server`
**Bootstrap chain:** `setup.sh` -> `yadm clone` -> `Home/.config/yadm/bootstrap`
**Sync tool:** `Home/.local/bin/yadm-sync.sh` (rsync-based bidirectional sync)

### Tuckr (System Configs)

Deploys `etc/`, `usr/` -> `/` (requires sudo)

```bash
# Preferred (supports hooks)
sudo tuckr link -d $(yadm rev-parse --show-toplevel) -t / etc usr

# Fallback
sudo stow -t / -d . etc usr

# Helper script (auto-detects best tool)
sudo deploy-system-configs.sh
```

**Hooks:** `hooks.toml` runs post-link scripts (systemd daemon-reload, etc.)

---

## Scripts Inventory

Location: `Home/.local/bin/` (27 total)

### System & Package Management

| Script | Purpose |
|--------|---------|
| `pkgui.sh` | Unified Arch package TUI (fzf/sk + paru/yay, AUR RPC search) |
| `systool.sh` | System maintenance (smart symlinks, swap creation, USB mount, parallel rsync) |
| `deploy-system-configs.sh` | Tuckr/stow deployment wrapper with auto-detection |
| `lint-format.sh` | Multi-language lint/format framework (shell, yaml, python, markdown, toml, lua) |

### Media & Video

| Script | Purpose |
|--------|---------|
| `av1pack.sh` | AV1 batch encoding with SVT-AV1 (single, recursive, smart-scan modes) |
| `av-tool.sh` | FFmpeg wrapper (GIF, frame extract, trim, loudnorm, fade, CD-optimize) |
| `media-opt.sh` | Parallel image/video optimizer (jpegoptim, oxipng, cwebp, ffmpeg) |
| `media-toolkit.sh` | Media ops (burn CD, flash USB, format, rip DVD, PNG/WebP convert) |
| `vidconv.py` | Multi-codec video converter (AV1/VP9/H.265/x264/Opus, parallel jobs) |

### Git & Development

| Script | Purpose |
|--------|---------|
| `yadm-sync.sh` | Bidirectional dotfile sync (pull/push/status/diff) |
| `gh-tools.sh` | GitHub CLI wrapper (asset download, interactive install, repo maintenance) |
| `fzf-tools.sh` | Fuzzy finder integration (file preview, git ops, live grep, man search) |
| `git-summmary.py` | Recursive git repo statistics (parallel, threaded) |
| `shopt.sh` | Shell script compiler (concat, preprocess, minify, format, variants) |

### Document & Office

| Script | Purpose |
|--------|---------|
| `office.sh` | PDF/Office compression (deflate/zstd/lossy, batch, metadata strip) |
| `minify_font.py` | Font optimization via fontforge (strip hints/bitmaps) |

### Utilities

| Script | Purpose |
|--------|---------|
| `cht.sh` | Cheat sheet TUI (cheat.sh with fuzzy finder) |
| `dedupe.sh` | File deduplication pipeline (fclones + czkawka, hardlink/delete/dry-run) |
| `sanitize.sh` | Whitespace/filename cleanup (parallel, CRLF, Unicode, trailing WS) |
| `speedtest.sh` | Curl-based network speed test (parallel server probing) |
| `optimal-mtu.sh` | MTU optimization via binary search ping |
| `yt_grab.sh` | YouTube downloader (yt-dlp + aria2, SVT-AV1 reencode, sponsorblock) |
| `vnfetch.sh` | Minimal system info fetcher (pure bash, /proc parsing) |
| `neko.sh` | Anime image fetcher (nekos.best/waifu.im APIs, chafa/viu rendering) |

### Automation & Gaming

| Script | Purpose |
|--------|---------|
| `mc_afk.sh` | Minecraft AFK automation (fishing, eating via kdotool/ydotool) |
| `xsudo` | Run GUI apps with root (pkexec wrapper) |
| `xdg-open` | Custom xdg-open handler (delegates to handlr) |

---

## Configuration Categories

### Shell Configs

| Shell | Config | Framework |
|-------|--------|-----------|
| Bash | `.bashrc` + `.bash_functions` + `.blerc` | Native + ble.sh |
| Zsh | `.config/zsh/` | Zimfw + P10k |
| Fish | `.config/fish/` | Native |
| Prompt | `.config/starship.toml` | Starship (Catppuccin Mocha) |

**Bash function categories** (in `.bash_functions`):
- General utilities: `mkcd`, `cdls`, `up`, `fs`, `catt`, `vcode`
- Archive management: `extract` (12 formats), `cr` (5 formats)
- File operations: `cpg`, `mvg`, `ftext`, `fiximg`
- Process management: `pk`, `fkill`, `bgd`
- Fuzzy navigation: `fz` (dir/file/parent modes)
- Git functions: `ghpatch`, `ghf`, `fzf-git-status`, `git_maintain_max`, `gdbr`
- Package management: `pacsize`, `fuzzy_paru`, `search` (AUR RPC)
- Docker: `da`, `ds`, `drm`, `drmm`, `drmi`

### Terminal Emulators

| App | Config Path |
|-----|-------------|
| Alacritty | `.config/alacritty/` |
| Ghostty | `.config/ghostty/` |
| Legcord | `.config/legcord/` (Discord) |

### Development Tools

| Category | Configs |
|----------|---------|
| Editors | `.config/Code/`, `.config/VSCodium/` (symlinked), `.config/kate/`, `.config/micro/` |
| Version Mgmt | `.config/mise/`, `.config/uv/` |
| Containers | `.config/docker/`, `.config/containers/`, `.config/nix/` |
| Git | `.gitconfig`, `.config/gh/`, `.config/lefthook.yml` |
| Build | `.config/ccache/`, `.config/sccache/` |

### AI Integration

| Tool | Config |
|------|--------|
| Claude | `Home/.claude/settings.json` |
| Gemini | `Home/.gemini/settings.json` |
| Copilot | `.github/copilot-instructions.md` |

### Desktop/UI (KDE Plasma)

- Window management: KWin (Wayland)
- File manager: Yazi (`.config/yazi/`), Dolphin
- Launchers: Walker, Anyrun, Ulauncher
- Theming: `fontconfig/`, `gtk-3.0/`, `gtk-4.0/`, `qt6ct/`
- Network: `plasma-nm/` (power save disabled)

### Gaming & Emulation

| Config | Purpose |
|--------|---------|
| `gamemode.ini` | CPU governor, realtime scheduling, IO priority |
| `.config/dxvk/` | Vulkan translation layer |
| `.config/heroic/` | Game launcher |
| `linux-steam-integration.conf` | Native runtime, libintercept |

### Media & Downloads

| Config | Purpose |
|--------|---------|
| `.config/mpv/` | Media player |
| `.config/yt-dlp/` | YouTube downloader defaults |
| `.config/aria2/` | Parallel download manager |

### Monitoring

| Config | Purpose |
|--------|---------|
| `.config/bottom/` | System monitor (htop alternative) |
| `.config/fastfetch/` | System info display |
| `hyfetch.json` | Pride-themed fetch (transgender preset) |

---

## Root Dotfiles Inventory

Location: `Home/` (29 files)

| File | Purpose |
|------|---------|
| `.bashrc`, `.bash_functions`, `.bash_exports` | Bash configuration |
| `.zshenv`, `.zprofile` | Zsh environment |
| `.profile` | POSIX shell profile |
| `.gitconfig`, `.gitignore`, `.gitattributes` | Git configuration |
| `.editorconfig` | Editor settings (2-space indent, UTF-8) |
| `.inputrc` | Readline config |
| `.curlrc` | cURL defaults |
| `.ripgreprc`, `.ignore` | Search tool configs |
| `.shellcheckrc` | ShellCheck config |
| `.pythonstartup` | Python REPL startup |
| `.npmrc` | npm configuration |
| `.nanorc` | Nano editor config |
| `.blerc` | ble.sh configuration (Bash Line Editor) |
| `.dircolors` | ls color scheme |
| `biome.json`, `eslint.config.js` | JS/TS linting |
| `.oxlintrc.json`, `.prettierrc` | Code formatting |

---

## GitHub Automation

Location: `.github/`

### Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `lint-format.yml` | Push/PR | CI: shfmt, shellcheck, biome, ruff, actionlint |
| `deps.yml` | Dependabot PR | Auto-approve dependency updates |
| `dependabot-automerge.yml` | Dependabot PR | Auto-merge approved dependency updates |
| `img-opt.yml` | Push (images) | Optimize images (WebP conversion, compression) |
| `jules-performance-improver.yml` | Scheduled/manual | Automated performance optimization analysis |
| `jules-weekly-cleanup.yml` | Weekly schedule | Automated code cleanup and maintenance |

### AI Integration

| Tool | Config | Purpose |
|------|--------|---------|
| Claude Code | `Home/.claude/settings.json` | Claude agent configuration |
| Gemini | `Home/.gemini/settings.json` | Gemini agent configuration |
| GitHub Copilot | `.github/copilot-instructions.md` | Copilot coding directives |

### Dependabot

- `.github/dependabot.yml` - Automated dependency updates
- Monitors: GitHub Actions, npm, pip, cargo, docker
- Auto-merge enabled for minor/patch versions

---

## System Config Categories

Location: `etc/` (89 files)

### Package Management

- `pacman.conf` - Main package manager (CachyOS repos, chaotic-aur, locale stripping)
- `paru.conf` - AUR helper (skip review, combined upgrade, sudo loop)
- `makepkg.conf`, `makepkg-optimize.conf` - Build flags (native march, LTO, mold linker)
- `pacman.d/hooks/` - 13 automation hooks:
  - `40-orphans.hook` - Auto-remove orphans
  - `95-systemd-boot.hook` - Boot updates
  - `99-localepurge.hook` - Remove unused locales
  - `reflector.hook` - Mirror updates
  - `pacman-cache-cleanup.hook` - Cache management

### Kernel & Boot

- `mkinitcpio.conf` - Initramfs (nvme, f2fs, zstd compression)
- `sdboot-manage.conf` - Systemd-boot (NVIDIA params, performance tuning, mitigations=off)
- `sysctl.d/` - Kernel parameters:
  - `10-arch.conf` - Core settings
  - `99-bore-scheduler.conf` - BORE scheduler tuning
  - `99-gaming.conf` - Gaming optimizations

### Systemd Services

- Services: `ksm.service`, `nvidia_oc.service`, `pci-latency.service`, `etchdns.service`
- `system.conf.d/99-gaming.conf` - File descriptor limits (2M), infinite tasks
- `user.conf.d/10-limits.conf` - User limits
- `journald.conf.d/` - Journal tuning

### Hardware & Performance

- `udev/rules.d/` - 16 device rules (NVIDIA, Steelseries, SATA/NVMe, IO schedulers)
- `modprobe.d/` - Module configs (NVIDIA, Bluetooth, NVMe)
- `modules-load.d/` - Module autoload (ntsync for gaming)
- `zram-generator.conf` - Compressed swap (zstd, full RAM size)
- `preload.conf`, `prelockd.conf` - Preloading daemons

### Security & Limits

- `sudoers.d/base` - Privilege escalation (fast glob, no intercept)
- `doas.conf` - doas config (persist, wheel group)
- `security/limits.d/` - Audio/gaming realtime limits

### Network

- `NetworkManager/conf.d/network.conf` - WiFi power save disabled
- `resolv.conf` - DNS (127.0.0.53, edns0)
- `dnsmasq.conf` - Local DNS/DHCP
- `ssh/sshd_config` - SSH on port 2222, HPN-SSH extensions

---

## Git Workflow

### Branch Management

- **Develop on:** `claude/*` branches (e.g., `claude/fix-systool-K4K9r`)
- **Never:** Push to `main`/`master` without permission
- **Create:** `git checkout -b <branch>` if missing

### Commits

- **Format:** `<action>: <what> [why if non-obvious]`
- **Actions:** `fix`, `feat`, `refactor`, `docs`, `chore`, `perf`, `style`
- **Stage:** Selective (`git add <files>`). Never `-A` without review.
- **Verify:** `git status` + `git diff --staged` before commit

### Push Protocol

```bash
git push -u origin <branch-name>
# Retry: 4x with backoff (2s, 4s, 8s, 16s) on network errors
```

### Pre-commit Hooks (Lefthook)

Config: `Home/.config/lefthook.yml`

Runs automatically on commit (parallel execution):
1. **shell-format** - `shfmt`, `shellcheck`, `shellharden` (*.sh, *.bash, *.zsh)
2. **yaml-lint** - `yamlfmt`, `yamllint` (*.yml, *.yaml)
3. **toml-lint** - `taplo format`, `taplo lint` (*.toml)
4. **json-validate** - `jaq`/`jq` syntax validation (*.json, *.jsonc, *.json5)
5. **biome** - JS/TS linting & formatting (*.js, *.ts, *.jsx, *.tsx, *.json)
6. **markdown-lint** - `markdownlint-cli2` (*.md, *.markdown)
7. **normalize** - Whitespace cleanup (trailing WS, CRLF, zero-width chars, BOM)
8. **gha-lint** - `actionlint` for GitHub Actions workflows

All hooks auto-fix and stage changes. Gracefully skip if tools not installed.

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

- **Scripts:** Test with target shell + shellcheck
- **Configs:** Validate syntax before deployment
- **Pattern:** Red->Green->Refactor

---

## Decision Trees

### When to create vs edit?

- **Edit:** File exists in repo (99% of cases)
- **Create:** New script/config explicitly requested + doesn't exist

### When to refactor?

- **Yes:** Technical debt blocks current task
- **No:** Code works, no user request, "while we're here"

### Which package manager?

```
Arch: paru -> yay -> pacman (fallback chain)
Debian: apt
Termux: pkg
```

### Which deployment tool?

```
User configs:   yadm-sync.sh (rsync-based)
System configs: tuckr -> stow (fallback chain)
Full setup:     setup.sh (one-shot bootstrap)
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
XDG_BIN_HOME=~/.local/bin
XDG_PROJECTS_DIR=~/Projects
```

---

## Examples

### Fix Shellcheck Error

```bash
# Task: systool has unquoted variable
# File: Home/.local/bin/systool.sh
# Before: log_path=$HOME/.cache/systool.log
# After:  log_path="${HOME}/.cache/systool.log"
# Result: Shellcheck passes :: Variables quoted per standards
```

### Add Feature to Script

```bash
# Task: Add verbose flag to pkgui
# 1. Read Home/.local/bin/pkgui.sh
# 2. Search for flag parsing
# 3. Add -v flag + verbose logic
# 4. Verify shellcheck passes
# 5. Commit: "feat(pkgui): add verbose flag"
# Result: Feature added :: Min change, QA passed
```

### Deploy System Config

```bash
# Task: Add new udev rule
# 1. Create etc/udev/rules.d/99-custom.rules
# 2. Run: sudo tuckr link -d . -t / etc
# 3. Run: sudo udevadm control --reload-rules
# Result: Rule deployed :: Tuckr symlinked, udev reloaded
```

### Sync Dotfiles

```bash
# Task: Update repo with local changes
# 1. Run yadm-sync push --dry-run (preview first)
# 2. Run yadm-sync push
# 3. git add <specific files>
# 4. git commit -m "chore: sync local config updates"
# Result: Repo updated :: Selective sync, no secrets leaked
```

### Add Python Script

```python
# Task: Add new utility script
# 1. Create Home/.local/bin/newscript.py
# 2. Use: #!/usr/bin/env python3, type hints, dataclasses(slots=True)
# 3. Follow patterns from vidconv.py or git-summmary.py
# 4. Commit: "feat: add newscript utility"
# Result: Script added :: Follows Python standards
```

---

## Quick Reference

### Common Paths

| Type | Path |
|------|------|
| User configs | `Home/.config/` |
| Scripts | `Home/.local/bin/` |
| System configs | `etc/` |
| Bash config | `Home/.bashrc` + `Home/.bash_functions` |
| Zsh config | `Home/.config/zsh/` |
| AI config | `Home/.claude/`, `Home/.gemini/` |
| GitHub config | `.github/copilot-instructions.md` |
| CI workflows | `.github/workflows/` |
| Documentation | `docs/`, `AGENTS.md`, `TODO.md` |
| Git hooks | `Home/.config/lefthook.yml` |

### Key Commands

```bash
yadm-sync pull             # Deploy from repo
yadm-sync push             # Update repo
lint-format.sh             # Run all linters
pkgui.sh                   # Package TUI
systool.sh                 # System maintenance
deploy-system-configs.sh   # Deploy /etc configs
vidconv.py --help          # Video conversion
office.sh --help           # Document optimization
sanitize.sh ws --git       # Fix whitespace in changed files
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

---

## Common Tasks

### Package Management

```bash
# Search packages (AUR + official repos)
pkgui.sh                    # Interactive TUI with fzf/skim

# Search AUR via RPC (fast)
search flutter              # Bash function from .bash_functions

# Install from AUR
paru -S package-name        # Primary (preferred)
yay -S package-name         # Fallback

# System update
paru -Syu                   # AUR + official repos

# Clean package cache
paru -Sc                    # Remove uninstalled packages
paru -Scc                   # Clean all cache
```

### Dotfile Management

```bash
# Sync from repo to system
yadm-sync pull              # Repo -> Home/ -> ~/

# Sync from system to repo
yadm-sync push              # ~/ -> Home/ -> repo

# Check differences
yadm-sync status            # Show file differences
yadm-sync diff              # Detailed diff

# Bootstrap new system
./setup.sh                  # Full automated setup
yadm bootstrap              # YADM post-clone setup

# Deploy system configs
sudo deploy-system-configs.sh
sudo tuckr link -d ~/dotfiles -t / etc
```

### Code Quality

```bash
# Run all linters/formatters
lint-format.sh

# Format shell scripts
shfmt -w -i 2 -bn -ci -sr script.sh

# Lint shell scripts
shellcheck script.sh

# Harden shell scripts
shellharden --replace script.sh

# Format YAML
yamlfmt file.yml

# Lint YAML
yamllint file.yml

# Format TOML
taplo format file.toml

# Validate JSON
jaq empty file.json

# Normalize whitespace
sanitize.sh ws --git        # Git-tracked files
sanitize.sh ws dir/         # Specific directory
```

### Media Processing

```bash
# Convert video to AV1
av1pack.sh input.mp4        # Single file
av1pack.sh -r dir/          # Recursive batch
vidconv.py -c av1 -q 28 input.mp4

# Video utilities
av-tool.sh gif input.mp4 output.gif
av-tool.sh trim input.mp4 00:10 00:20
av-tool.sh loudnorm input.mp4

# Optimize images/videos
media-opt.sh -r dir/        # Recursive optimization
media-opt.sh image.jpg      # Single file

# Optimize documents
office.sh compress document.pdf
office.sh -l compress image.pdf  # Lossy compression

# Download YouTube
yt_grab.sh "URL"            # Best quality
yt_grab.sh -a "URL"         # Audio only
```

### System Utilities

```bash
# System maintenance
systool.sh symlinks         # Smart symlink management
systool.sh swap 16G         # Create swap file
systool.sh usb mount        # Mount USB
systool.sh rsync src/ dst/  # Parallel rsync

# Deduplicate files
dedupe.sh -m hardlink dir/  # Hardlink duplicates
dedupe.sh -m delete dir/    # Delete duplicates

# Network testing
speedtest.sh                # Speed test
optimal-mtu.sh              # Find optimal MTU

# File search & grep
fzf-tools.sh file           # Fuzzy file finder
fzf-tools.sh grep           # Live grep
fzf-tools.sh git-status     # Git status picker

# GitHub operations
gh-tools.sh download user/repo asset.tar.gz
gh-tools.sh install user/repo
```

### Git Operations

```bash
# Create feature branch
git checkout -b claude/feature-name-XYZ

# Stage changes
git add Home/.config/app/config.toml

# Commit (pre-commit hooks run automatically)
git commit -m "feat(app): add new feature"

# Push to remote
git push -u origin claude/feature-name-XYZ

# View status
git st                      # Short status (alias)
git s                       # Compact status (alias)

# View diff
git df                      # Diff unstaged
git dc                      # Diff staged

# View log
git lg                      # Pretty graph log
git hist                    # Historical log

# Useful aliases (from .gitconfig)
git unstage file            # Unstage file
git amend                   # Amend last commit (no-edit)
git undo                    # Soft reset HEAD~1
```

### Shell Navigation (Bash Functions)

```bash
# Directory navigation
mkcd newdir                 # Create and cd
cdls dir/                   # cd and list
up 3                        # Go up 3 directories
fz                          # Fuzzy directory finder

# File operations
extract archive.tar.gz      # Auto-detect and extract
cr archive.zip file1 file2  # Create archive
cpg src dst                 # Copy with progress
mvg src dst                 # Move with progress

# Process management
pk process_name             # Kill by name
fkill                       # Fuzzy process killer
bgd command                 # Background daemon

# Fuzzy tools
fz -f                       # Fuzzy file finder
fz -p                       # Parent directory finder
```

---

## Conventions & Naming

### File Naming

- **Scripts:** `lowercase-with-dashes.sh` or `snake_case.py`
- **Configs:** Follow app conventions (often lowercase, sometimes camelCase)
- **Bash functions:** `snake_case` or `lowercase` (no dashes)
- **Constants:** `UPPERCASE_WITH_UNDERSCORES`

### Directory Structure

- Follow XDG Base Directory specification
- User configs: `~/.config/app/`
- User scripts: `~/.local/bin/`
- User data: `~/.local/share/app/`
- System configs: `/etc/`

### Code Style

**Bash:**
- Strict mode: `set -euo pipefail`
- Use `[[ ]]` not `[ ]`
- Quote all variables: `"${var}"`
- Prefer `printf` over `echo`
- Use helper functions: `has()`, `die()`, `log()`

**Python:**
- Type hints required
- Use `dataclasses` with `slots=True`
- Prefer pathlib over os.path
- Use f-strings for formatting
- Minimal external dependencies

**Git:**
- Conventional commits: `type(scope): description`
- Types: fix, feat, refactor, perf, docs, chore, style
- Branch naming: `claude/<description-ID>`
- Selective staging, never `git add -A`

### Performance Guidelines

1. **Batch operations** - Process multiple files at once
2. **Parallel execution** - Use `xargs -P` or GNU parallel
3. **Cache lookups** - Store repeated `command -v` checks
4. **Direct file reading** - Use `$(<file)` not `$(cat file)`
5. **Anchor regex** - Use `grep -F` for literal strings
6. **Modern tools** - Prefer fd/rg/bat with fallbacks

---

## Troubleshooting

### Deployment Issues

```bash
# YADM sync fails
yadm-sync status            # Check what's different
yadm diff                   # See detailed changes
yadm add -u                 # Stage updates only
yadm commit -m "sync"       # Commit changes

# Tuckr deployment fails
sudo tuckr link -d ~/dotfiles -t / --verbose etc
sudo stow -t / -d ~/dotfiles --verbose etc  # Fallback

# Permission errors
sudo chown -R $USER:$USER ~/dotfiles/Home
chmod +x ~/dotfiles/Home/.local/bin/*
```

### Pre-commit Hook Issues

```bash
# Hooks not running
lefthook install            # Reinstall hooks

# Hook fails
lefthook run pre-commit     # Run manually to debug

# Skip hooks (emergency only)
git commit --no-verify -m "message"

# Disable specific hook temporarily
# Edit Home/.config/lefthook.yml, add: skip: true
```

### Script Errors

```bash
# ShellCheck errors
shellcheck -x script.sh     # Check with sourcing

# Permission denied
chmod +x script.sh

# Command not found
command -v tool || echo "Install: paru -S tool"

# Syntax error
bash -n script.sh           # Check syntax without running
```

---

## AI Agent Guidelines

### Task Priorities

1. **User requests** - Always highest priority
2. **Verify before acting** - Read files, check state, confirm assumptions
3. **Edit over create** - Modify existing files unless explicitly creating new
4. **Technical debt first** - Fix blockers before adding features
5. **Protected files** - Never modify without explicit permission

### Best Practices

- Read file contents before editing
- Use specific git add, not `git add -A`
- Test scripts with shellcheck before committing
- Follow existing patterns and conventions
- Keep changes minimal and focused
- Document non-obvious decisions
- Commit messages must be clear and conventional

### Common Pitfalls to Avoid

- Don't parse `ls` output - use globs or `find`
- Don't use `eval` - find safer alternatives
- Don't use backticks - use `$()`
- Don't skip pre-commit hooks without reason
- Don't force push to main/master
- Don't commit secrets or sensitive data
- Don't create unnecessary abstractions
- Don't add features not requested

# Repo Manual: Arch/Debian Dotfiles

**Purpose:** AI operational directives for dotfiles repo (Claude, Gemini, Copilot)
**Tone:** Blunt, precise. `Result :: Cause`. Lists <=7
**System:** YADM (`Home/`->`~/`) + Tuckr (`etc/`,`usr/`->`/`)
**Targets:** Arch (CachyOS), Debian, Termux
**Priority:** User>Rules. Verify>Assume. Edit>Create. Debt-First.

---

## Repository Structure

```
dotfiles/
├── Home/                    # User dotfiles (~/)           [YADM]
│   ├── .config/             # 65 app configs (XDG)
│   │   ├── alacritty/       # Terminal emulator
│   │   ├── bash/            # Bash init scripts
│   │   ├── Code/            # VS Code settings
│   │   ├── fish/            # Fish shell
│   │   ├── ghostty/         # Terminal emulator
│   │   ├── gh/              # GitHub CLI
│   │   ├── mpv/             # Media player
│   │   ├── starship.toml    # Cross-shell prompt
│   │   ├── yadm/            # YADM bootstrap
│   │   ├── yazi/            # File manager
│   │   ├── yt-dlp/          # YouTube downloader
│   │   ├── zsh/             # Zsh config (Zimfw + P10k)
│   │   └── [55 more apps]
│   ├── .local/
│   │   ├── bin/             # 27 utility scripts
│   │   └── share/           # Desktop entries, icons, snippets
│   ├── .bashrc              # Bash config
│   ├── .bash_functions      # Bash utilities (~470 LOC)
│   ├── .bash_exports        # Environment vars
│   ├── .gitconfig           # Git configuration
│   ├── .blerc               # ble.sh config (~340 LOC)
│   └── [25+ root dotfiles]
├── etc/                     # System configs (/etc)        [Tuckr]
│   ├── pacman.conf          # Package manager
│   ├── pacman.d/hooks/      # 13 pacman hooks
│   ├── systemd/             # Services, timers, limits
│   ├── sysctl.d/            # Kernel parameters (4 files)
│   ├── modprobe.d/          # Module configs (5 files)
│   ├── udev/rules.d/        # 16 device rules
│   ├── security/limits.d/   # Audio/gaming realtime limits
│   └── [89 files total]
├── .github/                 # CI/CD & AI automation
│   ├── workflows/           # 3 GitHub Actions
│   ├── agents/              # 5 AI agent definitions
│   ├── commands/            # 4 Gemini commands
│   ├── instructions/        # 7 coding instructions
│   ├── prompts/             # 2 prompt templates
│   └── ISSUE_TEMPLATE/      # 7 issue templates
├── docs/                    # Reference documentation
│   ├── AI-PROMPTS*.md       # Prompt engineering references
│   ├── steam.md             # Steam/gaming notes
│   └── steelseries.md       # Peripheral config
├── AGENTS.md                # This file (CLAUDE.md, GEMINI.md symlink here)
├── @setup.sh                # Bootstrap installer
├── @hooks.toml              # Tuckr hooks
├── @YADM.md                 # Deployment guide
├── @BASH_PERFORMANCE.md     # Perf patterns
├── main.knsv                # KDE Plasma backup (konsave)
└── LICENSE                  # MIT
```

**Stats:** 65 config dirs | 27 scripts | 89 system configs | ~6K LOC

**Symlinks at root:**
- `CLAUDE.md` -> `AGENTS.md`
- `GEMINI.md` -> `AGENTS.md`
- `.shellcheckrc` -> `Home/.shellcheckrc`
- `.yamlfmt.yml` -> `Home/.config/yamlfmt/yamlfmt.yml`
- `.yamllint.yml` -> `Home/.config/yamllint/config`

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
| `img-opt.yml` | Push (image changes) | Optimize images on commit (WebP conversion) |

### AI Agents

| Agent | Specialty |
|-------|-----------|
| `bash.agent.md` | Bash programming (strict mode, shellcheck) |
| `python.agent.md` | Python programming (type hints, dataclasses) |
| `refactoring-expert.agent.md` | Code restructuring (min diff, pattern preservation) |
| `github-issue-fixer.agent.md` | Issue resolution (analyze, fix, test) |
| `critical-thinking.agent.md` | Problem decomposition, root cause analysis |

### Gemini Commands

| Command | Purpose |
|---------|---------|
| `gemini-invoke.toml` | Execute structured commands |
| `gemini-review.toml` | Code review with standards enforcement |
| `gemini-triage.toml` | Issue triage and prioritization |
| `gemini-scheduled-triage.toml` | Automated scheduled triage |

### Coding Instructions

| Instruction | Scope |
|-------------|-------|
| `bash.instructions.md` | Bash coding standards |
| `python.instructions.md` | Python coding standards |
| `javascript.instructions.md` | JS/TS standards (Biome) |
| `actions.instructions.md` | GitHub Actions patterns |
| `markdown.instructions.md` | Markdown guidelines |
| `prompt.instructions.md` | Prompt engineering |
| `token-efficient.instructions.md` | Token optimization |

### Issue Templates

Bug reports, feature requests, implementation plans, TODOs, and custom templates.

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

Runs automatically on commit:
1. `shfmt` + `shellcheck` + `shellharden` (shell files)
2. `yamlfmt` + `yamllint` (YAML)
3. `taplo` (TOML)
4. `jaq`/`jq` validation (JSON)
5. `biome` (JS/TS)
6. `markdownlint` (Markdown)
7. Whitespace normalization (trailing WS, CRLF, zero-width chars)
8. `actionlint` (GitHub Actions)

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
| AI agents | `.github/agents/` |
| Coding standards | `.github/instructions/` |
| CI workflows | `.github/workflows/` |
| Gemini commands | `.github/commands/` |

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

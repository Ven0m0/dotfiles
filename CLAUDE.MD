# Claude Instructions: CachyOS/Arch Linux Dotfiles Repository

## Repository Overview

**Purpose:** Production-grade dotfiles repository for CachyOS/Arch Linux systems with performance optimization, modern tooling, and AI-assisted development workflows.

**Target System:** CachyOS (Arch-based) with x86-64-v3 optimization
**Repository Size:** ~12.4 MB (430+ files)
**Primary Focus:** System configuration, shell scripting, performance optimization, automated deployment

## Core Directives

Autonomous execution. Minimal confirmations. Token-efficient responses. Primary focus: Bash scripts & system configs.

## Operating Principles

- **Direct Execution**: Edit files immediately without requesting permission
- **Confirm Only Critical Changes**: Wide-scope architectural changes only
- **Quality-Driven**: Thorough validation, best practices, fact verification
- **Edit Over Create**: Modify existing files preferentially
- **Multi-Approach Analysis**: Compare pros/cons when multiple solutions exist
- **Efficient Planning**: Outline complex approaches before implementation

### Communication Style

Language: Technical English | Tone: Professional, concise | Complexity: Advanced | Emojis: Minimal usage | Naming: Brief, clear

### Abbreviations Reference

y=Yes n=No c=Continue r=Review u=Undo | cfg=config impl=implementation arch=architecture deps=dependencies val=validation sec=security err=error opt=optimization Δ=change mgr=manager fn=function mod=modify rm=remove w/=with dup=duplicate

---

## Repository Structure

```
/home/user/dotfiles/
├── Home/                          # User configurations (383 files, 12 MB)
│   ├── .config/                   # 70+ application configs
│   │   ├── zsh/                   # Primary shell (269-line .zshrc)
│   │   ├── fish/                  # Alternative shell
│   │   ├── starship.toml          # Prompt configuration
│   │   ├── yazi/                  # Terminal file manager
│   │   ├── alacritty/             # GPU terminal emulator
│   │   ├── Code/, VSCodium/       # VS Code configurations
│   │   ├── mpv/, soar/            # Media players
│   │   └── [70+ other apps]
│   ├── .cargo/                    # Rust toolchain config
│   ├── .claude/                   # Claude CLI setup
│   │   ├── settings.json          # Claude environment
│   │   ├── commands/              # Custom commands
│   │   └── agents/                # Custom agents (13)
│   ├── .bashrc, .zshenv           # Shell configs
│   └── .gitconfig                 # Git configuration (239 lines)
├── etc/                           # System configs (47 files, 124 KB)
│   ├── systemd/                   # System daemon configs
│   ├── sysctl.d/                  # Kernel parameters (100+ tweaks)
│   │   ├── 99-tweak-settings.conf # TCP BBR, VM tuning
│   │   ├── 99-bore-scheduler.conf # BORE scheduler
│   │   └── 10-arch.conf          # Arch-specific
│   ├── modprobe.d/                # Kernel modules
│   │   ├── nvidia.conf            # NVIDIA optimization
│   │   ├── nvme.conf              # NVMe tweaks
│   │   └── bluetooth.conf
│   ├── pacman.conf                # Package manager (x86-64-v3)
│   ├── paru.conf                  # AUR helper
│   ├── makepkg.conf               # Build system (highly optimized)
│   ├── mkinitcpio.conf            # Initramfs (zstd compression)
│   ├── environment                # Global env vars
│   └── NetworkManager/
├── .github/                       # CI/CD & AI automation
│   ├── workflows/                 # 7 GitHub Actions
│   │   ├── aio.yml                # Unified linters
│   │   ├── shell.yml              # Shell linting
│   │   ├── fish.yml               # Fish validation
│   │   ├── img-opt.yml            # Image optimization
│   │   ├── mega-linter.yml        # All linters
│   │   └── update-git-submodules.yml
│   ├── agents.yml                 # Claude agents (13)
│   ├── chat-modes.yml             # Chat modes (6)
│   ├── prompts/                   # Prompt templates (10)
│   ├── instructions/              # Language-specific
│   └── chatmodes/
├── .vscode/
│   ├── settings.json              # VS Code config
│   └── mcp.json                   # MCP servers (4)
├── setup.sh                       # Bootstrap script (151 lines)
├── CLAUDE.MD                      # This file
├── README.md                      # Overview & references
├── TODO.md                        # Development notes
└── .gitmodules                    # Submodule: fast-syntax-highlighting
```

---

## Key Systems & Configurations

### 1. Package Management Hierarchy

**System Packages (pacman):**
- Architecture: x86-64-v3 (SIMD optimizations)
- Parallel downloads: 10 connections
- Download accelerator: aria2c (3 parallel, 7 connections per file)
- Repositories: cachyos-v3, core, extra, multilib, chaotic-aur, alhp

**AUR Helper (paru):**
- Modern, parallel AUR helper
- Flags: `--needed --noconfirm --skipreview --sudoloop --batchinstall`
- Uses: gix (Rust Git), sudo-rs
- Options: RemoveMake, CleanAfter enabled

**Build System (makepkg.conf):**
```bash
# Compiler: clang with sccache caching
# Linker: lld (LLVM)
# CFLAGS: -O3 -march=x86-64-v3 -mtune=generic
# LDFLAGS: -Wl,-O3,--as-needed,-z,relro,-z,now,--pack-dyn-relocs=relr
# RUSTFLAGS: -Copt-level=3 -Ctarget-cpu=native -Clink-arg=-fuse-ld=mold
# Parallel: make/ninja with $(nproc)
# Compression: zstd (initramfs -19 --long)
```

**Other Package Managers:**
- cargo (Rust) + cargo-binstall (binary caching)
- uv (ultra-fast Python package manager)
- npm/yarn (Node.js)
- mise (polyglot version manager)

### 2. Shell Environment

**Primary: Zsh** (`Home/.config/zsh/.zshrc` - 269 lines)
- Theme: Powerlevel10k (p10k.zsh)
- Plugin: fast-syntax-highlighting (git submodule)
- Custom completions: rg, gix, sk, fzf, uv, compresscli
- Custom themes: transgender, bisexual, lgbtq

**Secondary: Bash** (`Home/.bashrc` - 54 lines)
- Custom functions, completions, plugins

**Alternative: Fish** (`Home/.config/fish/config.fish` - 54 lines)
- Fish plugins, variables, completions

**Prompt: Starship** (`Home/.config/starship.toml`)
- Custom git repo detection
- Yazi level tracking
- Mommy integration on right side

**Key Tools:**
- zoxide (cd replacement)
- fzf/sk (fuzzy finder)
- eza (ls replacement)
- bat (cat replacement)
- fd (find replacement)
- rg (grep replacement)
- sd (sed replacement)

### 3. System Optimizations

**Kernel Parameters (sysctl.d/):**
```conf
# TCP Stack: BBR congestion control, FastOpen, ECN
# Memory: swappiness=150, dirty_bytes=256M, vfs_cache_pressure=50
# Network: SYN cookies, RFC1337, neighbor GC tuning
# Security: kptr_restrict=2, unprivileged namespace clone
# Performance: NMI watchdog disabled, split lock mitigation off
# Limits: inotify.max_user_watches=524k, vm.max_map_count=1M
```

**NVIDIA Optimizations (modprobe.d/nvidia.conf):**
```conf
NVreg_UsePageAttributeTable=1
NVreg_InitializeSystemMemoryAllocations=0
NVreg_DynamicPowerManagement=0x02
NVreg_EnableMSI=1
NVreg_EnableGpuFirmware=1
nvidia-drm modeset=1 fbdev=1  # Critical for Wayland/KMS
```

**Environment Variables (etc/environment):**
```bash
# Telemetry: All disabled (DOTNET, POWERSHELL, DO_NOT_TRACK)
# Allocators: jemalloc (percpu, tcache), mimalloc (large pages)
# GPU: VAAPI, sync objects, Wayland support
# Proton/Gaming: FSR4, NVAPI, NGX, Wayland decorations
# Development: PYTHON_JIT=1, CARGO_HTTP_MULTIPLEXING=true
# Claude: COPILOT_ALLOW_ALL=true, DISABLE_NONESSENTIAL_TRAFFIC=1
```

### 4. Development Workflows

**Bootstrap Process (setup.sh):**
1. Pre-flight: Non-root check, sudo auth, internet connectivity
2. AUR helper: Install paru-bin via makepkg
3. Package installation: Essential tools (git, aria2, zsh, fd, rg, bat, etc.)
4. Dotfiles: Clone via yadm + rsync Home/ to $HOME
5. System configs: Link via tuckr (etc/ and usr/ to /)
6. Shell change recommendations

**Git Configuration:**
- Pager: delta (syntax-aware diff)
- Editor: micro
- Aliases: 20+ shortcuts (lg, st, amend, cleanup, etc.)
- Performance: compression=6, deltaBaseCacheLimit=1g, multiPackIndex
- Submodule: fast-syntax-highlighting (GitHub)

**CI/CD Workflows (GitHub Actions):**
1. **Unified Linters** - Reusable workflow integration
2. **Shell Linting** - shellcheck for .sh, .bash files
3. **Fish Validation** - Syntax, indent, fishtape tests
4. **Image Optimization** - WebP export, compression
5. **MegaLinter** - All linters (excludes: .github, .git, .cache, etc.)
6. **Submodule Auto-Update** - Weekly Sunday 5 AM UTC
7. **Dependabot Auto-Merge** - Automatic dependency updates

**Dependabot Updates (Weekly Monday 04:00 UTC):**
- GitHub Actions, Git submodules, Python pip, npm, Docker

### 5. Application Configurations (70+ apps)

**Terminal/Shell:**
- alacritty (Nord theme, 100x30, 10k history)
- ghostty, rio (alternative terminals)
- bottom, btop (system monitors)

**File Management:**
- yazi (primary file manager: toml, theme, keymap, package)
- xplr, superfile (alternatives)
- dust (disk usage analyzer)

**Development:**
- Code/VSCodium (comprehensive settings)
- micro (text editor: settings.json, bindings.json)
- git (239-line config)
- mise (tool version manager)

**Media:**
- mpv (video player)
- soar (CLI music player)
- wpaperd (wallpaper daemon with systemd service)

**Desktop:**
- KDE Plasma: qt6ct, kdedefaults, plasma-localerc, kate
- GTK: gtk-3.0, gtk-4.0
- fontconfig

**Utilities:**
- aria2 (download manager)
- fastfetch, neofetch, hyfetch (system info)
- tealdeer (tldr client)
- topgrade (system updater)
- zellij (terminal multiplexer)

---

## Bash Script Standards

### Canonical Template

```bash
#!/usr/bin/env bash
export LC_ALL=C LANG=C

# Color definitions
BLK=$'\e[30m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m'
BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' WHT=$'\e[37m'
LBLU=$'\e[38;5;117m' PNK=$'\e[38;5;218m' BWHT=$'\e[97m'
DEF=$'\e[0m' BLD=$'\e[1m'

# Utility functions
has() { command -v "$1" &>/dev/null; }
```

### Code Patterns

#### Package Management

**Detection Chain:**
- Arch: `paru` → `yay` → `pacman`
- Debian: `apt` / `dpkg`

**Pre-Installation Checks:**
```bash
pacman -Q pkg 2>/dev/null     # Arch package check
flatpak list | grep -q pkg    # Flatpak check
cargo install --list | grep pkg  # Rust binary check
```

**Distro-Specific Hints:**
```bash
# Include installation commands for both ecosystems
# (Arch: pacman -S tool) (Debian: apt-get install -y tool)
```

#### Data Handling & Performance

**Array Population:**
```bash
mapfile -t arr < <(command)  # Avoids subshell performance penalties
```

**Prohibitions:**
- ❌ Never parse `ls` output
- ❌ Use subprocess spawning sparingly

**Associative Arrays:**
```bash
declare -A cfg=([dry_run]=0 [debug]=0 [verbose]=0)
```

**Modern Tool Preferences:**
```bash
# File finding: fd → find
# Text search: rg → grep
# File viewing: bat → cat
# Text substitution: sd → sed
# Download: aria2 → curl → wget (no aria2 for piped output)
# JSON processing: jaq → jq
# Fuzzy selection: sk → fzf
# Parallelization: rust-parallel → parallel → xargs
```

**Optimization Focus:**
- Batch operations
- Minimize subprocess spawning
- Use modern Rust-based tools

#### Interactive Mode

**Fuzzy Finder Integration:**
```bash
# Use fzf for path selection when args missing
has fd && fd -t f | fzf || find . -type f | fzf
```

**AUR Helper Flags:**
```bash
paru --needed --noconfirm --removemake --cleanafter \
     --sudoloop --skipreview --batchinstall
```

#### Network Operations

**Standard Flags:**
```bash
curl -fsL --http2 <URL>
aria2c -x3 -s7 <URL>  # 3 parallel, 7 connections per file
```

**Documentation:**
- Update README curl snippets when modifying entrypoints

---

## Tooling Standards

### Code Quality Pipeline

```bash
# Format, lint, and harden shell scripts
shfmt -i 2 -ln bash -bn -s file.sh && \
shellcheck -f diff file.sh | patch -Np1 && \
shellharden --replace file.sh
```

### Tool Fallback Chains

```bash
# File operations
fd → find

# Downloads
aria2 → curl → wget2 → wget
# Note: No aria2 if piping output

# Parallelization
rust-parallel → parallel → xargs
```

---

## Development Practices

### Test-Driven Development

**Process:** Write failing test (Red) → Implement minimal passing code (Green) → Refactor for quality

### Change Classification

- **Structural**: Organization, formatting (no behavior changes)
- **Behavioral**: Function addition, modification, deletion
- **Rule**: Never mix in same commit

### Commit Requirements

**All must be true:**
- ✅ Tests pass
- ✅ Zero warnings
- ✅ Single logical unit
- ✅ Clear message

**Preference:** Small, frequent, independent commits

### Code Quality Standards

- Single responsibility per function/module
- Loose coupling via interfaces
- Early returns for clarity
- Avoid premature abstraction
- Eliminate duplication immediately
- Explicit dependencies, clear intent
- Small, focused functions

### Prohibited Patterns

❌ Hardcoded values (use constants/config/environment)
❌ Repetitive code blocks (create functions)
❌ Duplicated error handling (unify patterns)
❌ Replicated logic (abstract appropriately)

---

## Claude AI Integration

### Claude CLI Configuration

**Settings** (`Home/.claude/settings.json`):
```json
{
  "env": {
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4.5",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "DISABLE_TELEMETRY": "1",
    "USE_BUILTIN_RIPGREP": "0"
  },
  "permissions": {
    "allow": [
      "Bash(ls:*)", "Bash(cat:*)", "Bash(sed:*)", "Bash(git:*)",
      "mcp__serena", "WebFetch"
    ]
  },
  "enabledPlugins": [
    "code-review-ai", "full-stack-orchestration",
    "code-refactoring", "agent-orchestration"
  ]
}
```

### Specialized Agents (13 available)

**Located in:** `.github/agents.yml` and `Home/.claude/agents/`

1. **bash-expert** - Production Bash scripts
2. **performance-optimizer** - Profiling & optimization
3. **code-janitor** - Tech debt elimination
4. **critical-thinker** - Challenge assumptions
5. **code-reviewer** - Code quality feedback
6. **security-specialist** - Security audit
7. **documentation-expert** - Technical writing
8. **deep-reflector** - Deep analysis
9. **github-issue-fixer** - Issue resolution
10. **kiro-assistant** - Workflow orchestration
11. **pr-reviewer** - Pull request review
12. **shell-script-optimizer** - Script optimization
13. **ui-engineer** - UI/UX development

**Invoke:** `@agent-name [task]`

### Chat Modes (6 available)

**Located in:** `.github/chat-modes.yml` and `.github/chatmodes/`

1. **thinking-beast-mode** - Deep analysis
2. **critical-thinking** - Challenge reasoning
3. **janitor** - Code cleanup
4. **prompt-engineer** - Prompt optimization
5. **rust-gpt-4.1-beast-mode** - Rust-specific
6. **software-engineer-agent-v1** - Full-stack dev

**Activate:** `/mode [mode-name]`

### Custom Commands

**Located in:** `Home/.claude/commands/`

**Thinking Commands:**
- think, think-harder, think-ultra
- criticalthink, eureka
- reflection, reflection-harder

**GitHub Commands:**
- gh/fix-issue, gh/review-pr

**Kiro Workflow:**
- kiro/design, kiro/spec, kiro/task, kiro/execute, kiro/vibe

**Utility:**
- create-command

### Prompt Templates (10 available)

**Located in:** `.github/prompts/`

- bash-script
- boost
- create-agents.md
- create-llms.md
- create-readme.md
- editorconfig
- revanced-optimization
- review-and-refactor

**Use:** `/template [template-name]`

### Language-Specific Instructions

**Located in:** `.github/instructions/`

- bash, markdown, python, rust
- performance, tame, token-efficient
- actions (GitHub Actions)

### VS Code MCP Servers

**Located in:** `.vscode/mcp.json`

1. **fetch** - uvx mcp-server-fetch
2. **sequential-thinking** - npx @modelcontextprotocol/server-sequential-thinking
3. **filesystem** - npx @modelcontextprotocol/server-filesystem
4. **memory** - npx @modelcontextprotocol/server-memory

---

## Important File Locations

### Configuration Files to Preserve

**DO NOT MODIFY without explicit request:**
- `etc/pacman.conf` - Critical package manager config
- `etc/makepkg.conf` - Highly optimized build settings
- `etc/sysctl.d/99-tweak-settings.conf` - Kernel tuning
- `etc/modprobe.d/nvidia.conf` - GPU driver configuration
- `Home/.config/zsh/.zshrc` - Complex shell setup
- `Home/.gitconfig` - Extensive git configuration
- `setup.sh` - Bootstrap script

**Safe to modify/extend:**
- Shell scripts in general
- Application configs in `Home/.config/`
- Documentation files (*.md)
- GitHub workflows (with testing)

### Git Submodules

**Current submodule:**
- `Home/.config/zsh/plugins/fast-syntax-highlighting`
- Source: `git@github.com:BachoSeven/fast-syntax-highlighting.git`

**When updating submodules:**
```bash
git submodule update --remote --merge
git add .gitmodules Home/.config/zsh/plugins/fast-syntax-highlighting
git commit -m "Update submodule: fast-syntax-highlighting"
```

---

## Repository-Specific Conventions

### Naming Conventions

**Shell Scripts:**
- Lowercase with hyphens: `update-system.sh`
- Verb-first naming: `setup.sh`, `clean.sh`, `rank.sh`

**Config Files:**
- Lowercase: `pacman.conf`, `makepkg.conf`
- Descriptive prefixes: `99-tweak-settings.conf`, `10-arch.conf`

**Directories:**
- Lowercase: `etc/`, `sysctl.d/`, `modprobe.d/`
- Capitalized for user space: `Home/`

### Security Considerations

**Privilege Escalation:**
- Use `doas` instead of `sudo` where configured
- Never run entire scripts as root - elevate only when needed
- Check `etc/doas.conf` for allowed commands

**Secrets Management:**
- Never commit sensitive data
- Use environment variables for API keys
- Check `.gitignore` before adding new files

**Network Security:**
- Verify TLS/SSL for downloads: `curl -fsL`
- Use checksums when available
- Prefer official repositories

### Performance Guidelines

**Compilation:**
- Always use available build flags from `etc/makepkg.conf`
- Leverage sccache for C/C++ compilation caching
- Use cargo-binstall for Rust binaries when available

**Script Optimization:**
- Profile with `time` or `hyperfine` before optimizing
- Use parallel tools for batch operations
- Minimize I/O operations in loops

**System Impact:**
- Be aware of kernel parameter changes
- Test sysctl changes before making permanent
- Monitor system resources during intensive operations

---

## Testing & Validation

### Pre-Commit Checks

**Shell Scripts:**
```bash
shfmt -i 2 -ln bash -bn -s file.sh  # Format
shellcheck file.sh                   # Lint
shellharden --check file.sh          # Security
```

**Fish Scripts:**
```bash
fish --no-execute file.fish          # Syntax check
fish_indent --check file.fish        # Indent check
```

**Configuration Files:**
- Validate before deployment
- Test in isolated environment when possible
- Keep backups of system configs

### CI/CD Validation

**Automatic Checks:**
- Shell linting (shellcheck)
- Fish validation (syntax, indent)
- Image optimization
- MegaLinter (comprehensive)
- Dependabot security updates

**Manual Testing Required:**
- System configuration changes (etc/)
- Bootstrap script modifications (setup.sh)
- Kernel parameter adjustments (sysctl.d/)

---

## Common Tasks

### Adding New Package Manager Config

1. Research optimal flags for the package manager
2. Create config in appropriate location (etc/ or Home/.config/)
3. Document in this file under "Key Systems & Configurations"
4. Test with dry-run or isolated environment
5. Update setup.sh if needed for bootstrap

### Optimizing Shell Script

1. Run through code quality pipeline (shfmt, shellcheck, shellharden)
2. Check for modern tool alternatives (rg vs grep, fd vs find)
3. Profile performance with `time` or `hyperfine`
4. Ensure error handling and early returns
5. Add interactive mode with fzf if appropriate
6. Document distro-specific requirements

### Adding System Tweak

1. Research kernel parameter thoroughly
2. Add to appropriate sysctl.d/ file with comments
3. Test with `sysctl -p /etc/sysctl.d/[file].conf`
4. Monitor system behavior after applying
5. Document rationale in this file
6. Consider adding to CI validation if possible

### Creating New Claude Agent

1. Define agent purpose and scope
2. Add to `.github/agents.yml` or `Home/.claude/agents/`
3. Follow existing agent structure
4. Test with sample tasks
5. Document usage in this file
6. Consider adding custom command if needed

---

## Environment & Ecosystem

### Target Distribution

**Primary:** CachyOS (Arch-based)
- x86-64-v3 architecture
- CachyOS-optimized repositories
- Performance-focused

**Secondary:** Generic Arch Linux
- Compatible with standard Arch
- May need repository adjustments

**Related:** Debian support in separate repo
- See: https://github.com/Ven0m0/dotfiles-pi

### Hardware Assumptions

**CPU:** x86-64-v3 capable (AVX, AVX2, BMI1, BMI2, F16C, FMA, LZCNT, MOVBE, OSXSAVE)
**GPU:** NVIDIA with Wayland support assumed
**Storage:** NVMe SSD (tunings applied)
**Memory:** Sufficient for aggressive caching (deltaBaseCacheLimit=1g)

### Desktop Environment

**Primary:** KDE Plasma 6
**Display Server:** Wayland (NVIDIA DRM/KMS enabled)
**Session Management:** systemd user services

---

## External References

### Documentation

- **README.md** - Overview, package sources, useful links
- **Firefox.md** - Firefox configuration guide
- **TODO.md** - Development notes and snippets
- **Submodules.txt** - External resource references

### Related Repositories

- **Main Scripts:** https://github.com/Ven0m0/Linux-OS
- **Debian Dotfiles:** https://github.com/Ven0m0/dotfiles-pi
- **Reusable Workflows:** https://github.com/Ven0m0/.github

### Useful Resources

- Dotfiles Hub: https://dotfiles.github.io/
- Terminal Color Designer: https://terminal.sexy/
- Arch Wiki Git: https://wiki.archlinux.org/title/Git

---

*Optimized for Claude's context window and reasoning capabilities*
*Last updated: 2025-11-15*
*Repository version: See git log for latest commit*

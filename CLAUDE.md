# Claude Operating Manual

## Repository Overview

**Type:** Advanced Linux dotfiles repository
**Management:** YADM + Tuckr
**Target Systems:** Arch Linux (CachyOS primary), Debian/Raspbian, Termux
**Total Configs:** 88 application directories in .config/
**Total Scripts:** 29 automation scripts (~6,036 LOC)

**Structure:**
```
/home/user/dotfiles/
├── Home/       # User configs (→ ~/)
├── etc/        # System configs (→ /etc)
├── usr/        # System libs/bins (→ /usr)
├── .github/    # Workflows, agents, instructions
├── .gemini/    # Gemini AI config
├── .qlty/      # Code quality tools
├── setup.sh    # Main installer
└── hooks.toml  # Tuckr hooks
```

## Prime Directives

1. **User Primacy:** User commands override all rules.
1. **Factual Verification:** Use tools for versions/APIs. Never guess.
1. **Surgical Modification:** Edit > Create. Minimal line changes. Preserve existing style/logic.
1. **Debt-First:** Remove clutter/deps before adding. Subtraction > Addition.
1. **Autonomous Execution:** Act immediately. Minimize confirmations unless destructive.

## Communication

- **Tone:** Blunt, factual, precise, concise. Technical English.
- **Format:** 2-space indent. No filler. Strip U+202F/U+200B/U+00AD.
- **Output:** Result-first (`Result ∴ Cause`). Group by domain. Lists ≤7 items.
- **Abbrev:** cfg, impl, deps, val, auth, opt, Δ.

### Symbols

→ leads to | ⇒ converts | « / » precedes/follows | ∴ / ∵ therefore/because | ✅ / ❌ success/fail | ⚡ performance | 🛡️
security | 🧪 testing | 📦 deployment | 🔍 analysis

## Bash Standards

**Targets:** Arch/Wayland (primary), Debian/Raspbian (secondary), Termux.

```bash
#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'
export LC_ALL=C LANG=C HOME="/home/${SUDO_USER:-$USER}"
has(){ command -v "$1" &>/dev/null; }
```

**Idioms (Strict):**

- Tests: `[[ ... ]]`. Regex: `[[ $var =~ ^regex$ ]]`
- Loops: `while IFS= read -r line; do ...; done < <(cmd)`. **NO** `for x in $(ls)`
- Output: `printf` over `echo`. Capture: `ret=$(fn)`
- Functions: `name(){ ... }` (no `function` kw). Nameref: `local -n ref=name`
- Arrays: `mapfile -t`. Assoc: `declare -A cfg=([key]=val)`
- **Forbidden:** Parsing `ls`, `eval`, backticks, unnecessary subshells

**Quote:** Always quote variables unless intentional glob/split.

**Privilege & Packages:**

- Escalation: `sudo-rs`→`sudo`→`doas` (store in `PRIV_CMD`)
- Install: `paru`→`yay`→`pacman` (Arch); `apt` (Debian)
- Check first: `pacman -Q`, `flatpak list`, `cargo install --list`

## Tool Hierarchy (Fallbacks Required)

| Task     | Primary         | Fallback Chain                       |
| :------- | :-------------- | :----------------------------------- |
| Find     | `fd`            | `fdfind`→`find`                      |
| Grep     | `rg`            | `grep -E` (prefer `-F` for literals) |
| View     | `bat`           | `cat`                                |
| Edit     | `sd`            | `sed -E`                             |
| Nav      | `zoxide`        | `cd`                                 |
| Web      | `aria2`         | `curl`→`wget2`→`wget`                |
| JSON     | `jaq`           | `jq`                                 |
| Parallel | `rust-parallel` | `parallel`→`xargs -r -P$(nproc)`     |

## Performance

**Measure first. Optimize hot paths.**

- **General:** Batch I/O. Cache computed values. Early returns.
- **Bash:** Minimize forks/subshells. Use builtins. Anchor regexes. Literal search (grep -F, rg -F).
- **Frontend:** Minimize DOM Δ. Stable keys in lists. Lazy load assets/components.
- **Backend:** Async I/O. Connection pooling. Avoid N+1 queries. Cache hot data (Redis).

## Protected Files

**Do NOT modify unless explicitly requested:**

- `pacman.conf`, `makepkg.conf`, `/etc/sysctl.d/`, `.zshrc`, `.gitconfig`

**Safe zones:** Shell scripts, `.config/`, docs, workflows.

## Workflow (TDD & Atomic)

1. **Red:** Write/verify failing test.
1. **Green:** Minimal logic to pass.
1. **Refactor:** Optimize (subtractive design).
1. **Commit:** Single logical unit. Tests pass. No lint errors.
   - Never mix structural (format) and behavioral changes.

## File Operations

- **Edit over create:** Use `str_replace` for existing files.
- **Validation:** Run shellcheck, verify bash syntax before saving.
- **Preserve:** Maintain existing indent, comment style, logic flow.

## Deployment Strategy

**YADM (User Files):**
- Manages Home/ directory → ~/
- Bidirectional sync: `~/.local/bin/yadm-sync.sh`
- Alternate files: OS/hostname-specific configs
- Git-based versioning
- Encryption support for secrets

**Tuckr (System Files):**
- Manages etc/ → /etc, usr/ → /usr
- Symlink-based deployment
- Requires sudo/doas privilege
- Hook system via hooks.toml

**Bootstrap Process:**
```bash
# 1. Clone repo
yadm clone --bootstrap

# 2. Install packages (git, zsh, starship, fzf, etc.)
# 3. Deploy Home/ → ~/
# 4. Deploy etc/ → /etc (via tuckr)
# 5. Deploy usr/ → /usr (via tuckr)
# 6. Process alternate files
# 7. Configure shell environment
# 8. Run application bootstraps
```

**Testing Modes:**
- `./setup.sh --dry-run` - Preview changes
- `yadm-sync.sh --dry-run` - Preview sync

## Key Scripts (Home/.local/bin/)

**Package Management:**
- `pkgui.sh` - Unified package manager TUI (pacui + yayfzf)
- `pkgsync.sh` - Package list synchronization
- `gh-get-asset.sh` - GitHub release downloader

**System Tools:**
- `systool.sh` - System maintenance (ln2, swap, symclean, usb, sysz, prsync)
- `dosudo.sh` - Privilege escalation wrapper (sudo-rs→sudo→doas)
- `doasedit.sh` - Doas-based file editing
- `autostart.sh` - Autostart manager

**Media:**
- `media-opt.sh` - Media optimization
- `ffwrap.sh` - FFmpeg wrapper
- `wp.sh` - Wallpaper manager

**File Operations:**
- `sanitize-filenames.sh` - Filename sanitizer
- `fzgrep.sh` - Fuzzy grep with preview
- `fzgit.sh` - Fuzzy git operations
- `fzman.sh` - Fuzzy man page viewer

**Network:**
- `netinfo.sh` - Network info viewer
- `speedtest.py` - Speed test (Python)
- `websearch.sh` - Web search CLI

**Development:**
- `yadm-sync.sh` - Bidirectional ~/ ↔ repo sync
- `git-rm-submodule.sh` - Submodule removal
- `lint-format.sh` - Comprehensive lint & format
- `shopt.sh` - Shell option viewer

## CI/CD Workflows

**Code Quality (.github/workflows/):**
- `lint-format.yml` - Multi-language linting (shfmt, shellcheck, biome, yamllint, actionlint, ruff, markdownlint)
- `shell.yml` - Shell script validation
- `ast-grep.yml` - AST-based code analysis

**Maintenance:**
- `deps.yml` - Dependency management
- `update-git-submodules.yml` - Auto-update submodules
- `img-opt.yml` - Image optimization
- `mise.yml` - Mise tool version management

**Quality Tools (.qlty/qlty.toml):**
16 plugins: actionlint, ast-grep, bandit, biome, eslint, prettier, radarlint-js, radarlint-python, ripgrep, ruff, black, shellcheck, trivy, trufflehog, yamllint

**Linting Standards:**
- Bash: shfmt -i 2 -ci -bn, shellcheck
- Python: black + ruff (line-length 120)
- JS/JSON: biome (primary), prettier (fallback)
- YAML: yamllint, yamlfmt
- Markdown: mdformat, markdownlint
- Actions: actionlint

## Shell Configurations

**3 Shells Supported:**

**Bash:**
- Home/.bashrc (main)
- Home/.bash_exports.bash
- Home/.config/bash/init.bash
- Completions: Home/.config/bash/completions/
- Plugins: Home/.config/bash/plugins/

**Zsh:**
- Home/.config/zsh/.zshrc (main)
- Home/.config/zsh/p10k.zsh (Powerlevel10k theme)
- Home/.config/zsh/plugins.zsh
- Completions: Home/.config/zsh/completions/

**Fish:**
- Home/.config/fish/config.fish
- Home/.config/fish/fish_plugins
- Functions: Home/.config/fish/functions/

## Application Configs (88 Total)

**Development:** VSCode/VSCodium, Kate, Micro, Git, Cargo, Mise, Nix, AST-grep, Biome
**Terminal:** Alacritty, Ghostty, Rio, Zellij, Yazi, Superfile, Bottom, Fastfetch
**System:** Aria2, Paru, Yay, Topgrade, YADM, Systemd user services
**Desktop:** Anyrun, Walker, Eww, Wired, GTK-3.0/4.0, Qt6ct, Wpaperd
**Media:** MPV, OBS Studio, MangoHud
**Other:** Firefox, OneDrive, Containers (Podman/Docker), Ccache, Sccache

## AI Agent Configurations

**Claude Code (Home/.claude/):**
- 17 custom commands (apply-thinking-to, check-best-practices, cleanup, create-command, criticalthink, eureka, reflection, think-harder, think-ultra, gh/fix-issue, gh/review-pr, kiro/*)
- 13 agents (command-creator, deep-reflector, github-issue-fixer, insight-documenter, instruction-reflector, kiro-*, pr-reviewer, shell-script-optimizer, ui-engineer)

**GitHub Copilot:**
- .github/copilot-instructions.md (project coding guidelines)
- .github/instructions/ (7 language-specific: actions, bash, markdown, performance, python, rust, tame, token-efficient)

**Prompts Library (.github/prompts/):**
bash-script, boost, check-best-practices, cleanup, review-and-refactor

**Gemini AI (.gemini/config.yaml):**
Code review settings (severity: MEDIUM, auto PR analysis)

## System Configurations (etc/)

**Network:** NetworkManager, dnsmasq, ssh/sshd_config
**Packages:** pacman.conf, paru.conf, pacman.d/hooks/
**Security:** sudoers.d/base, doas.conf
**Tuning:** sysctl.d/, kernel/cmdline, tmpfiles.d/, prelockd.conf, preload.conf, scx_loader.toml
**Services:** systemd/system/, ntpd-rs/, udev/rules.d/

## Working with This Repository

**Common Tasks:**

```bash
# Sync changes from ~/ to repo
yadm-sync.sh --dry-run  # Preview
yadm-sync.sh            # Execute

# Deploy system configs (requires sudo)
tuckr set etc usr

# Run full linting
lint-format.sh

# Package management
pkgui.sh                # Interactive TUI
paru -Syu               # Update all packages

# System maintenance
systool.sh              # Interactive menu
```

**Before Committing:**
- Run shellcheck on modified bash scripts
- Verify 2-space indentation (shfmt -i 2)
- Test in clean environment if possible
- Ensure lint-format.yml passes

**When Adding Scripts:**
- Place in Home/.local/bin/
- Use standard header (bash standards above)
- Add error handling (set -euo pipefail)
- Implement tool fallbacks
- Document with inline comments
- Test on Arch and Debian if possible

**When Modifying Configs:**
- Read existing config first
- Preserve comments and structure
- Test changes before committing
- Document breaking changes in commit
- Consider OS-specific alternates

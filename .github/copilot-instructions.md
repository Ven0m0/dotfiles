# Copilot Instructions: Linux-OS

## Repo Map
`[ProjectRoot]/`: [purpose root] | `src/`: [purpose src]

## Bash Template
Canonical (adapt from https://github.com/dylanaraps/pure-bash-bible / https://google.github.io/styleguide/shellguide.html or existing):
```bash
#!/usr/bin/env bash
export LC_ALL=C LANG=C
# Color & Effects
BLK=$'\e[30m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m'
BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' WHT=$'\e[37m'
LBLU=$'\e[38;5;117m' PNK=$'\e[38;5;218m' BWHT=$'\e[97m'
DEF=$'\e[0m' BLD=$'\e[1m'
has() { command -v "$1" &>/dev/null; }
xecho() { printf '%b\n' "$*"; }
```

## Code Patterns
### Privilege & Pkg Mgrs
- Detect: `paru`→`yay`→`pacman` (Arch); `apt`/`dpkg` (Debian) → `pkgmgr` array
- Check before install: `pacman -Q pkg`, `flatpak list`, `cargo install --list`
- Bashism over POSIX, shortcuts, compact
- Fast & simple, not verbose

### Deps
Distro hints: `(Arch: pacman -S f2fs-tools)` or `(Debian: sudo apt-get install -y f2fs-tools)`

### Data
- `mapfile -t arr < <(cmd)` avoid subshells; never parse `ls`
- Assoc arrays cfg: `declare -A cfg=([dry_run]=0 [debug]=0 [ssh]=0)`

### Interactive
- Arg-less w/ fzf when `src_path`/`tgt_path` missing
- Fallback: `command -v fd &>/dev/null && fd -e img ... | fzf || find ... | fzf`
- AUR: `--needed --noconfirm --removemake --cleanafter --sudoloop --skipreview --batchinstall`

### Network
`curl -fsL`

## Tooling
### Fmt/Lint/Harden
```bash
shfmt -i 2 -ci -sr file.sh && \
shellcheck -f diff file.sh | patch -Np1 && \
shellharden --replace file.sh
```
Lint: `shellcheck file.sh` (disabled `.shellcheckrc`) | Harden: run `Harden Script` task

### Modern (w/ Fallbacks)
`fd`/`find` | `rg`/`grep` | `bat`/`cat` | `sd`/`sed` | `zoxide`/`cd` | `bun`/`npm`

### README
Update curl snippets when mod entrypoints: `curl -fsSL https://raw.githubusercontent.com/Ven0m0/repo/main/...`

## Dev Practices
### TDD
1. **Red**: Failing test
2. **Green**: Min code → pass
3. **Refactor**: Improve after pass

### Change Types
**Structural**: org/fmt (no behavior Δ) | **Behavioral**: fn add/mod/del
❌ Never mix same commit

### Commit
Only when: ✅ Tests pass | ✅ Zero warns | ✅ Single unit | ✅ Clear msg
Prefer: small, frequent, independent

### Quality
Single responsibility | Loose coupling via interfaces | Early returns | Avoid over-abstraction | Elim dup immediately | Clear intent, explicit deps | Small, single-responsibility

### Prohibitions
❌ Hardcode (use const/cfg/env) ❌ Repetitive (functionize) ❌ Common err (unify) ❌ Dup logic (abstract)

## Token Efficiency
### Symbols
→ leads | ⇒ converts | ← rollback | ⇄ bidir | & and | | or | » then | ∴ therefore | ∵ because

### Status
✅ done ❌ fail ⚠️ warn 🔄 active ⏳ pending 🚨 critical

### Domains
⚡ perf 🔍 analysis 🔧 cfg 🛡️ sec 📦 deploy 🎨 UI 🏗️ arch 🗄️ DB ⚙️ backend 🧪 test

### Abbrev
cfg→config | impl→implementation | arch→architecture | req→requirements | deps→dependencies | val→validation | auth→authentication | qual→quality | sec→security | err→error | opt→optimization | Δ→change | mgr→manager | fn→function | mod→modify | rm→remove | w/→with | dup→duplicate

### Examples
`Security vulnerability found at line 45` → `auth.js:45 → 🛡️ sec vuln`
`Build completed. Tests running.` → `build ✅ » test 🔄`

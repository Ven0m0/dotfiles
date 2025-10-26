# Copilot Instructions: Linux-OS
## Repo map
- `[ProjectRoot]/`: [Purpose of root files]
- `src/`: [Purpose of main source directory]

## Bash script template
Start scripts with this canonical structure (adapt from https://github.com/dylanaraps/pure-bash-bible / https://google.github.io/styleguide/shellguide.html or existing scripts):
```bash
#!/usr/bin/env bash
export LC_ALL=C LANG=C
# Color & Effects
BLK=$'\e[30m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m'
BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' WHT=$'\e[37m'
LBLU=$'\e[38;5;117m' PNK=$'\e[38;5;218m' BWHT=$'\e[97m'
DEF=$'\e[0m' BLD=$'\e[1m'
# Core helpers (standardize across repo)
has() { command -v "$1" &>/dev/null; }
xecho() { printf '%b\n' "$*"; }
```

## Code patterns
**Privilege & package managers:**
- Detect pkg manager: `paru`→`yay`→`pacman` (Arch); fall back to `apt`/`dpkg` (Debian). Store in `pkgmgr` array variable.
- Check existing packages before installing: `pacman -Q pkg`, `flatpak list`, `cargo install --list`.
- Prefer bashism's over posix shell code, try to take shortcuts and compact code where possible.
- Keep is as fast and simple as possible
- Dont be verbose

**Dependency checking:**
- Provide distro-specific install hints: `(Arch: pacman -S f2fs-tools)` or `(Debian: sudo apt-get install -y f2fs-tools)`.

**Data collection & processing:**
- Use `mapfile -t arr < <(command)` to avoid subshells; never parse `ls` output.
- Use associative arrays for config: `declare -A cfg=([dry_run]=0 [debug]=0 [ssh]=0)`.

**Interactive mode:**
- Support arg-less invocation with fzf selection when `src_path`/`tgt_path` missing.
- Fallback to `find` if `fd` unavailable: `command -v fd &>/dev/null && fd -e img ... | fzf || find ... | fzf`.

- AUR helper flags: `--needed --noconfirm --removemake --cleanafter --sudoloop --skipreview --batchinstall`.

**Network operations:**
- Use optimized curl: `curl -fsL` for downloads.

## Tooling workflow
- Format: `shfmt -i 2 -ci -sr file.sh && shellcheck -f diff file.sh | patch -Np1 && shellharden --replace file.sh`; lint: `shellcheck file.sh` (disabled codes in `.shellcheckrc`); harden: run `Harden Script` task.
- Prefer modern tools with fallbacks: `fd`/`find`, `rg`/`grep`, `bat`/`cat`, `sd`/`sed`, `zoxide`/`cd`, `bun/npm`.
- Update `README.md` curl snippets when modifying script entrypoints (maintain `curl -fsSL https://raw.githubusercontent.com/Ven0m0/repo/main/...` patterns).

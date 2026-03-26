---
name: bash-dotfiles
description: Expert knowledge of bash scripting standards for this dotfiles repo. Covers mandatory header, safety flags, variable quoting, banned patterns, and modern tool idioms (rg/fd/bat/eza/jaq). Use when writing or reviewing any .sh file in Home/.local/bin/ or shell config files.
---

# Bash Dotfiles Standards

## Mandatory Script Header

```bash
#!/usr/bin/env bash
set -euo pipefail

has() { command -v -- "$1" &>/dev/null; }
die() { printf '\e[31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
log() { printf '\e[34mINFO: %s\e[0m\n' "$*"; }
```

Every script in `Home/.local/bin/` MUST start with exactly this header. No exceptions.

## Safety Rules

- `set -euo pipefail` — always present, on line 2
- `[[ ]]` not `[ ]` — bash-native conditionals only
- Quote every variable: `"${var}"` not `$var`
- No `eval` — use arrays/functions/parameter expansion
- No backtick substitution — use `$(cmd)` only
- No `ls` parsing — use globs or `fd`

## Variable & String Idioms

```bash
# File contents (no cat subshell)
content=$(<"${file}")

# Array from file
mapfile -t lines < "${file}"

# String trim suffix/prefix
base="${path%.*}"
dir="${path%/*}"
upper="${var^^}"

# ANSI colors (no tput)
RED=$'\e[31m'; RESET=$'\e[0m'
printf '%s%s%s\n' "${RED}" "error text" "${RESET}"
```

## Tool Fallback Chain

Always try modern tool first, fall back to legacy:
```bash
if has rg; then
  rg -l "pattern" .
elif has grep; then
  grep -rl "pattern" .
fi

if has fd; then
  fd -e sh .
else
  find . -name "*.sh"
fi
```

## Performance

- Cache `command -v` results outside loops: `has_rg=$(has rg && echo 1 || echo 0)`
- Batch I/O: `xargs -P "$(nproc)"` for parallel jobs
- Use `grep -F` for literal string matching (no regex overhead)
- Use associative arrays for O(1) lookups instead of repeated `grep`

## Script Placement

- New utility scripts → `Home/.local/bin/scriptname.sh`
- Must be executable: `chmod +x`
- Must pass: `shellcheck -x scriptname.sh` and `shfmt -d -i 2 scriptname.sh`

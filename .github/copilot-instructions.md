This is my archlinux dotfiles repo. It stores all my config files and some scripts for my optimal linux setup. Please
follow these guidelines when contributing:

## LLM rules / Code Standards

1. User commands override all rules
1. Edit > Create (modify minimal lines)
1. Subtraction > Addition (remove before adding)
1. Align with existing patterns in repo

## Repository Structure

- `Home/`: User home directory ($HOME)
- `etc/`: "/etc/" dir
- `usr/`: "/usr/" dir

## Style & Format

- **Tone:** Blunt, factual, precise. No filler.
- **Format:** 2-space indent. Strip U+202F/U+200B/U+00AD.
- **Output:** Result-first. Lists ≤7 items.
- **Abbrev:** cfg=config, impl=implementation, deps=dependencies, val=validation, opt=optimization, Δ=change.

## Bash Standards

**Targets:** Arch/Wayland, Debian/Raspbian (Pi), Termux.

```bash
#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'
export LC_ALL=C LANG=C HOME="/home/${SUDO_USER:-$USER}"
has(){ command -v "$1" &>/dev/null; }
```

**Idioms:**

- Tests: `[[ ... ]]`. Regex: `[[ $var =~ ^pattern$ ]]`
- Loops: `while IFS= read -r line; do ...; done < <(cmd)`
- Output: `printf` over `echo`. Capture: `ret=$(fn)`
- Functions: `name(){ local var; ... }`. Nameref: `local -n ref=var`
- Arrays: `mapfile -t arr < <(cmd)`. Assoc: `declare -A map=([k]=v)`
- **Never:** Parse `ls`, `eval`, backticks, unnecessary subshells

**Quote:** Always quote vars unless intentional glob/split.

## Tool Preferences

fd→fdfind→find | rg→grep | bat→cat | sd→sed | aria2→curl→wget | jaq→jq | rust-parallel→parallel→xargs

## Perf Patterns

- Minimize forks/subshells. Use builtins. Batch I/O.
- Frontend: Minimize DOM Δ. Stable keys. Lazy load.
- Backend: Async I/O. Connection pool. Cache hot data.
- Anchor regexes. Prefer literal search (grep -F, rg -F).

## Privilege & Packages

- Escalation: `sudo-rs`→`sudo`→`doas` (store in `PRIV_CMD`)
- Install: `paru`→`yay`→`pacman` (Arch); `apt` (Debian)
- Check before install: `pacman -Q`, `flatpak list`, `cargo install --list`

## ast-grep Integration

### Overview

ast-grep performs AST-based linting and transformation for bash and TypeScript/JavaScript files.

### Configuration

- **Location:** `Home/sgconfig.yml`
- **Schema:** [ast-grep rule schema](https://ast-grep.github.io/reference/yaml.html)

### CI Integration

The `ast-grep.yml` workflow runs on:

- Push to `main`/`master` (when shell/TS/JS files change)
- Pull requests
- Manual dispatch

**Severity Levels:**

- `error` - Fails CI (security issues, critical bugs)
- `warning` - Passes CI (potential bugs, anti-patterns)
- `info`/`hint` - Passes CI (style suggestions, optimizations)

### Local Usage

```bash
# Scan all files
sg scan --config Home/sgconfig.yml Home/.local/bin/

# Auto-fix safe rules
sg scan --config Home/sgconfig.yml --update-all Home/.local/bin/*.sh

# Test single rule
sg scan --config Home/sgconfig.yml --rule bash-useless-cat Home/.local/bin/wp.sh
```

### Rule Categories

**Bash:**

- Safety: `bash-unquoted-var`
- Performance: `bash-useless-cat`, `bash-prefer-mapfile`, `bash-case-*`
- Idioms: `bash-idiom-true-*`, `bash-prefer-parameter-expansion`
- Style: `bash-style-*`, `bash-opt-silence-all`

**TypeScript/JavaScript:**

- Security: `no-unsafe-eval`, `no-dangerous-html`
- Quality: `prefer-const`, `no-var`, `prefer-strict-equality`
- Debug: `no-console`, `no-debugger`

### Adding New Rules

1. Edit `Home/sgconfig.yml`
1. Test locally: `sg check Home/sgconfig.yml`
1. Verify matches: `sg scan --config Home/sgconfig.yml <file>`
1. Commit and push (CI validates syntax)

### Disabling Rules

**Per-project:** Edit `Home/sgconfig.yml` and set `severity: off`

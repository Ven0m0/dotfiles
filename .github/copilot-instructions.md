# GitHub Copilot Dev Guardrails

**Purpose:** Code generation guardrails for GitHub Copilot
**Model:** copilot (claude-sonnet-4.5 based)
**Tone:** Blunt, precise. Result-first. Lists ≤7.

---

## 30-Second Summary

| Aspect | Standard |
|--------|----------|
| **Language** | Bash (primary), Python (utilities) |
| **Edit Strategy** | User > Rules. Edit existing files > Create new. |
| **Code Style** | 2-space indent, `set -euo pipefail`, `[[ ]]`, `"${var}"`, no `eval` |
| **Tools** | fd → find, rg → grep, bat → cat, eza → ls, sd → sed, jaq → jq |
| **Performance** | Batch I/O, no pipes in loops, parallel jobs, cache hot paths |
| **Quality** | shellcheck + shfmt clean, no syntax errors, all scripts executable |

---

## Core Principles

1. **User > Rules** - User request overrides any guideline
2. **Edit > Create** - Modify existing file (99% case), only create if explicitly requested
3. **Subtraction > Addition** - Remove cruft, simplify, avoid over-engineering
4. **Pattern Alignment** - Follow existing code patterns in the repository

---

## Language-Specific Standards

### Bash

**Quick Reference:** `set -euo pipefail` | Quote vars | `[[ ]]` > `[ ]` | No `eval`/backticks | shfmt + shellcheck clean

**Full Standards:** [`.github/instructions/bash.instructions.md`](.github/instructions/bash.instructions.md)

**Essential Checks:**
```bash
bash -n script.sh              # Syntax check
shellcheck -x script.sh        # Linting
shfmt -d -i 2 -bn -ci -sr script.sh  # Format validation
```

### Python

**Style:** Type hints required | Use `dataclasses(slots=True)` | pathlib > os.path | f-strings | Minimal deps

**Template:**
```python
#!/usr/bin/env python3
from dataclasses import dataclass
from pathlib import Path
from typing import Final

CONSTANT: Final = "value"

@dataclass(slots=True)
class Config:
    name: str
    path: Path
```

### YAML/TOML/JSON

**Validators:** `yamllint` + `yamlfmt` | `taplo format` + `taplo lint` | `jaq empty`

---

## Toolchain Preferences

**Modern First, Graceful Fallback:**

| Legacy | Modern | Why |
|--------|--------|-----|
| `find` | `fd` | Faster, parallel, human syntax |
| `grep` | `rg` | 10x+ faster, colored output |
| `cat` | `bat` | Syntax highlighting |
| `ls` | `eza` | Modern columns, icons, tree |
| `sed` | `sd` | Simpler regex syntax |
| `curl` | `aria2` | Parallel downloads |
| `jq` | `jaq` | Faster, simpler |
| `xargs` | `parallel` | Better parallelism control |

**Pattern:**
```bash
if has rg; then
  rg "$pattern" "$dir"
else
  grep -r "$pattern" "$dir"
fi
```

---

## Performance Optimization

### Key Rules

1. **Minimize forks** - Use builtins, avoid subshells in loops
2. **Batch I/O** - Process multiple files at once
3. **Parallel execution** - Use `xargs -P $(nproc)` or `parallel`
4. **Anchor regexes** - Use `grep -F` for literal strings
5. **Cache lookups** - Store `command -v` results, use associative arrays
6. **Direct file reads** - Use `$(<file)` not `$(cat file)`
7. **Direct ANSI codes** - No `tput`, use `$'\e[31m'` directly

### Bad Patterns to Avoid

```bash
# ❌ Subshell in loop
for file in *.sh; do
  version=$(grep "version=" "$file")
done

# ✅ Read once, use in loop
mapfile -t versions < <(grep "version=" *.sh)
for v in "${versions[@]}"; do
  echo "$v"
done

# ❌ Pipe creates subshell
cat file | while read line; do process "$line"; done

# ✅ Use redirection
while IFS= read -r line; do process "$line"; done < file

# ❌ Grep in loop
for item in "${items[@]}"; do
  grep "$item" largefile
done

# ✅ Use associative array
declare -A cache
while IFS= read -r line; do
  cache["${line%%:*}"]=1
done < largefile

for item in "${items[@]}"; do
  [[ ${cache[$item]:-} ]] && echo "Found: $item"
done
```

---

## Code Quality

### Pre-commit Gates (Automatic)

Lefthook runs these on every commit:
- `shfmt` (format shell scripts)
- `shellcheck` (lint shell scripts)
- `shellharden` (harden shell)
- `yamlfmt` + `yamllint` (YAML)
- `taplo` (TOML)
- `jaq` (JSON syntax)
- `biome` (JS/TS)
- `markdownlint` (Markdown)

### Manual Validation

Before committing, verify:
```bash
# All scripts pass syntax check
bash -n Home/.local/bin/*.sh

# All config files valid
yamllint Home/.config/**/*.yml
jaq empty Home/.config/**/*.json

# Specific file change
shellcheck -x Home/.local/bin/myscript.sh
```

---

## Decision Tree

```
"Should I create a new file?"
├─ User explicitly requests new file → YES, create it
├─ File with that name exists → NO, edit existing
└─ New feature, no related file → NO, ask user for clarity

"Should I refactor surrounding code?"
├─ Code is part of current task → YES, clean it up
├─ Code is adjacent but unrelated → NO, leave it
├─ Code works fine but could be better → NO, avoid scope creep
└─ Code is unmaintainable/buggy → YES, fix the blocker

"Which tool should I recommend?"
├─ Tool exists in .local/bin → Use it
├─ Modern tool available (fd/rg/bat) → Prefer it with fallback
├─ Standard tool only option (grep/find) → Use with flags
└─ No tool available → Use shell builtins

"Should I add error handling?"
├─ External input (files, network, users) → YES
├─ Internal calls between functions → NO, trust the boundary
└─ Potential failure scenario not caught → YES, add trap/validation
```

---

## Commit Guidelines

**Format:** `<type>(scope): <description>`

**Types:** `fix` | `feat` | `refactor` | `perf` | `docs` | `chore` | `style`

**Examples:**
- `fix(systool): handle symlink creation race condition`
- `feat(pkgui): add verbose output flag`
- `perf(av1pack): parallelize encoding jobs`
- `docs: update deployment instructions`

**Rules:**
- ✅ Selective staging: `git add Home/.local/bin/myscript.sh`
- ❌ Never: `git add -A` without review
- ✅ Verify staged changes: `git diff --staged`
- ✅ Keep commits focused on single task

---

## Protected Files

These files must not be modified without explicit user request:

- `etc/pacman.conf`
- `Home/.config/zsh/.zshrc`
- `Home/.gitconfig`
- `etc/sysctl.d/`
- `etc/paru.conf`
- `etc/makepkg.conf`
- `etc/sudoers`
- `etc/ssh/sshd_config`

---

## Example Interactions

### Task: Add Feature to Script

```
Input: "Add verbose flag to pkgui.sh"

Process:
1. Read pkgui.sh (understand structure)
2. Find flag parsing section
3. Add -v flag + verbose logic
4. Test: shellcheck -x pkgui.sh
5. Commit: "feat(pkgui): add verbose flag"

Result: Minimal change, QA passed, clear commit message
```

### Task: Generate Search Function

```
Input: "Find all .sh files modified in last 7 days"

Output:
fd -e sh -t f --changed-within 7d

Why: Prefers fd over find per toolchain standards
Fallback: find . -name "*.sh" -mtime -7 (if fd unavailable)
```

### Task: Optimize Function

```
Input: "This function is slow, grep in a loop"

Before:
for item in "${items[@]}"; do
  grep "$item" /tmp/large_file
done

After:
declare -A cache
while IFS= read -r line; do
  cache["${line%%:*}"]=1
done < /tmp/large_file

for item in "${items[@]}"; do
  [[ ${cache[$item]:-} ]] && echo "Found: $item"
done

Why: Single file read + associative array lookup
      vs. N grepping passes over entire file
```

---

## Quick Links

| Topic | Reference |
|-------|-----------|
| Bash Standards | [`.github/instructions/bash.instructions.md`](.github/instructions/bash.instructions.md) |
| Project Overview | [`CLAUDE.md`](../CLAUDE.md) (or `AGENTS.md`/`GEMINI.md`) |
| Repository Structure | `CLAUDE.md` → Repository Structure section |
| Scripts Inventory | `CLAUDE.md` → Scripts Inventory section |
| Tool Installation | `CLAUDE.md` → Dependencies section |
| Common Tasks | `CLAUDE.md` → Common Tasks section |
| Git Workflow | `CLAUDE.md` → Git Workflow section |

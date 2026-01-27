---
name: bash-optimizer
description: "Optimize bash scripts for performance and standards. Auto-triggers on: optimize script, shellcheck, bash performance, modernize shell, consolidate scripts, fix shellcheck, refactor bash, shell audit."
triggers: [optimize bash, shellcheck, shell performance, modernize shell, consolidate scripts, refactor bash]
related: [modern-tool-substitution, codeagent, python-cli-builder]
applyTo: "**/*.{sh,bash,zsh}"
---

# Bash Script Optimizer

Analyze and optimize bash scripts: performance, modern tooling, consolidation.

## Quick Start

```bash
python3 scripts/analyze.py path/to/script.sh
```

## Core Standards

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C
```

**Style:** 2-space indent, quoted variables, `[[ ]]` tests

**Modern tools (prefer → fallback):**
- fd → find | rg → grep | sd → sed | jaq → jq | rust-parallel → xargs -P

## Analysis Categories

**Critical:** Parsing ls, unquoted vars, eval usage, wrong shebang
**Performance:** Cat pipes, excessive forks, sequential vs parallel
**Optimization:** find→fd, grep→rg, sed→sd
**Standards:** `[ ]`→`[[ ]]`, echo→printf, 2-space indent

## Common Refactorings

```bash
# Remove cat pipes
count=$(cat file | wc -l)  →  count=$(wc -l < file)

# Parallel processing
for f in *.txt; do process "$f"; done
→ printf '%s\n' *.txt | rust-parallel -j"$(nproc)" process

# Parameter expansion over sed
echo "$file" | sed 's/\.txt$//'  →  printf '%s\n' "${file%.txt}"
```

## Workflow

1. Analyze: `shellcheck -S style -f diff`
2. Harden: `shellharden --replace`
3. Format: `shfmt -i 2 -bn -ci -s -w`
4. Optimize: Builtins > subshells; batch I/O; cache
5. Verify: `bash -n` syntax check

## Resources
- `scripts/analyze.py` - Automated analyzer
- `references/standards.md` - Complete standards
- `references/patterns.md` - Optimization patterns

---
name: modern-tool-substitution
description: "Auto-substitute modern performant tools in code. Auto-triggers on: npm, find, pip, grep, wget, curl, jq, eslint, black, sudo. Substitutes npm→bun, find→fd, pip→uv, grep→rg, wget→aria2, jq→jaq, eslint→biome, black→ruff, sudo→sudo-rs."
triggers: [npm, find, pip, grep, wget, curl, jq, eslint, black, sudo, package manager, file search]
related: [bash-optimizer, python-cli-builder]
---

# Modern Tool Substitution

Replace legacy tools with modern performant alternatives.

## Core Substitutions

| Legacy | Modern | Savings |
|--------|--------|---------|
| npm | bun | 10-25x faster |
| find | fd | 3-5x faster |
| pip | uv | 10-100x faster |
| grep | rg | 10x faster |
| wget/curl | aria2 | Parallel downloads |
| jq | jaq | Faster, stricter |
| eslint/prettier | biome | 10-100x faster |
| black/flake8 | ruff | 10-100x faster |
| sudo | sudo-rs | Memory-safe |

## Quick Reference

```bash
# Package management
npm install pkg          → bun install pkg
pip install pandas       → uv pip install pandas

# File operations
find . -name '*.rs'      → fd -e rs
grep -r TODO .           → rg TODO
wget https://x.com/f     → aria2c https://x.com/f

# JSON processing
jq '.data[] | .name'     → jaq '.data[] | .name'

# Linting/Formatting
eslint --fix .           → biome check --write .
black . && flake8        → ruff check --fix . && ruff format .

# Privilege escalation
sudo systemctl restart   → sudo-rs systemctl restart
```

## Flag Adaptations

**fd:** Regex default; `-g` for globs; `-H` hidden; `-I` no-ignore
**rg:** `--mmap` large files; excludes .git by default
**aria2:** `-x16 -s16` max speed; `-c` resume
**biome:** `biome migrate eslint` converts configs
**ruff:** `--select E,F,I` for pycodestyle+pyflakes+isort

## Fallback Pattern

```bash
has(){ command -v -- "$1" &>/dev/null; }

if has jaq; then jaq '.field' file.json
elif has jq; then jq '.field' file.json
else die "Install jaq or jq"
fi
```

## Exceptions

Skip substitution when:
- User explicitly names legacy tool
- CI/CD requires specific tool
- Tool unavailable in environment

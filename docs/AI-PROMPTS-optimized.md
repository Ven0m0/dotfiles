# AI Prompts

## PR Commands
`@gemini-code-assist review` | `@dependabot rebase` | `@copilot` | `@claude` | `@cursor` | `@jules`

## Quick Tasks
**Audit**: Scan codebase for duplicated logic, slow paths, bugs, edge cases, bad practices. Find outdated/insecure deps; remove unused/bloated packages. Resolve straightforward TODO/FIXME comments. Apply formatters (Biome, Ruff, rustfmt, shfmt/shellcheck/shellharden). Provide refactored code or PR-style diff; list remaining non-trivial issues.

**Deps**: Analyze dependencies for outdated packages, security vulnerabilities, unnecessary bloat; apply changes.

**TODOs**: Identify and resolve straightforward tasks from in-code TODOs or GitHub Issues.

**Cleaner**: Purge unused code, dead paths, stale deps. Flatten complex logic, inline single-use abstractions. Strip emojis, enforce 2-space indent, 100-char min line width. Merge files with >80% similarity. Refactor docs into modular reusable Markdown.

## Bash Refactor Agent
**Scope**: `*.sh`, `*.bash`, `*.zsh`, rc files. Exclude `.git/`, `node_modules/`, vendor/, generated. Bash preferred; bashisms allowed.

**Prologue** (ensure equivalent exists):
```bash
#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t' LC_ALL=C
cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null
has(){ command -v -- "$1" &>/dev/null; }
```

**Formatting**: `shfmt -i 2 -bn -ci -ln bash`. Max 1 empty line. Compact: `name(){ … }`. Inline case: `pat) cmd1; cmd2 ;;`. Prefer `[[ ]]` over `[ ]`.

**Forbidden**: `eval`, parsing `ls`, unquoted expansions, unnecessary subshells, piping into sh/bash.

**Safety**: Skip heredocs, single-quoted blocks, regex-heavy lines, ambiguous `[` conversions. Inline only when behavior unchanged.

**Inlining**: Functions ≤6 lines, ≤2 call sites, no complex flow → inline. Blocks >50 tokens or ≥3 repeats → extract function. No sourcing; standalone scripts only.

**Performance**: Builtins over externals. Use arrays, `mapfile`, parameter expansion. Avoid useless `cat`. Printf-based date. `read -t` over `sleep` when safe.

**Helpers**:
```bash
date(){ local x="${1:-%d/%m/%y-%R}"; printf "%($x)T\n" '-1'; }
fcat(){ printf '%s\n' "$(<"${1}")"; }
sleepy(){ read -rt "${1:-1}" -- <> <(:) &>/dev/null || :; }
```

**Redirects**: No spaces (`>/dev/null`). Normalize `&>/dev/null`.

**Pipeline**: Token-aware read → codemod transforms → `shfmt` → `shellcheck --severity=error` → `shellharden --replace` (if safe) → `shellcheck` (must pass).

**Output**: 3-6 bullet plan, unified diff, final standalone script(s), one-line risk note.

## Python Architect
**Stack**: `ruff format` (Black), `ruff check`, `mypy --strict`, `pytest --durations=0`. Deps via `uv`.

**Typing**: Full annotations. Modern generics (`list[str]`). No `Any` without justification. Prefer dataclasses/TypedDict.

**Performance**: `orjson` over `json`, `uvloop` over `asyncio`, `httpx` over `requests`, streaming `csv` over pandas for ETL.

**Quality**: Target O(n)+. Small atomic functions (SRP). Snake_case. Specific exceptions with `raise ... from e`. No global mutable state.

**Workflow**: Plan (bullets) → Refactor (atomic) → Verify (lint/test).

## JS/TS Quality
**Discovery**: `fd -tf -e js -e jsx -e ts -e tsx -E node_modules -E .git`

**Toolchain**: `biome format --write` → `biome check --write` → `oxlint -D all --deny-warnings`

**Style**: 2-space indent, double quotes, trailing commas. No functional changes; style/safety only.

**Output**: Single bash script, summary table (`| File | Status | Biome | Oxc |`), JSON logs if `CI=true`.

## GitHub Actions Hardening
**Process**: Plan (list workflows, objectives) → Baseline (triggers, jobs, caching, permissions, secrets) → Refactor → Validate → Deliver.

**Refactor rules**: Add `permissions: { contents: read }` at top. Remove dead/duplicate jobs. Add `concurrency` where needed. Use `matrix` for parallel tests. `actions/checkout` with `fetch-depth: 1`. Cache deps with scoped keys. Replace hardcoded values with `${{ secrets.* }}`.

**Validation**: `actionlint` → `action-validator` → `ghalint` → `yamlfmt` + `yamllint`. Optional `act` for local smoke tests.

**Constraints**: No `main`/`latest` refs. No hardcoded secrets. ≤7 parallel jobs unless justified.

**Output**: Scope summary, unified diffs with rationale, lint commands, rollback steps.

## Lint/Format Pipeline
**Discovery**: `fd` preferred, fallback `find`. Format before lint. Batch with `xargs -P` where tools lack parallelism.

| Type | Format | Lint |
|------|--------|------|
| YAML | `yamlfmt` | `yamllint -f parsable` |
| JSON/CSS/JS/HTML | `biome fmt` or `prettier` | `eslint --fix` |
| Shell | `shfmt -w -i 2 -bn -ci -ln bash` | `shellcheck --severity=error`, `shellharden` |
| Fish | `fish_indent -w` | — |
| TOML | `taplo fmt` | `tombi lint` |
| Markdown | `mdformat` | `markdownlint --fix` |
| Actions | `yamlfmt` | `yamllint`, `actionlint` |
| Python | `ruff format` | `ruff check --fix` |
| Lua | `stylua` | `selene` |

## Flow-Style Compaction
Apply to JSON/YAML/TOML: inline arrays/objects if resulting line ≤140 chars; else retain block style. Collapse 3+ newlines to 2. Delete HTML comments. Tight lists (no blank lines between items).

## AGENTS.md Generator
Analyze repository; create comprehensive AGENTS.md documenting codebase structure, dev workflows, key conventions. Symlink CLAUDE.md and GEMINI.md to AGENTS.md. Use `@` for important file references.

## Jules Prompts
`Find duplicate logic across files` | `Analyze repo, generate 3 feature ideas` | `Cluster related functions, suggest refactors` | `Refactor for parallel processing` | `Upgrade linter, autofix breaking config` | `Set up Renovate/Dependabot` | `Turn tool into GitHub App` | `Build web scraper starter`

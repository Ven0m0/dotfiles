# AI Prompts

## PR Commands
`@gemini-code-assist review` | `@dependabot rebase` | `@copilot` | `@claude` | `@cursor` | `@jules`

---

## Quick Tasks

<details><summary><b>Audit</b></summary>

```text
Scan for duplicate logic, slow paths, bugs, edge cases, bad practices. Find outdated/insecure deps, remove unused packages. Resolve TODO/FIXME. Format (Biome/Ruff/rustfmt/shfmt+shellcheck+shellharden). Output: summary table, unified diffs, risk assessment.
```
</details>
<details><summary><b>Deps</b></summary>

```text
Find outdated packages, CVEs, bloat, unused deps. Suggest modern replacements. Apply updates respecting semver. Output: report table, update commands, migration notes.
```
</details>
<details><summary><b>TODOs</b></summary>

```text
Extract all TODOs from code/issues. Categorize: trivial/moderate/complex. Resolve trivial items inline. Output: completion report, diffs, remaining backlog.
```
</details>
<details><summary><b>Cleaner</b></summary>

```text
Purge unused code, dead paths, stale deps. Flatten complex logic, inline single-use abstractions. Enforce 2-space indent, 100-char lines. Merge files >80% similar. Strip emojis, comments. Output: before/after metrics, diffs.
```
</details>
<details><summary><b>AIO</b></summary>

```text
Refactor duplicates. Fix slow paths, errors, bad practices. Analyze deps for outdated/CVEs/bloat — apply changes. Resolve trivial TODOs. Format (Biome/Ruff/shellcheck+shellharden/clippy/yamlfmt+yamllint). Output: summary, diffs, risk notes.
```
</details>
<details><summary><b>Cleanup</b></summary>

```text
Delete logs, temp files, caches, build artifacts, lockfiles not in .gitignore. Remove duplicate lines, redundant/dead text, bloat files, empty dirs. Strip trailing whitespace, normalize line endings (LF), max 1 trailing newline per file. Then format:
  YAML:     yamlfmt
  JSON:     biome format (or prettier --write)
  JS/TS:    biome format --write → biome check --write
  Shell:    shfmt -i 2 -bn -ci -ln bash → shellcheck --severity=error → shellharden --replace
  Python:   ruff format → ruff check --fix
  Markdown: markdownlint --fix
  All text: codespell --write-changes
Output: deleted file list, before/after byte counts, format diffs, codespell fixes.
```
</details>

---

## Bash Refactor

<details><summary><b>Full Spec</b></summary>

```text
Refactor shell scripts (*.sh, *.bash, *.zsh, rc files).
Exclude: .git/, node_modules/, vendor/, generated assets. Bash preferred.

── Prologue (required) ──
#!/usr/bin/env bash
shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'; LC_ALL=C
cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null
has(){ command -v -- "$1" &>/dev/null; }

── Style: shfmt -i 2 -bn -ci -ln bash ──
Max 1 empty line | Compact: name(){ … } | Inline case: pat) cmd1; cmd2 ;;
[[ ]] over [ ] | No spaces in redirects: >/dev/null | Normalize: &>/dev/null
fn() { → fn(){ | Ensure bash shebang when bashisms present

── Forbidden ──
eval | parsing ls | unquoted expansions | unnecessary subshells | curl|bash

── Safety: DO NOT modify ──
heredocs, single-quoted blocks, regex-heavy lines, ambiguous [ conversions

── Inline/Extract rules ──
Inline: ≤6 lines + ≤2 calls + no complex flow
Extract: >50 tokens + ≥3 repeats → function | No sourcing; standalone only

── Prefer ──
Builtins > externals | arrays + mapfile + parameter expansion
printf > echo | (( )) arithmetic | [[ ]] with =~ | mapfile -t | read -ra
local -n | declare -A | while IFS= read -r line; do ...; done

── Helpers ──
date(){ local x="${1:-%d/%m/%y-%R}"; printf "%($x)T\n" '-1'; }
fcat(){ printf '%s\n' "$(<"${1}")"; }
sleepy(){ read -rt "${1:-1}" -- <> <(:) &>/dev/null || :; }

── Pipeline ──
parse → transform → shfmt → shellcheck --severity=error → shellharden --replace → shellcheck

── Output: plan (3-6 lines), unified diff, standalone script(s), risk note, LOC metrics ──
```
</details>

---

## Python Refactor

<details><summary><b>Full Spec</b></summary>

```text
Refactor Python following strict standards.

Pipeline: ruff format → ruff check --fix → mypy --strict → pytest --durations=0 | uv
Types:    Full hints, modern generics (list[str]), no Any w/o docs, prefer dataclasses/TypedDict/Protocol
Perf:     orjson > json | uvloop > asyncio | httpx > requests | csv > pandas for ETL
          Generators for large data | Target O(n)+
Style:    Atomic functions (SRP) | snake_case, PascalCase classes, UPPER constants
          Specific exceptions: raise X from e | No globals | Max 50 lines/func
Tests:    pytest + fixtures + hypothesis | Min 80% coverage

Output: plan (5-10 lines), type-checked code, coverage report, perf metrics, migration guide
```
</details>

---

## JS/TS Refactor

<details><summary><b>Full Spec</b></summary>

```text
Refactor JS/TS with modern tooling.

Discovery: fd -tf -e js -e jsx -e ts -e tsx -e mjs -e cjs -E node_modules -E .git -E dist
Pipeline:  biome format --write . → biome check --write --unsafe . → oxlint -D all --deny-warnings

Style:  2-space, double quotes, trailing commas, semicolons
        const > let | arrow funcs | template literals | destructure | ?./??
TS:     strict mode | no any w/o comment | interfaces for objects | satisfies
Perf:   No O(n²) | Map/Set | lazy load | memoize | debounce/throttle

Output: summary table (File|Status|Biome|Oxlint|Notes), diffs
```
</details>

---

## GitHub Actions Fix

<details><summary><b>Full Spec</b></summary>

```text
Fix and harden CI/CD workflows.

Fixes: SHA-pin actions, add permissions: {contents: read}, fix deprecated commands,
       use ${{ secrets.* }}, add timeout-minutes (60), fix YAML errors
Security: SHA pins | explicit permissions | never echo secrets | env protection
Perf:     concurrency groups | cache deps | matrix parallelism | fetch-depth: 1
Validate: actionlint → action-validator → ghalint → yamlfmt → yamllint
Limits:   ≤20 files | ≤20min/job | ≤7 matrix jobs | No main/latest refs

Output: analysis, diffs, new workflows, validation results, rollback plan
```
</details>

---

## Lint/Format Orchestrator

<details><summary><b>Full Spec</b></summary>

```text
Orchestrate multi-language quality checks.
Exclude: .git, node_modules, vendor, dist, .venv
Rules: Format before lint | Batch: xargs -P$(nproc) | Exit on error in CI

YAML:      yamlfmt -w        → yamllint -f parsable
JS/TS:     biome fmt          → biome check
Shell:     shfmt -w -i 2 -bn -ci → shellcheck --severity=error → shellharden
Fish:      fish_indent -w
TOML:      taplo fmt          → tombi lint
Markdown:  mdformat           → markdownlint --fix
Actions:   yamlfmt            → yamllint → actionlint
Python:    ruff format        → ruff check --fix
Rust:      cargo fmt          → cargo clippy -D warnings
Lua:       stylua             → selene
Go:        gofmt -w           → golangci-lint run

Output: orchestration script, error reports, summary table, CI exit codes
```
</details>

---

## Utilities

<details><summary><b>Flow-Style Compaction</b></summary>

```text
Compact JSON/YAML/TOML: inline arrays/objects ≤140 chars, else block. Max 2 consecutive newlines. Delete HTML comments. Sort keys alphabetically. Output: diffs, space savings (bytes/lines), validation.
```
</details>
<details><summary><b>AGENTS.md Generator</b></summary>

```text
Analyze repo: languages, frameworks, conventions, workflows, configs. Generate AGENTS.md covering: project overview + stack, repo structure (@prefix key files), dev workflows (setup/build/test/deploy), conventions (naming/style/patterns), deps, common tasks. Symlink: CLAUDE.md → AGENTS.md, GEMINI.md → AGENTS.md.
```
</details>

---

## Copilot / Jules Tasks
```text
Find duplicate logic across files
Cluster related functions by responsibility, suggest module refactoring
Refactor for parallel processing using modern concurrency
Upgrade linters to latest, autofix breaking config changes
Set up Renovate/Dependabot with optimal config
Implement test coverage for untested modules
Set up pre-commit hooks with linters/formatters
Create CI/CD workflows with caching and parallel jobs
Refactor large functions into composable smaller functions
```

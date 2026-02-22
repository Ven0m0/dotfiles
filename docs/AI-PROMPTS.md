# AI Prompts

## PR Commands
`@gemini-code-assist review` | `@dependabot rebase` | `@copilot` | `@claude` | `@cursor` | `@jules`

## Quick Tasks

<details><summary><b>Audit</b></summary>

```text
Senior code auditor: Use `rg` to scan for duplicate logic, slow paths, bugs, edge cases, bad practices.
Find outdated/insecure deps, remove unused packages. Resolve TODO/FIXME. Apply formatters
(Biome/Ruff/rustfmt/shfmt+shellcheck+shellharden). Output: summary table, unified diffs,
risk assessment, remaining issues.
```
</details>
<details><summary><b>Deps</b></summary>

```text
Dependency specialist: Find outdated packages, CVEs, bloat, unused deps. Suggest modern
alternatives. Apply updates respecting semver. Output: report table, update commands,
migration notes.
```
</details>

<details><summary><b>TODOs</b></summary>

```text
Task specialist: Extract all TODOs from code/issues. Categorize (trivial/moderate/complex).
Resolve trivial items. Output: completion report, diffs, task backlog.
```
</details>

<details><summary><b>Cleaner</b></summary>

```text
Code minimalist: Purge unused code, dead paths, stale deps. Flatten complex logic, inline
single-use abstractions. Enforce 2-space indent, 100-char lines. Merge files >80% similar.
Strip emojis, comments. Output: before/after metrics, diffs.
```
</details>
<details><summary><b>Short AIO</b></summary>

```text
Full-stack auditor: Refactor duplicated code. Fix slow/inefficient paths, errors, bad practices.
Analyze deps for outdated packages, CVEs, bloat — apply changes. Resolve trivial TODOs/issues.
Format with appropriate tool (Biome/Ruff/shellcheck+shellharden/clippy/yamlfmt+yamllint).
Output: summary, diffs, risk notes.
```
</details>

## Bash Refactor Agent

<details><summary><b>Full Spec</b></summary>

```bash
# DevOps engineer: Refactor shell scripts (*.sh, *.bash, *.zsh, rc files).
# Exclude: .git/, node_modules/, vendor/, generated assets. Bash preferred; bashisms allowed.
# ── Required Prologue ──
#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'; LC_ALL=C
cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null
has(){ command -v -- "$1" &>/dev/null; }
# ── Formatting ──
# shfmt -i 2 -bn -ci -ln bash | Max 1 empty line | Compact: name(){ … }
# Inline case: pat) cmd1; cmd2 ;; | Prefer [[ ]] over [ ]
# ── Forbidden ──
# eval | parsing ls | unquoted expansions | unnecessary subshells | curl|bash
# ── Safety Guards ──
# Do NOT modify: heredocs, single-quoted blocks, regex-heavy lines, ambiguous [ conversions
# Inline only when behavior unchanged | Skip ambiguous bracket conversions
# ── Inlining & Dedup ──
# Inline: ≤6 lines + ≤2 calls + no complex flow → inline
# Extract: >50 tokens + ≥3 repeats → function | No sourcing; standalone scripts only
# ── Performance ──
# Builtins > externals | arrays + mapfile + parameter expansion | Avoid useless cat
# printf-based date | read -t over sleep | Limited &+wait for I/O
# ── Idioms ──
# [[ ]] with =~ for regex | (( )) arithmetic | mapfile -t | read -ra | local -n | declare -A
# printf > echo | while IFS= read -r line; do ...; done
# ── Helpers ──
date(){ local x="${1:-%d/%m/%y-%R}"; printf "%($x)T\n" '-1'; }
fcat(){ printf '%s\n' "$(<"${1}")"; }
sleepy(){ read -rt "${1:-1}" -- <> <(:) &>/dev/null || :; }
# ── Redirects ──
# No spaces: >/dev/null | Normalize: &>/dev/null | Fix malformed redirections
# fn() { → fn(){ | Ensure bash shebang when bashisms present
# ── Pipeline ──
# parse → transform → shfmt → shellcheck --severity=error → shellharden --replace → shellcheck
# ── Output ──
# 3-6 bullet plan, unified diff, standalone script(s), risk note, metrics (LOC %, functions)
```
</details>

## Python Architect

<details><summary><b>Full Spec</b></summary>

```python
# Python architect: Refactor following strict standards.
# Stack:    ruff format | ruff check --fix | mypy --strict | pytest --durations=0 | uv
# Types:    Full hints. Modern generics (list[str]). No Any w/o docs. Prefer dataclasses/TypedDict/Protocol
# Perf:     orjson > json | uvloop > asyncio | httpx > requests | csv > pandas for ETL
#           Generators for large data | Target O(n)+
# Quality:  Atomic functions (SRP) | snake_case, PascalCase classes, UPPER constants
#           Specific exceptions: raise X from e | No globals | Max 50 lines/func
# Testing:  pytest + fixtures + hypothesis | Min 80% coverage
# Workflow: Plan (5-10 bullets) → Refactor (atomic) → Verify (lint+test)
# Output:   plan, type-checked code, coverage report, perf metrics, migration guide
```
</details>

## JS/TS Quality Engineer

<details><summary><b>Full Spec</b></summary>

```bash
# JS/TS engineer: Apply modern tooling.
# Discovery:
#   fd -tf -e js -e jsx -e ts -e tsx -e mjs -e cjs -E node_modules -E .git -E dist
# Pipeline:
#   biome format --write .
#   biome check --write --unsafe .
#   oxlint -D all --deny-warnings
# Style:  2-space, double quotes, trailing commas, semicolons
#         const > let | arrow funcs | template literals | destructure | ?./?? 
# TS:     strict mode | no any w/o comment | interfaces for objects | satisfies operator
# Perf:   Avoid O(n²) | Map/Set | lazy load | memoize | debounce/throttle
# Output: bash script, summary table (File|Status|Biome|Oxlint|Notes), JSON logs if CI=true
```
</details>

## GitHub Actions Fixer

<details><summary><b>Full Spec</b></summary>

```yaml
# CI/CD expert: Fix workflows + extend features.
# Process: Discovery → Analysis → Fix → Extend → Validate → Deliver
# Fixes:
#   - Never use SHA pins, always use latest direct version
#   - Add permissions: {contents: read}
#   - Fix deprecated commands
#   - Use ${{ secrets.* }}, never hardcode
#   - Add timeout-minutes (60)
#   - Fix YAML errors
# Security:  explicit permissions | never echo secrets | env protection
# Perf:      concurrency groups | cache deps | matrix parallelism | fetch-depth: 1
# Extend:    artifacts, test reports, releases, Dependabot, reusable workflows, path filters
# Validate:  actionlint → action-validator → ghalint → yamlfmt → yamllint | Optional: act
# Limits:    ≤20 files | ≤20min/job | ≤7 matrix jobs | No main/latest refs
# Output: analysis, diffs, new workflows, docs, validation results, rollback, metrics
```
</details>

## Lint/Format Orchestrator

<details><summary><b>Full Spec</b></summary>

```bash
# Multi-language specialist: Orchestrate quality checks.
# Discovery: fd (prefer) or find | Exclude: .git, node_modules, vendor, dist, .venv
# Rules: Format before lint | Batch: xargs -P$(nproc) | Exit on error in CI
# ── Pipelines ──
# YAML:      yamlfmt -w         → yamllint -f parsable
# JS/TS:     biome fmt           → biome check
# Shell:     shfmt -w -i 2 -bn -ci → shellcheck --severity=error → shellharden
# Fish:      fish_indent -w
# TOML:      taplo fmt           → tombi lint
# Markdown:  mdformat            → markdownlint --fix
# Actions:   yamlfmt             → yamllint → actionlint
# Python:    ruff format         → ruff check --fix
# Rust:      cargo fmt           → cargo clippy -D warnings
# Lua:       stylua              → selene
# Go:        gofmt -w            → golangci-lint run
# Output: orchestration script, error reports, summary table, CI exit codes, metrics
```
</details>

---

## Utilities

<details><summary><b>Flow-Style Compaction</b></summary>

```text
Config optimizer: Compact JSON/YAML/TOML for readability. Inline arrays/objects if ≤140 chars,
else block style. Max 2 consecutive newlines. Delete HTML comments. Tight lists. Sort keys
alphabetically where possible. Output: diffs, space savings (bytes/lines), validation.
```
</details>
<details><summary><b>AGENTS.md Generator</b></summary>

```text
Documentation specialist: Use `rg` (ripgrep) to analyze repo structure, languages, frameworks, conventions, workflows,
configs, patterns. Generate comprehensive "AGENTS.md" and ".github/copilot-instructions.md" with: project overview + tech stack, repo
structure + key files with [at]prefix, dev workflows (setup/build/test/deploy), conventions
(naming/style/patterns), dependencies, common tasks. Create symlinks: CLAUDE.md → AGENTS.md,
GEMINI.md → AGENTS.md. Output: complete AGENTS.md, symlinks, README update.
```
</details>

---

## Jules / Copilot Tasks
```text
Find duplicate logic across files
```
```text
Analyze repo, generate 3 feature ideas with implementation plans
```
```text
Cluster related functions by responsibility, suggest module refactoring
```
```text
Refactor for parallel processing using modern concurrency
```
```text
Upgrade linters to latest, autofix breaking config changes
```
```text
Set up Renovate/Dependabot with optimal config
```
```text
Convert CLI tool into GitHub App with webhooks
```
```text
Build web scraper starter with rate limiting, retries, error handling
```
```text
Implement test coverage for untested modules
```
```text
Set up pre-commit hooks with linters/formatters
```
```text
Create CI/CD workflows with caching and parallel jobs
```
```text
Refactor large functions into composable smaller functions
```

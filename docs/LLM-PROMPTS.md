# LLM Prompts

## PR Commands

```text
@gemini-code-assist review | @dependabot rebase | @copilot | @claude | @cursor | @jules
```

## Quick Tasks

<details><summary><b>Audit</b></summary>

```text
Audit codebase for quality, security, and correctness. Use `rg` to find files. Use ultrathink.
Scope: all source files. Exclude: .git/, node_modules/, vendor/, dist/, .venv/, generated/.
Steps:
1. Duplicate logic: rg for repeated patterns >10 lines across files, propose shared functions
2. Performance: identify O(n²)+ paths, blocking I/O in async, unnecessary allocations, missing caches
3. Bugs/edge cases: unchecked errors, race conditions, off-by-one, null/undefined access, resource leaks
4. Bad practices: hardcoded secrets, magic numbers, dead code, unreachable branches, implicit any
5. Dependencies: flag CVEs (check advisories), unmaintained (>2yr no release), duplicated, unused
6. Resolve all TODO/FIXME that are trivial (<10 min effort). List remaining with severity.
7. Format per language: biome (JS/TS) | ruff (Python) | rustfmt+clippy (Rust) | shfmt+shellcheck+shellharden (Shell)
Output: summary table (file|issue|severity|fix), unified diffs, risk assessment (breaking changes, data loss potential).
```

</details>
<details><summary><b>Deps</b></summary>

```text
Audit and update all dependencies. Use `rg` to find lockfiles, manifests, import statements.
Steps:
1. Inventory: list all deps with current version, latest version, last publish date, weekly downloads
2. CVEs: cross-reference with known advisories, flag severity (critical/high/medium/low)
3. Unused: trace imports with rg, flag deps imported nowhere. Check for transitive-only usage.
4. Bloat: identify deps replaceable with builtins or lighter alternatives (e.g., lodash → native, moment → Temporal/dayjs)
5. Outdated: categorize as patch/minor/major. Apply patch+minor automatically. Major: note breaking changes.
6. Duplicates: find multiple versions of same package in lockfile, dedupe where possible.
7. Apply updates respecting semver. Regenerate lockfiles. Verify build passes after changes.
Output: table (package|current|latest|status|action), update commands, migration notes for major bumps, before/after lockfile size.
```

</details>
<details><summary><b>TODOs</b></summary>

```text
Extract and resolve TODOs/FIXMEs across entire codebase. Use `rg` to find all occurrences.
Pattern: rg -n "TODO|FIXME|HACK|XXX|WARN|DEPRECATED" --type-add 'src:*.{sh,bash,py,ts,tsx,js,jsx,rs,go,lua,yml,yaml,toml}'
Steps:
1. Extract all matches with file, line number, surrounding context (3 lines)
2. Categorize: trivial (type fix, rename, add guard) | moderate (refactor, new function) | complex (architecture, new feature)
3. Resolve all trivial items inline — apply the fix, remove the TODO comment
4. For moderate: create actionable description with estimated LOC change
5. For complex: note as backlog with suggested approach
Output: completion report (resolved count/total), diffs for resolved items, remaining backlog table (file|line|category|description).
```

</details>
<details><summary><b>Cleaner</b></summary>

```text
Aggressive code cleanup and deduplication. Use `rg` to find files. Use ultrathink.
Exclude: .git/, node_modules/, vendor/, dist/, .venv/, generated/, *.min.*, *.lock
Steps:
1. Dead code: remove unused functions, unreachable branches, commented-out code, unused imports/variables
2. Dead paths: find files with zero importers/references via rg, confirm unused, delete
3. Stale deps: remove packages not imported anywhere (verify transitive usage first)
4. Flatten: inline single-use abstractions, unwrap unnecessary wrapper functions, simplify nested conditionals
5. Merge: files with >80% similar content → combine into one with parameters for differences
6. Normalize: 2-space indent (except Python: 4), 120-char max line width, LF line endings
7. Strip: remove emoji from source code, delete comments that restate the code, remove empty catch blocks
8. Preserve: do NOT touch tests, docs, configs, or generated files unless explicitly broken
Output: before/after metrics (file count, total LOC, total bytes), unified diffs, list of deleted files/functions.
```

</details>
<details><summary><b>AIO</b></summary>

```text
All-in-one: refactor, fix, update, and format entire codebase. Use `rg` to find files. Use ultrathink.
Exclude: .git/, node_modules/, vendor/, dist/, .venv/, generated/
Execution order (dependencies matter):
1. Deps: audit for CVEs/outdated/unused/bloat → apply safe updates (patch+minor), flag majors
2. Dedup: rg for repeated logic >10 lines → extract to shared functions/modules
3. Bugs: fix error handling, null checks, race conditions, resource leaks, off-by-one
4. Perf: eliminate O(n²)+, replace sync I/O in async paths, add missing caches, lazy-load heavy imports
5. TODOs: resolve trivial TODO/FIXME/HACK inline, list remaining
6. Format per language:
   Shell: shfmt -i 2 -bn -ci → shellcheck --severity=error → shellharden --replace
   JS/TS: biome format --write → biome check --write --unsafe
   Python: ruff format → ruff check --fix
   Rust: cargo fmt → cargo clippy -D warnings
   YAML: yamlfmt → yamllint
7. Verify: ensure build/lint passes after all changes
Output: summary table (category|files changed|issues fixed), unified diffs grouped by category, risk notes (breaking changes, behavior changes), LOC delta.
```

</details>
<details><summary><b>Cleanup</b></summary>

```text
Filesystem and formatting cleanup. Use `rg`/`fd` to find files. Use ultrathink.
Phase 1 — Delete junk:
  fd -tf -e log -e bak -e tmp -e swp -e orig -e rej | xargs rm -f
  Remove: build artifacts not in .gitignore, empty directories, duplicate files (by hash), .DS_Store, Thumbs.db
  Remove: redundant/dead text files, zero-byte files (except intentional __init__.py)
Phase 2 — Normalize text:
  Strip trailing whitespace on all text files. Normalize line endings to LF. Ensure exactly 1 trailing newline.
  Collapse 3+ consecutive blank lines to max 2. Remove BOM from UTF-8 files.
Phase 3 — Format per language:
  YAML:     yamlfmt → yamllint -f parsable
  JSON:     biome format (or jq -S . for standalone JSON)
  JS/TS:    biome format --write → biome check --write
  Shell:    shfmt -i 2 -bn -ci -ln bash → shellcheck → shellharden --replace
  Python:   ruff format → ruff check --fix
  Markdown: markdownlint --fix (or mdformat)
  All text: codespell --write-changes (skip vendored/generated)
Phase 4 — Validate:
  Verify no broken imports, configs parse correctly, build still passes.
Output: deleted files list, before/after byte counts per phase, format diffs, codespell corrections table.
```

</details>

## Bash Refactor

<details><summary><b>Full Spec</b></summary>

```text
Refactor shell scripts to modern, strict, optimized bash. Use `rg` to find files. Use ultrathink.
Target: *.sh, *.bash, *.zsh, rc/profile files containing bashisms.
Exclude: .git/, node_modules/, vendor/, generated/, third-party scripts.

── Prologue (required for all scripts) ──
#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'; LC_ALL=C
cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null
has(){ command -v -- "$1" &>/dev/null; }

── Style (enforced by shfmt -i 2 -bn -ci -ln bash) ──
Max 1 consecutive empty line. Compact one-liners: name(){ body; }
Inline short case arms: pat) cmd1; cmd2 ;; (one per line if >100 chars)
[[ ]] over [ ] everywhere. No spaces in redirects: >/dev/null 2>&1 → &>/dev/null
fn() { → fn(){ — no space before brace. Ensure #!/usr/bin/env bash when bashisms present.

── Forbidden (never emit, always replace) ──
eval | parsing ls output | unquoted variable expansions | unnecessary subshells ($() where ${} works)
curl|bash pipes | echo with escape sequences (use printf) | test/[ (use [[ ]])
seq (use {1..n} or C-style for) | cat file|cmd (use cmd < file or $(<file))
basename/dirname on variables (use ${var##*/} / ${var%/*})

── Safety: DO NOT modify ──
Heredocs (<<EOF blocks) | single-quoted blocks containing special chars
Regex-heavy lines (=~ with complex patterns) | intentional [ ] for POSIX compat (if documented)

── Inline/Extract rules ──
Inline function if: ≤6 lines AND ≤2 call sites AND no complex control flow
Extract to function if: >50 tokens AND ≥3 occurrences → named function with local vars
All scripts must be standalone: no sourcing external files unless explicitly required.

── Prefer (replace old patterns with these) ──
Builtins over externals: ${#var}, ${var//old/new}, ${var:offset:length}
Arrays + mapfile -t over command substitution into strings
printf over echo | (( )) for arithmetic | [[ ]] with =~ for regex
mapfile -t arr < <(cmd) over arr=($(cmd)) | read -ra over manual IFS splitting
local -r for constants | local -n for namerefs | declare -A for associative arrays
while IFS= read -r line; do ...; done < file over for line in $(cat file)

── Helpers (include if used, not by default) ──
date(){ local x="${1:-%d/%m/%y-%R}"; printf "%($x)T\n" '-1'; }
fcat(){ printf '%s\n' "$(<"${1}")"; }
sleepy(){ read -rt "${1:-1}" -- <> <(:) &>/dev/null || :; }
die(){ printf '%s\n' "$*" >&2; exit 1; }

── Pipeline (execute in order) ──
1. Parse and transform source
2. shfmt -i 2 -bn -ci -ln bash -w
3. shellcheck --severity=error --format=gcc
4. shellharden --replace
5. shellcheck (final verify, must pass clean)

── Output ──
Plan (3-6 lines describing approach), unified diff, standalone script(s), risk notes (behavior changes, trap handling), LOC before/after with % reduction.
```

</details>

## Python Refactor

<details><summary><b>Full Spec</b></summary>

```text
Refactor Python to strict, modern, typed, performant code. Use `rg` to find files. Use ultrathink.
Exclude: .git/, __pycache__/, .venv/, dist/, generated/, *_pb2.py

── Pipeline (execute in order) ──
ruff format → ruff check --fix --unsafe-fixes → mypy --strict → pytest --durations=0
Package management: uv only (never pip).

── Types ──
Full type hints on all functions, including return types. Use modern generics: list[str], dict[str, int], str | None.
No Any without documented justification. Prefer: dataclasses (mutable) | NamedTuple (immutable) | TypedDict (dicts with known shape) | Protocol (structural typing over ABC).
Use Self for return-self patterns. Use TypeGuard for type narrowing.

── Performance (replace old patterns) ──
orjson > json (3-10x faster) | httpx > requests (async support) | uvloop > asyncio default
csv.DictReader > pandas for simple ETL | pathlib > os.path for path manipulation
Generators/itertools for large datasets (never materialize full list if streaming works)
Target O(n) or better. Flag any O(n²)+ with justification or fix.
Use __slots__ on data classes in hot paths. Prefer dict/set lookups over list scans.

── Style ──
Atomic functions: single responsibility, max 50 lines, max 5 parameters.
Naming: snake_case functions/vars, PascalCase classes, UPPER_SNAKE constants.
Specific exceptions only: raise ValueError("msg") from e — never bare except or except Exception.
No module-level mutable globals. Use functools.cache/lru_cache for expensive pure functions.
Import order: stdlib → third-party → local (enforced by ruff isort rules).

── Async patterns ──
Use async/await for I/O-bound work. asyncio.TaskGroup over gather (3.11+).
Never mix sync and async I/O in same function. Use asyncio.to_thread for sync→async bridge.

── Tests ──
pytest + fixtures + parametrize. hypothesis for property-based testing where applicable.
Minimum 80% line coverage. Test edge cases: empty input, None, boundary values, error paths.

── Output ──
Plan (5-10 lines), type-checked code with all ruff/mypy clean, coverage summary, perf notes (complexity changes), migration guide for breaking API changes.
```

</details>

## JS/TS Refactor

<details><summary><b>Full Spec</b></summary>

```text
Refactor JS/TS to modern, strict, performant code. Use `rg` to find files. Use ultrathink.
Discovery: fd -tf -e js -e jsx -e ts -e tsx -e mjs -e cjs -E node_modules -E .git -E dist -E .next
Package management: bun only (never npm/pnpm/yarn).

── Pipeline ──
biome format --write . → biome check --write --unsafe . → oxlint -D all --deny-warnings
For TS: tsc --noEmit (type check without build)

── Style ──
2-space indent, double quotes, trailing commas, semicolons.
const over let (never var). Arrow functions for callbacks/lambdas. Template literals over concatenation.
Destructuring for object/array access. Optional chaining (?.) and nullish coalescing (??) over manual checks.
Prefer: satisfies over as, unknown over any, readonly where immutable.

── TypeScript strict mode ──
Enable: strict, noUncheckedIndexedAccess, exactOptionalPropertyTypes.
No any without // eslint-disable-next-line comment explaining why.
Interfaces for object shapes (not type aliases for plain objects). Use discriminated unions for state.
Generics with constraints: <T extends Base> not <T>. Use satisfies for type-safe object literals.
Zod/valibot for runtime validation at boundaries (API inputs, env vars, config).

── Performance ──
No O(n²): use Map/Set for lookups, avoid nested .find()/.filter().
Lazy imports: dynamic import() for heavy modules not needed at startup.
Memoize expensive computations. Debounce/throttle user-triggered events.
Prefer for...of over .forEach() in hot paths. Use structuredClone over JSON parse/stringify for deep copy.
Avoid spreading large objects in loops: {...obj} creates new allocation each iteration.

── Error handling ──
Custom error classes extending Error. Never throw strings.
Use Result/Either pattern for expected failures. try/catch only at boundaries.
Always type catch clause: catch (error: unknown) { if (error instanceof X) }.

── Output ──
Summary table (File|Status|Biome|Oxlint|Type Errors|Notes), unified diffs, migration notes for breaking changes.
```

</details>

## GitHub Actions Fix

<details><summary><b>Full Spec</b></summary>

```text
Fix, harden, and optimize CI/CD workflows. Use `rg` to find .github/workflows/*.yml.

── Security ──
Explicit permissions block on every workflow AND job (least privilege: contents: read default).
Never echo secrets or use secrets in run step interpolation (${{ secrets.* }} in env: only).
Pin third-party actions to latest stable version tag (e.g., actions/checkout@v4, NOT @main, NOT SHA pins).
Use environment protection rules for deployment jobs. No pull_request_target with checkout of PR head.

── Fixes ──
Replace deprecated: set-output → $GITHUB_OUTPUT, save-state → $GITHUB_STATE, ::set-env → $GITHUB_ENV.
Add timeout-minutes to every job (default: 30, max: 60). Add continue-on-error only where explicitly needed.
Fix YAML syntax errors. Ensure all `uses:` reference existing action versions.
Add `if: success()` / `if: always()` explicitly where failure handling matters.

── Performance ──
Concurrency groups: cancel in-progress on PR push: concurrency: { group: ${{ github.workflow }}-${{ github.ref }}, cancel-in-progress: true }
Cache dependencies: actions/cache or built-in cache (setup-node, setup-python, etc.).
fetch-depth: 1 for checkouts (unless history needed). Shallow submodules if used.
Matrix parallelism where applicable, max 7 combinations. Split slow tests into shards.
Use `paths:` and `paths-ignore:` filters to skip irrelevant workflows.

── Validation pipeline ──
yamlfmt → yamllint → actionlint → verify all referenced secrets exist in repo settings.

── Constraints ──
Max 20 workflow files. Max 20 min expected runtime per job. Max 7 matrix combinations.
No workflow_dispatch without input validation. No self-hosted runners without security review.

── Output ──
Analysis table (workflow|issue|severity|fix), unified diffs, new/modified workflow files, validation results (actionlint output), rollback plan (previous working versions).
```

</details>

## Lint/Format Orchestrator

<details><summary><b>Full Spec</b></summary>

```text
Orchestrate multi-language linting and formatting across entire codebase.
Use `rg`/`fd` to discover files by language. Use ultrathink.
Exclude: .git, node_modules, vendor, dist, .venv, __pycache__, *.min.*, generated/

── Rules ──
Always format BEFORE lint (formatters may fix lint issues). Batch with xargs -P$(nproc) where safe.
Exit non-zero on any lint failure in CI. In interactive mode, fix what's auto-fixable, report rest.

── Language pipeline (format → lint, in order) ──
YAML:      yamlfmt -w        → yamllint -f parsable -d '{extends: default, rules: {line-length: {max: 140}}}'
JSON:      biome format      → biome check (or jq -S . for standalone files)
JS/TS:     biome format --write → biome check --write --unsafe → oxlint -D all
Shell:     shfmt -w -i 2 -bn -ci -ln bash → shellcheck --severity=error -f gcc → shellharden --replace
Fish:      fish_indent -w
TOML:      taplo fmt          → taplo lint (or tombi lint)
Markdown:  mdformat           → markdownlint --fix
Actions:   yamlfmt            → yamllint → actionlint
Python:    ruff format        → ruff check --fix --unsafe-fixes
Rust:      cargo fmt          → cargo clippy -- -D warnings
Lua:       stylua             → selene
Go:        gofmt -w -s        → golangci-lint run
CSS:       biome format       → biome check (or stylelint --fix)

── Execution strategy ──
Detect languages present via fd/rg. Only run pipelines for detected languages.
Run independent language pipelines in parallel. Collect all results before reporting.
If a formatter modifies a file, re-run its linter to verify fix didn't introduce new issues.

── Output ──
Orchestration script (executable, standalone), per-language error reports, summary table (language|files|formatted|lint errors|fixed|remaining), CI-compatible exit code (0 = clean, 1 = unfixed issues).
```

</details>

## Utilities

<details><summary><b>Flow-Style Compaction</b></summary>

```text
Compact structured data files for density without losing readability.
Use `rg`/`fd` to find JSON/YAML/TOML files. Use ultrathink.
Exclude: lockfiles (package-lock.json, yarn.lock, bun.lockb), node_modules/, .git/

Rules:
- Arrays/objects with total serialized length ≤140 chars → inline/flow-style on one line
- Arrays/objects >140 chars → block/expanded style with proper indentation
- Collapse 3+ consecutive blank lines to max 1
- Delete HTML/XML comments in non-HTML files. Preserve YAML comments.
- Sort object/mapping keys alphabetically (unless order is semantically meaningful, e.g., "name" before "version" in package.json)
- JSON: normalize with jq -S or biome format. Remove trailing commas (invalid JSON).
- YAML: prefer flow for short sequences: tags: [ci, build, test] not multi-line
- TOML: inline tables for ≤3 key-value pairs

Validation: parse output to verify no data loss (diff key counts, value equality check).
Output: unified diffs, space savings (bytes before/after, line count before/after), validation confirmation.
```

</details>
<details><summary><b>AGENTS.md Generator</b></summary>

```text
Generate comprehensive AGENTS.md for AI-assisted development. Use `rg` to analyze repo. Use ultrathink.

Analysis steps:
1. Languages: fd -tf | rg -o '\.[^.]+$' | sort | uniq -c | sort -rn (top extensions)
2. Frameworks: rg for imports/requires of major frameworks (react, next, express, flask, fastapi, etc.)
3. Build system: detect package.json, Cargo.toml, pyproject.toml, go.mod, Makefile, etc.
4. CI/CD: .github/workflows/, .gitlab-ci.yml, Jenkinsfile, etc.
5. Conventions: analyze existing code for patterns (naming, error handling, testing approach)
6. Config files: .editorconfig, biome.json, ruff.toml, tsconfig.json, .eslintrc, etc.
7. Key entry points: main files, CLI entrypoints, API routes, exported modules

Output AGENTS.md with sections:
- Project: one-line description, primary language(s), framework(s)
- Structure: tree of key directories with purpose annotations (use @path prefix)
- Dev workflow: exact commands for setup, build, test, lint, deploy
- Conventions: naming (snake_case/camelCase), file organization, error handling, import style
- Dependencies: key deps with purpose (not full list)
- Common tasks: how to add a feature, fix a bug, add a test, update deps
- CI/CD: what runs on PR, what runs on merge, deploy process
- Tool preferences: formatter, linter, package manager, runtime

Create symlinks: CLAUDE.md → AGENTS.md, GEMINI.md → AGENTS.md
Also generate: .github/copilot-instructions.md (subset: conventions + commands)
Output: complete AGENTS.md, symlink commands, summary of detected patterns.
```

</details>

## Copilot / Jules Tasks

```text
Find duplicate logic across files — rg for repeated patterns >10 lines, propose shared abstractions
```

```text
Analyze repo structure, test coverage gaps, and dependency health. Generate 3 high-impact feature/improvement ideas with: problem statement, proposed solution, affected files, estimated LOC, risk level.
```

```text
Cluster related functions by responsibility using import/call graph analysis. Suggest module refactoring with: current→proposed file mapping, migration steps, import update commands.
```

```text
Identify CPU-bound sequential code. Refactor for parallel processing using language-native concurrency (asyncio/TaskGroup, Promise.all, rayon, goroutines). Benchmark before/after.
```

```text
Audit all linter/formatter configs. Upgrade to latest versions. Auto-fix breaking config schema changes. Verify lint passes after upgrade.
```

```text
Set up Renovate with: automerge for patch/minor, grouped updates by ecosystem, schedule (weekdays only), PR limits, custom rules for known-breaking packages. Include renovate.json and workflow.
```

```text
Convert CLI tool into GitHub App: webhook receiver, event handlers for PR/push/issue events, installation auth flow, Dockerfile, deploy workflow.
```

```text
Build web scraper with: rate limiting (token bucket), exponential backoff retries (max 3), structured error handling, proxy rotation support, robots.txt compliance, output as JSON/CSV.
```

```text
Find untested public functions/methods via coverage report. Generate pytest/vitest test files with: happy path, edge cases (empty/null/boundary), error paths. Target 80%+ coverage.
```

```text
Set up pre-commit hooks: format (biome/ruff/shfmt) → lint (oxlint/ruff/shellcheck) → type-check (tsc --noEmit/mypy) → codespell. Include .pre-commit-config.yaml and setup instructions.
```

```text
Create CI/CD workflows: lint+format check, test matrix (OS × runtime version), build, deploy preview on PR, deploy prod on merge. Include: caching, concurrency groups, path filters, artifact upload.
```

```text
Identify functions >50 lines or >5 parameters. Decompose into focused <30-line functions using: extract method, introduce parameter object, replace conditional with polymorphism. Preserve public API.
```
</details>

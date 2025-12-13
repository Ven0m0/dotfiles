# `Dotfiles`

<details>
<summary><b>Features</b></summary>

- [Auto optimized media](.github/workflows/image-optimizer.yml)
- [Auto validated config files](.github/workflows/config-validate.yml)
- [Auto shell check](.github/workflows/shellcheck.yml)
- [Auto updated submodules](.github/workflows/update-git-submodules.yml)

</details>
<details>
<summary><b>Arch scripts</b></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Updates.sh | bash
```

```bash
curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Clean.sh | bash
```

```bash
curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Rank.sh | bash
```

</details>
<details>
<summary><b>Useful Stuff</b></summary>

- [https://dotfiles.github.io/](https://dotfiles.github.io/)
- [https://terminal.sexy/](https://terminal.sexy/)
- [https://wiki.archlinux.org/title/Git](https://wiki.archlinux.org/title/Git)

</details>
<details>
<summary><b>Packages:</b></summary>

- [Arch PKG](https://archlinux.org/packages)
- [AUR PKG](https://aur.archlinux.org)
- [Crates.io](https://crates.io)
- [FlatHub](https://flathub.org)
- [Lure.sh](https://lure.sh)
- [Basher](https://www.basher.it/package)
- [bpkg](https://bpkg.sh)
- [x-cmd](https://www.x-cmd.com)

<details>
<summary><b>Install x-cmd</b></summary>

bash:

```bash
eval "$(curl -s https://get.x-cmd.com)"
```

fish:

```sh
curl -s https://get.x-cmd.com | sh; chmod +x $HOME/.x-cmd.root/bin/x-cmd && ./$HOME/.x-cmd.root/bin/x-cmd fish --setup
```

</details>
</details>
<details>
<summary><b>Supported Linux Distributions</b></summary>

- [CachyOS](https://cachyos.org) specifically, but really any arch based distro is good
- [DietPi](https://dietpi.com)
- [Raspberry Pi OS](https://www.raspberrypi.com/software)

</details>
<details>
<summary><b>Alternative frontends</b></summary>

- [Libredirect](https://libredirect.github.io)
- [alternative-front-ends](https://github.com/mendel5/alternative-front-ends)
- [Privacy-tools](https://www.privacytools.io)
- [Redlib instance list](https://github.com/redlib-org/redlib-instances/blob/main/instances.md)
- [Redlib reddit](https://lr.ptr.moe)
- [Imgur](https://rimgo.lunar.icu)

**Search engines**

- [DuckduckGo](https://duckduckgo.com)
- [Searchxng](https://searx.dresden.network/) [Instances](https://searx.space)
- [Brave search](https://search.brave.com)

</details>

## **Quick prompts**

<details>
<summary><b>Lint/Format</b></summary>

```markdown
Objective: full tree conformance to .editorconfig; 2-space indent; zero remaining errors; non-zero exit on unresolved
issues. Discovery: fd -tf -u -E .git -E node_modules -e <ext>; fallback: find. Scan: rg for invalid chars/invisibles; sd
to clean; compressors: zstd→gzip→xz. Policy:
- Format before lint.
- Only use safe write modes (--write/--apply/--fix/-w).
- Batch file lists; minimal forks; xargs -P for parallel.
- Respect project configs (.editorconfig, prettierrc, pyproject.toml, etc.).
- Detect missing tools; report & skip group. Pipeline (group → format → lint/fix → report):
- yaml: yamlfmt --apply; yamllint -f parsable.
- json/css/js/html: biome fmt --apply || prettier --write; eslint --fix; minify final.
- xml: minify only (no linter).
- sh/zsh: shfmt -w -i 2; shellcheck --format=gcc || :; shellharden audit.
- fish: fish_indent -w.
- toml: taplo fmt; tombi lint.
- markdown: mdformat; markdownlint --fix.
- github actions: yamlfmt; yamllint; actionlint.
- python: ruff --fix; black --fast.
- lua: stylua; selene.
- global: ast-grep rules; rg enumeration; run via xargs -P. Output (structured):
- table: {file, group, modified(yes/no), errors(count/list)}
- commands: exact CLI for reproducing fixes
- summary: totals + final exit Cleanup:
- Remove duplicate/obsolete/deprecated configs.
- Normalize all config files; unify indentation, charset, EOL.
- Ensure consistent toolchains (taplo/tombi, biome/prettier/eslint, mdformat/markdownlint).
```

</details>
<details>
<summary><b>LLM files</b></summary>

```markdown
Role: LLM MD File Optimizer — ensure CLAUDE.MD, GEMINI.MD, copilot-instructions.md exist, minimal, consistent,
lint-clean, CI-fail on missing/invalid. Discovery
- Find candidate files: `fd -H -I -E .git -e md || find . -name '*.md'`
- Locate targets: `rg -nS 'CLAUDE|GEMINI|copilot' || :` Tools (preferred → fallback)
- fd → find; rg → grep; shfmt; markdownlint; shfmt (code blocks). Preflight checks (must run)
1. Encoding/clean: `file -bi <file>` → UTF-8, strip BOM; `rg -nU '\p{Cc}' || :` → no control chars.
2. Invisibles: `rg -nU '\p{C}' || :` and `sd '  +$' ''` (strip trailing spaces).
3. Line width: wrap/soft-fail >80 cols; enforce ≤80 cols where reasonable.
4. Code blocks: run `shfmt -i 2 -w` for bash blocks; preserve fenced language tags. Templates & canonical structure (per
   file)
- Location: `docs/{claude|gemini|copilot}/<short>.md` (create dir if missing).
- Required header (YAML or plain):
  - Title
  - Purpose (1 line)
  - Model pattern (e.g., `claude-*` / `gemini-*`)
  - Tone (blunt/precise)
  - Key rules (bulleted)
  - Minimal example: `system + task → expected short output`
- File must be minimal and focused; no long narrative. Workflow (must follow)
1. Plan: output 3–6 bullet plan (files touched, small|big change, tests, rollback).
2. Read target files; if missing → create from template.
3. Merge/prune:
   - Merge sections when overlap; prune duplicates.
   - Dedupe text blocks >3 lines or >50 tokens (prefer canonical template).
4. Normalize:
   - 2-space indent; remove invisible chars; LF endings; ≤80 cols.
   - Run markdownlint: `markdownlint -c .markdownlint.json <files>`.
5. Validate:
   - Ensure presence of required sections and a minimal example per file.
   - Ensure code blocks formatted (shfmt for bash blocks).
6. Commit/PR:
   - Small change → branch `docs/<type>/<short>`; commit msg: `docs(<type>): <short> — add/fix <what>`.
   - Big/ambiguous → open ISSUE.md proposing changes and stop.
7. Deliverables:
   - Patched files (path list), unified diff, `CHANGES.md` entry, tests/smoke commands, `ISSUE.md` if non-auto.
   - One-line risk note per file changed. CI rules (must cause fail)
- If any required file missing → exit non-zero.
- If `markdownlint` finds errors → fail.
- If invisibles/control chars present → fail.
- If example smoke test (run small parse or prompt check) fails → fail. Output format (Markdown)
- Plan (3–6 bullets)
- Files created/updated (paths)
- Unified diff(s)
- Tests / run commands (1–3 commands)
- CHANGES.md entry content
- One-line rationale + risk per non-trivial change Assumptions & limits
- Do not alter intent or semantics of existing prompts without explicit approval.
- Keep templates minimal; prefer small PRs. If ambiguous, create ISSUE.md and stop.
```

</details>
<details>
<summary><b>Bash short</b></summary>

```markdown
Role: Bash Refactor Agent — full-repo shell codemod, fixer, and optimizer. Goal:
- Scan all bash/sh files using rg/ripgrep and apply a compact, safe codemod: normalize syntax, fix redirects, inline
  trivial code, run linters/formatters, and emit standalone, deduped, fully optimized scripts. Scope (targets):
- All `*.sh`,`*.bash`,`*.zsh`, and rc-like shell files, excluding `.git`, `node_modules`, vendored/generated assets.
- Prefer bash; user wants bashisms. Core rules:
- Formatting: `shfmt -i 2 -bn -ci -ln bash`; max 1 empty line, keep whitespace reasonably minimal
- Linters: `shellcheck --severity=error`; `shellharden --replace` when safe.
- Forbidden: `eval`, parsing `ls`, unquoted expansions, unnecessary subshells, runtime piping into shell.
- Standalone: Avoid sourcing files; dedupe repeated logic; keep guard comments.
- Inline case (`example) action1; action2 ;;`)
- Performance: Prefer bashism's and shell native methods, replace slow loops/subshells with bash builtins (arrays,
  mapfile, parameter expansion); limited `&` + `wait`.
- Use printf's date instead of date (`date(){ local x="${1:-%d/%m/%y-%R}"; printf "%($x)T\n" '-1'; }`).
- Use bash native methods instead of a useless cat (`fcat(){ printf '%s\n' "$(<${1})"; }`).
- Use read instead of sleep when safe (`sleepy(){ read -rt "${1:-1}" -- <> <(:) &>/dev/null || :; }`).
- Start every script like this: #!/usr/bin/env bash # shellcheck enable=all shell=bash source-path=SCRIPTDIR
  external-sources=true set -euo pipefail; shopt -s nullglob globstar export LC_ALL=C; IFS=$'\n\t'
    s=${BASH_SOURCE[0]}; [[$s != /*]] && s=$PWD/$s; cd -P -- "${s%/\*}" has(){ command -v -- "$1" &>/dev/null; } Codemod
  transformations
1. Header/style normalization:
   - Convert `() {` → `(){` and enforce compact function form.
   - Remove space in redirects: `> /dev/null` → `>/dev/null`.
   - Collapse combined redirects: `>/dev/null 2>&1` and malformed `2&>1` → `&>/dev/null`.
   - Always prefer `[[ ... ]]` over `[ ... ]`.
   - Ensure explicit bash shebang on scripts containing bashisms.
2. Inlining:
   - Inline small functions (≤6 non-empty lines, ≤2 call sites, no complex control flow).
   - Inline short adjacent commands using `;` if clarity preserved.
3. Safety guards:
   - Skip heredocs and single-quoted blocks.
   - Skip ambiguous bracket conversions (arrays, arithmetic, regex-heavy lines).
   - Flag blocks >50 tokens or repeated >3 lines; extract into atomic functions.
   - Preserve behavior; smallest safe change wins.
4. Deduplication:
   - On inlining or inlining sourced code, dedupe repeated blocks and emit a single canonical version.
5. Linters/fixes:
   - Run `shellcheck`; auto-apply trivial fixes (quoting, redirs) when safe.
   - Run `shellharden`; accept safe output or revert unsafe changes.
   - Re-run linters; fail if remaining errors.
6. Deliverables from Claude Code:
   - Short plan (3–6 bullets).
   - Unified diff.
   - Final standalone script(s).
   - One-line risk note. Pipeline (per file)
- Token-aware read; apply ordered transforms → shfmt → shellcheck → shellharden → re-check.
- PR: Clean lint, atomic commits (fmt != logic), tests pass.
- Create branch `codemod/bash/<timestamp>`; atomic commits per file.
```

</details>
<details>
<summary><b>AIO</b></summary>

````markdown
Role: Bash Refactor & Repo Hygiene Agent — full-repo shell codemod, fixer, optimizer, and lint/format orchestrator.
Priorities (strict)
1. Correctness → Portability → Performance.
2. Minimal, reversible edits; preserve behavior.
3. Bash rules from “Bash short” override other instructions for shell work. Scope
- Primary: All `*.sh`, `*.bash`, `*.zsh`, and rc-like shell files, excluding `.git`, `node_modules`, vendored/generated
  assets.
- Secondary: Repo-wide lint/format for other languages (YAML, JSON, MD, Python, etc.) as a coordinated pipeline.
- Prefer Bash; user explicitly wants bashisms where reasonable. Bash Standards (Bash short takes priority)
  `bash     #!/usr/bin/env bash     # shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true     set -euo pipefail; shopt -s nullglob globstar     export LC_ALL=C; IFS=$'\n\t'     s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"     has(){ command -v -- "$1" &>/dev/null; }     `
- Idioms:
  - Always use `[[ ... ]]` (regex via `=~`) over `[ ... ]` where safe.
  - Use bash arithmetic `(( ))`, arrays, `mapfile -t`, `read -ra`, `local -n`, `declare -A`.
  - Prefer `printf` over `echo`, parameter expansion over `sed/awk` for simple transforms.
  - While loops: `while IFS= read -r line; do ...; done`.
  - Inline `case` styles: `pat) cmd1; cmd2 ;;`.
- Formatting:
  - `shfmt -i 2 -bn -ci -ln bash`.
  - Max 1 consecutive empty line; keep whitespace minimal.
- Linters:
  - `shellcheck --severity=error` (Bash short priority).
  - `shellharden --replace` only when changes are clearly safe; otherwise audit mode.
- Forbidden:
  - `eval`, backticks, parsing `ls`, unquoted expansions, unnecessary subshells, runtime piping into shell (`curl | sh`
    style) unless explicitly required by user snippet.
- Performance:
  - Minimize forks; prefer builtins and parameter expansion.
  - Avoid subshells in tight loops.
  - Use simple helpers instead of common external calls:
    ```bash
    date(){ local x="${1:-%d/%m/%y-%R}"; printf "%($x)T\n" '-1'; }
    fcat(){ printf '%s\n' "$(<"${1}")"; }
    sleepy(){ read -rt "${1:-1}" -- <> <(:) &>/dev/null || :; }
    ```
  - Limited `&` + `wait` for I/O-heavy operations; no over-parallelization. Bash Codemod Rules
1. Header/style normalization:
   - Convert `fn() {` → `fn(){`.
   - Normalize redirects: `> /dev/null` → `>/dev/null`; `>/dev/null 2>&1` → `&>/dev/null` where equivalent.
   - Replace `[ ... ]` with `[[ ... ]]` where semantics are clear (no ambiguous `=` vs `==`, no POSIX-only constraints).
   - Ensure explicit bash shebang on scripts using bashisms.
2. Inlining:
   - Inline small functions (≤6 non-empty lines, ≤2 call sites, no complex flow) where it increases clarity and reduces
     indirection.
   - Inline adjacent trivial commands using `;` when it does not harm readability.
3. Safety guards:
   - Do not touch heredocs or heavy-regex lines unless trivial.
   - Skip ambiguous bracket conversions (e.g., array literals, arithmetic in `[ ]`, complex globbing).
   - When in doubt, prefer smallest safe change; do not alter behavior.
4. Deduplication & Standalone:
   - Avoid runtime `source` dependencies in final scripts: fold shared helpers into a single canonical function set when
     practical.
   - Dedupe repeated logic blocks; keep one canonical implementation.
   - Preserve guard comments and any documented behavior. Repo-wide Lint/Format Pipeline (adapted from Lint/Format +
     AIO)
- Discovery:
  - Prefer `fd`; fallback to `find`.
  - Example: `fd -tf -u -E .git -E node_modules -e <ext> || find . -type f -name '*.<ext>'`.
- General policy:
  - Format before lint.
  - Only use safe write modes (`--write`, `--apply`, `--fix`, `-w`).
  - Batch file lists; minimal forks; use `xargs -P` for parallel where tools don’t handle parallelism themselves.
  - Respect project configs (`.editorconfig`, `prettierrc`, `pyproject.toml`, etc.).
  - Detect missing tools; report and skip that group rather than half-configured changes.
- Per-group pipeline (example defaults, respect repo tooling when present):
  - YAML: `yamlfmt --apply`; `yamllint -f parsable`.
  - JSON/CSS/JS/HTML: `biome fmt --apply || prettier --write`; `eslint --fix` if present; optional minify step.
  - XML: minify only; no linter by default.
  - Shell (`sh`/`bash`/`zsh`):
    - `shfmt -w -i 2 -bn -ci -ln bash`.
    - `shellcheck --format=gcc --severity=error || :` (do not fail the entire run on legacy warnings, but for new work
      aim for clean).
    - `shellharden audit` or `shellharden --replace` only when obvious safe.
  - Fish: `fish_indent -w`.
  - TOML: `taplo fmt`; `tombi lint` if available.
  - Markdown: `mdformat`; `markdownlint --fix`.
  - GitHub Actions: `yamlfmt`; `yamllint`; `actionlint`.
  - Python: `ruff --fix`; `black --fast`.
  - Lua: `stylua`; `selene`.
  - Global: optional `ast-grep` passes; `rg` enumeration. Hygiene & Validation (AIO-aligned, but Bash rules still win
    for shell)
- Encoding & invisibles:
  - Ensure files are UTF-8 (no BOM).
  - Strip trailing spaces, remove control chars/invisibles.
- Line width:
  - Soft 80-column limit for new content; do not wrap existing long lines unless part of a refactor.
- CI expectations:
  - Scripts must pass `shfmt` and `shellcheck` for Bash-related changes.
  - Markdown must pass `markdownlint`.
  - If required tooling is missing, clearly state the expected commands instead of guessing alternatives. Workflow (what
    the agent should do per request)
1. Plan (3–6 bullets)
   - Identify target files, change scope (small style vs non-trivial logic), and risk.
2. Discovery
   - Enumerate relevant files (Bash first, then others for lint/format when requested).
3. Transform
   - For Bash: apply codemod pipeline (normalize → inline trivial → dedupe → optimize; obey Bash short rules).
   - For non-Bash: run the appropriate lint/format pipeline with minimal behavior change.
4. Validate
   - Run formatters and linters as specified; ensure no syntax errors.
   - For risky Bash changes, provide or suggest simple smoke tests.
5. Output
   - Short plan.
   - Unified diff(s) for changed files.
   - Final standalone script(s) for any Bash entrypoints.
   - One-line risk note per non-trivial change. Constraints
- No new runtime external dependencies; only use tools that are either already part of the repo toolchain or explicitly
  allowed above.
- Do not change user-facing behavior without clear reason; when unsure, prefer formatting and safety-only changes.
- Bash short rules are the tiebreaker for any contradictions about shell.
````

</details>
<details>
<summary><b>Python</b></summary>

```markdown
name: Python Architect & SRE description: Refactor and optimize Python code with strict typing, high performance
(orjson/uvloop), Black formatting, and atomic workflows.
# Role: Senior Python Architect & SRE
**Goal**: Refactor existing Python code to maximize maintainability, type safety, and performance. Eliminate duplication
(`DRY`) and enforce strict standards while preserving behavior.
## 1. Tooling & Standards
- **Format**: Enforce **Black** style via `ruff format`. Soft limit **80 chars**.
- **Lint**: `ruff check .` (Python) and `biome` (configs/docs).
- **Deps**: Manage via `uv`. Lazy-import heavy modules.
- **Tests**: `pytest --durations=0`. New code **must** include tests (edge cases/boundaries).
## 2. Strict Type Safety
- **Rules**: Fully annotate functions/params/returns. Run `mypy --strict`.
- **Syntax**: Use modern generics (`list[str]`) over `typing` imports where possible.
- **Constraint**: No `Any` unless justified with `# TODO`. Prefer `DataClasses`/`TypedDict` over ad-hoc dicts.
## 3. High-Performance Stack
Prioritize speed and low memory footprint. Replace standard libs where applicable: | Standard | **Optimized
Replacement** | **Why** | | :--- | :--- | :--- | | `json` | **`orjson`** | ~6x faster serialization. | | `asyncio` |
**`uvloop`** | Node.js-level event loop speed. | | `requests` | **`httpx`** | Async, HTTP/2 support. | | `pandas` |
**`csv`** (Std Lib) | Use streaming `csv` for ETL to save RAM; Pandas only for complex analytics. |
## 4. Code Quality & Logic
- **Complexity**: Target **O(n)** or better. Use sets/dicts for lookups; avoid nested loops.
- **Structure**: Small, atomic functions (SRP). Snake_case naming.
- **Errors**: Catch specific exceptions only. Use `raise ... from e`.
- **State**: Avoid global mutable state.
## 5. Workflow (Mandatory)
Do **not** output code immediately. Follow this process:
1.  **Plan**: Bullet-point summary of changes, rationale, and verification steps.
2.  **Refactor**: Incremental, atomic changes.
3.  **Verify**: Run linters/tests. Compare metrics (complexity, coverage) if possible.
```

</details>
<details>
<summary><b>Javascript</b></summary>

```markdown
Role: JS/TS Quality & High-Perf Enforcer Target: Architecture Guide compliant Bash script. Scope: Scan, Format, Lint,
Report, CI Gate.
## Discovery
- **Tool**: `fd` (preferred) > `find`.
- **Pattern**: `\.(js|jsx|ts|tsx|mjs|cjs)$`.
- **Ignore**: `node_modules`, `.git`, `dist`, `build`.
- **Cmd**: `fd -tf -e js -e jsx -e ts -e tsx -E node_modules -E .git`.
## Toolchain & Config
- **Formatter**: `biome format` (Replaces Prettier).
- **Linter**: `biome check` (Replaces ESLint basic) + `oxlint` (Oxc, for deep static).
- **Config Priority**:
  1. `biome.json` / `oxlint.json` (Project root).
  2. Fallback: Zero-config defaults (Opinionated best-practice).
- **Integration**: Ensure Biome handles formatting; Oxc handles semantic correctness.
## Policy
- **Order**: Format (Write) » Lint (Fix) » Lint (Check) » Report.
- **Concurrency**: Use tool native parallelism; avoid external `xargs -P` if tool handles it.
- **Safety**: Only apply safe fixes automatically.
- **CI**: Exit code `1` if unfixable errors remain; `0` otherwise.
## Workflow Execution
1. **Check Tools**: Verify `biome` and `oxlint` exist; warn/install if missing.
2. **Format**: `biome format --write <files>`.
3. **Lint (Fix)**: `biome check --write <files>` (applies safe fixes/imports).
4. **Lint (Deep)**: `oxlint -D all --deny-warnings <files>` (catch complex issues).
5. **Reporting**:
   - Generate summary table: `| File | Status | Biome Issues | Oxc Issues |`.
   - Output structured JSON logs for CI parsers if env `CI=true`.
## Constraints
- **Perf**: Maximize throughput (Rust-based tools); minimal I/O.
- **Style**: 2-space indent, double quotes (Biome default), trailing commas.
- **Logic**: No functional changes; style/safety only.
- **Deps**: Do not rely on Node.js/npm runtime if binary exists.
## Deliverables
- Single Bash script (`quality-check.sh`).
- Reproducible command sequence.
- Output matrix (Files scanned vs. Errors found).
```

</details>
<details>
<summary><b>Actions</b></summary>

```markdown
Prompt: GitHub Actions – Workflow Audit, Refactor & Harden Role: GitHub-Actions CI Auditor & Hardening Agent Goal:
Review and refactor `.github/workflows/*.yml` for security, performance, maintainability.
### Process:
1. **Plan**
   - List workflows to inspect.
   - Identify main objectives: performance, security, maintainability.
   - Categorize each change scope: small (format/CI tweaks), medium (refactor), large (job logic changes).
2. **Baseline**
   - For each workflow — output: triggers, jobs, caching, permissions, env/secrets usage.
   - Flag redundant or duplicated logic, unsafe permissions, EOL or exposed secrets, missing caching.
   - List any insecure or `latest`-tagged action references.
3. **Refactor**
   - Add `permissions: { contents: read }` at top of workflow; override per-job only if stricter permissions are needed.
   - Remove dead, redundant or duplicate jobs/steps.
   - Add `concurrency` to critical workflows where parallel runs might conflict.
   - Convert parallelizable test suites to use a `matrix`.
   - Optimize `actions/checkout`: use `fetch-depth: 1`, disable submodules/LFS unless necessary.
   - Inline concise shell scripts; name steps clearly for log readability.
   - Cache package-manager dependencies (via `actions/cache`) with appropriately scoped keys.
   - Replace hardcoded sensitive values with `${{ secrets.* }}`.
   - Add top-of-file comments documenting all relevant envs/secrets.
4. **Testing & Validation**
   - Syntax / semantic lint: run `actionlint`. :contentReference[oaicite:4]{index=4}
   - Schema validation: run `action-validator` against workflow files. :contentReference[oaicite:5]{index=5}
   - Validate third-party action refs (tags/SHAs) with `GHA Workflow Linter` (ghalint) or similar.
     :contentReference[oaicite:6]{index=6}
   - (Optional) Use `act` for local simulation / smoke tests.
   - Format and lint YAML (e.g. `yamlfmt`, `yamllint`).
   - Produce summary diff of applied changes + listing of new/modified CI checks.
5. **Deliverable**
   - Compact summary: scope, risks addressed, next-steps.
   - Unified diffs per changed file, with rationale for non-trivial modifications.
   - Commands for CI/QA + local validation (lint, schema, smoke test).
   - Rollback instructions if needed.
### Constraints:
- Avoid code/logic mutation unless strictly justified; preserve existing behavior.
- Do not use `main` or `latest` as action refs.
- No hardcoded secrets.
- Limit parallel jobs to ≤ 7 unless justified. Output: plan, changed-file summary, unified diff(s), rationale(s),
  lint/validation/CI commands, rollback steps.
```

</details>
<details>
<summary><b>TODO</b></summary>

```markdown
Role: Senior Dev-Assistant Goal: Identify and resolve straightforward tasks from in-code TODOs or the GitHub Issues Tab.
Deliver a standalone, test-verified patch.
1. Discovery (Dual-Source)
- Issues: List via `gh issue list --limit 10 --label 'bug,good-first-issue,chore'` or API equivalent.
- TODOs: Find via `rg --hidden -g '!node_modules' -n 'TODO'`.
- Filter: Exclude vendor, build, or docs paths. Skip schema changes or complex auth.
2. Selection Criteria
- Priority 1: Open issue with "good first issue" or "bug" label and clear repro steps.
- Priority 2: Explicit TODO in a stable, well-tested file.
- Heuristics: Single file, ≤50 LOC, no external API/schemas, existing test coverage.
3. Implementation & Validation
- Fix: Minimal logic to satisfy issue or TODO.
- Lint/Format: Use project-specific tools (e.g., shfmt, black, prettier).
- Test: Run focused unit tests, then full suite. Zero regressions allowed.
4. Output Requirements Source: Issue ID/URL or file:line with snippet. Rationale: Brief safety/feasibility note. Unified
   Diff: Full git diff patch. Verification Log: Key linter and test output. Commit/PR:
- PR summary: Fix overview and risk: Low/Med. Constraints
- Use only existing dev dependencies; no new external libraries.
- No drive-by refactoring.
- If ambiguous, state one assumption, document, and proceed.
```

</details>

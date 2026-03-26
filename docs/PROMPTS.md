
<details><summary><b>Opencode/Kilocode rules</b></summary>

```text
<investigate_before_answering>
Before generating any files, read these paths if they exist — never speculate about project stack, commands, or workflows:
- package.json / Cargo.toml / pyproject.toml / go.mod / build.gradle / CMakeLists.txt
- .opencode/opencode.json and any existing .opencode/**
- .kilocode/ tree and any existing .kilocodemodes
- AGENTS.md / AGENT.md
- README.md (first 60 lines only)
- .github/workflows/*.yml (names only, no content)
- Any Makefile or justfile (targets list only)
Run: fd -d 3 -t f '(SKILL|AGENTS|opencode)' . 2>/dev/null
Run: rg -l 'scripts|test|lint|build|deploy' package.json Makefile justfile 2>/dev/null | head -5
</investigate_before_answering>
<use_parallel_tool_calls>
All file-read operations above are independent — execute them in parallel.
</use_parallel_tool_calls>
# Scaffold .opencode and .kilocode for {PROJECT_ROOT}
## Instructions
1. **Detect** project type, stack, test runner, linter, build tool, and CI system from the files read above.
2. **Generate .opencode/** layout — create only what is non-trivially useful for this project:
   a. `.opencode/commands/` — one `.md` file per workflow command. Each file MUST have YAML frontmatter with `description` (required), optionally `agent` (build/plan/code), `model`, `subtask: true` if it should run isolated. Body is the prompt template. Use `$ARGUMENTS`, `$1`…`$N` for parameters. Use `!` backtick shell output injection `` !`cmd` `` for dynamic context. Use `@path` for file references.  
   Required commands to generate if applicable:
   - `test.md` — run test suite, show failures, suggest fixes
   - `lint.md` — run linter + formatter, output violations
   - `build.md` — build/compile, capture errors
   - `review.md` — diff-aware code review (uses `` !`git diff HEAD` ``)
   - `release.md` — changelog + version bump workflow
   - `commit.md` — conventional commit from `` !`git diff --staged` ``
   Add project-specific commands for any repeated workflows found in Makefile/justfile/CI.
   b. `.opencode/skills/` — one folder per skill, each with `SKILL.md`. Frontmatter: `name` (match dir name, lowercase-alphanum-hyphen, ≤64 chars), `description` (≤512 chars, written so the agent picks it correctly). Body: concise expert instructions. Generate skills for:
   - Detected stack conventions (e.g., `rust-idioms`, `nextjs-patterns`, `django-conventions`)
   - Repo-specific patterns found in code (naming, error handling, API shapes)
   - Any CI/release/git workflow worth encoding
3. **Generate .kilocode/** layout:
   a. `.kilocode/rules/` — one `.md` per concern. Mandatory categories:
   - `code-style.md` — language-specific formatting, indentation, naming (inferred from config files like `.editorconfig`, `rustfmt.toml`, `pyproject.toml` `[tool.ruff]`, `biome.json`)
   - `security.md` — files/secrets MUST NOT be read, injection/auth patterns
   - `architecture.md` — module boundaries, import rules, where new files go
   - `testing.md` — test structure, coverage expectations, mocking policy
   Include only rules that are specific and actionable — no generic AI platitudes.
   b. `.kilocode/skills/` — mirror any `.opencode/skills/` skills here (same SKILL.md format). Kilo picks up from `.kilocode/skills/*/SKILL.md`. Mode-specific: `.kilocode/skills-{mode-slug}/`.
4. **Generate `.kilocodeignore`** at project root. This file uses gitignore syntax and tells Kilo Code which paths it MUST NOT access via any tool (read_file, write_to_file, apply_diff, delete_file, execute_command, list_files). Generate by:
   - Scanning for secrets/credentials: `.env*`, `*.pem`, `*.key`, `*.crt`, `*credentials*`, `*secrets*`, `*token*`
   - Identifying build output and generated dirs from detected toolchain: `dist/`, `build/`, `target/`, `__pycache__/`, `*.pyc`, `.next/`, `coverage/`
   - Identifying large asset dirs that add no AI value: `*.lock` files (list explicitly if found), model weights, binary blobs
   - Use `!pattern` to explicitly un-ignore any gitignored files that Kilo SHOULD access (e.g., `!.env.example`)
   - Add a `# execute_command restriction` comment block listing shell commands that MUST NOT be run on blocked files (cat, grep, head, tail, sed, awk, less) — reinforces rules since execute_command bypasses read_file restrictions
5. **Generate `.ignore`** at project root. This is the ripgrep ignore file consumed by opencode's `grep`, `glob`, and `list` tools (opencode uses rg internally). Use it to:
   - Exclude directories that are already in `.gitignore` and should stay excluded from opencode search: match your `dist/`, `build/`, `target/`, vendor dirs
   - Use `!pattern` to **un-ignore** any gitignored paths that opencode SHOULD be able to discover (e.g., `!notes/`, `!.env.example`, `!docs/generated/`) — this is the primary use case since `.gitignore` already covers the common exclusions
   - Do NOT duplicate `.gitignore` entries that don't need overriding — blank/minimal is fine if gitignore already covers the project well
6. **Generate AGENTS.md** at project root if missing or incomplete. Include:
   - Project purpose (1 sentence)
   - Stack and key dependencies
   - Directory structure (top-level only, annotated)
   - Build / test / lint commands (exact CLI invocations)
   - Coding conventions (language, style, patterns)
   - What NOT to touch (generated files, secrets, lock files)
   - PR/commit conventions at project root if missing or incomplete. Include:
   - Project purpose (1 sentence)
   - Stack and key dependencies
   - Directory structure (top-level only, annotated)
   - Build / test / lint commands (exact CLI invocations)
   - Coding conventions (language, style, patterns)
   - What NOT to touch (generated files, secrets, lock files)
   - PR/commit conventions
## Rules
- NEVER create a file with placeholder content — every file must be specific to this project
- NEVER duplicate content between opencode and kilocode — if both tools are present, commands go in opencode, modes/rules go in kilocode, skills mirror both
- NEVER emit generic advice like "write clean code" — every rule must be a concrete constraint
- NEVER use `grep` — use `rg` for all search operations
- NEVER create a mode that duplicates a built-in (code, debug, ask, architect, orchestrator) unless overriding it with project-specific restrictions
- Skills: `name` field MUST exactly match the parent directory name
- Commands: file name becomes the command name — keep it a single lowercase word or hyphenated phrase
- All shell injections in command templates (`!` backtick) MUST run in ≤2 seconds or be guarded with a timeout
## Formatting
Output a shell script block that creates the entire directory tree using `mkdir -p` + `cat > file << 'EOF'` heredocs, runnable from project root. Then output a summary table:
| File | Purpose | Why it matters for this project |
|------|---------|----------------------------------|
| ... | ... | ... |
## Answer
<answer>
Success: all generated files are project-specific, non-trivially useful, and pass this check:
- rg "TODO|PLACEHOLDER|generic" .opencode/ .kilocode/ AGENTS.md → zero matches
- Every SKILL.md has name + description frontmatter with name matching its directory
- Every .kilocode/rules/*.md contains ≥1 concrete, falsifiable rule
- AGENTS.md exists and contains exact CLI commands for build/test/lint
- .kilocodeignore exists and contains ≥1 secret/credential pattern AND ≥1 build-output pattern
- .ignore exists (may be minimal if .gitignore is comprehensive; document why if empty)
</answer>
```
</details>

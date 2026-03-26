# Testing Rules

## What "Testing" Means in This Repo

There is no unit test framework. Validation is linting + syntax checking + manual smoke tests.

## Required Checks Before Committing Any `.sh` File

1. **Syntax:** `bash -n script.sh` — must exit 0
2. **Lint:** `shellcheck -x script.sh` — zero warnings at `style` level or above
3. **Format:** `shfmt -d -i 2 -bn -ci -sr script.sh` — zero diff output

Lefthook runs these automatically on `git commit`. Do NOT bypass with `--no-verify` unless explicitly asked.

## Required Checks Before Committing Python Files

1. **Syntax:** `python3 -m py_compile script.py` — must exit 0
2. **Type check (if mypy available):** `mypy --strict script.py`

## Required Checks Before Committing YAML Files

1. **Format:** `yamlfmt file.yml` — apply first
2. **Lint:** `yamllint -s file.yml` — zero errors

## CI Validation

The `lint-format` workflow runs on every PR and push to main:
- Runs the same shellcheck/shfmt/yamllint/biome checks as lefthook
- Also runs `qlty fmt` for additional format verification
- All checks must pass before merge

## Manual Smoke Tests for Key Scripts

After editing these scripts, test the indicated command:

| Script | Smoke Test |
|--------|-----------|
| `yadm-sync.sh` | `yadm-sync status` (read-only, safe) |
| `lint-format.sh` | `./Home/.local/bin/lint-format.sh --dry-run` |
| `pkgui.sh` | `pkgui.sh --help` |
| `deploy-system-configs.sh` | `sudo deploy-system-configs.sh --dry-run` |

## Coverage Expectations

- Every new function in `.bash_functions` must have a shellcheck-clean implementation
- Scripts that accept flags must validate all flag combinations in the arg-parsing section
- Error paths (`die()` calls) must be reachable — no dead code

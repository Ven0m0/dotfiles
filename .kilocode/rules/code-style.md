# Code Style Rules

## Shell Scripts (`*.sh`, `*.bash`)

- **Line 1:** `#!/usr/bin/env bash` — no exceptions, no `/bin/bash`
- **Line 2:** `set -euo pipefail` — no exceptions
- **Indentation:** 2 spaces (per `.editorconfig` `[shell]` section)
- **Variables:** Always `"${var}"` with braces and quotes — never bare `$var`
- **Tests:** `[[ ]]` only — never `[ ]` or `/usr/bin/test`
- **Functions:** Defined as `name() { }` — no `function` keyword prefix
- **Line length:** ≤120 chars (per `.editorconfig` `max_line_length = 120`)
- **Strings:** `$'...'` or `"..."` — no backticks anywhere
- **Printf over echo:** Use `printf '%s\n' "${msg}"` not `echo "${msg}"`

## Python (`*.py`)

- **Header:** `#!/usr/bin/env python3`
- **Indentation:** 4 spaces
- **Line length:** ≤100 chars
- **Type hints:** Required on all function signatures
- **Style:** `dataclasses(slots=True)` for data structures, f-strings for formatting, `pathlib.Path` for paths
- **Imports:** stdlib only unless explicitly adding a dependency

## YAML (`.yml`, `.yaml`)

- **Indentation:** 2 spaces
- **Quotes:** Double quotes for strings containing special chars
- **Trailing newline:** Required (auto-added by yamlfmt)

## TOML (`.toml`)

- **Indentation:** 2 spaces
- **Format:** Run `taplo format` before committing

## JSON (`.json`)

- **Indentation:** 2 spaces
- **Validate with:** `jaq empty file.json` (prefer `jaq` over `jq`)

## Markdown (`.md`)

- **Line length:** Unset (no wrapping per `.editorconfig`)
- **Trailing whitespace:** Preserved (per `.editorconfig` `trim_trailing_whitespace = false`)

# Lint & Format Pipeline

Comprehensive linting and formatting pipeline for the dotfiles repository.

## Overview

The `lint-format.sh` script enforces:

- **2-space indent** per `.editorconfig`
- **Format before lint** policy
- **Zero errors** requirement (exits non-zero on errors)
- **Structured reporting** with diff summary and CLI commands

## File Groups & Tools

### YAML

- **Format**: `yamlfmt -conf .yamlfmt <file>`
- **Lint**: `yamllint -f parsable -c .yamllint.yaml <file>`

### JSON/CSS/JS/HTML

- **Format**: `biome format --write .`
- **Lint**: `biome check .`

### Shell Scripts (sh/bash)

- **Format**: `shfmt -w -i 2 -ci -bn <file>` (2-space indent)
- **Lint**: `shellcheck --format=gcc <file>`
- **Note**: Zsh files are excluded from shellcheck

### Fish Scripts

- **Format**: `fish_indent -w <file>`

### TOML

- **Format**: `taplo format <file>`
- **Lint**: `tombi lint <file>`

### Markdown

- **Format**: `mdformat --wrap 80 <file>`

### Python

- **Format**: `ruff format .`
- **Lint**: `ruff check --fix .`
- **Note**: User-local files (`Home/.local/`) are excluded

### GitHub Actions

- **Lint**: `actionlint .github/workflows/*.yml`

## Usage

```bash
./lint-format.sh
```

The script will:

1. Format all files (format phase)
1. Lint all files (lint phase)
1. Generate a report with:
   - Modified files
   - Error files
   - Total error count
   - CLI commands to reproduce fixes

## Exit Codes

- `0`: Success (all files formatted, no errors)
- `1`: Failure (errors found or formatting failed)

## CI Integration

The `.github/workflows/lint-format.yml` workflow:

- Runs on push/PR to main/master
- Installs all required tools
- Runs the comprehensive lint-format script
- **Fails CI on non-zero exit code**

## Configuration Files

- `.editorconfig` - Base formatting rules (2-space indent)
- `.yamllint.yaml` - YAML linting rules
- `.yamlfmt` - YAML formatting config
- `biome.json` - JSON/CSS/JS/HTML formatting & linting
- `pyproject.toml` - Python formatting & linting (ruff, black)
- `.shellcheckrc` - Shell script linting rules
- `.markdownlintrc` - Markdown linting rules

## Excluded Directories

The following directories are excluded from linting/formatting:

- `.git/`
- `node_modules/`
- `vendor/`
- `.cache/`
- `.venv/`
- `__pycache__/`
- `.ruff_cache/`
- `target/`
- `dist/`
- `build/`
- `.next/`
- `.turbo/`
- `coverage/`
- `.var/`
- `.rustup/`
- `.wine/`
- `.zim/`
- `.void-editor/`
- `.vscode/`
- `.claude/`
- `Home/.local/` (user-installed scripts)

## Tool Requirements

Required tools (checked at runtime):

- `yamlfmt` - YAML formatting
- `yamllint` - YAML linting
- `biome` - JSON/CSS/JS/HTML formatting & linting
- `shfmt` - Shell script formatting
- `shellcheck` - Shell script linting
- `fish_indent` - Fish script formatting
- `taplo` - TOML formatting
- `tombi` - TOML linting
- `mdformat` - Markdown formatting
- `actionlint` - GitHub Actions linting
- `ruff` - Python formatting & linting

Optional tools:

- `prettier` - Fallback for JSON/CSS/JS/HTML
- `eslint` - Additional JS linting
- `black` - Additional Python formatting
- `stylua` - Lua formatting
- `selene` - Lua linting
- `ast-grep` - Global pattern matching

## Fallbacks

- `fd` → `find` (file discovery)
- `rg` → `grep` (content search)
- `sd` → `sed` (text replacement)
- `zstd` → `gzip` → `xz` (compression)

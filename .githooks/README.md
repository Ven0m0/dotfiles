# Git Hooks for Dotfiles Repository

This directory contains Git hooks for automated quality and performance checks.

## Installation

To enable these hooks in your local repository:

```bash
git config core.hooksPath .githooks
```

Or if you want to copy them to `.git/hooks`:

```bash
cp .githooks/* .git/hooks/
chmod +x .git/hooks/*
```

## Available Hooks

### pre-commit

Runs before each commit to check for bash performance anti-patterns.

**Checks performed:**

1. **$(cat file) patterns**: Detects inefficient use of `cat` in command substitutions
   - Suggests using bash builtin: `$(<file)`

2. **tput calls**: Detects subprocess-heavy tput usage for colors
   - Suggests using direct ANSI codes: `$'\e[31m'`

3. **cat | command patterns**: Detects unnecessary cat usage in pipelines
   - Suggests direct redirection: `command < file`

4. **ls parsing**: Detects dangerous `for ... in $(ls ...)` patterns
   - Suggests using glob patterns: `for file in *.txt`

5. **ShellCheck**: Runs shellcheck if available to catch errors and warnings

**Exit codes:**
- `0`: All checks passed
- `1`: Errors found or user declined to continue with warnings

**Bypass hook (not recommended):**
```bash
git commit --no-verify
```

## Performance Best Practices

See [docs/BASH_PERFORMANCE.md](../docs/BASH_PERFORMANCE.md) for detailed guidelines on writing performant bash scripts.

## Customization

To disable specific checks, edit `.githooks/pre-commit` and comment out the relevant sections.

To make checks more strict (warnings become errors), modify the exit logic in the hook.

# ast-grep Rules Directory

Organized rule structure for maintainability and selective enablement.

## Directory Structure

```
.config/ast-grep/
├── sgconfig.yml              # Root config with shared utilities
└── rules/
    ├── python/
    │   ├── type-safety.yml   # Type hints, unsafe patterns (errors)
    │   └── performance.yml   # Loop optimizations, idioms (warning/info)
    ├── bash/
    │   ├── critical.yml      # Shebang, quoting, eval (errors)
    │   ├── style.yml         # Compact syntax, idioms (error/info)
    │   ├── performance.yml   # Fork avoidance, mapfile (warning/info)
    │   └── optimization.yml  # Modern tools, parallelism (hints)
    ├── typescript/
    │   ├── critical.yml      # console, eval, var, === (errors)
    │   └── safety.yml        # XSS, empty catch, modern syntax (warning/info/hint)
    └── shared/
        └── todos.yml         # TODO/FIXME comments (warning)
```

## Total Rules: 22 (same as compact config)

| Language   | Files | Rules  | Errors | Warnings | Info  | Hints |
| ---------- | ----- | ------ | ------ | -------- | ----- | ----- |
| Python     | 2     | 5      | 2      | 1        | 2     | 0     |
| Bash       | 4     | 12     | 3      | 2        | 3     | 4     |
| TypeScript | 2     | 4      | 2      | 1        | 1     | 1     |
| Shared     | 1     | 1      | 0      | 1        | 0     | 0     |
| **Total**  | **9** | **22** | **7**  | **5**    | **6** | **5** |

## Usage

### Scan with all rules

```bash
sg scan
```

### Scan specific severity

```bash
sg scan --severity error
sg scan --severity error,warning
```

### Disable entire category

```bash
# Temporarily
sg scan --no-rule bash-modern-tools --no-rule bash-parallel-jobs

# Permanently: delete or rename file
mv rules/bash/optimization.yml rules/bash/optimization.yml.disabled
```

### Scan specific languages only

```bash
# Python only
sg scan --rule 'py-*'

# Bash only
sg scan --rule 'bash-*'

# TypeScript only
sg scan --rule 'ts-*'
```

### Enable/disable specific rules

```bash
# Disable specific rule
sg scan --no-rule py-dataclass-slots

# Enable only specific rules
sg scan --rule bash-critical-standards --rule bash-unquoted-expansion
```

## Advantages of Directory Structure

### 1. Modular Organization

- Each file is a logical unit (type safety, performance, etc.)
- Easy to find and update related rules
- Clear separation of concerns

### 2. Selective Enablement

```bash
# Production CI: Errors only
sg scan --severity error

# Pre-commit: Errors + warnings
sg scan --severity error,warning

# Local dev: Everything
sg scan
```

### 3. Team Ownership

```bash
rules/
├── python/        # Owned by: Python team
├── bash/          # Owned by: DevOps team
└── typescript/    # Owned by: Frontend team
```

### 4. Gradual Adoption

```
Phase 1: Enable critical.yml files only (errors)
Phase 2: Add style.yml and safety.yml (warnings)
Phase 3: Add performance.yml (info)
Phase 4: Add optimization.yml (hints)
```

### 5. Version Control

- Each file can be versioned independently
- Easier to review changes (small diffs)
- Can revert specific categories without affecting others

### 6. Documentation

- Each file is self-documenting
- Notes explain why rules exist
- Examples in fix: fields

## Customization

### Add new rule

Create `rules/python/custom.yml`:

```yaml
id: py-custom-check
language: python
severity: warning
message: Your custom check
rule:
  pattern: dangerous_pattern($$$)
```

### Override rule severity

Copy rule file and modify:

```bash
cp rules/bash/optimization.yml rules/bash/optimization-custom.yml
# Edit optimization-custom.yml, change severity: hint → severity: warning
rm rules/bash/optimization.yml
```

### Create team-specific rules

```bash
mkdir -p rules/team-{backend,frontend,devops}
# Add team-specific rules
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: ast-grep lint
  run: |
    # Errors block merge
    sg scan --severity error || exit 1

    # Warnings are informational
    sg scan --severity warning || true
```

### Pre-commit hook

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit
sg scan --severity error --changed-only || {
  echo "Fix errors before committing"
  exit 1
}
```

### GitLab CI

```yaml
lint:ast-grep:
  script:
    - sg scan --severity error,warning --json > report.json
  artifacts:
    reports:
      codequality: report.json
```

## Migration from Monolithic Config

### From sgconfig-compact.yml

This directory structure contains the same 22 rules as `sgconfig-compact.yml`, just organized into files. No changes
needed.

### From sgconfig.yml (full)

The directory structure uses the compact version (22 merged rules). If you need all 71 rules:

1. Split each merged rule back into individual rules
2. Or use monolithic config for granular control
3. Or mix: keep some merged, split others

## Performance

Directory structure has identical performance to monolithic config:

- ast-grep loads all `.yml` files from `rules/` directory
- No overhead from file organization
- Same scan speed as single config file

## Best Practices

1. **Keep files focused**: One category per file (type-safety, performance, etc.)
2. **Consistent naming**: `<language>/<category>.yml`
3. **Document severity**: Explain why error vs warning vs info vs hint
4. **Add examples**: Use `note:` field with concrete examples
5. **Test fixes**: `fix:` fields should be tested before deployment
6. **Version control**: Commit rule changes with descriptive messages

## Quick Reference

| Want to...         | Command                        |
| ------------------ | ------------------------------ |
| Scan everything    | `sg scan`                      |
| Errors only        | `sg scan --severity error`     |
| Disable category   | Delete/rename file in `rules/` |
| Disable rule       | `sg scan --no-rule <id>`       |
| Python only        | `sg scan --rule 'py-*'`        |
| Add custom rule    | Create new `.yml` in `rules/`  |
| Test single file   | `sg scan path/to/file.py`      |
| Auto-fix           | `sg scan --fix` (careful!)     |
| JSON output        | `sg scan --json`               |
| Changed files only | `sg scan --changed-only`       |

## Troubleshooting

### Rules not loading

```bash
# Verify structure
ls -R .config/ast-grep/rules/

# Check for syntax errors
sg scan --debug
```

### Rule conflicts

```bash
# List all loaded rules
sg scan --help

# Disable conflicting rule
sg scan --no-rule conflicting-rule-id
```

### Performance issues

```bash
# Check how many rules are loaded
sg scan --help | grep -c "  - "

# Reduce rules: disable hint/info levels
rm rules/*/optimization.yml
```

## Support

- [ast-grep docs](https://ast-grep.github.io/)
- [Rule syntax reference](https://ast-grep.github.io/guide/rule-config.html)
- [Pattern syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

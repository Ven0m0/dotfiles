---
name: python-cli-builder
description: "Build production Python CLI tools. Auto-triggers on: create CLI, build utility, write script, python automation, file processing, system utility, argparse, click, typer."
triggers: [python cli, build utility, write script, automation, file processing, argparse, click, typer]
related: [bash-optimizer, modern-tool-substitution, codeagent]
applyTo: "**/*.py"
---

# Python CLI Builder

Build efficient, typed, production-ready Python scripts.

## Core Template

```python
#!/usr/bin/env python3
"""Brief description."""
import sys
from pathlib import Path
from dataclasses import dataclass
from typing import Final

@dataclass(frozen=True, slots=True)
class Config:
    input_dir: Path
    verbose: bool = False

def main() -> int:
    try:
        # Parse args, validate, process
        return 0
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
```

## Standards

- **Types**: All functions typed, `dataclass(slots=True)`
- **Performance**: O(n) algorithms, frozenset for lookups, generators
- **Stdlib-first**: Zero external deps unless justified
- **Exit codes**: 0=success, 1=error, 2+=specific failures
- **Error handling**: Catch specific exceptions, fail fast

## Reusable Components

Use from `scripts/`:
- `cli_template.py` - Production scaffold
- `log_component.py` - ANSI colored logging
- `subprocess_helpers.py` - Safe subprocess wrappers
- `common_utils.py` - has(), find_files(), safe file ops

## Performance Tips

Consult `references/stdlib_perf.md`:
- File scanning: fd subprocess vs os.walk vs Path.glob
- Data structures: frozenset vs set, dict vs linear
- String ops: str.translate vs regex
- External tools: When to shell out to fd/rg/parallel

## Security Checklist

- [ ] No hardcoded secrets
- [ ] Validate all user input
- [ ] Use `Path.resolve()` to prevent traversal
- [ ] Catch `PermissionError`, `FileNotFoundError`
- [ ] Timeout on subprocess calls
- [ ] No `eval()`, `exec()`

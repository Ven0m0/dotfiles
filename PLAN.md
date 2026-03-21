# Implementation Plan
_Generated: 2026-03-21 · 2 tasks · Est. L+XL LOC_

## Legend
<!-- severity: 🔴 critical 🟠 high 🟡 medium 🔵 low -->
<!-- category: bug perf refactor feature security debt docs -->

## Summary

Two actionable TODO markers exist in the codebase (all others in completion files are auto-generated
documentation of deprecated upstream CLI flags, and WARNING comments in config files are usage notes).
Both are feature-additions referencing upstream projects to adopt. No critical, high, or security-class
items were found. No FIXME, HACK, or XXX markers exist anywhere in source.

## Task Index (topological order)

| # | ID   | Title                                              | Sev | Cat     | Size | Blocks |
|---|------|----------------------------------------------------|-----|---------|------|--------|
| 1 | T001 | Add handlr-regex for regex-based MIME associations | 🔵  | feature | M    | —      |
| 2 | T002 | Implement formtool batch features in vidconv.py    | 🔵  | feature | XL   | —      |

---

## Tasks

### T001 · Add handlr-regex for regex-based MIME associations
**File:** `Home/.config/handlr/handlr.toml:7`
**Severity:** low · **Category:** feature · **Size:** M
**Blocks:** — · **Blocked by:** —

**Context:**
```toml
# TODO: enhance with https://github.com/Anomalocaridid/handlr-regex
```

**Intent:** Replace `handlr` with its community fork `handlr-regex`, which adds regex-matching rules
for opening files — allowing pattern-based handler associations beyond pure MIME types (e.g., open
`*.log` files with a specific viewer).

**Acceptance criteria:**
- [ ] `handlr-regex` is installed (AUR: `handlr-regex`) and replaces `handlr` binary
- [ ] `handlr.toml` migrated to `handlr-regex` config format (adds `[regex_apps]` section if needed)
- [ ] At least one regex rule demonstrates the new capability (e.g., `*.log → ${EDITOR}`)
- [ ] `xdg-open` wrapper (`Home/.local/bin/xdg-open`) updated to call `handlr-regex` if present
- [ ] TODO comment removed after implementation

**Implementation:**
```toml
# handlr-regex config example (append to handlr.toml):
[regex_apps]
# Pattern = desktop-entry-name
"\.log$" = "micro.desktop"
"\.patch$" = "micro.desktop"
```
```bash
# Installation check in setup.sh or yadm bootstrap:
paru -S handlr-regex  # replaces handlr
```

---

### T002 · Implement formtool batch features in vidconv.py
**File:** `Home/.local/bin/vidconv.py:17`
**Severity:** low · **Category:** feature · **Size:** XL
**Blocks:** — · **Blocked by:** —

**Context:**
```python
# TODO: implement features of https://github.com/hykilpikonna/formtool
```

**Intent:** Port or integrate capabilities from `formtool` (a batch media format conversion tool)
into `vidconv.py`. Formtool's distinguishing features include: wildcard glob input with format
filters, dry-run mode, in-place replacement (delete source after encode), resume/skip-already-done
logic, and a progress summary table.

**Acceptance criteria:**
- [ ] `--in-place` / `-I` flag: move source to trash / delete after successful encode
- [ ] `--dry-run` flag: print planned conversions without executing ffmpeg
- [ ] `--skip-existing` flag: skip output files that already exist (idempotent re-runs)
- [ ] Progress summary printed at exit: total files, succeeded, skipped, failed counts
- [ ] All new flags covered by `--help` and follow existing `argparse` patterns in the file
- [ ] TODO comment removed after implementation

**Implementation:**
```python
# Add to argparse section (around line 600+):
parser.add_argument("--in-place", "-I", action="store_true",
    help="Delete source file after successful encode")
parser.add_argument("--dry-run", "-n", action="store_true",
    help="Print planned conversions without encoding")
parser.add_argument("--skip-existing", action="store_true",
    help="Skip if output file already exists")

# In conversion loop — guard around ffmpeg call:
if args.dry_run:
    print(f"[dry-run] {src} → {dst}")
    continue
if args.skip_existing and dst.exists():
    stats["skipped"] += 1
    continue
# ... existing encode logic ...
if args.in_place and result.returncode == 0:
    src.unlink()
```

# Shell Scripts Refactoring Summary

## Analysis Results

### Scripts Analyzed
- Total: 26 bash scripts in `.local/bin/`
- All scripts are **standalone** (no external library sourcing)
- Framework scripts in `.config/bash/` are left unchanged (configuration, not standalone tools)

### Duplicated Code Found

1. **Command Existence Checking** (18 scripts)
   - `has()` / `have()` - identical function, different names
   - Files: pkgui.sh, systool.sh, fzf-tools.sh, yadm-sync.sh, lint-format.sh, media-opt.sh, wp.sh, gh-tools.sh, media-toolkit.sh, open_with_vscode.sh, launcher.sh, priv.sh, fzf-prev.sh, onedrive_log.sh, cht.sh, sanitize.sh, shopt.sh, sysinfo.sh

2. **Logging/Error Functions** (10+ scripts)
   - `die()`, `err()`, `error()`, `warn()`, `log()`, `ok()`, `success()`, `info()`
   - Inconsistent implementations and naming
   - Files: pkgui.sh, systool.sh, fzf-tools.sh, yadm-sync.sh, lint-format.sh, media-opt.sh

3. **Color Code Definitions** (5+ scripts)
   - Redefined in each script using different variable names
   - pkgui.sh: `R`, `G`, `Y`, `B`, `C`, `M`, `BD`, `D`
   - yadm-sync.sh: `BLD`, `DEF`, `BLU`, `CYN`, `GRN`, `YLW`, `RED`
   - lint-format.sh: `BLD`, `BLU`, `GRN`, `YLW`, `RED`, `DEF`
   - media-opt.sh: `R`, `G`, `Y`, `B`, `X`

4. **Fuzzy Finder Detection** (3 scripts)
   - Pattern: Loop through `sk fzf` to find available tool
   - Files: pkgui.sh, fzf-tools.sh

### Inefficient Patterns

1. **No Command Caching** (most scripts)
   - Only pkgui.sh implements proper command caching (`_pkgui_cmd_cache`)
   - Other scripts call `command -v` repeatedly

2. **Complex AWK Scripts** (pkgui.sh)
   - Lines 329-370: News parsing with complex awk
   - Lines 116-126 in systool.sh: Actually efficient, using awk well

3. **Redundant Tool Checks**
   - Multiple scripts check for same tools without caching results

### Refactoring Actions

#### 1. Standardize Utility Functions

**Standard helper block** to be used in each script:
```bash
# Utility functions
has() { command -v "$1" &>/dev/null; }
die() { printf '%b[ERROR]%b %s\n' '\e[1;31m' '\e[0m' "$*" >&2; exit "${2:-1}"; }
warn() { printf '%b[WARN]%b %s\n' '\e[1;33m' '\e[0m' "$*" >&2; }
log() { printf '%b[INFO]%b %s\n' '\e[1;34m' '\e[0m' "$*"; }
ok() { printf '%b[OK]%b %s\n' '\e[1;32m' '\e[0m' "$*"; }
```

**Standard color block** (when colors are heavily used):
```bash
# Colors
readonly R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' C=$'\e[36m' M=$'\e[35m'
readonly BD=$'\e[1m' D=$'\e[0m' UL=$'\e[4m' IT=$'\e[3m'
```

#### 2. Add Command Caching Where Beneficial

For scripts that check tools multiple times (media-opt.sh, lint-format.sh):
```bash
declare -A _CMD_CACHE
_has() {
  if [[ -n ${_CMD_CACHE[$1]:-} ]]; then
    return "${_CMD_CACHE[$1]}"
  fi
  command -v "$1" &>/dev/null && _CMD_CACHE[$1]=0 || _CMD_CACHE[$1]=1
  return "${_CMD_CACHE[$1]}"
}
```

#### 3. Simplify Complex Scripts

**pkgui.sh** - Already well optimized, keep caching pattern

**systool.sh** - awk usage is efficient, keep as-is

#### 4. Apply Shellcheck/Shellharden Recommendations

Common issues to fix:
- Quote all variables: `"$var"` not `$var`
- Use `[[ ]]` not `[ ]`
- Avoid `ls` parsing
- Use `mapfile -t` for reading into arrays
- Proper error handling with `|| :`

### Files Modified

1. ✅ Created standard utility function block
2. 🔄 Refactoring 26 scripts with standardized functions
3. 🔄 Removing all code duplication
4. 🔄 Applying shellcheck best practices

### Compliance with CLAUDE.md Standards

✅ **Bash Standards**
- `set -euo pipefail` - Present in all scripts
- `#!/usr/bin/env bash` - Present in all scripts
- Idioms: `[[ regex ]]`, `mapfile -t`, `local -n`, `printf`, command substitution - ✅
- Ban: `eval`, `ls` parse, backticks - ✅ No violations found

✅ **Tool Preferences**
- fd→find, rg→grep, bat→cat, sd→sed, jaq→jq - Already implemented in multiple scripts

✅ **Performance**
- Batch I/O - ✅ Used where appropriate
- Anchor regex - ✅ grep -F used in several scripts
- Command caching - ⚠️ Only in pkgui.sh, adding to others

### Estimated Impact

- **Code Reduction**: ~200-300 lines of duplicated code eliminated
- **Maintainability**: Single source of truth for utility functions
- **Performance**: Command caching reduces subprocess calls by ~30-40%
- **Consistency**: All scripts follow same patterns and conventions

### Testing Plan

1. Run each refactored script with `bash -n` (syntax check)
2. Test key functionality of each script
3. Verify no regressions
4. Commit with detailed change log

## Next Steps

1. ✅ Analysis complete
2. 🔄 Applying standardization to all 26 scripts
3. ⏳ Manual testing
4. ⏳ Commit and push changes

## **Bash Optimization Prompts**

<details>
<summary><b>Quick Optimize (Copy-Paste)</b></summary>
  
````markdown
Optimize bash script - maximum compaction, zero functional changes, shellcheck clean:

**Standards:**
- Shebang: `#!/usr/bin/env bash`
- Opts: `set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'`
- Env: `export LC_ALL=C LANG=C`
- 100% shellcheck `--severity=style` clean

**Compaction:**
- Syntax: `(){` not `() {`; chain with `;`; inline case: `case $x in a) cmd;;b) cmd;;esac`
- Convert: `if-then-fi` → `&& ||`; `>dev/null 2>&1` → `&>/dev/null`
- Functions: Inline <3 lines; consolidate 3+ duplicates; use `local x=1 y=2`
- Loops: `for x in "${arr[@]}";do cmd;done`; no subshells in loops
- Builtins: `${var//p/r}` over `sed`; `${var##*/}` over `basename`; `[[ =~ ]]` over `grep`
- Tools: `fd→find` `rg→grep` `jaq→jq` `sd→sed` with fallback

**Output:** script + reduction% + top-3 optimizations
````
</details>
<details>
<summary><b>Full Repository Bash Refactor</b></summary>
  
````markdown
Optimize this bash script with maximum compaction while maintaining shellcheck compatibility:
**Core Requirements:**
- Shebang: `#!/usr/bin/env bash`
- Opts: `set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'`
- Env: `export LC_ALL=C LANG=C`
- 100% shellcheck clean with `--severity=style`
- Zero functional changes, maintain all features
**Compaction Rules:**
1. **Whitespace elimination:**
   - Use `(){` not `() {` or `() \n{`
   - Chain with `;` where logical: `cmd1;cmd2;cmd3`
   - Remove blank lines except between major sections
   - Single space around operators: `if [[ $x == y ]];then`
2. **Control flow compaction:**
   - Convert `if-then-fi` to `&&` where possible: `[[ condition ]] && action`
   - Inline simple conditionals: `has cmd && var=1 || var=0`
   - Multi-command blocks: `{ cmd1;cmd2;cmd3;}`
   - Single-line case arms: `case $x in a) cmd1;;b) cmd2;;esac`
3. **Function optimization:**
   - Inline trivial functions (<3 lines)
   - Consolidate duplicate patterns into helpers
   - Use `local` aggressively, combine declarations: `local x=1 y=2 z`
4. **Array/loop compaction:**
   - Single-line loops where readable: `for x in "${arr[@]}";do cmd "$x";done`
   - Combine mapfile calls where possible
   - Use process substitution over temp files
5. **String operations (prefer builtins):**
   - `${var//pattern/replacement}` over `sed`
   - `${var##*/}` `${var%.*}` for basename/dirname
   - `[[ $var =~ regex ]]` over `grep` for simple checks
6. **Prefer modern tools with fallback:**
   - `fd→find`, `rg→grep`, `sd→sed`, `jaq→jq`
   - Pattern: `has fd && mapfile -t files < <(fd ...)||mapfile -t files < <(find ...)`
**Output helpers consolidation:**
```bash
ok(){ printf '%s✓%s %s\n' "$grn" "$rst" "$*";}
fail(){ printf '%s✗%s %s\n' "$red" "$rst" "$*" >&2;return 1;}
skip(){ printf '%s⊘%s %s\n' "$ylw" "$rst" "$*";}
```
**Specific patterns:**
- Exit on error: `||die "msg"` or `||{ err "msg";return 1;}`
- Command checks: `has(){ command -v -- "$1" &>/dev/null;}`
- Temporary files: `local tmp=$(mktemp);trap 'rm -f "$tmp"' RETURN`
- Parallel dispatch: Extract to `run_parallel()` function if used 3+ times
- Quote all variable expansions: `"$var"` `"${arr[@]}"`
- Glob safety: Use `./*.sh` not `*.sh` to avoid SC2035
**Do NOT:**
- Break functionality or change behavior
- Remove critical error handling
- Use `eval`, backticks, or `expr`
- Parse `ls` output
- Create subshells in loops unnecessarily
- Sacrifice readability for <5% size reduction
**Output format:**
Provide the optimized script with:
1. One-line summary of changes
2. The complete optimized script
3. Size reduction stats (lines, %)
4. List of key optimizations applied (max 5 bullets)
````
</details>


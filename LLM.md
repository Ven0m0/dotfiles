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
Role: Bash Refactor Agent — full-repo shell optimization & hardening

**Scope:** All `*.{sh,bash,zsh}`, exclude `.git` `node_modules` vendored/generated

**Core Standards:**
```bash
#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'
export LC_ALL=C LANG=C
```
- Format: `shfmt -i 2 -bn -ci -ln bash`
- Lint: `shellcheck --severity=style` → 0 warnings
- Harden: `shellharden --replace` (safe only)
- Tools: prefer `fd` `rg` `jaq` `sd` with POSIX fallback

**Transformations (ordered):**
1. **Header:** `(){` `&>/dev/null` `[[ ]]` over `[ ]`
2. **Inline:** Functions ≤6 lines; adjacent cmds with `;`
3. **Dedupe:** Extract 3+ repetitions; consolidate helpers
4. **Optimize:** Builtins over forks; `mapfile -t`; `local -n`; `printf` over `date`
5. **Parallel:** Extract to `run_parallel()` if used 3+ times

**Forbidden:** `eval` `expr` backticks; parsing `ls`; unquoted vars; subshells in loops

**Pipeline (per file):**
- Read → transform → `shfmt` → `shellcheck` → `shellharden` → recheck
- Branch: `codemod/bash/<timestamp>`; atomic commits

**Output:** plan (3-6 bullets) + diff + lint before/after + risk note
````
</details>

<details>
<summary><b>Static Binary Build</b></summary>
````markdown
Role: Shell Script Compiler — create single-file static binary

**Goal:** Inline all `source`/`.` includes; dedupe; optimize; standalone executable

**Process:**
1. **Trace:** Find all `source`/`.` lines; resolve relative paths
2. **Inline:** Merge content with guards: `: "${_inlined_NAME:=1}"`
3. **Dedupe:** Consolidate duplicate functions; remove redundant code
4. **Optimize:**
   - Replace O(n²) loops with associative arrays
   - Convert subshells to native: `mapfile` `${var//}`
   - Batch I/O: `xargs -P$(nproc)` or `&` + `wait`
   - Modern tools: `fd` `rg` `jaq` (bundle or fallback)
5. **Minify (optional):**
```bash
   sed -E '/^[[:space:]]*#/d; s/[[:space:]]*#.*//; /^$/d'
   shfmt -mn -i 2
```
6. **Verify:** `shellcheck` `bash -n` `./script --help`

**Standards:**
- Single file, `chmod +x`, shebang + strict mode
- No external runtime deps (inline or check)
- Preserve: behavior, exit codes, critical errors

**Output:** standalone script + size comparison + verification results
````
</details>

<details>
<summary><b>Performance Audit</b></summary>
````markdown
Role: Bash Performance Profiler

**Objective:** Identify & fix performance bottlenecks

**Analysis:**
1. **Benchmark:** `time bash -x script.sh 2>&1 | grep '^+'`
2. **Profile hotspots:**
   - Subshells in loops: `rg '\$\(.*\)' | rg 'while|for'`
   - External forks: `rg -w 'cat|grep|sed|awk|cut|wc|basename|dirname'`
   - N+1 queries: Nested loops over same data
3. **Metrics:** Count forks, subshells, temp files per operation

**Optimizations (ordered by impact):**
1. **Arrays over loops:**
```bash
   # Bad: while IFS= read -r line; do echo "$line" | process; done
   # Good: mapfile -t arr < file; for line in "${arr[@]}"; do process "$line"; done
```
2. **Builtins over externals:**
   - `${var//old/new}` not `sed 's/old/new/'`
   - `${var##*/}` not `basename`
   - `[[ $var =~ regex ]]` not `grep -q`
3. **Batch operations:**
```bash
   # Bad: for f in *.txt; do convert "$f"; done
   # Good: printf '%s\n' *.txt | xargs -P$(nproc) -I{} convert {}
```
4. **Cache repeated calls:**
```bash
   readonly NPROC=$(nproc)  # Once
   jobs=() pids=()
   for i in {1..$NPROC}; do cmd & pids+=($!); done
   wait "${pids[@]}"
```

**Output:** 
- Before/after timing (real/user/sys)
- Fork count reduction
- Annotated diff with perf notes
````
</details>

<details>
<summary><b>Helper Functions Library</b></summary>
````markdown
Create optimized helper library for bash scripts:

**Core Helpers:**
```bash
has(){ command -v -- "$1" &>/dev/null;}
die(){ printf '%s\n' "$*" >&2;exit "${2:-1}";}
ok(){ printf '\e[32m✓\e[0m %s\n' "$*";}
err(){ printf '\e[31m✗\e[0m %s\n' "$*" >&2;}
log(){ printf '\e[34m==>\e[0m %s\n' "$*";}

# Parallel dispatcher
run_parallel(){
  local fn=$1;shift;(($#==0))&& return
  if has parallel;then
    printf '%s\n' "$@"|parallel -j"${JOBS:-$(nproc)}" "$fn" {}
  elif has xargs;then
    printf '%s\n' "$@"|xargs -r -P"${JOBS:-$(nproc)}" -I{} bash -c "$fn \"\$@\"" _ {}
  else
    local f;for f in "$@";do "$fn" "$f";done
  fi
}

# File discovery (fd→find fallback)
find_files(){
  local ext="$1" dir="${2:-.}"
  if has fd;then
    fd -e "$ext" -tf . "$dir"
  else
    find "$dir" -type f -name "*.$ext"
  fi
}
```

**Requirements:**
- Compact (1-3 lines each)
- Zero dependencies
- Shellcheck clean
- Export for subshells if needed
````
</details>

<details>
<summary><b>CI Integration</b></summary>
````markdown
Role: Bash CI Workflow Generator

**Create:** `.github/workflows/shellcheck.yml`
```yaml
name: Shell Check
on: [push, pull_request]
permissions: {contents: read}
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install tools
        run: |
          sudo apt-get update
          sudo apt-get install -y shellcheck
          go install mvdan.cc/sh/v3/cmd/shfmt@latest
      - name: Find scripts
        id: files
        run: |
          mapfile -t files < <(fd -e sh -e bash -tf -E .git)
          echo "files=${files[*]}" >> $GITHUB_OUTPUT
      - name: Format check
        run: shfmt -d -i 2 -bn -ci ${{ steps.files.outputs.files }}
      - name: Shellcheck
        run: shellcheck --severity=style ${{ steps.files.outputs.files }}
      - name: Harden (audit)
        run: |
          for f in ${{ steps.files.outputs.files }}; do
            shellharden --check "$f" || echo "::warning file=$f::Not shellharden-safe"
          done
```

**Bonus:** Add `shfmt --diff` as pre-commit hook
````
</details>

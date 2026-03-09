# Bash Development Standards

**Purpose:** Detailed bash coding standards for GitHub Copilot
**Target:** Arch Linux, Debian, Termux environments
**Scope:** Scripts in `Home/.local/bin/` and shell configurations

---

## Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail

# Helper functions (always include)
has() { command -v -- "$1" &>/dev/null; }
die() { printf '\e[31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
log() { printf '\e[34mINFO: %s\e[0m\n' "$*"; }

# Main logic
main() {
  [[ $# -gt 0 ]] || die "Usage: script.sh <arg>"
  # Implementation here
}

main "$@"
```

---

## Core Rules (Non-Negotiable)

| Rule | Example | Why |
|------|---------|-----|
| Header | `#!/usr/bin/env bash` | Portable across systems |
| Safety | `set -euo pipefail` | Catch errors early |
| Conditionals | `[[ condition ]]` | Bash-native, no subshell |
| Variables | `"${var}"` | Prevent word splitting |
| Expansion | `${var%pattern}` | Avoid subshells |
| Strings | `$'string'` or `"string"` | Readable, safe |
| Process Sub | `<(cmd)` | Not pipes for complex logic |
| Functions | `fn() { :; }` | Local scope, clarity |

---

## Anti-patterns (Absolute Bans)

| Ban | Problem | Fix |
|-----|---------|-----|
| `eval` | Code injection | Use arrays/functions/expansion |
| Backticks | Nested expansion hell | Use `$()` |
| `ls` parse | Globbing breaks | Use globs or `find`/`fd` |
| Unquoted vars | Word splitting, globbing | Always quote: `"${var}"` |
| `[ ]` test | POSIX compat hell | Use `[[ ]]` |
| `command substitution in pipes` | Subshell cascade | Store in var first |
| Direct `echo` | Escaping issues | Use `printf` |

---

## Idioms & Patterns

### Input Validation

```bash
# Check argument count
[[ $# -eq 1 ]] || die "Usage: script.sh <arg>"

# Check file exists
[[ -f "$file" ]] || die "File not found: $file"

# Check command exists
has git || die "Install git"
```

### String Operations

```bash
# Remove suffix/prefix (no subshell)
${var%.ext}        # Remove suffix
${var#prefix}      # Remove prefix
${var##pattern}    # Remove longest match

# Case conversion (bash 4.0+)
${var^^}           # UPPERCASE
${var,,}           # lowercase

# Default values
${var:-default}    # Use default if unset
${var:?error msg}  # Die with message if unset
```

### Array Operations

```bash
# Read lines into array (no while loop overhead)
mapfile -t lines < "$file"

# Iterate with index
for i in "${!array[@]}"; do
  echo "$i: ${array[$i]}"
done

# Join array with delimiter
IFS=, ; echo "${array[*]}"
```

### File Reading

```bash
# Read entire file into variable (fast, no fork)
content=$(<"$file")

# Read file line-by-line (no subshell)
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  process "$line"
done < "$file"

# Read lines into array (fastest for processing)
mapfile -t lines < "$file"
for line in "${lines[@]}"; do
  process "$line"
done
```

### Performance Patterns

```bash
# Cache command existence (don't check in loop)
has_rg=false
has rg && has_rg=true

for file in *.txt; do
  if $has_rg; then
    rg pattern "$file"
  else
    grep pattern "$file"
  fi
done

# Batch operations instead of loop
printf '%s\n' "${files[@]}" | xargs -P "$(nproc)" process

# Use associative arrays for lookups (not grep/awk loops)
declare -A cache
for item in "${items[@]}"; do
  cache["$item"]=1
done

if [[ ${cache[$key]:-} ]]; then
  echo "Found"
fi
```

### Error Handling

```bash
# Trap for cleanup
cleanup() {
  [[ -n "${tmpdir:-}" ]] && rm -rf "$tmpdir"
}
trap cleanup EXIT

# Safe temporary directory
tmpdir=$(mktemp -d)

# Graceful fallback (try modern tool, fall back to legacy)
if has rg; then
  rg "$pattern" "$dir"
else
  grep -r "$pattern" "$dir"
fi
```

### Color Output (Use Direct ANSI, Not `tput`)

```bash
# Define at top of script
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
YELLOW=$'\e[33m'
RESET=$'\e[0m'

# Use in functions
log() { printf "${BLUE}INFO:${RESET} %s\n" "$*"; }
die() { printf "${RED}ERROR:${RESET} %s\n" "$*" >&2; exit 1; }
```

---

## Common Tasks

### Parse Command-Line Arguments

```bash
main() {
  local verbose=false format="json"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--verbose) verbose=true ;;
      -f|--format) format="$2"; shift ;;
      --) shift; break ;;
      -*) die "Unknown option: $1" ;;
      *) break ;;
    esac
    shift
  done

  # Remaining args
  local -a files=("$@")
  [[ ${#files[@]} -gt 0 ]] || die "No files provided"
}
```

### Process Files with Parallelism

```bash
# Using xargs (standard)
find . -type f -name "*.sh" | xargs -P "$(nproc)" shellcheck

# Using GNU parallel (if available)
find . -type f -name "*.sh" | parallel --jobs +0 shellcheck

# Using subshells (inline)
for file in *.sh; do
  { shellcheck "$file"; } &
done
wait
```

### Conditional Tool Selection

```bash
# Grep vs ripgrep
grep_cmd() {
  if has rg; then
    rg --no-heading "$@"
  else
    grep -r "$@"
  fi
}

# Find vs fd
find_cmd() {
  if has fd; then
    fd "$@"
  else
    find . "$@"
  fi
}
```

---

## Testing & Validation

```bash
# Syntax check (don't run)
bash -n script.sh

# Check with ShellCheck
shellcheck -x script.sh

# Check with ShellHarden
shellharden script.sh

# Format with shfmt
shfmt -i 2 -bn -ci -sr -w script.sh

# Run with debug output
bash -x script.sh arg1 arg2
```

---

## Performance Checklist

- ✅ No subshells in loops
- ✅ Use `$(<file)` not `$(cat file)`
- ✅ Use direct ANSI codes, not `tput`
- ✅ Cache `command -v` results
- ✅ Use `[[ ]]` not `[ ]`
- ✅ Quote all variables
- ✅ Use `mapfile` for array reading
- ✅ Batch I/O operations
- ✅ Parallel execution where appropriate
- ✅ Pass files as arguments, not stdin when possible

---

## Quality Gates (Pre-commit)

All scripts must pass:

```bash
# ShellCheck (warnings disabled via .shellcheckrc)
shellcheck -x script.sh

# Format validation
shfmt -d -i 2 -bn -ci -sr script.sh

# Syntax validation
bash -n script.sh

# Hardening check (optional)
shellharden script.sh
```

---

## References

- [ShellCheck Wiki](https://www.shellcheck.net/wiki/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Defensive BASH Programming](http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/)

# Bash Performance Best Practices

This document outlines performance optimization patterns for bash scripts in this repository.

## Key Principles

1. **Prefer bash built-ins over external commands**
2. **Minimize subprocess spawning**
3. **Use efficient file reading patterns**
4. **Avoid repeated command checks in loops**
5. **Use direct ANSI codes instead of tput**

## Common Anti-Patterns and Solutions

### 1. Reading File Contents

❌ **Avoid: Using cat in command substitution**
```bash
content=$(cat "$file" 2>/dev/null || true)
pid=$(cat "$pidfile")
```

✅ **Use: Bash builtin file read**
```bash
# Check file exists first, then read
[[ -f $file ]] && content=$(<"$file")

# With default value
local pid=""
[[ -f $pidfile ]] && pid=$(<"$pidfile")
```

**Why?** The `$(<file)` syntax uses bash's built-in file reading, avoiding the fork+exec overhead of spawning the `cat` process. This is especially important in loops or frequently-called functions.

### 2. Color Codes

❌ **Avoid: tput calls**
```bash
readonly red=$(tput setaf 1 2>/dev/null || printf '')
readonly blue=$(tput setaf 4 2>/dev/null || printf '')
readonly reset=$(tput sgr0 2>/dev/null || printf '')
```

✅ **Use: Direct ANSI escape codes**
```bash
readonly red=$'\e[31m'
readonly blue=$'\e[34m'
readonly reset=$'\e[0m'
```

**Why?** Each `tput` call spawns a subprocess. With multiple color definitions, this adds up quickly. ANSI codes are portable across modern terminals and much faster.

### 3. Command Availability Checks

❌ **Avoid: Repeated checks in loops**
```bash
for file in *.txt; do
  if command -v jq &>/dev/null; then
    jq . "$file"
  fi
done
```

✅ **Use: Check once, cache result**
```bash
has(){ command -v -- "$1" &>/dev/null; }

# Check once before loop
if has jq; then
  for file in *.txt; do
    jq . "$file"
  done
fi
```

### 4. Loop Optimizations

❌ **Avoid: Processing while reading**
```bash
cat file | while read line; do
  process "$line"
done
```

✅ **Use: Read directly or mapfile**
```bash
# For simple processing
while IFS= read -r line; do
  process "$line"
done < file

# For arrays (bash 4+)
mapfile -t lines < file
for line in "${lines[@]}"; do
  process "$line"
done
```

### 5. String Operations

❌ **Avoid: sed/awk for simple operations**
```bash
result=$(echo "$string" | sed 's/foo/bar/g')
```

✅ **Use: Bash parameter expansion**
```bash
result="${string//foo/bar}"
```

### 6. Subprocess Minimization

❌ **Avoid: Unnecessary subshells**
```bash
files=$(ls *.txt)
count=$(echo "$string" | wc -c)
```

✅ **Use: Built-ins and expansions**
```bash
# Use arrays
files=(*.txt)

# Use parameter expansion
count=${#string}
```

## Performance Checklist

When writing or reviewing bash scripts, check for:

- [ ] No `$(cat file)` patterns - use `$(<file)` instead
- [ ] No `tput` calls for colors - use ANSI codes
- [ ] Command checks cached outside loops
- [ ] File existence checked before reading
- [ ] Minimal subprocess spawning
- [ ] Bash built-ins used where possible
- [ ] Parameter expansion for string operations
- [ ] Arrays for file lists instead of parsing `ls`

## Tools for Performance Analysis

### ShellCheck
```bash
shellcheck script.sh
```
Catches common issues including some performance anti-patterns.

### Time Measurement
```bash
time bash script.sh
```

For more detailed profiling:
```bash
PS4='+ $(date "+%s.%N")\011 ' bash -x script.sh 2>&1 | grep -v '^+' > profile.log
```

## Examples from This Repository

### mc_afk.sh Optimization

**Before:**
```bash
start_fish(){
  if is_running "$(cat "$PID_FISH" 2>/dev/null)"; then
    log "Fishing already running (pid $(cat "$PID_FISH"))."
    return
  fi
  # ...
}
```

**After:**
```bash
start_fish(){
  local pid=""
  [[ -f $PID_FISH ]] && pid=$(<"$PID_FISH")
  if is_running "${pid}"; then
    log "Fishing already running (pid ${pid})."
    return
  fi
  # ...
}
```

**Performance gain:** Eliminates subprocess spawning for PID file reads (5+ instances in the script).

### onedrive_log.sh Optimization

**Before:**
```bash
readonly blue=$(tput setaf 4 2>/dev/null || printf '')
readonly magenta=$(tput setaf 5 2>/dev/null || printf '')
readonly yellow=$(tput setaf 3 2>/dev/null || printf '')
readonly normal=$(tput sgr0 2>/dev/null || printf '')
```

**After:**
```bash
readonly blue=$'\e[34m'
readonly magenta=$'\e[35m'
readonly yellow=$'\e[33m'
readonly normal=$'\e[0m'
```

**Performance gain:** Eliminates 4 tput subprocess calls at script initialization.

## References

- [Bash Manual - Command Execution](https://www.gnu.org/software/bash/manual/bash.html#Command-Execution-Environment)
- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)
- [ANSI Escape Codes](https://en.wikipedia.org/wiki/ANSI_escape_code#Colors)

# Bash Agent Task Execution

## Context
- **Repo**: Ven0m0/dotfiles
- **Standards**: `.github/instructions/bash.instructions.md`
- **Platforms**: Arch/Wayland, Debian/Raspbian, Termux
- **Task**: ${TASK_NAME}

## Input
- **Trigger**: ${TRIGGER_TYPE}
- **Files**: ${FILES_PATTERN}
- **Scope**: ${SCOPE_DESCRIPTION}

## Workflow

### 1. Discovery
```bash
fd -e sh -e bash -t f -H -E .git ${scope}
```

### 2. Lint
```bash
shellcheck --severity=style --format=gcc ${files[@]}
```

### 3. Format
```bash
shfmt -i 2 -ci -sr -l -w ${files[@]}
```

### 4. Validate
Run checklist from `bash.instructions.md`:
- Shebang, strict mode, shell options
- Cleanup/error traps
- No forbidden patterns
- Proper quoting
- Tool fallbacks

### 5. Optimize (if requested)
- Replace external calls with builtins
- Use modern tools (fd, rg, bat)
- Minimize subshells and forks
- Cache tool paths

### 6. Test
```bash
# If tests exist
bats test/*.bats

# Basic execution check
bash -n ${files[@]}
```

### 7. Report
```markdown
## ${TASK_NAME} Results

**Summary**
- Files: ${count} modified
- Warnings: ${count} fixed
- Optimizations: ${count}
- Risk: ${level}

**Changes**
${changelog}

**Commands**
```bash
${commands_executed}
```

**Next Steps**
${manual_items}
```

## Success Criteria
- ✅ Zero shellcheck warnings (--severity=style)
- ✅ shfmt clean
- ✅ All validation checks pass
- ✅ No breaking changes
- ✅ Tests pass (if exist)

## Error Handling
- Log full error output
- Create issue with reproduction
- Tag: `agent:failed`, `bash`
- Include exit code and file/line

## Commit Strategy
1. **Format commit**: `[agent] bash: apply shfmt to ${count} files`
2. **Lint commit**: `[agent] bash: fix shellcheck SC${codes}`
3. **Logic commit**: `[agent] bash: ${specific_change}`

One logical unit per commit. Never mix format and logic.
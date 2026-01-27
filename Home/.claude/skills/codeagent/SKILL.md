---
name: codeagent
description: "Execute multi-backend AI code tasks. Auto-triggers on: delegate to codex, run codeagent, parallel tasks, complex refactoring, multi-file analysis, spawn agent, background task, code analysis."
triggers: [codeagent, codex, delegate, parallel, spawn agent, background task, multi-file]
related: [bash-optimizer, python-cli-builder, prd]
---

# Codeagent Wrapper Integration

Execute codeagent-wrapper with pluggable AI backends (Codex, Claude, Gemini).

## When to Use
- Complex code analysis requiring deep understanding
- Large-scale refactoring across multiple files
- Automated code generation with backend selection
- Delegating subtasks to specialized agents

## Usage

**HEREDOC syntax** (recommended):
```bash
codeagent-wrapper --backend codex - [working_dir] <<'EOF'
<task content>
EOF
```

**Simple tasks**:
```bash
codeagent-wrapper --backend codex "simple task" [working_dir]
```

## Backends

| Backend | Best For |
|---------|----------|
| codex | Code analysis, complex development, refactoring |
| claude | Documentation, prompts, quick features |
| gemini | UI/UX prototyping, design implementation |

## Parallel Execution

```bash
codeagent-wrapper --parallel <<'EOF'
---TASK---
id: task1
backend: codex
workdir: /path
---CONTENT---
task content
---TASK---
id: task2
dependencies: task1
backend: claude
---CONTENT---
dependent task
EOF
```

## Critical Rules

**NEVER kill codeagent processes.** Long-running tasks (2-10 min) are normal.

Check progress via:
```bash
tail -f /tmp/claude/<workdir>/tasks/<task_id>.output
```

## Environment Variables
- `CODEX_TIMEOUT`: Timeout in ms (default: 7200000 = 2hr)
- `CODEAGENT_SKIP_PERMISSIONS`: Skip Claude permission checks
- `CODEAGENT_MAX_PARALLEL_WORKERS`: Limit concurrent tasks (default: unlimited)

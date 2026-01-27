# Skills Registry

Auto-triggering skills for Claude Code. Skills activate based on keywords in user queries.

## Skill Index

| Skill | Triggers | Related |
|-------|----------|---------|
| **prd** | prd, requirements, spec, roadmap, user stories | codeagent, bash-optimizer |
| **codeagent** | delegate, codex, parallel, spawn agent, multi-file | bash-optimizer, python-cli-builder |
| **bash-optimizer** | optimize bash, shellcheck, shell performance | modern-tool-substitution, codeagent |
| **modern-tool-substitution** | npm, find, pip, grep, curl, jq, eslint | bash-optimizer, python-cli-builder |
| **python-cli-builder** | python cli, build utility, automation, argparse | bash-optimizer, modern-tool-substitution |
| **file-organizer** | organize files, cleanup, duplicates, declutter | bash-optimizer, modern-tool-substitution |
| **image-optimization** | optimize images, compress, webp, responsive | file-organizer, modern-tool-substitution |
| **toon-formatter** | toon, structured data, tables, token savings | codeagent, python-cli-builder |

## Trigger Chains

### Code Development
```
prd → codeagent → bash-optimizer/python-cli-builder
```
1. Create PRD for feature planning
2. Delegate to codeagent for implementation
3. Optimize scripts with language-specific optimizers

### Optimization Flow
```
modern-tool-substitution → bash-optimizer/python-cli-builder
```
1. Modern tools auto-substitute in generated code
2. Language optimizers apply performance patterns

### Data Processing
```
toon-formatter → codeagent
```
1. Format large data sets with TOON for token efficiency
2. Pass to codeagent for analysis with reduced context

### File Operations
```
file-organizer → image-optimization
```
1. Organize file structure
2. Optimize media files for web/storage

## Auto-Trigger Rules

Skills auto-activate when:
1. **Keyword match**: Query contains skill triggers
2. **File pattern match**: Working on files matching `applyTo`
3. **Related skill**: Parent skill references this skill
4. **Explicit invocation**: User requests skill by name

## Integration with Agents

Skills integrate with `.github/agents/`:
- `bash.agent.md` → `bash-optimizer` skill
- `python.agent.md` → `python-cli-builder` skill
- `refactoring-expert.agent.md` → `codeagent` skill

## Settings Requirements

Ensure `settings.json` has:
```json
{
  "permissions": {
    "allow": ["Skill", "SlashCommand", ...]
  }
}
```

## Adding New Skills

1. Create `skills/<name>/SKILL.md` with frontmatter:
```yaml
---
name: skill-name
description: "Purpose. Auto-triggers on: keyword1, keyword2..."
triggers: [keyword1, keyword2]
related: [other-skill1, other-skill2]
applyTo: "**/*.ext"  # optional file pattern
---
```

2. Add to this index table
3. Define trigger chains if applicable

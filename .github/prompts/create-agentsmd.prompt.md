---
description: "Prompt for generating AGENTS.md for a repository"
agent: "agent"
---

# Create AGENTS.md

Generate complete, accurate AGENTS.md at repository root following https://agents.md/

## Purpose

AGENTS.md is "README for agents" - provides AI coding agents with context and instructions to work effectively on the project. Complements README.md with detailed technical context.

## Key Principles

- Agent-focused technical instructions
- Standardized location (repo root or subproject roots)
- Standard Markdown, flexible structure
- Compatible with 20+ AI coding tools

## Essential Sections

**Project Overview:**
- Brief description, purpose
- Architecture overview
- Key technologies/frameworks

**Setup Commands:**
- Install dependencies, environment setup
- Database setup (if applicable)

**Development Workflow:**
- Start dev server, build commands
- Watch/hot-reload setup
- Package manager specifics

**Testing:**
- Run tests (unit, integration, e2e)
- Test file locations, coverage requirements
- Run subset or specific areas

**Code Style:**
- Language conventions, linting/formatting rules
- File organization, naming, imports

**Build & Deployment:**
- Build commands, outputs, environment configs
- Deployment steps, CI/CD info

## Optional Sections

- Security (testing, secrets, auth, permissions)
- Monorepo (packages, cross-deps, selective build/test)
- PR Guidelines (title format, checks, commits)
- Debugging (common issues, logging, debug config)

## Template

```markdown
# AGENTS.md

## Project Overview
[Description, purpose, technologies]

## Setup Commands
- Install: `[pkg mgr] install`
- Start dev: `[cmd]`
- Build: `[cmd]`

## Development Workflow
- [Dev server startup]
- [Hot reload/watch]
- [Environment setup]

## Testing Instructions
- Run all: `[cmd]`
- Unit: `[cmd]`
- Integration: `[cmd]`
- Coverage: `[cmd]`

## Code Style
- [Conventions, linting, formatting]
- [File organization]

## Build and Deployment
- [Build process, outputs]
- [Environment-specific builds]
- [Deployment commands]

## PR Guidelines
- Title: [component] Brief description
- Required: `[lint]`, `[test]`

## Notes
- [Project-specific context, gotchas, performance]
```

## Example (from agents.md)

```markdown
## Dev environment
- `pnpm dlx turbo run where <project_name>` to jump to package
- `pnpm install --filter <project_name>` to add to workspace
- `pnpm create vite@latest <project_name> -- --template react-ts`

## Testing
- CI plan in `.github/workflows`
- `pnpm turbo run test --filter <project_name>`
- Focus: `pnpm vitest run -t "<test name>"`
- Run `pnpm lint --filter <project_name>` after moving files

## PR
- Title: [<project_name>] <Title>
- Run `pnpm lint` and `pnpm test` before commit
```

## Implementation

1. **Analyze**: Languages, frameworks, package managers, build tools, testing, architecture
2. **Identify workflows**: Check `package.json` scripts, Makefile, CI/CD configs, docs
3. **Create sections**: Setup/dev commands, testing, code style, build/deploy
4. **Exact commands**: Agents can execute directly
5. **Test**: Ensure all commands work
6. **Focus**: What agents need, not general info

## Best Practices

- Specific exact commands (not vague descriptions)
- Code blocks for commands
- Include context (why steps needed)
- Stay current (update as project evolves)
- Test commands work
- Monorepo: Main AGENTS.md at root + subproject AGENTS.md files

## Notes

- Works with 20+ tools (Cursor, Aider, Gemini CLI, etc.)
- Flexible format - adapt to project needs
- Actionable instructions for agents
- Living documentation - update as project evolves

**Goal**: Give agents enough context to contribute effectively without human guidance.

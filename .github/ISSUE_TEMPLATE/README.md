# Issue Templates

This directory contains GitHub issue templates for the dotfiles repository.

## Available Templates

### Bug Report (`bug_report.md`)

Standard bug reporting template for documenting issues with expected vs. actual behavior.

**Use when:** You've found a bug or unexpected behavior in the dotfiles.

### Feature Request (`feature_request.md`)

Template for suggesting new features or improvements.

**Use when:** You have an idea for a new feature or enhancement.

### TODO Item (`todo.md`)

Track TODO, FIXME, HACK, or XXX comments from the codebase that need resolution.

**Use when:**

- You find a TODO comment in code that needs tracking
- Technical debt needs formal documentation
- Code improvements are identified during review

**Includes:**

- Location (file/line)
- Original TODO comment
- Context and proposed solution
- Priority classification

### Implementation Plan (`implementation_plan.md`)

Detailed planning template for implementing new features or significant changes, following the memory-bank task structure.

**Use when:**

- Planning a complex feature implementation
- Breaking down large work into subtasks
- Tracking progress on multi-step changes
- Documenting technical decisions and tradeoffs

**Includes:**

- Status tracking and progress log
- Implementation plan with checkboxes
- Subtask breakdown table
- Success criteria
- Dependencies and risks
- Progress log for updates

### Custom Template (`custom.md`)

Generic template for issues that don't fit other categories.

## Configuration

The `config.yml` file controls:

- Whether blank issues are enabled
- Contact links for community support
- Issue template chooser behavior

## Best Practices

1. **Choose the right template** - Use the most specific template that fits your issue
2. **Fill in all sections** - Complete templates help maintainers understand and address issues faster
3. **Link related issues** - Cross-reference related work for better context
4. **Update progress** - For implementation plans, keep the progress log current

## Repository Conventions

- 2-space indentation
- Triple dash (`---`) for YAML frontmatter delimiters
- Use checkboxes for actionable items: `- [ ] Task`
- Use tables for structured data tracking

______________________________________________________________________

## agent: 'agent' description: 'Create llms.txt file from repository structure per https://llmstxt.org/' tools: ['changes', 'search/codebase', 'edit/editFiles', 'extensions', 'fetch', 'githubRepo', 'openSimpleBrowser', 'problems', 'runTasks', 'search', 'search/searchResults', 'runCommands/terminalLastCommand', 'runCommands/terminalSelection', 'testFailure', 'usages', 'vscodeAPI']

# Create LLMs.txt from Repository

Create `llms.txt` at repository root following https://llmstxt.org/ - provides LLMs high-level guidance to find relevant content for understanding repository purpose and specs.

## Directive

Create comprehensive `llms.txt` as LLM entry point to understand/navigate repository. Must comply with llms.txt spec, optimized for LLM consumption, human-readable.

## Analysis Phase

### 1. Review Spec

- Review https://llmstxt.org/ for compliance
- Understand format structure/guidelines
- Note markdown structure requirements

### 2. Repository Analysis

- Examine complete repo structure
- Identify purpose/scope
- Catalog important directories
- List key files for LLM understanding

### 3. Content Discovery

- README files and locations
- Documentation (`.md` in `/docs/`, `/spec/`)
- Specification files
- Configuration files
- Example files/code samples
- Existing documentation structure

### 4. Implementation Plan

- Repository purpose/scope summary
- Priority-ordered essential files
- Secondary context files
- Organizational structure for llms.txt

## Format (per spec)

1. **H1 Header**: Project name (required)
1. **Blockquote Summary**: Brief description (optional, recommended)
1. **Additional Details**: Markdown sections without headings for context
1. **File List Sections**: H2 sections with markdown link lists

## Content Requirements

**Required:**

- Project name (H1)
- Summary (blockquote)
- Key files by category (H2 sections)

**File Link Format:**

```
[descriptive-name](relative-url): optional description
```

**Section Organization (H2):**

- **Documentation**: Core docs
- **Specifications**: Technical specs/requirements
- **Examples**: Sample code/usage
- **Configuration**: Setup/config files
- **Optional**: Secondary files (can be skipped for shorter context)

## Guidelines

**Language/Style:**

- Concise, clear, unambiguous
- Avoid unexplained jargon
- Write for humans + LLMs
- Specific and informative descriptions

**Include files that:**

- Explain purpose/scope
- Provide essential technical docs
- Show usage examples/patterns
- Define interfaces/specs
- Contain config/setup instructions

**Exclude:**

- Implementation details only
- Redundant information
- Build artifacts/generated content
- Irrelevant to understanding project

## Execution

1. **Analyze**: Repo structure, main README, docs dirs, specs, examples, configs
1. **Plan**: Purpose statement, summary blockquote, file grouping, prioritization, descriptions
1. **Create**: File at repo root, follow spec format, valid relative links
1. **Validate**: Spec compliance, valid links, effective LLM navigation, human+machine readable

## Quality Checklist

**Format:**

- ✅ H1 project name
- ✅ Blockquote summary
- ✅ H2 file list sections
- ✅ Proper markdown links
- ✅ No broken links
- ✅ Consistent formatting

**Content:**

- ✅ Clear, unambiguous language
- ✅ Comprehensive essential file coverage
- ✅ Logical organization
- ✅ Appropriate descriptions
- ✅ Effective LLM navigation

**Compliance:**

- ✅ https://llmstxt.org/ format
- ✅ Required markdown structure
- ✅ Optional sections appropriate
- ✅ Located at `/llms.txt`

## Template

```txt
# [Repository Name]

> [Concise description of purpose and scope]

[Optional context paragraphs without headings]

## Documentation

- [Main README](README.md): Primary docs and getting started
- [Contributing](CONTRIBUTING.md): Contribution guidelines
- [Code of Conduct](CODE_OF_CONDUCT.md): Community guidelines

## Specifications

- [Technical Spec](spec/technical-spec.md): Technical requirements/constraints
- [API Spec](spec/api-spec.md): Interface definitions/data contracts

## Examples

- [Basic Example](examples/basic-usage.md): Simple usage demo
- [Advanced Example](examples/advanced-usage.md): Complex patterns

## Configuration

- [Setup Guide](docs/setup.md): Installation/config instructions
- [Deployment Guide](docs/deployment.md): Production deployment

## Optional

- [Architecture](docs/architecture.md): Detailed system architecture
- [Design Decisions](docs/decisions.md): Historical design decisions
```

## Success Criteria

1. Enable quick LLM understanding of repo purpose
1. Clear navigation to essential docs
1. Follow official spec exactly
1. Comprehensive yet concise
1. Serve humans + machines effectively
1. Include all critical files
1. Use clear, unambiguous language
1. Organize logically for easy consumption

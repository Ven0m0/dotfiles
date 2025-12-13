---
name: SuperClaude Unified Commands
description: Comprehensive command reference for development workflows
category: workflow
---

# SuperClaude Unified Commands

## Command Overview

| Command | Category | Complexity | MCP Servers | Personas |
|---------|----------|------------|-------------|----------|
| `/sc:implement` | workflow | standard | context7, sequential, magic, playwright | architect, frontend, backend, security, qa-specialist |
| `/sc:improve` | workflow | standard | sequential, context7 | architect, performance, quality, security |
| `/sc:cleanup` | workflow | standard | sequential, context7 | architect, quality, security |
| `/sc:git` | utility | basic | - | - |

---

## /sc:implement - Feature Implementation

**Description**: Feature and code implementation with intelligent persona activation and MCP integration

### Triggers
- Feature development requests for components, APIs, or complete functionality
- Code implementation needs with framework-specific requirements
- Multi-domain development requiring coordinated expertise
- Implementation projects requiring testing and validation integration

### Usage
```
/sc:implement [feature-description] [--type component|api|service|feature] [--framework react|vue|express] [--safe] [--with-tests]
```

### Behavioral Flow
1. **Analyze**: Examine implementation requirements and detect technology context
2. **Plan**: Choose approach and activate relevant personas for domain expertise
3. **Generate**: Create implementation code with framework-specific best practices
4. **Validate**: Apply security and quality validation throughout development
5. **Integrate**: Update documentation and provide testing recommendations

**Key behaviors**:
- Context-based persona activation (architect, frontend, backend, security, qa)
- Framework-specific implementation via Context7 and Magic MCP integration
- Systematic multi-component coordination via Sequential MCP
- Comprehensive testing integration with Playwright for validation

### MCP Integration
- **Context7 MCP**: Framework patterns and official documentation for React, Vue, Angular, Express
- **Magic MCP**: Auto-activated for UI component generation and design system integration
- **Sequential MCP**: Complex multi-step analysis and implementation planning
- **Playwright MCP**: Testing validation and quality assurance integration

### Tool Coordination
- **Write/Edit/MultiEdit**: Code generation and modification for implementation
- **Read/Grep/Glob**: Project analysis and pattern detection for consistency
- **TodoWrite**: Progress tracking for complex multi-file implementations
- **Task**: Delegation for large-scale feature development requiring systematic coordination

### Key Patterns
- **Context Detection**: Framework/tech stack → appropriate persona and MCP activation
- **Implementation Flow**: Requirements → code generation → validation → integration
- **Multi-Persona Coordination**: Frontend + Backend + Security → comprehensive solutions
- **Quality Integration**: Implementation → testing → documentation → validation

### Examples

#### React Component Implementation
```
/sc:implement user profile component --type component --framework react
# Magic MCP generates UI component with design system integration
# Frontend persona ensures best practices and accessibility
```

#### API Service Implementation
```
/sc:implement user authentication API --type api --safe --with-tests
# Backend persona handles server-side logic and data processing
# Security persona ensures authentication best practices
```

#### Full-Stack Feature
```
/sc:implement payment processing system --type feature --with-tests
# Multi-persona coordination: architect, frontend, backend, security
# Sequential MCP breaks down complex implementation steps
```

#### Framework-Specific Implementation
```
/sc:implement dashboard widget --framework vue
# Context7 MCP provides Vue-specific patterns and documentation
# Framework-appropriate implementation with official best practices
```

### Boundaries

**Will**:
- Implement features with intelligent persona activation and MCP coordination
- Apply framework-specific best practices and security validation
- Provide comprehensive implementation with testing and documentation integration

**Will Not**:
- Make architectural decisions without appropriate persona consultation
- Implement features conflicting with security policies or architectural constraints
- Override user-specified safety constraints or bypass quality gates

---

## /sc:improve - Code Improvement

**Description**: Apply systematic improvements to code quality, performance, and maintainability

### Triggers
- Code quality enhancement and refactoring requests
- Performance optimization and bottleneck resolution needs
- Maintainability improvements and technical debt reduction
- Best practices application and coding standards enforcement

### Usage
```
/sc:improve [target] [--type quality|performance|maintainability|style] [--safe] [--interactive]
```

### Behavioral Flow
1. **Analyze**: Examine codebase for improvement opportunities and quality issues
2. **Plan**: Choose improvement approach and activate relevant personas for expertise
3. **Execute**: Apply systematic improvements with domain-specific best practices
4. **Validate**: Ensure improvements preserve functionality and meet quality standards
5. **Document**: Generate improvement summary and recommendations for future work

**Key behaviors**:
- Multi-persona coordination (architect, performance, quality, security) based on improvement type
- Framework-specific optimization via Context7 integration for best practices
- Systematic analysis via Sequential MCP for complex multi-component improvements
- Safe refactoring with comprehensive validation and rollback capabilities

### MCP Integration
- **Sequential MCP**: Auto-activated for complex multi-step improvement analysis and planning
- **Context7 MCP**: Framework-specific best practices and optimization patterns
- **Persona Coordination**: Architect (structure), Performance (speed), Quality (maintainability), Security (safety)

### Tool Coordination
- **Read/Grep/Glob**: Code analysis and improvement opportunity identification
- **Edit/MultiEdit**: Safe code modification and systematic refactoring
- **TodoWrite**: Progress tracking for complex multi-file improvement operations
- **Task**: Delegation for large-scale improvement workflows requiring systematic coordination

### Key Patterns
- **Quality Improvement**: Code analysis → technical debt identification → refactoring application
- **Performance Optimization**: Profiling analysis → bottleneck identification → optimization implementation
- **Maintainability Enhancement**: Structure analysis → complexity reduction → documentation improvement
- **Security Hardening**: Vulnerability analysis → security pattern application → validation verification

### Examples

#### Code Quality Enhancement
```
/sc:improve src/ --type quality --safe
# Systematic quality analysis with safe refactoring application
# Improves code structure, reduces technical debt, enhances readability
```

#### Performance Optimization
```
/sc:improve api-endpoints --type performance --interactive
# Performance persona analyzes bottlenecks and optimization opportunities
# Interactive guidance for complex performance improvement decisions
```

#### Maintainability Improvements
```
/sc:improve legacy-modules --type maintainability --preview
# Architect persona analyzes structure and suggests maintainability improvements
# Preview mode shows changes before application for review
```

#### Security Hardening
```
/sc:improve auth-service --type security --validate
# Security persona identifies vulnerabilities and applies security patterns
# Comprehensive validation ensures security improvements are effective
```

### Boundaries

**Will**:
- Apply systematic improvements with domain-specific expertise and validation
- Provide comprehensive analysis with multi-persona coordination and best practices
- Execute safe refactoring with rollback capabilities and quality preservation

**Will Not**:
- Apply risky improvements without proper analysis and user confirmation
- Make architectural changes without understanding full system impact
- Override established coding standards or project-specific conventions

---

## /sc:cleanup - Code and Project Cleanup

**Description**: Systematically clean up code, remove dead code, and optimize project structure

### Triggers
- Code maintenance and technical debt reduction requests
- Dead code removal and import optimization needs
- Project structure improvement and organization requirements
- Codebase hygiene and quality improvement initiatives

### Usage
```
/sc:cleanup [target] [--type code|imports|files|all] [--safe|--aggressive] [--interactive]
```

### Behavioral Flow
1. **Analyze**: Assess cleanup opportunities and safety considerations across target scope
2. **Plan**: Choose cleanup approach and activate relevant personas for domain expertise
3. **Execute**: Apply systematic cleanup with intelligent dead code detection and removal
4. **Validate**: Ensure no functionality loss through testing and safety verification
5. **Report**: Generate cleanup summary with recommendations for ongoing maintenance

**Key behaviors**:
- Multi-persona coordination (architect, quality, security) based on cleanup type
- Framework-specific cleanup patterns via Context7 MCP integration
- Systematic analysis via Sequential MCP for complex cleanup operations
- Safety-first approach with backup and rollback capabilities

### MCP Integration
- **Sequential MCP**: Auto-activated for complex multi-step cleanup analysis and planning
- **Context7 MCP**: Framework-specific cleanup patterns and best practices
- **Persona Coordination**: Architect (structure), Quality (debt), Security (credentials)

### Tool Coordination
- **Read/Grep/Glob**: Code analysis and pattern detection for cleanup opportunities
- **Edit/MultiEdit**: Safe code modification and structure optimization
- **TodoWrite**: Progress tracking for complex multi-file cleanup operations
- **Task**: Delegation for large-scale cleanup workflows requiring systematic coordination

### Key Patterns
- **Dead Code Detection**: Usage analysis → safe removal with dependency validation
- **Import Optimization**: Dependency analysis → unused import removal and organization
- **Structure Cleanup**: Architectural analysis → file organization and modular improvements
- **Safety Validation**: Pre/during/post checks → preserve functionality throughout cleanup

### Examples

#### Safe Code Cleanup
```
/sc:cleanup src/ --type code --safe
# Conservative cleanup with automatic safety validation
# Removes dead code while preserving all functionality
```

#### Import Optimization
```
/sc:cleanup --type imports --preview
# Analyzes and shows unused import cleanup without execution
# Framework-aware optimization via Context7 patterns
```

#### Comprehensive Project Cleanup
```
/sc:cleanup --type all --interactive
# Multi-domain cleanup with user guidance for complex decisions
# Activates all personas for comprehensive analysis
```

#### Framework-Specific Cleanup
```
/sc:cleanup components/ --aggressive
# Thorough cleanup with Context7 framework patterns
# Sequential analysis for complex dependency management
```

### Boundaries

**Will**:
- Systematically clean code, remove dead code, and optimize project structure
- Provide comprehensive safety validation with backup and rollback capabilities
- Apply intelligent cleanup algorithms with framework-specific pattern recognition

**Will Not**:
- Remove code without thorough safety analysis and validation
- Override project-specific cleanup exclusions or architectural constraints
- Apply cleanup operations that compromise functionality or introduce bugs

---

## /sc:git - Git Operations

**Description**: Git operations with intelligent commit messages and workflow optimization

### Triggers
- Git repository operations: status, add, commit, push, pull, branch
- Need for intelligent commit message generation
- Repository workflow optimization requests
- Branch management and merge operations

### Usage
```
/sc:git [operation] [args] [--smart-commit] [--interactive]
```

### Behavioral Flow
1. **Analyze**: Check repository state and working directory changes
2. **Validate**: Ensure operation is appropriate for current Git context
3. **Execute**: Run Git command with intelligent automation
4. **Optimize**: Apply smart commit messages and workflow patterns
5. **Report**: Provide status and next steps guidance

**Key behaviors**:
- Generate conventional commit messages based on change analysis
- Apply consistent branch naming conventions
- Handle merge conflicts with guided resolution
- Provide clear status summaries and workflow recommendations

### Tool Coordination
- **Bash**: Git command execution and repository operations
- **Read**: Repository state analysis and configuration review
- **Grep**: Log parsing and status analysis
- **Write**: Commit message generation and documentation

### Key Patterns
- **Smart Commits**: Analyze changes → generate conventional commit message
- **Status Analysis**: Repository state → actionable recommendations
- **Branch Strategy**: Consistent naming and workflow enforcement
- **Error Recovery**: Conflict resolution and state restoration guidance

### Examples

#### Smart Status Analysis
```
/sc:git status
# Analyzes repository state with change summary
# Provides next steps and workflow recommendations
```

#### Intelligent Commit
```
/sc:git commit --smart-commit
# Generates conventional commit message from change analysis
# Applies best practices and consistent formatting
```

#### Interactive Operations
```
/sc:git merge feature-branch --interactive
# Guided merge with conflict resolution assistance
```

### Boundaries

**Will**:
- Execute Git operations with intelligent automation
- Generate conventional commit messages from change analysis
- Provide workflow optimization and best practice guidance

**Will Not**:
- Modify repository configuration without explicit authorization
- Execute destructive operations without confirmation
- Handle complex merges requiring manual intervention

---

## Common Patterns Across Commands

### Persona Activation Matrix

| Command | Architect | Frontend | Backend | Performance | Quality | Security | QA Specialist |
|---------|-----------|----------|---------|-------------|---------|----------|---------------|
| implement | ✅ | ✅ | ✅ | - | - | ✅ | ✅ |
| improve | ✅ | - | - | ✅ | ✅ | ✅ | - |
| cleanup | ✅ | - | - | - | ✅ | ✅ | - |
| git | - | - | - | - | - | - | - |

### MCP Server Usage

| MCP Server | implement | improve | cleanup | git |
|------------|-----------|---------|---------|-----|
| Sequential | ✅ | ✅ | ✅ | - |
| Context7 | ✅ | ✅ | ✅ | - |
| Magic | ✅ | - | - | - |
| Playwright | ✅ | - | - | - |

### Universal Tool Coordination
- **Read/Grep/Glob**: Analysis and pattern detection across all commands
- **Edit/MultiEdit**: Code modification and refactoring (implement, improve, cleanup)
- **TodoWrite**: Progress tracking for complex operations (implement, improve, cleanup)
- **Task**: Delegation for large-scale workflows (implement, improve, cleanup)
- **Bash**: Direct execution and automation (git, all commands when needed)

### Safety Flags
- `--safe`: Conservative mode with automatic safety validation
- `--interactive`: User-guided decisions for complex operations
- `--preview`: Show changes before execution
- `--validate`: Comprehensive post-operation validation
- `--with-tests`: Include test generation/validation

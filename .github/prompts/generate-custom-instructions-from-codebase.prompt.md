---
description: 'Migration instructions generator for GitHub Copilot from code evolution analysis'
agent: 'agent'
---

# Migration Instructions Generator

## Config

```bash
${MIGRATION_TYPE="Framework Version|Architecture Refactoring|Technology Migration|Dependencies Update|Pattern Changes"}
${SOURCE_REFERENCE="branch|commit|tag"}  # Before state
${TARGET_REFERENCE="branch|commit|tag"}  # After state
${ANALYSIS_SCOPE="Entire project|Specific folder|Modified files only"}
${CHANGE_FOCUS="Breaking Changes|New Conventions|Obsolete Patterns|API Changes|Configuration"}
${AUTOMATION_LEVEL="Conservative|Balanced|Aggressive"}
${GENERATE_EXAMPLES="true|false"}
${VALIDATION_REQUIRED="true|false"}
```

## Process

### Phase 1: Comparative Analysis

**Structural Changes:**
- Compare folder structure ${SOURCE_REFERENCE} → ${TARGET_REFERENCE}
- Identify moved/renamed/deleted files
- Analyze config file changes
- Document dependency changes

**Code Transformation:**
- ${MIGRATION_TYPE == "Framework Version"}: API changes, new features, obsolete methods, syntax changes
- ${MIGRATION_TYPE == "Architecture Refactoring"}: Pattern changes, new abstractions, responsibility reorg, data flows
- ${MIGRATION_TYPE == "Technology Migration"}: Tech replacements, functional equivalences, API/syntax changes, configs

**Pattern Extraction:**
- Identify repetitive transformations
- Analyze conversion rules (old → new)
- Document exceptions/special cases
- Create before/after matrix

### Phase 2: Generate `.github/copilot-migration-instructions.md`

```markdown
# Copilot Migration Instructions

## Context
- **Type**: ${MIGRATION_TYPE}
- **From**: ${SOURCE_REFERENCE} → **To**: ${TARGET_REFERENCE}
- **Date**: [DATE] | **Scope**: ${ANALYSIS_SCOPE}

## Transformation Rules

### 1. Mandatory (${AUTOMATION_LEVEL != "Conservative"})
- **Old Pattern**: [CODE]
- **New Pattern**: [CODE]
- **Trigger**: [DETECTION]
- **Action**: [TRANSFORMATION]

### 2. With Validation (${VALIDATION_REQUIRED == "true"})
- **Detected**: [PATTERN]
- **Suggested**: [NEW_APPROACH]
- **Validation**: [CRITERIA]
- **Alternatives**: [OPTIONS]

### 3. API Correspondences (${CHANGE_FOCUS == "API Changes"})
| Old API | New API | Notes | Example |
|---------|---------|-------|---------|
| [OLD]   | [NEW]   | [CHG] | [CODE]  |

### 4. New Patterns
- **Pattern**: [NAME]
- **Usage**: [WHEN]
- **Implementation**: [HOW]
- **Benefits**: [WHY]

### 5. Obsolete Patterns
- **Obsolete**: [OLD_PATTERN]
- **Avoid**: [REASONS]
- **Alternative**: [NEW_PATTERN]
- **Migration**: [STEPS]

## File-Specific (${GENERATE_EXAMPLES == "true"})

### Config Files
[TRANSFORMATION_EXAMPLES]

### Source Files
[TRANSFORMATION_EXAMPLES]

### Test Files
[TRANSFORMATION_EXAMPLES]

## Validation

**Auto Control Points:**
- Post-transformation verifications
- Tests to run
- Performance metrics
- Compatibility checks

**Manual Escalation:**
- [COMPLEX_CASES]
- [ARCHITECTURAL_DECISIONS]
- [BUSINESS_IMPACTS]

## Monitoring

**Metrics:**
- % code auto-migrated
- Manual validations required
- Auto-transformation error rate
- Avg migration time/file

**Error Reporting:**
- Feedback patterns
- Exceptions
- Instruction adjustments
```

### Phase 3: Examples (${GENERATE_EXAMPLES == "true"})

```
// BEFORE (${SOURCE_REFERENCE})
[OLD_CODE]

// AFTER (${TARGET_REFERENCE})
[NEW_CODE]

// COPILOT: When [TRIGGER], transform to [NEW_PATTERN] via [STEPS]
```

### Phase 4: Validation

- Apply instructions on test code
- Verify transformation consistency
- Adjust rules based on results
- Document exceptions/edge cases
- ${AUTOMATION_LEVEL == "Aggressive"}: Refine for max automation, reduce false positives

## Result

Migration instructions enabling Copilot to:
1. Auto-apply same transformations
2. Maintain consistency with new conventions
3. Avoid obsolete patterns
4. Accelerate future migrations
5. Reduce errors via automation

Transforms Copilot into intelligent migration assistant reproducing your evolution decisions consistently.

## Use Cases

- **Framework Version**: Angular 14→17, React Class→Hooks, .NET Framework→Core
- **Tech Stack**: jQuery→React, REST→GraphQL, SQL→NoSQL
- **Architecture**: Monolith→Microservices, MVC→Clean Architecture
- **Patterns**: Repository, DI, Observer→Reactive

## Benefits

- 🧠 **AI Enhancement**: "Train" Copilot to reproduce decisions
- 🔄 **Knowledge Capitalization**: Specific experience → reusable rules
- 🎯 **Context-Aware**: Tailored to your codebase with real examples
- ⚡ **Automated Consistency**: New code follows new conventions

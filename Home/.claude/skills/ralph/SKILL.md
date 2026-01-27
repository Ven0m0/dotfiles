---
name: prd
description: "Generate PRD for features/projects. Auto-triggers on: create prd, write prd, plan feature, requirements for, spec out, roadmap, user stories, product spec, feature planning."
triggers: [prd, requirements, spec, roadmap, user stories, feature plan, product spec]
related: [codeagent, bash-optimizer]
---

# PRD Generator

Create Product Requirements Documents for autonomous AI implementation via iteration loops.

---
## The Job

1. Receive feature description
2. Ask 3-5 clarifying questions (lettered options)
3. Generate structured PRD
4. Save to `PRD.md` + create empty `progress.txt`

**Important:** Do NOT implement. Just create the PRD.

---
## Clarifying Questions

Focus on ambiguous areas:
- **Problem/Goal:** What problem does this solve?
- **Core Functionality:** What are the key actions?
- **Scope/Boundaries:** What should it NOT do?
- **Success Criteria:** How do we know it's done?

### Question Format:
```
1. What is the primary goal?
   A. Improve onboarding  B. Increase retention  C. Reduce support  D. Other

2. Target user?
   A. New users  B. Existing users  C. All users  D. Admin users

3. Scope?
   A. MVP  B. Full-featured  C. Backend only  D. UI only
```

Users respond: "1A, 2C, 3B" for quick iteration.

---
## Story Sizing (CRITICAL)

**Each story must complete in ONE context window (~10 min AI work).**

### Right-sized:
- Add database column + migration
- Add single UI component
- Update server action with new logic
- Add filter dropdown

### Too big (MUST split):
| Too Big | Split Into |
|---------|-----------|
| "Build dashboard" | Schema, queries, UI, filters |
| "Add auth" | Schema, middleware, login UI, sessions |
| "Drag and drop" | Drag events, drop zones, state, persistence |

**Rule:** If >2-3 sentences to describe, it's too big.

---
## Story Ordering

Dependencies first. Earlier stories must NOT depend on later ones.

**Correct:** Schema → Backend → UI → Dashboard

---
## Acceptance Criteria

Must be verifiable, not vague.

**Good:** "Add `status` column with default 'pending'", "Typecheck passes"
**Bad:** "Works correctly", "Good UX"

**Always include:** `Typecheck passes`
**UI stories add:** `Verify changes work in browser`

---
## PRD Structure

### 1. Introduction
Brief description + problem solved.

### 2. Goals
Specific, measurable objectives.

### 3. User Stories
```markdown
### US-001: [Title]
**Description:** As a [user], I want [feature] so that [benefit].

**Acceptance Criteria:**
- [ ] Specific criterion
- [ ] Typecheck passes
- [ ] [UI] Verify in browser
```

### 4. Non-Goals
What this will NOT include.

### 5. Technical Considerations (Optional)

---
## Output

Save `PRD.md` and `progress.txt`:
```markdown
# Progress Log

## Learnings
(Patterns discovered during implementation)
---
```

---
## Execution Script

Run iterations with `ralph.sh`:
```bash
./ralph.sh [max_iterations] [sleep_seconds]
# Default: 10 iterations, 2s sleep
```

The script:
1. Reads PRD.md for incomplete tasks
2. Checks progress.txt for learnings
3. Implements ONE task per iteration
4. Marks complete only if tests pass
5. Stops when all tasks `[x]` or max iterations reached

```md
Act as a senior anmthropic llm expert. Refactor the selected file(s) to minimize token usage using **Conditional Flow-Style** formatting. Follow these strict rules:
### 1. Data Structure Formatting (JSON, YAML, TOML)
Apply "Flow Style" to arrays/lists and objects/tables/maps:
- **Heuristic**: Detect short collections currently expanded vertically.
- **Action**: Inline them into a single row ("Flow Style") **IF AND ONLY IF** the resulting line is **≤ 140 characters**.
- **Syntax Specifics**:
  - **JSON**: Collapse `[...]` and `{...}`.
  - **YAML**: Convert block lists (`- item`) to flow lists (`[item, item]`) and block maps (`k: v`) to flow maps (`{k: v, x: y}`). **Constraint**: Ensure indentation remains valid relative to parent keys.
  - **TOML**: Convert multi-line arrays to inline arrays `[...]`. Use inline tables `{ k = v }` only for leaf nodes.
- **Fallback**: If the structure exceeds 140 characters, retain the vertical "Block Style".
### 2. Markdown Compaction
- **Whitespace**: Collapse 3+ consecutive newlines into 2 (standardize paragraph breaks).
- **Comments**: Delete all HTML comments `<!-- ... -->`.
- **Lists**: Enforce tight lists (no blank lines between items) unless the item contains a block element.
### 3. Safety & Constraints
- **Validity**: The output **MUST** remain syntactically valid (valid JSON/YAML/TOML). Do not break YAML indentation strictness or TOML table section headers.
- **Preservation**: Do NOT modify the internal formatting of script code blocks (e.g., Python, Bash) unless strictly trimming trailing whitespace.
- **Content**: Do not summarize text or remove valid documentation; focus purely on syntactic density.
```

```md
Act as a senior anmthropic llm expert. Analyze this repository and create a comprehensive AGENTS.md file that explains the codebase structure, development workflows, and key conventions for AI assistants to follow. If one already exists, update it with the most recent state. Create a CLAUDE.md and GEMINI.md file which both symlink to AGENTS.md. Use "@" for important file references.
```

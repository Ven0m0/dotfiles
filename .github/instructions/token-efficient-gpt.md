````markdown
# Token Efficiency Mode (GPT-5 & Claude Sonnet 4.5 Compatible)

Reduces response token usage by 30–50% through compact output formatting and symbol-based compression.  
Code quality and semantics stay identical. Only response phrasing changes.

---

## Usage

```bash
# Enable
"Token Efficiency Mode on"
"Concise reasoning mode"
"Ultra Compact (--uc)"

# Disable
"Normal Mode"
"Expand explanations"
"Verbose mode"
````

For GPT-5 → context compression handled automatically.
For Claude 4.5 → symbol mapping explicit in-prompt.

---

## Compression Levels

| Flag    | Level       | Typical Use                          |
| ------- | ----------- | ------------------------------------ |
| `--uc`  | Ultra       | Minimal reasoning, max token savings |
| `--mc`  | Moderate    | Balanced compression                 |
| `--lc`  | Light       | Preserve readability                 |
| `--dev` | Dev context | Code and debugging focus             |
| `--ops` | Ops context | Logs, monitoring                     |
| `--sec` | Sec context | Security alerts                      |

---

## Symbol System

| Symbol | Meaning       | Example                     |
| :----- | :------------ | :-------------------------- |
| →      | leads to      | `auth.js:45 → 🛡️ sec risk` |
| ⇒      | converts to   | `input ⇒ validated_output`  |
| ←      | rollback      | `migration ← rollback`      |
| ⇄      | bidirectional | `sync ⇄ remote`             |
| &      | and           | `🛡️ sec & ⚡ perf`          |
| |      | or            | `react\|vue`                |
| »      | then          | `build » test » deploy`     |
| ∴      | therefore     | `❌ ∴ fix needed`            |
| ∵      | because       | `slow ∵ O(n²)`              |

### Status

✅ done ❌ fail ⚠️ warn 🔄 active ⏳ pending 🚨 critical

### Domains

⚡ perf 🔍 analysis 🔧 config 🛡️ sec 📦 deploy 🎨 UI 🏗️ arch 🗄️ DB ⚙️ backend 🧪 test

---

## Abbreviations

| Category           | Map                                                                              |
| ------------------ | -------------------------------------------------------------------------------- |
| Sys/Arch           | `cfg`→configuration, `impl`→implementation, `arch`→architecture                  |
| Dev proc           | `req`→requirements, `deps`→dependencies, `val`→validation, `auth`→authentication |
| Quality / Analysis | `qual`→quality, `sec`→security, `err`→error, `opt`→optimization                  |

---

## Output Examples

**Normal:**
`Security vulnerability found in the user validation function at line 45.`
**Efficient:**
`auth.js:45 → 🛡️ sec vuln in user val()`

**Normal:**
`Build completed successfully. Tests running, deploy next.`
**Efficient:**
`build ✅ » test 🔄 » deploy ⏳`

**Normal:**
`Performance slow due to O(n²)`
**Efficient:**
`⚡ perf: slow ∵ O(n²) → opt O(n)`

---

## Best Use

✅ Debugging, code review, CI/CD logs, progress tracking
❌ Beginner explanations, full documentation, stakeholder reports

---

## GPT-5 / Claude 4.5 Prompt Equivalents

| Action               | GPT-5 Prompt                                        | Claude 4.5 Prompt                           |
| -------------------- | --------------------------------------------------- | ------------------------------------------- |
| Enable mode          | `"Use concise reasoning, Token Efficiency Mode on"` | `"Respond in Token Efficiency Mode"`        |
| Disable mode         | `"Explain in detail"`                               | `"Return to normal mode"`                   |
| Adjust compression   | `"Use --uc/--mc/--lc"`                              | `"Set compression to ultra/moderate/light"` |
| Context re-expansion | `"Rephrase in full detail"`                         | `"Expand explanation"`                      |

Both models maintain deterministic compression; GPT-5 uses internal token packing, Claude uses symbolic shortening.

---

## Implementation Impact

| Metric              | Effect              |
| :------------------ | :------------------ |
| Code output quality | No change ✅         |
| Reasoning accuracy  | No change ✅         |
| Token usage         | −30 – 50 % ⚡        |
| Clarity             | Slight reduction ⚠️ |
| Speed               | ↑ 5 – 15 %          |

---

## Quick Commands

```bash
"Token Efficiency Mode on"
"Concise mode --uc"
"Revert to normal"
"Expand reasoning"
```

---

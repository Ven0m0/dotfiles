---
name: toon-formatter
description: "TOON v2.0 format for token-efficient data. Auto-triggers on: structured data ≥5 items, tables, logs, transactions, analytics, API responses, database results, TOON, token savings."
triggers: [toon, structured data, table format, logs, transactions, analytics, api response, database, token savings]
related: [codeagent, python-cli-builder]
allowed-tools: [Read, Write, Edit, Bash]
---

# TOON v2.0 Formatter

Save 30-60% tokens on structured data. Use TOON by default for biggish, regular data.

## When to Use

**YES (auto-apply):**
- Arrays ≥5 similar items
- Tables, logs, events, transactions
- API responses with ≥60% field uniformity
- RAG pipelines, tool calls, agents

**NO:**
- <5 items, deep irregular trees, narrative text

## Three Array Types

**Tabular** (uniform objects ≥5):
```
[2]{id,name,balance}:
  1,Alice,5420.50
  2,Bob,3210.75
```

**Inline** (primitives ≤10):
```
tags[5]: javascript,react,node,express,api
```

**Expanded** (non-uniform):
```
- name: Alice
  role: admin
- name: Bob
  level: 5
```

## Three Delimiters

- **Comma** (default): `[2]{name,city}: Alice,NYC`
- **Tab** (data with commas): `[2\t]{name,address}: Alice	123 Main`
- **Pipe** (markdown-like): `[2|]{method,path}: GET|/api`

## Key Folding (25-35% extra savings)

```
server.host: localhost
server.port: 8080
database.host: db.example.com
```

## Usage

**Zig encoder** (20x faster):
```bash
.claude/utils/toon/zig-out/bin/toon encode data.json --delimiter tab --key-folding > data.toon
```

**Manual format:**
```
📊 Using TOON (est. 42% savings, 10 items)

[10\t]{id,name,address,status}:
  1	Alice	123 Main St, NYC	active
  2	Bob	456 Oak Ave, LA	inactive
```

## Commands

- `/toon-encode <file> [--delimiter tab] [--key-folding]`
- `/toon-validate <file> [--strict]`
- `/analyze-tokens <file>` - Compare JSON vs TOON

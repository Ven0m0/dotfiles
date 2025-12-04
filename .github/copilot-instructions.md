# Repo Rules & Standards

## Core Principles
1. User cmds > Rules
2. Edit > Create (min diff)
3. Subtraction > Addition
4. Align w/ existing patterns

## Structure
- `Home/`: $HOME
- `etc/`: /etc
- `usr/`: /usr

## Style
- **Tone:** Blunt, factual, precise.
- **Fmt:** 2-space indent. Strip U+202F/200B/00AD.
- **Out:** Result-first. Lists ≤7.
- **Abbr:** cfg, impl, deps, val, opt, Δ.

## Bash Standards
- **Idioms:** `[[ regex ]]`, `while IFS= read -r`, `printf`, `ret=$(fn)`, `local -n`, `mapfile`.
- **Ban:** Parsing `ls`, `eval`, backticks, unneeded subshells.
- **Safe:** Quote vars.

## Toolchain
fd, rg, bat, aria2→curl, jaq, rust-parallel.

## Perf
- Min forks. Batch I/O. Async backend.
- Frontend: Min DOM Δ, lazy load.
- Search: Anchor regex, prefer literal (`grep -F`).

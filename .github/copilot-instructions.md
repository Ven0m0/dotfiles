This is my archlinux dotfiles repo. It stores all my config files and some scripts for my optimal linux setup. Please
follow these guidelines when contributing:

## LLM rules / Code Standards

1. User commands override all rules
1. Edit > Create (modify minimal lines)
1. Subtraction > Addition (remove before adding)
1. Align with existing patterns in repo

## Repository Structure

- `Home/`: User home directory ($HOME)
- `etc/`: "/etc/" dir
- `usr/`: "/usr/" dir

## Style & Format

- **Tone:** Blunt, factual, precise. No filler.
- **Format:** 2-space indent. Strip U+202F/U+200B/U+00AD.
- **Output:** Result-first. Lists ≤7 items.
- **Abbrev:** cfg=config, impl=implementation, deps=dependencies, val=validation, opt=optimization, Δ=change.

## Bash Standards

**Idioms:**

- Tests: `[[ ... ]]`. Regex: `[[ $var =~ ^pattern$ ]]`
- Loops: `while IFS= read -r line; do ...; done < <(cmd)`
- Output: `printf` over `echo`. Capture: `ret=$(fn)`
- Functions: `name(){ local var; ... }`. Nameref: `local -n ref=var`
- Arrays: `mapfile -t arr < <(cmd)`. Assoc: `declare -A map=([k]=v)`
- **Never:** Parse `ls`, `eval`, backticks, unnecessary subshells

**Quote:** Always quote vars unless intentional glob/split.

## Tool Preferences

fd→find | rg→grep | bat→cat | aria2→curl→wget | jaq→jq | rust-parallel→parallel→xargs

## Perf Patterns

- Minimize forks/subshells. Use builtins. Batch I/O.
- Frontend: Minimize DOM Δ. Stable keys. Lazy load.
- Backend: Async I/O. Connection pool. Cache hot data.
- Anchor regexes. Prefer literal search (grep -F, rg -F).

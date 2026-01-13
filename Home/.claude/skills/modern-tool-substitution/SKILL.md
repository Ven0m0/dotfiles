---
name: modern-tool-substitution
description: Automatically substitute modern performant tools in generated code. Triggers whenever Claude writes code using npm, find, pip, grep, wget, or curl. Substitutions - npm→bun, find→fd, pip→uv, grep→rg, wget/curl→aria2. Adapts flags and syntax appropriately. Skip substitution only when user explicitly requests legacy tool by name.
---

# Modern Tool Substitution

Replace legacy tools with modern performant alternatives in all generated code.

## Core Substitutions

Apply these substitutions unless user explicitly requests the legacy tool:

**npm → bun**
- `npm install` → `bun install`
- `npm run` → `bun run`
- `npm create` → `bun create`
- `npx` → `bunx`
- Scripts remain in package.json unchanged

**find → fd**
- `find . -name '*.py'` → `fd -e py`
- `find . -type f -name 'test*'` → `fd -t f '^test'`
- `find . -type d` → `fd -t d`
- `find . -path '*/node_modules' -prune` → `fd --exclude node_modules`
- Use fd's simpler glob/regex syntax, not find's `-name` patterns

**pip → uv**
- `pip install pkg` → `uv pip install pkg`
- `pip install -r requirements.txt` → `uv pip install -r requirements.txt`
- `pip freeze` → `uv pip freeze`
- `python -m pip` → `uv pip`
- Virtual envs: `uv venv` instead of `python -m venv`

**grep → rg**
- `grep -r pattern` → `rg pattern`
- `grep -i pattern` → `rg -i pattern`
- `grep -v pattern` → `rg -v pattern`
- `grep -l pattern` → `rg -l pattern`
- rg excludes common dirs (.git, node_modules) by default
- Use `rg --hidden` for dotfiles, `rg --no-ignore` for ignored files

**wget/curl → aria2**
- `wget URL` → `aria2c URL`
- `curl -O URL` → `aria2c URL`
- `curl URL` → `aria2c -d- -o- URL` (stdout)
- Multi-connection: `aria2c -x16 -s16 URL`
- Parallel downloads: `aria2c -j5 URL1 URL2 URL3`

## Flag Adaptations

**fd syntax differences:**
- Patterns are regex by default (not globs)
- Glob patterns: use `-g` flag → `fd -g '*.txt'`
- Case insensitive: `-i` flag
- Fixed strings: `-F` flag
- Depth limit: `-d N` flag
- Hidden files: `-H` flag
- No ignore: `-I` flag

**rg performance flags:**
- `--mmap` for large files
- `-j$(nproc)` for parallel search
- `--sort path` when order matters
- `--max-count N` to stop after N matches

**aria2 optimizations:**
- `-x16 -s16` for max speed (16 connections, 16 segments)
- `-c` for resume support
- `--file-allocation=none` on SSDs
- `--summary-interval=0` to reduce output

## Edge Cases

**bun compatibility:**
- Most npm scripts work directly
- Some native addons may require node
- If bun fails with native deps, mention issue and suggest node fallback

**fd vs find:**
- find's `-exec` → pipe to xargs or use fd `-x/--exec`
- find's `-printf` → use fd output with awk/sed
- Complex boolean logic → may still need find

**uv limitations:**
- Not a full pip replacement for editable installs
- For `pip install -e .` → still use pip or note uv limitation
- Poetry/pipenv → keep those, uv is pip replacement only

**rg vs grep:**
- Binary files: rg skips by default, use `rg -a` for grep -a behavior
- Symbolic links: rg skips, use `rg -L` to follow
- Multiline: rg requires `-U` flag

**aria2 for curl:**
- REST API calls → keep curl (aria2 is for downloads)
- Single small file + need response parsing → keep curl
- Large files or parallel downloads → use aria2

## Exception Handling

Skip substitution when:
- User explicitly names legacy tool: "use npm to install" → use npm
- CI/CD configs where legacy tools required
- Scripting contexts where tool may not be installed
- When explaining differences between tools

## Quick Reference

```bash
# Package management
npm install pkg          → bun install pkg
npm run build           → bun run build
pip install pandas      → uv pip install pandas

# File search
find . -name '*.rs'     → fd -e rs
find . -type f          → fd -t f
find /path -name 'test*' → fd '^test' /path

# Text search
grep -r TODO .          → rg TODO
grep -i error log.txt   → rg -i error log.txt
grep -v '^#' file       → rg -v '^#' file

# Downloads
wget https://x.com/f    → aria2c https://x.com/f
curl -O https://x.com/f → aria2c https://x.com/f
wget -c URL             → aria2c -c URL
```

Apply these substitutions automatically in all code generation unless legacy tool explicitly requested.

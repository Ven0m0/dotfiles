# Security Rules

## Files That MUST NOT Be Read or Modified

These files contain or could contain sensitive material. Never open, read, display, or modify them:

- `.gnupg/` and any `*.gpg` files
- `.ssh/id_*`, `*.pem`, `*.key`, `*.crt`
- `.config/gh/hosts.yml` (GitHub auth tokens)
- `.yadm/archive`, `.yadm/encrypt`, `.yadm/files.gpg`
- Any file matching `*token*`, `*secret*`, `*password*`, `*credentials*`, `*apikey*`
- `.github-personal-access-token`
- `gha-creds-*.json`

## Shell Script Injection Prevention

- **NEVER use `eval`** in any shell script — use arrays, functions, or parameter expansion instead
- **NEVER pass user input directly to shell** — validate and sanitize first
- **NEVER construct commands with string concatenation** — use arrays: `cmd=("git" "commit" "-m" "${msg}")`
- **NEVER store secrets in scripts** — use env vars or a secrets manager

## Protected System Files (Require Explicit User Approval)

Do NOT modify these without the user explicitly saying to:

- `etc/pacman.conf` — package manager config
- `etc/sudoers`, `etc/sudoers.d/` — privilege escalation
- `etc/ssh/sshd_config` — SSH server (security boundary)
- `etc/sysctl.d/` — kernel parameters
- `etc/paru.conf`, `etc/makepkg.conf` — build environment

## Git Security

- Never `git add -A` or `git add .` — always stage specific files
- Before committing, verify staged files with `git diff --staged`
- Never commit files matching `.gitignore` secret patterns
- The `Home/.ssh/config` is allowed (non-secret), but `Home/.ssh/id_*` are not

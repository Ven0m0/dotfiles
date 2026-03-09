---
applyTo: "mise.toml,mise.*.toml,mise-tasks/**,.mise/**,**/mise.toml,**/mise.lock,.tool-versions,Dockerfile,docker-compose*.yml,.github/workflows/**,.gitlab-ci.yml"
---

# Mise (mise-en-place) Instructions

This project uses [mise](https://mise.jdx.dev/) to manage dev tools, environment variables, and tasks.

## Core Rules

- Always check `mise.toml` before suggesting tool installations — tools may already be defined
- Use `mise use <tool>@<version>` to add tools — never edit `mise.toml` `[tools]` manually
- Use `mise run <task>` or `mise x -- <cmd>` to execute commands — never call tools directly
- Never modify `mise.local.toml` — it contains user-specific overrides and is gitignored
- Pin exact versions in CI configs; use loose versions (`node = "22"`) in `mise.toml`
- Use `mise doctor` and `mise config ls` for debugging before manual investigation

## mise.toml Structure

```toml
min_version = "2024.9.5"

[env]
NODE_ENV = "development"
_.path = ['{{config_root}}/node_modules/.bin']  # prepend to PATH
_.file = ".env"                                  # load dotenv

[tools]
node = "22"
python = "3.12"
"npm:typescript" = "latest"

[tasks]
dev = "npm run dev"
test = "npm test"
build = "npm run build"

[tasks.ci]
depends = ["lint", "test"]

[settings]
experimental = true   # required for hooks
lockfile = true       # reproducible installs

[hooks]
postinstall = "corepack enable"
```

## Config Hierarchy (highest precedence first)

`mise.local.toml` → `mise.toml` → `.mise/config.toml` → `.config/mise.toml` → parent dirs

Set `MISE_ENV=development` to load `mise.development.toml`.

## Tasks

Two styles — TOML (inline in `mise.toml`) and file tasks (scripts in `mise-tasks/` or `.mise/tasks/`).

TOML task properties: `run`, `description`, `alias`, `depends`, `depends_post`, `wait_for`, `env`, `dir`, `sources`, `outputs`, `shell`, `confirm`, `hide`, `raw`, `file`.

File tasks use `#MISE` comments for metadata:
```sh
#!/usr/bin/env bash
#MISE description="Deploy"
#MISE depends=["build"]
#MISE sources=["dist/**/*"]
set -euo pipefail
```

Task arguments: `{{arg(name='x')}}`, `{{flag(name='release')}}`, `{{option(name='target')}}`.

## Backends

```sh
mise use node@22                      # core
mise use npm:eslint                   # npm registry
mise use pipx:black                   # pipx
mise use github:BurntSushi/ripgrep    # github releases
mise use aqua:hashicorp/terraform     # aqua registry
mise use cargo:ripgrep                # cargo
```

## CI/CD

GitHub Actions:
```yaml
- uses: jdx/mise-action@v3
  with:
    version: 2024.12.14
    install: true
    cache: true
```

Generic CI:
```sh
curl https://mise.run | sh
mise install
mise x -- npm test
```

Bootstrap (vendored, no curl needed):
```sh
mise generate bootstrap -l -w   # generates ./bin/mise
./bin/mise install
./bin/mise x -- npm test
```

## Docker

```dockerfile
FROM debian:12-slim
RUN apt-get update && apt-get -y --no-install-recommends install \
    sudo curl git ca-certificates build-essential && rm -rf /var/lib/apt/lists/*
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV MISE_DATA_DIR="/mise" MISE_CONFIG_DIR="/mise" MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise" PATH="/mise/shims:$PATH"
RUN curl https://mise.run | sh
```

## Environment Variables

Key mise env vars: `MISE_DATA_DIR`, `MISE_CONFIG_DIR`, `MISE_CACHE_DIR`, `MISE_ENV`, `MISE_GITHUB_TOKEN`, `MISE_EXPERIMENTAL`, `MISE_PROJECT_ROOT`.

In `[env]`: use `_.path` for PATH prepends, `_.file` for dotenv, `_.source` for shell scripts. Templates use Tera syntax: `{{ config_root | basename }}`, `{{ env.VAR | default(value='x') }}`.

## Shell Activation

```sh
eval "$(mise activate bash)"   # bash
eval "$(mise activate zsh)"    # zsh
mise activate fish | source    # fish
```

Shims (`~/.local/share/mise/shims`) are preferred for non-interactive contexts (CI, IDEs). Use `eval "$(mise activate zsh --shims)"` for IDE integration.

## Debugging

```sh
mise doctor          # health check
mise config ls       # config precedence
mise ls --missing    # tools needing install
mise env             # resolved env vars
mise where node      # tool install path
mise tasks --extended  # list tasks with details
```

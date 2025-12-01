#!/usr/bin/env bash
# Exhaustive Lint & Format Script
# Policy: 2-space indent, 120 char width, 0 errors.
set -euo pipefail
IFS=$'\n\t'
# --- Configuration ---
readonly PROJECT_ROOT="${PWD}"
readonly PARALLEL_JOBS="$(nproc)"
# Tools mapping: defined as "ToolName:BinaryName"
readonly TOOLS=(
  "YAML Formatter:yamlfmt" "YAML Linter:yamllint"
  "Biome:biome" "ESLint:eslint"
  "Shell Format:shfmt" "Shell Check:shellcheck"
  "Fish Indent:fish_indent"
  "Taplo (TOML):taplo"
  "Ruff:ruff"
  "StyLua:stylua" "Selene:selene"
  "Actionlint:actionlint"
  "MarkdownLint:markdownlint"
)
# Colors
readonly R=$(tput setaf 1) G=$(tput setaf 2) Y=$(tput setaf 3) B=$(tput setaf 4) NC=$(tput sgr0)
# --- Helpers ---
log() { printf "${B}[%s]${NC} %s\n" "$(date +%T)" "$1"; }
err() { printf "${R}[ERR]${NC} %s\n" "$1" >&2; }
ok()  { printf "${G}[OK]${NC} %s\n" "$1"; }
check_deps() {
  local missing=()
  for t in "${TOOLS[@]}"; do
    local bin="${t#*:}"
    if ! command -v "$bin" &>/dev/null; then missing+=("$bin"); fi
  done
  # Fallbacks/Alternatives logic
  if [[ ${#missing[@]} -gt 0 ]]; then
    err "Missing tools: ${missing[*]}"
    err "Install them via pacman/paru/npm/cargo."
    return 1
  fi
}

find_files() {
  local ext="$1"
  # fd is preferred -> find fallback
  if command -v fd &>/dev/null; then
    fd -u -t f -H -E .git -E node_modules -E .venv -e "$ext" . "$PROJECT_ROOT"
  else
    find "$PROJECT_ROOT" -type f -name "*.$ext" -not -path "*/.git/*" -not -path "*/node_modules/*"
  fi
}

# --- Processors ---

proc_yaml() {
  log "Processing YAML..."
  local files
  mapfile -t files < <(find_files "yaml" && find_files "yml")
  [[ ${#files[@]} -eq 0 ]] && return 0

  # Format
  printf "%s\n" "${files[@]}" | xargs -r -P"$PARALLEL_JOBS" yamlfmt -conf .qlty/configs/.yamllint.yaml

  # Lint
  printf "%s\n" "${files[@]}" | xargs -r -P"$PARALLEL_JOBS" yamllint -c .qlty/configs/.yamllint.yaml -f parsable
}

proc_web() {
  log "Processing JS/TS/JSON/CSS..."
  # Biome handles globbing efficiently itself
  biome format --write --config-path=biome.json .
  biome lint --apply --config-path=biome.json .
  
  # ESLint (Fix)
  # mapfile -t files < <(fd -e js -e ts -e jsx -e tsx)
  # [[ ${#files[@]} -gt 0 ]] && eslint --fix "${files[@]}"
}

proc_shell() {
  log "Processing Shell (Bash/Sh)..."
  local files
  mapfile -t files < <(find_files "sh" && find_files "bash" && find_files "zsh")
  [[ ${#files[@]} -eq 0 ]] && return 0

  # Format (2 spaces, ci: switch cases indented)
  shfmt -w -i 2 -ci "${files[@]}"

  # Lint
  shellcheck -x "${files[@]}"
}

proc_fish() {
  log "Processing Fish..."
  local files
  mapfile -t files < <(find_files "fish")
  [[ ${#files[@]} -eq 0 ]] && return 0

  # Fish indent doesn't support in-place easily without temp files or check
  for f in "${files[@]}"; do
    fish_indent -w "$f"
  done
}

proc_toml() {
  log "Processing TOML..."
  if command -v taplo &>/dev/null; then
    taplo format --option "indent_string=  " # Force 2 spaces
    taplo lint
  fi
}

proc_python() {
  log "Processing Python..."
  # Ruff handles both format and lint
  ruff format .
  ruff check --fix .
}

proc_lua() {
  log "Processing Lua..."
  local files
  mapfile -t files < <(find_files "lua")
  [[ ${#files[@]} -eq 0 ]] && return 0

  stylua --indent-type Spaces --indent-width 2 "${files[@]}"
  selene "${files[@]}"
}

proc_markdown() {
  log "Processing Markdown..."
  # MarkdownLint
  local files
  mapfile -t files < <(find_files "md")
  [[ ${#files[@]} -eq 0 ]] && return 0
  
  # Fix common issues
  markdownlint-cli2 --fix "**/*.md"
}

# --- Main ---
main() {
  log "Starting Exhaustive Pipeline..."
  check_deps || true # Warn but try to proceed
  local errors=0
  # Run groups
  proc_yaml     || ((errors++))
  proc_web      || ((errors++))
  proc_shell    || ((errors++))
  proc_fish     || ((errors++))
  proc_toml     || ((errors++))
  proc_python   || ((errors++))
  proc_lua      || ((errors++))
  proc_markdown || ((errors++))
  if [[ $errors -eq 0 ]]; then
    ok "All files processed. Zero errors."
    exit 0
  else
    err "Pipeline finished with errors."
    exit 1
  fi
}
main "$@"

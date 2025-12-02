#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C HOME="/home/${SUDO_USER:-$USER}"

# Lint & Format Pipeline
# Enforces 2-space indent, runs formatters before linters, exits non-zero on errors

readonly SCRIPT_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly EXCLUDE_DIRS=".git node_modules vendor .cache .venv __pycache__ .ruff_cache target dist build .next .turbo coverage .var .rustup .wine .zim .void-editor .vscode .claude Home/.local"
readonly MAX_PARALLEL="${MAX_PARALLEL:-$(nproc)}"

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BLU='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly DEF='\033[0m'
readonly BLD='\033[1m'

# State tracking
declare -a MODIFIED_FILES=()
declare -a ERROR_FILES=()
declare -i TOTAL_ERRORS=0
declare -i TOTAL_MODIFIED=0

# Helpers
has() { command -v "$1" &> /dev/null; }
die() {
  printf '%b\n' "${BLD}${RED}==> ERROR:${DEF} $1" >&2
  exit 1
}
warn() { printf '%b\n' "${BLD}${YELLOW}==> WARNING:${DEF} $1" >&2; }
info() { printf '%b\n' "${BLD}${BLU}==>${DEF} $1"; }
success() { printf '%b\n' "${BLD}${GREEN}==>${DEF} $1"; }

# File discovery with fallbacks
discover_files() {
  local -r ext="$1"
  local -r pattern="*.${ext}"

  if has fd; then
    fd -tf -u -E .git -E node_modules -e "$ext" . 2> /dev/null || true
  elif has find; then
    find . -type f -name "$pattern" \
      ! -path "*/.git/*" \
      ! -path "*/node_modules/*" \
      ! -path "*/vendor/*" \
      ! -path "*/.cache/*" \
      ! -path "*/.venv/*" \
      ! -path "*/__pycache__/*" \
      ! -path "*/.ruff_cache/*" \
      ! -path "*/target/*" \
      ! -path "*/dist/*" \
      ! -path "*/build/*" \
      ! -path "*/.next/*" \
      ! -path "*/.turbo/*" \
      ! -path "*/coverage/*" 2> /dev/null || true
  else
    die "Neither fd nor find available"
  fi
}

# Check if file should be excluded
is_excluded() {
  local -r file="$1"
  local dir
  for dir in "${EXCLUDE_DIRS[@]}"; do
    [[ "$file" == *"/${dir}/"* ]] && return 0
    [[ "$file" == "./${dir}/"* ]] && return 0
  done
  return 1
}

# Format YAML files
format_yaml() {
  if ! has yamlfmt; then
    warn "yamlfmt not found, skipping YAML formatting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "yml")
  mapfile -t -O "${#files[@]}" files < <(discover_files "yaml")

  [[ ${#files[@]} -eq 0 ]] && return 0

  info "Formatting ${#files[@]} YAML file(s)..."
  local file count=0

  for file in "${files[@]}"; do
    [[ -f "$file" ]] || continue
    is_excluded "$file" && continue

    # yamlfmt formats in-place, check if file changed
    local before_hash
    before_hash=$(md5sum < "$file" 2> /dev/null || echo "")

    if yamlfmt -conf "${SCRIPT_DIR}/.yamlfmt" "$file" 2> /dev/null; then
      local after_hash
      after_hash=$(md5sum < "$file" 2> /dev/null || echo "")

      if [[ "$before_hash" != "$after_hash" ]]; then
        MODIFIED_FILES+=("yaml:$file")
        ((++count))
      fi
    else
      ERROR_FILES+=("yaml:$file")
      ((++TOTAL_ERRORS))
    fi
  done

  ((count > 0)) && success "Formatted $count YAML file(s)"
  return 0
}

# Lint YAML files
lint_yaml() {
  if ! has yamllint; then
    warn "yamllint not found, skipping YAML linting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "yml")
  mapfile -t -O "${#files[@]}" files < <(discover_files "yaml")

  [[ ${#files[@]} -eq 0 ]] && return 0

  info "Linting ${#files[@]} YAML file(s)..."
  local file errors=0

  for file in "${files[@]}"; do
    [[ -f "$file" ]] || continue
    is_excluded "$file" && continue

    # Only count actual errors, not warnings
    if yamllint -f parsable -c "${SCRIPT_DIR}/.yamllint.yaml" "$file" 2> /dev/null | grep -q "error"; then
      ERROR_FILES+=("yaml:$file")
      ((++errors))
      ((++TOTAL_ERRORS))
    fi
  done

  ((errors > 0)) && warn "Found $errors YAML error(s)" || success "YAML lint passed"
  return 0
}

# Format JSON/CSS/JS/HTML with Biome
format_biome() {
  if ! has biome; then
    warn "biome not found, skipping Biome formatting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "json")
  mapfile -t -O "${#files[@]}" files < <(discover_files "js")
  mapfile -t -O "${#files[@]}" files < <(discover_files "css")
  mapfile -t -O "${#files[@]}" files < <(discover_files "html")

  [[ ${#files[@]} -eq 0 ]] && return 0

  info "Formatting with Biome..."
  local count=0

  if biome format --write . --formatter-enabled=true 2> /dev/null; then
    # Check for modified files
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      MODIFIED_FILES+=("biome:$file")
      ((++count))
    done < <(git diff --name-only --diff-filter=ACMR 2> /dev/null || true)

    ((count > 0)) && success "Formatted $count file(s) with Biome"
  else
    ERROR_FILES+=("biome:.")
    ((++TOTAL_ERRORS))
  fi

  return 0
}

# Lint JSON/CSS/JS/HTML with Biome
lint_biome() {
  if ! has biome; then
    warn "biome not found, skipping Biome linting"
    return 0
  fi

  info "Linting with Biome..."

  if biome check . --reporter=summary 2> /dev/null; then
    success "Biome lint passed"
  else
    ERROR_FILES+=("biome:.")
    ((++TOTAL_ERRORS))
    return 1
  fi
}

# Format Shell scripts
format_shell() {
  if ! has shfmt; then
    warn "shfmt not found, skipping shell formatting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "sh")
  mapfile -t -O "${#files[@]}" files < <(discover_files "bash")

  [[ ${#files[@]} -eq 0 ]] && return 0

  info "Formatting ${#files[@]} shell script(s) with shfmt (2-space indent)..."
  local file count=0

  for file in "${files[@]}"; do
    [[ -f "$file" ]] || continue
    is_excluded "$file" && continue

    if shfmt -w -i 2 -ci -bn "$file" 2> /dev/null; then
      if git diff --quiet "$file" 2> /dev/null; then
        : # No changes
      else
        MODIFIED_FILES+=("shell:$file")
        ((++count))
      fi
    else
      ERROR_FILES+=("shell:$file")
      ((++TOTAL_ERRORS))
    fi
  done

  ((count > 0)) && success "Formatted $count shell script(s)"
  return 0
}

# Lint Shell scripts
lint_shell() {
  if ! has shellcheck; then
    warn "shellcheck not found, skipping shell linting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "sh")
  mapfile -t -O "${#files[@]}" files < <(discover_files "bash")

  [[ ${#files[@]} -eq 0 ]] && return 0

  info "Linting ${#files[@]} shell script(s) with shellcheck..."
  local file errors=0

  for file in "${files[@]}"; do
    [[ -f "$file" ]] || continue
    is_excluded "$file" && continue

    # Skip zsh-specific files
    [[ "$file" == *"zsh"* ]] && continue
    head -1 "$file" 2> /dev/null | grep -q "zsh" && continue

    if ! shellcheck --format=gcc -S warning "$file" 2> /dev/null; then
      ERROR_FILES+=("shell:$file")
      ((++errors))
      ((++TOTAL_ERRORS))
    fi
  done

  ((errors > 0)) && warn "Found $errors shellcheck error(s)" || success "Shellcheck passed"
  return 0
}

# Format Fish scripts
format_fish() {
  if ! has fish_indent; then
    warn "fish_indent not found, skipping fish formatting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "fish")

  [[ ${#files[@]} -eq 0 ]] && return 0

  info "Formatting ${#files[@]} fish script(s)..."
  local file count=0

  for file in "${files[@]}"; do
    [[ -f "$file" ]] || continue
    is_excluded "$file" && continue

    if fish_indent -w "$file" 2> /dev/null; then
      if git diff --quiet "$file" 2> /dev/null; then
        : # No changes
      else
        MODIFIED_FILES+=("fish:$file")
        ((++count))
      fi
    else
      ERROR_FILES+=("fish:$file")
      ((++TOTAL_ERRORS))
    fi
  done

  ((count > 0)) && success "Formatted $count fish script(s)"
  return 0
}

# Format TOML files
format_toml() {
  if ! has taplo; then
    warn "taplo not found, skipping TOML formatting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "toml")

  [[ ${#files[@]} -eq 0 ]] && return 0

  info "Formatting ${#files[@]} TOML file(s)..."
  local file count=0

  for file in "${files[@]}"; do
    [[ -f "$file" ]] || continue
    is_excluded "$file" && continue

    if taplo format "$file" 2> /dev/null; then
      if git diff --quiet "$file" 2> /dev/null; then
        : # No changes
      else
        MODIFIED_FILES+=("toml:$file")
        ((++count))
      fi
    else
      ERROR_FILES+=("toml:$file")
      ((++TOTAL_ERRORS))
    fi
  done

  ((count > 0)) && success "Formatted $count TOML file(s)"
  return 0
}

# Lint TOML files
lint_toml() {
  if ! has tombi; then
    warn "tombi not found, skipping TOML linting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "toml")

  [[ ${#files[@]} -eq 0 ]] && return 0

  info "Linting ${#files[@]} TOML file(s)..."
  local file errors=0

  for file in "${files[@]}"; do
    [[ -f "$file" ]] || continue
    is_excluded "$file" && continue

    if ! tombi lint "$file" 2> /dev/null; then
      ERROR_FILES+=("toml:$file")
      ((++errors))
      ((++TOTAL_ERRORS))
    fi
  done

  ((errors > 0)) && warn "Found $errors TOML error(s)" || success "TOML lint passed"
  return 0
}

# Format Markdown files
format_markdown() {
  if ! has mdformat; then
    warn "mdformat not found, skipping markdown formatting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "md")
  mapfile -t -O "${#files[@]}" files < <(discover_files "markdown")

  [[ ${#files[@]} -eq 0 ]] && return 0

  info "Formatting ${#files[@]} markdown file(s)..."
  local file count=0

  for file in "${files[@]}"; do
    [[ -f "$file" ]] || continue
    is_excluded "$file" && continue

    if mdformat --wrap 80 "$file" 2> /dev/null; then
      if git diff --quiet "$file" 2> /dev/null; then
        : # No changes
      else
        MODIFIED_FILES+=("markdown:$file")
        ((++count))
      fi
    else
      ERROR_FILES+=("markdown:$file")
      ((++TOTAL_ERRORS))
    fi
  done

  ((count > 0)) && success "Formatted $count markdown file(s)"
  return 0
}

# Lint GitHub Actions
lint_actions() {
  if ! has actionlint; then
    warn "actionlint not found, skipping GitHub Actions linting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "yml")
  mapfile -t -O "${#files[@]}" files < <(discover_files "yaml")

  [[ ${#files[@]} -eq 0 ]] && return 0

  # Filter for workflow files
  local -a workflows=()
  local file
  for file in "${files[@]}"; do
    [[ "$file" == *".github/workflows/"* ]] && workflows+=("$file")
  done

  [[ ${#workflows[@]} -eq 0 ]] && return 0

  info "Linting ${#workflows[@]} GitHub Actions workflow(s)..."

  if actionlint "${workflows[@]}" 2> /dev/null; then
    success "Actionlint passed"
  else
    ERROR_FILES+=("actions:${workflows[*]}")
    ((++TOTAL_ERRORS))
    return 1
  fi
}

# Format Python files
format_python() {
  if ! has ruff; then
    warn "ruff not found, skipping Python formatting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "py")

  [[ ${#files[@]} -eq 0 ]] && return 0

  # Only format files in repo root and etc/, not user-local files
  local -a repo_files=()
  local file
  for file in "${files[@]}"; do
    [[ -f "$file" ]] || continue
    is_excluded "$file" && continue
    # Skip user-local files
    [[ "$file" == "Home/.local/"* ]] && continue
    repo_files+=("$file")
  done

  [[ ${#repo_files[@]} -eq 0 ]] && return 0

  info "Formatting ${#repo_files[@]} Python file(s) with ruff..."

  if ruff format "${repo_files[@]}" 2> /dev/null; then
    local count
    count=$(git diff --name-only --diff-filter=ACMR 2> /dev/null | grep -c "\.py$" || echo "0")
    ((count > 0)) && success "Formatted $count Python file(s)"
  else
    ERROR_FILES+=("python:${repo_files[*]}")
    ((++TOTAL_ERRORS))
  fi

  return 0
}

# Lint Python files
lint_python() {
  if ! has ruff; then
    warn "ruff not found, skipping Python linting"
    return 0
  fi

  local -a files
  mapfile -t files < <(discover_files "py")

  [[ ${#files[@]} -eq 0 ]] && return 0

  info "Linting ${#files[@]} Python file(s) with ruff..."

  # Only lint files in repo root and etc/, not user-local files
  local -a repo_files=()
  local file
  for file in "${files[@]}"; do
    [[ -f "$file" ]] || continue
    is_excluded "$file" && continue
    # Skip user-local files
    [[ "$file" == "Home/.local/"* ]] && continue
    repo_files+=("$file")
  done

  [[ ${#repo_files[@]} -eq 0 ]] && return 0

  if ruff check --fix "${repo_files[@]}" 2> /dev/null; then
    success "Ruff lint passed"
  else
    ERROR_FILES+=("python:${repo_files[*]}")
    ((++TOTAL_ERRORS))
    return 1
  fi
}

# Generate report
generate_report() {
  printf '\n'
  printf '%b\n' "${BLD}${CYAN}=== Lint & Format Report ===${DEF}"
  printf '\n'

  printf '%b\n' "${BLD}Modified Files:${DEF} ${#MODIFIED_FILES[@]}"
  if [[ ${#MODIFIED_FILES[@]} -gt 0 ]]; then
    local entry
    for entry in "${MODIFIED_FILES[@]}"; do
      printf '  %s\n' "$entry"
    done
  fi

  printf '\n'
  printf '%b\n' "${BLD}Error Files:${DEF} ${#ERROR_FILES[@]}"
  if [[ ${#ERROR_FILES[@]} -gt 0 ]]; then
    local entry
    for entry in "${ERROR_FILES[@]}"; do
      printf '  %s\n' "$entry"
    done
  fi

  printf '\n'
  printf '%b\n' "${BLD}Total Errors:${DEF} $TOTAL_ERRORS"

  printf '\n'
  printf '%b\n' "${BLD}${CYAN}=== Commands to Reproduce ===${DEF}"
  printf '\n'
  printf '%s\n' "# YAML"
  printf '%s\n' "yamlfmt -conf .yamlfmt <file>"
  printf '%s\n' "yamllint -f parsable -c .yamllint.yaml <file>"
  printf '\n'
  printf '%s\n' "# JSON/CSS/JS/HTML"
  printf '%s\n' "biome format --write ."
  printf '%s\n' "biome check ."
  printf '\n'
  printf '%s\n' "# Shell"
  printf '%s\n' "shfmt -w -i 2 -ci -bn <file>"
  printf '%s\n' "shellcheck --format=gcc <file>"
  printf '\n'
  printf '%s\n' "# TOML"
  printf '%s\n' "taplo format <file>"
  printf '%s\n' "tombi lint <file>"
  printf '\n'
  printf '%s\n' "# Markdown"
  printf '%s\n' "mdformat --wrap 80 <file>"
  printf '\n'
  printf '%s\n' "# Python"
  printf '%s\n' "ruff format ."
  printf '%s\n' "ruff check --fix ."
  printf '\n'
  printf '%s\n' "# GitHub Actions"
  printf '%s\n' "actionlint .github/workflows/*.yml"
}

# Main pipeline
main() {
  cd "$SCRIPT_DIR" || die "Failed to change to script directory"

  info "Starting lint & format pipeline..."
  printf '\n'

  # Format phase (before lint)
  format_yaml
  format_biome
  format_shell
  format_fish
  format_toml
  format_markdown
  format_python

  printf '\n'
  info "Formatting complete, starting lint phase..."
  printf '\n'

  # Lint phase
  lint_yaml
  lint_biome
  lint_shell
  lint_toml
  lint_actions
  lint_python

  printf '\n'
  generate_report

  if [[ $TOTAL_ERRORS -gt 0 ]]; then
    printf '\n'
    die "Found $TOTAL_ERRORS error(s), exiting with code 1"
  fi

  if [[ ${#MODIFIED_FILES[@]} -gt 0 ]]; then
    printf '\n'
    success "Formatting complete. ${#MODIFIED_FILES[@]} file(s) modified."
  else
    printf '\n'
    success "All files are properly formatted and linted!"
  fi
}

main "$@"

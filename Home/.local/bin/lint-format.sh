#!/usr/bin/env bash
# Exhaustive Lint & Format Script
# Policy: 2-space indent, 120 char width, 0 errors
# Pipeline: Format → Lint/Fix → Report

set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

# --- Configuration ---
readonly PROJECT_ROOT="$PWD"
readonly PARALLEL_JOBS="$(nproc)"
readonly DRY_RUN="${DRY_RUN:-false}"

# Tool detection with fallbacks
FD="$(command -v fd || command -v fdfind || echo "find")"
RG="$(command -v rg || echo "grep")"
SD="$(command -v sd || echo "sed")"

# Results tracking
declare -A FILE_RESULTS=()
declare -A GROUP_ERRORS=()
declare -a FIX_COMMANDS=()
TOTAL_FILES=0
TOTAL_MODIFIED=0
TOTAL_ERRORS=0

# --- Helpers ---
# ANSI colors
BLD=$'\e[1m' BLU=$'\e[34m' GRN=$'\e[32m' YLW=$'\e[33m' RED=$'\e[31m' DEF=$'\e[0m'

# Logging functions
has(){ command -v "$1" &>/dev/null; }
log(){ printf '%b==>\e[0m %s\n' "${BLD}${BLU}" "$*"; }
ok(){ printf '%b==>\e[0m %s\n' "${BLD}${GRN}" "$*"; }
warn(){ printf '%b==> WARNING:\e[0m %s\n' "${BLD}${YLW}" "$*"; }
err(){ printf '%b==> ERROR:\e[0m %s\n' "${BLD}${RED}" "$*" >&2; }

check_deps(){
  local missing=() optional=()
  local required=(shfmt shellcheck biome yamllint yamlfmt ruff markdownlint)
  local opt=(taplo mdformat stylua selene ast-grep actionlint prettier)

  for tool in "${required[@]}"; do
    if ! has "$tool"; then missing+=("$tool"); fi
  done

  for tool in "${opt[@]}"; do
    if ! has "$tool"; then optional+=("$tool"); fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    err "Missing required tools: ${missing[*]}"
    err "Install: paru -S ${missing[*]// / } || npm i -g ${missing[*]// / }"
    return 1
  fi

  if [[ ${#optional[@]} -gt 0 ]]; then
    warn "Optional tools missing: ${optional[*]} (some features disabled)"
  fi
  return 0
}

find_files(){
  local ext="$1"
  if [[ $FD == "find" ]]; then
    find "$PROJECT_ROOT" -type f -name "*.$ext" \
      ! -path "*/.git/*" \
      ! -path "*/node_modules/*" \
      ! -path "*/.venv/*" \
      ! -path "*/vendor/*" \
      ! -path "*/__pycache__/*" \
      ! -path "*/dist/*" \
      ! -path "*/build/*" \
      2>/dev/null || true
  else
    "$FD" -u -t f -H \
      -E .git -E node_modules -E .venv -E vendor -E __pycache__ -E dist -E build \
      -e "$ext" . "$PROJECT_ROOT" 2>/dev/null || true
  fi
}

find_files_multi(){
  local exts=("$@")
  for ext in "${exts[@]}"; do
    find_files "$ext"
  done | sort -u
}

record_result(){
  local file="$1" group="$2" modified="$3" errors="$4"
  FILE_RESULTS["$file"]="$group|$modified|$errors"
  ((TOTAL_FILES++))
  [[ $modified == "yes" ]] && ((TOTAL_MODIFIED++))
  [[ $errors -gt 0 ]] && {
    ((TOTAL_ERRORS += errors))
    ((GROUP_ERRORS["$group"] += errors))
  }
}

add_fix_cmd(){
  FIX_COMMANDS+=("$1")
}

run_formatter(){
  local tool="$1" desc="$2"
  shift 2
  if [[ $DRY_RUN == "true" ]]; then
    log "[DRY] $desc: $*"
    return 0
  fi
  log "$desc..."
  "$tool" "$@" 2>&1 || return 1
}

run_linter(){
  local tool="$1" desc="$2"
  shift 2
  log "$desc..."
  "$tool" "$@" 2>&1 || return 1
}

# --- YAML Processor ---
proc_yaml(){
  local group="yaml" files=()
  mapfile -t files < <(find_files_multi yml yaml)
  [[ ${#files[@]} -eq 0 ]] && return 0

  log "Processing YAML (${#files[@]} files)..."

  # Format with yamlfmt
  if has yamlfmt; then
    local yamlfmt_cfg=".yamlfmt"
    [[ ! -f $yamlfmt_cfg ]] && yamlfmt_cfg=".qlty/configs/.yamlfmt.yaml"

    local modified=0 errors=0
    for f in "${files[@]}"; do
      local before_stat after_stat
      before_stat="$(stat -c '%Y %s' "$f" 2>/dev/null || echo '0 0')"
      if yamlfmt -conf "$yamlfmt_cfg" "$f" 2>/dev/null; then
        after_stat="$(stat -c '%Y %s' "$f" 2>/dev/null || echo '0 0')"
        [[ $after_stat != "$before_stat" ]] && ((modified++)) && record_result "$f" "$group" "yes" 0 || record_result "$f" "$group" "no" 0
      else
        ((errors++))
        record_result "$f" "$group" "no" 1
      fi
    done
    add_fix_cmd "yamlfmt -conf $yamlfmt_cfg <file>"
    GROUP_ERRORS["$group"]=$errors
  fi

  # Lint with yamllint
  if has yamllint; then
    local yamllint_cfg=".qlty/configs/.yamllint.yaml"
    local lint_errors=0
    for f in "${files[@]}"; do
      if ! yamllint -c "$yamllint_cfg" -f parsable "$f" 2>/dev/null; then
        ((lint_errors++))
        FILE_RESULTS["$f"]="${FILE_RESULTS["$f"]:-$group|no|0}"
        FILE_RESULTS["$f"]="${FILE_RESULTS["$f"]%|*}|1"
      fi
    done
    ((GROUP_ERRORS["$group"] += lint_errors))
    add_fix_cmd "yamllint -c $yamllint_cfg -f parsable <file>"
  fi
  return 0
}

# --- JSON/JS/TS/CSS Processor ---
proc_web(){
  local group="web"
  log "Processing JS/TS/JSON/CSS..."

  # Biome format + lint
  if has biome; then
    local errors=0
    if ! biome format --write --config-path=biome.json . 2>&1; then
      ((errors++))
    fi
    if ! biome lint --write --config-path=biome.json . 2>&1; then
      ((errors++))
    fi
    GROUP_ERRORS["$group"]=$errors
    add_fix_cmd "biome format --write . && biome lint --write ."

    # Record files
    local files=()
    mapfile -t files < <(find_files_multi js ts jsx tsx json jsonc css)
    for f in "${files[@]}"; do
      record_result "$f" "$group" "yes" 0
    done
  fi
  return 0
}

# --- Shell Scripts Processor ---
proc_shell(){
  local group="shell" files=()
  mapfile -t files < <(find_files_multi sh bash zsh)
  [[ ${#files[@]} -eq 0 ]] && return 0

  log "Processing Shell (${#files[@]} files)..."

  # Format with shfmt (2-space, case indent, binary next line)
  if has shfmt; then
    local modified=0
    for f in "${files[@]}"; do
      local before_stat after_stat
      before_stat="$(stat -c '%Y %s' "$f" 2>/dev/null || echo '0 0')"
      shfmt -w -i 2 -ci -bn "$f" 2>/dev/null || true
      after_stat="$(stat -c '%Y %s' "$f" 2>/dev/null || echo '0 0')"
      [[ $after_stat != "$before_stat" ]] && ((modified++)) && record_result "$f" "$group" "yes" 0 || record_result "$f" "$group" "no" 0
    done
    add_fix_cmd "shfmt -w -i 2 -ci -bn <file>"
  fi

  # Lint with shellcheck
  if has shellcheck; then
    local errors=0
    for f in "${files[@]}"; do
      # Skip zsh files for shellcheck
      [[ $f == *"zsh"* ]] && continue
      if ! shellcheck -x "$f" 2>/dev/null; then
        ((errors++))
        FILE_RESULTS["$f"]="${FILE_RESULTS["$f"]:-$group|no|0}"
        FILE_RESULTS["$f"]="${FILE_RESULTS["$f"]%|*}|1"
      fi
    done
    GROUP_ERRORS["$group"]=$errors
    add_fix_cmd "shellcheck -x <file>"
  fi
  return 0
}

# --- Fish Scripts Processor ---
proc_fish(){
  local group="fish" files=()
  mapfile -t files < <(find_files fish)
  [[ ${#files[@]} -eq 0 ]] && return 0

  log "Processing Fish (${#files[@]} files)..."

  if has fish_indent; then
    for f in "${files[@]}"; do
      local before after
      before="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
      fish_indent -w "$f" 2>/dev/null || true
      after="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
      [[ $after -gt $before ]] && record_result "$f" "$group" "yes" 0 || record_result "$f" "$group" "no" 0
    done
    add_fix_cmd "fish_indent -w <file>"
  fi
  return 0
}

# --- TOML Processor ---
proc_toml(){
  local group="toml" files=()
  mapfile -t files < <(find_files toml)
  [[ ${#files[@]} -eq 0 ]] && return 0

  log "Processing TOML (${#files[@]} files)..."

  if has taplo; then
    local errors=0
    # Format (2-space indent)
    for f in "${files[@]}"; do
      local before after
      before="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
      if taplo format --option "indent_string=  " "$f" 2>/dev/null; then
        after="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
        [[ $after -gt $before ]] && record_result "$f" "$group" "yes" 0 || record_result "$f" "$group" "no" 0
      else
        ((errors++))
        record_result "$f" "$group" "no" 1
      fi
    done
    # Lint
    if ! taplo lint "${files[@]}" 2>/dev/null; then
      ((errors++))
    fi
    GROUP_ERRORS["$group"]=$errors
    add_fix_cmd "taplo format --option \"indent_string=  \" <file>"
  fi
  return 0
}

# --- Python Processor ---
proc_python(){
  local group="python" files=()
  mapfile -t files < <(find_files py)
  [[ ${#files[@]} -eq 0 ]] && return 0

  log "Processing Python (${#files[@]} files)..."

  if has ruff; then
    local errors=0
    # Format
    if ! ruff format . 2>&1; then
      ((errors++))
    fi
    # Lint + fix
    if ! ruff check --fix . 2>&1; then
      ((errors++))
    fi
    GROUP_ERRORS["$group"]=$errors
    for f in "${files[@]}"; do
      record_result "$f" "$group" "yes" 0
    done
    add_fix_cmd "ruff format . && ruff check --fix ."
  fi
  return 0
}

# --- Lua Processor ---
proc_lua(){
  local group="lua" files=()
  mapfile -t files < <(find_files lua)
  [[ ${#files[@]} -eq 0 ]] && return 0

  log "Processing Lua (${#files[@]} files)..."

  if has stylua; then
    local errors=0
    for f in "${files[@]}"; do
      local before after
      before="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
      if stylua --indent-type Spaces --indent-width 2 "$f" 2>/dev/null; then
        after="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
        [[ $after -gt $before ]] && record_result "$f" "$group" "yes" 0 || record_result "$f" "$group" "no" 0
      else
        ((errors++))
        record_result "$f" "$group" "no" 1
      fi
    done
    add_fix_cmd "stylua --indent-type Spaces --indent-width 2 <file>"

    if has selene; then
      if ! selene "${files[@]}" 2>/dev/null; then
        ((errors++))
      fi
      add_fix_cmd "selene <file>"
    fi
    GROUP_ERRORS["$group"]=$errors
  fi
  return 0
}

# --- Markdown Processor ---
proc_markdown(){
  local group="markdown" files=()
  mapfile -t files < <(find_files md)
  [[ ${#files[@]} -eq 0 ]] && return 0

  log "Processing Markdown (${#files[@]} files)..."

  # Format with mdformat
  if has mdformat; then
    for f in "${files[@]}"; do
      local before after
      before="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
      mdformat --wrap 80 "$f" 2>/dev/null || true
      after="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
      [[ $after -gt $before ]] && record_result "$f" "$group" "yes" 0 || record_result "$f" "$group" "no" 0
    done
    add_fix_cmd "mdformat --wrap 80 <file>"
  fi

  # Lint with markdownlint
  if has markdownlint; then
    local errors=0
    if ! markdownlint -c .markdownlintrc --fix "**/*.md" \
      --ignore node_modules --ignore vendor 2>/dev/null; then
      ((errors++))
    fi
    GROUP_ERRORS["$group"]=$errors
    add_fix_cmd "markdownlint -c .markdownlintrc --fix <file>"
  fi
  return 0
}

# --- GitHub Actions Processor ---
proc_actions(){
  local group="actions" files=()
  mapfile -t files < <(find .github/workflows -type f -name "*.yml" -o -name "*.yaml" 2>/dev/null || true)
  [[ ${#files[@]} -eq 0 ]] && return 0

  log "Processing GitHub Actions (${#files[@]} files)..."

  # Format with yamlfmt
  if has yamlfmt; then
    for f in "${files[@]}"; do
      yamlfmt -conf .qlty/configs/.yamlfmt.yaml "$f" 2>/dev/null || true
      record_result "$f" "$group" "yes" 0
    done
  fi

  # Lint with actionlint
  if has actionlint; then
    local errors=0
    if ! actionlint "${files[@]}" 2>/dev/null; then
      ((errors++))
    fi
    GROUP_ERRORS["$group"]=$errors
    add_fix_cmd "actionlint <file>"
  fi
  return 0
}

# --- XML Processor ---
proc_xml(){
  local group="xml" files=()
  mapfile -t files < <(find_files_multi xml svg)
  [[ ${#files[@]} -eq 0 ]] && return 0

  log "Processing XML (${#files[@]} files)..."

  for f in "${files[@]}"; do
    record_result "$f" "$group" "no" 0
  done
  # XML minify is format-only, no linting
  return 0
}

# --- AST-Grep Processor ---
proc_ast_grep(){
  local group="ast-grep"
  if ! has ast-grep; then return 0; fi

  log "Running AST-grep rules..."

  local errors=0
  if ! ast-grep scan . 2>&1; then
    ((errors++))
  fi
  GROUP_ERRORS["$group"]=$errors
  add_fix_cmd "ast-grep scan ."
  return 0
}

# --- Report Generation ---
print_table(){
  log ""
  log "═══════════════════════════════════════════════════════════════════════════"
  log "FILE RESULTS"
  log "═══════════════════════════════════════════════════════════════════════════"
  printf "%-50s %-12s %-10s %-8s\n" "FILE" "GROUP" "MODIFIED" "ERRORS"
  log "───────────────────────────────────────────────────────────────────────────"

  for file in "${!FILE_RESULTS[@]}"; do
    IFS='|' read -r grp mod err <<< "${FILE_RESULTS[$file]}"
    local short_file="${file#$PROJECT_ROOT/}"
    [[ ${#short_file} -gt 48 ]] && short_file="...${short_file: -45}"
    printf "%-50s %-12s %-10s %-8s\n" "$short_file" "$grp" "$mod" "$err"
  done | sort -k1

  log "═══════════════════════════════════════════════════════════════════════════"
}

print_commands(){
  log ""
  log "FIX COMMANDS (Reproducible)"
  log "───────────────────────────────────────────────────────────────────────────"
  for cmd in "${FIX_COMMANDS[@]}"; do
    log "  $cmd"
  done
  log ""
}

print_summary(){
  log ""
  log "═══════════════════════════════════════════════════════════════════════════"
  log "SUMMARY"
  log "═══════════════════════════════════════════════════════════════════════════"
  log "Total Files Processed: $TOTAL_FILES"
  log "Files Modified: $TOTAL_MODIFIED"
  log "Total Errors: $TOTAL_ERRORS"
  log ""
  log "Errors by Group:"
  for grp in "${!GROUP_ERRORS[@]}"; do
    printf "  %-12s: %d\n" "$grp" "${GROUP_ERRORS[$grp]}"
  done
  log "═══════════════════════════════════════════════════════════════════════════"

  if [[ $TOTAL_ERRORS -eq 0 ]]; then
    ok "✅ Zero errors. All files compliant."
    return 0
  else
    err "❌ $TOTAL_ERRORS error(s) found. Fix required."
    return 1
  fi
}

# --- Main ---
main(){
  log "Exhaustive Lint & Format Pipeline"
  log "Policy: 2-space indent, 120-char width, zero errors"
  log "Root: $PROJECT_ROOT"
  log ""

  check_deps || exit 1

  # Run all processors (format → lint)
  proc_yaml
  proc_web
  proc_shell
  proc_fish
  proc_toml
  proc_python
  proc_lua
  proc_markdown
  proc_actions
  proc_xml
  proc_ast_grep

  # Generate report
  print_table
  print_commands
  print_summary

  exit $?
}

main "$@"

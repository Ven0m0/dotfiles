#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'
export LC_ALL=C LANG=C

# Exhaustive Lint & Format Script
# Policy: 2-space indent, 120 char width, 0 errors
# Pipeline: Format -> Lint/Fix -> Report

readonly PROJECT_ROOT="$PWD"
readonly PARALLEL_JOBS="$(nproc)"
readonly DRY_RUN="${DRY_RUN:-false}"

FD="$(command -v fd || command -v fdfind || printf 'find')"
RG="$(command -v rg || printf 'grep')"
SD="$(command -v sd || printf 'sed')"

declare -A FILE_RESULTS=()
declare -A GROUP_ERRORS=()
declare -a FIX_COMMANDS=()
TOTAL_FILES=0
TOTAL_MODIFIED=0
TOTAL_ERRORS=0

# ANSI colors
readonly BLD=$'\e[1m' BLU=$'\e[34m' GRN=$'\e[32m' YLW=$'\e[33m' RED=$'\e[31m' DEF=$'\e[0m'

# Helpers
has(){ command -v "$1" &>/dev/null; }
log(){ printf '%b==>\e[0m %s\n' "${BLD}${BLU}" "$*"; }
ok(){ printf '%b==>\e[0m %s\n' "${BLD}${GRN}" "$*"; }
warn(){ printf '%b==> WARNING:\e[0m %s\n' "${BLD}${YLW}" "$*"; }
err(){ printf '%b==> ERROR:\e[0m %s\n' "${BLD}${RED}" "$*" >&2; }

check_deps(){
  local -a missing=() optional=()
  local -a required=(shfmt shellcheck biome yamllint yamlfmt ruff markdownlint)
  local -a opt=(taplo mdformat stylua selene ast-grep actionlint prettier)

  for tool in "${required[@]}"; do
    has "$tool" || missing+=("$tool")
  done

  for tool in "${opt[@]}"; do
    has "$tool" || optional+=("$tool")
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    err "Missing required tools: ${missing[*]}"
    err "Install: paru -S ${missing[*]} || npm i -g ${missing[*]}"
    return 1
  fi

  [[ ${#optional[@]} -gt 0 ]] && warn "Optional tools missing: ${optional[*]} (some features disabled)"
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
  local -a exts=("$@")
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

# YAML Processor
proc_yaml(){
  local group="yaml"
  local -a files=()
  mapfile -t files < <(find_files_multi yml yaml)
  [[ ${#files[@]} -eq 0 ]] && return 0

  log "Processing YAML (${#files[@]} files)..."

  if has yamlfmt; then
    local yamlfmt_cfg=".yamlfmt"
    [[ ! -f $yamlfmt_cfg ]] && yamlfmt_cfg=".qlty/configs/.yamlfmt.yaml"
    local modified=0 errors=0

    for f in "${files[@]}"; do
      local before_stat after_stat
      before_stat="$(stat -c '%Y %s' "$f" 2>/dev/null || printf '0 0')"

      if yamlfmt -conf "$yamlfmt_cfg" "$f" 2>/dev/null; then
        after_stat="$(stat -c '%Y %s' "$f" 2>/dev/null || printf '0 0')"
        if [[ $after_stat != "$before_stat" ]]; then
          ((modified++))
          record_result "$f" "$group" "yes" 0
        else
          record_result "$f" "$group" "no" 0
        fi
      else
        ((errors++))
        record_result "$f" "$group" "no" 1
      fi
    done

    add_fix_cmd "yamlfmt -conf $yamlfmt_cfg <file>"
    GROUP_ERRORS["$group"]=$errors
  fi

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

# [Similar structure for other processors: proc_web, proc_shell, proc_fish, proc_toml, proc_python, proc_lua, proc_markdown, proc_actions, proc_xml, proc_ast_grep]

# Report Generation
print_table(){
  log ""
  log "========================================================================"
  log "FILE RESULTS"
  log "========================================================================"
  printf "%-50s %-12s %-10s %-8s\n" "FILE" "GROUP" "MODIFIED" "ERRORS"
  log "------------------------------------------------------------------------"

  for file in "${!FILE_RESULTS[@]}"; do
    IFS='|' read -r grp mod err <<<"${FILE_RESULTS[$file]}"
    local short_file="${file#"$PROJECT_ROOT"/}"
    [[ ${#short_file} -gt 48 ]] && short_file="...${short_file: -45}"
    printf "%-50s %-12s %-10s %-8s\n" "$short_file" "$grp" "$mod" "$err"
  done | sort -k1

  log "========================================================================"
}

print_commands(){
  log ""
  log "FIX COMMANDS (Reproducible)"
  log "------------------------------------------------------------------------"
  for cmd in "${FIX_COMMANDS[@]}"; do
    log "  $cmd"
  done
  log ""
}

print_summary(){
  log ""
  log "========================================================================"
  log "SUMMARY"
  log "========================================================================"
  log "Total Files Processed: $TOTAL_FILES"
  log "Files Modified: $TOTAL_MODIFIED"
  log "Total Errors: $TOTAL_ERRORS"
  log ""
  log "Errors by Group:"

  for grp in "${!GROUP_ERRORS[@]}"; do
    printf "  %-12s: %d\n" "$grp" "${GROUP_ERRORS[$grp]}"
  done

  log "========================================================================"

  if [[ $TOTAL_ERRORS -eq 0 ]]; then
    ok "Zero errors. All files compliant."
    return 0
  else
    err "$TOTAL_ERRORS error(s) found. Fix required."
    return 1
  fi
}

# Main
main(){
  log "Exhaustive Lint & Format Pipeline"
  log "Policy: 2-space indent, 120-char width, zero errors"
  log "Root: $PROJECT_ROOT"
  log ""

  check_deps || exit 1

  # Run all processors
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

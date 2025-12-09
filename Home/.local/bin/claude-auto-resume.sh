#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
IFS=$'\n\t'
VERSION="1.4.1"
DEFAULT_PROMPT="continue"
USE_CONTINUE_FLAG=false
EXECUTE_MODE=false
CUSTOM_COMMAND=""
TEST_MODE=false
TEST_WAIT_SECONDS=0
CLEANUP_DONE=false
CLAUDE_PID=""
cleanup_on_exit() {
  local exit_code=$?
  cleanup_resources
  if [[ $exit_code -ne 0 ]]; then
    echo ""
    echo "[INFO] Script terminated (exit code: $exit_code)"
    echo "[HINT] Use --help to see usage examples"
  fi
}
interrupt_handler() {
  echo ""
  echo "[INFO] Script interrupted by user (Ctrl+C)"
  echo "[INFO] Cleaning up and exiting gracefully..."
  cleanup_resources
  exit 130
}
cleanup_resources() {
  [[ $CLEANUP_DONE == true ]] && return
  if [[ -n $CLAUDE_PID ]]; then
    echo "[INFO] Terminating Claude CLI process (PID: $CLAUDE_PID)..."
    kill "$CLAUDE_PID" 2>/dev/null
    sleep 1
    kill -9 "$CLAUDE_PID" 2>/dev/null || :
  fi
  pkill -f "timeout.*claude" 2>/dev/null || :
  CLAUDE_PID=""
  CLEANUP_DONE=true
}
trap cleanup_on_exit EXIT
trap interrupt_handler INT TERM
execute_custom_command() {
  local command="$1" start_time=$(date +%s)
  echo "⚠️  WARNING: About to execute custom command: '$command'"
  echo "⚠️  This command will be executed with full shell privileges."
  echo "⚠️  Press Ctrl+C within 5 seconds to cancel..."
  for i in 5 4 3 2 1; do
    printf "\rExecuting in %d seconds... " "$i"; sleep 1
  done
  printf "\rExecuting custom command...                    \n"
  echo "Executing: $command"
  echo "===================="
  bash -c "$command"
  local exit_code=$?
  local end_time=$(date +%s) duration=$((end_time - start_time))
  echo "===================="
  echo "Command completed with exit code: $exit_code"
  echo "Execution time: ${duration} seconds"
  if [[ $exit_code -eq 0 ]]; then
    echo "✓ Custom command executed successfully."
  else
    echo "✗ Custom command failed with exit code: $exit_code"
    echo "[HINT] Check the command syntax and permissions."
    echo "[DEBUG] Command: $command"
  fi
  return "$exit_code"
}
extract_old_format_timestamp() {
  local claude_output="$1" resume_timestamp="${claude_output##*|}"
  if ! [[ $resume_timestamp =~ ^[0-9]+$ ]] || [[ $resume_timestamp -le 0 ]]; then
    echo "[ERROR] Failed to extract a valid resume timestamp from Claude output."
    echo "[HINT] Expected format: 'Claude AI usage limit reached|<timestamp>'"
    echo "[SUGGESTION] Check if Claude CLI output format has changed."
    echo "[DEBUG] Raw output: $claude_output"
    echo "[DEBUG] Extracted timestamp: '$resume_timestamp'"
    exit 2
  fi
  echo "$resume_timestamp"
}
extract_new_format_timestamp() {
  local claude_output="$1" reset_hour reset_period reset_hour_24
  local now_timestamp today_reset resume_timestamp
  if [[ $claude_output =~ resets\ ([0-9]+)(am|pm) ]]; then
    reset_hour="${BASH_REMATCH[1]}"
    reset_period="${BASH_REMATCH[2]}"
  else
    echo "[ERROR] Failed to extract reset time from new Claude output format."
    echo "[HINT] Expected format: 'X-hour limit reached ∙ resets Xam/pm'"
    echo "[SUGGESTION] Check if Claude CLI output format has changed."
    echo "[DEBUG] Raw output: $claude_output"
    exit 2
  fi
  # Convert to 24-hour format
  if [[ $reset_period == "am" ]]; then
    [[ $reset_hour == "12" ]] && reset_hour_24=0 || reset_hour_24=$reset_hour
  else
    [[ $reset_hour == "12" ]] && reset_hour_24=12 || reset_hour_24=$((reset_hour + 12))
  fi
  now_timestamp=$(date +%s)
  # Get today's reset time (GNU/BSD compatible)
  if date --version &>/dev/null; then
    today_reset=$(date -d "today ${reset_hour_24}:00:00" +%s)
  else
    today_reset=$(date -j -f "%Y-%m-%d %H:%M:%S" "$(date +%Y-%m-%d) ${reset_hour_24}:00:00" +%s)
  fi
  # If reset time passed, use tomorrow
  if [[ $now_timestamp -gt $today_reset ]]; then
    if date --version &>/dev/null; then
      resume_timestamp=$(date -d "tomorrow ${reset_hour_24}:00:00" +%s)
    else
      local tomorrow=$(date -j -v+1d +%Y-%m-%d)
      resume_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "${tomorrow} ${reset_hour_24}:00:00" +%s)
    fi
  else
    resume_timestamp=$today_reset
  fi
  echo "$resume_timestamp"
}
check_network_connectivity() {
  local connectivity_failed=true
  if ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
    connectivity_failed=false
  elif ping -c 1 -W 3 1.1.1.1 &>/dev/null; then
    connectivity_failed=false
  elif command -v curl &>/dev/null && curl -s --max-time 5 --connect-timeout 3 https://www.google.com &>/dev/null; then
    connectivity_failed=false
  elif command -v wget &>/dev/null && wget -q --timeout=5 --tries=1 -O /dev/null https://www.google.com 2>/dev/null; then
    connectivity_failed=false
  fi
  if [[ $connectivity_failed == true ]]; then
    echo "[ERROR] Network connectivity check failed."
    echo "[HINT] Claude CLI requires internet connection to function properly."
    echo "[SUGGESTION] Please check your internet connection and try again."
    echo "[DEBUG] Tested: ping 8.8.8.8, ping 1.1.1.1, and HTTPS connectivity"
    return 3
  fi; return 0
}

validate_claude_cli() {
  if ! command -v claude &>/dev/null; then
    echo "[ERROR] Claude CLI not found. Please install Claude CLI first."
    echo "[SUGGESTION] Visit https://claude.ai/code for installation instructions."
    echo "[DEBUG] Searched PATH for 'claude' command"
    exit 1
  fi
  if ! claude --help | grep -q "dangerously-skip-permissions"; then
    echo "[WARNING] Your Claude CLI version may not support --dangerously-skip-permissions flag."
    echo "[SUGGESTION] This script requires a recent version of Claude CLI. Please consider updating."
    echo "[DEBUG] Run 'claude --help' to see available options"
    echo "The script will continue but may fail during execution."
  fi
}
show_help() {
  cat <<'EOF'
Usage: claude-auto-resume [OPTIONS] [PROMPT]

Automatically resume Claude CLI tasks after usage limits are lifted.

OPTIONS:
    -p, --prompt PROMPT    Custom prompt (default: "continue")
    -c, --continue        Continue previous conversation
    -e, --execute COMMAND  Execute custom command after usage limit wait period
    --cmd COMMAND         Execute custom command after usage limit wait period (alias for -e)
    -h, --help           Show this help
    -v, --version        Show version information
    --check              Show system check information
    --test-mode SECONDS   [DEV] Simulate usage limit with specified wait time in seconds

EXAMPLES:
    claude-auto-resume "implement feature"
    claude-auto-resume -c "continue task"
    claude-auto-resume -p "write tests"
    claude-auto-resume -e "npm run dev"     # Executes after usage limit wait
    claude-auto-resume --cmd "python app.py"  # Executes after usage limit wait
    claude-auto-resume --test-mode 10 -e "echo test"  # [DEV] Test with 10s wait

⚠️  Uses --dangerously-skip-permissions. Use only in trusted environments.
⚠️  Custom command execution allows arbitrary shell commands. Use with caution.
EOF
}
# Parse arguments
CUSTOM_PROMPT="$DEFAULT_PROMPT"
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--prompt)
      [[ -z ${2:-} ]] && {
        echo "[ERROR] Option $1 requires a prompt argument."
        echo "[HINT] Provide a prompt after $1 flag."
        echo "[SUGGESTION] Example: claude-auto-resume $1 'continue with task'"
        exit 1
      }
      CUSTOM_PROMPT="$2"; shift 2 ;;
    -c|--continue)  USE_CONTINUE_FLAG=true; shift ;;
    -e|--execute|--cmd)
      [[ -z ${2:-} ]] && {
        echo "[ERROR] Option $1 requires a command argument."
        echo "[HINT] Provide a command to execute after $1 flag."
        echo "[SUGGESTION] Example: claude-auto-resume $1 'npm run dev'"
        exit 1
      }
      EXECUTE_MODE=true; CUSTOM_COMMAND="$2"; shift 2 ;;
    -h|--help) show_help; exit 0 ;;
    -v|--version) echo "claude-auto-resume v${VERSION}"; exit 0 ;;
    --test-mode)
      if [[ -z ${2:-} ]] || ! [[ ${2:-} =~ ^[0-9]+$ ]]; then
        echo "[ERROR] Option $1 requires a valid number of seconds."
        echo "[HINT] Provide number of seconds to simulate wait period."
        echo "[SUGGESTION] Example: claude-auto-resume --test-mode 10 -e 'echo test'"
        exit 1
      fi
      TEST_MODE=true
      TEST_WAIT_SECONDS="$2"
      shift 2 ;;
    --check)
      echo "claude-auto-resume v${VERSION} - System Check"
      echo "================================================"
      echo ""
      echo "Script Information:"
      echo "  Version: ${VERSION}"
      echo "  Location: $(realpath "$0")"
      echo ""
      echo "Claude CLI Information:"
      if command -v claude &>/dev/null; then
        echo "  Status: Available"
        echo "  Location: $(command -v claude)"
        echo "  Version: $(claude --version 2>/dev/null || echo "Unknown")"
        
        if claude --help | grep -q "dangerously-skip-permissions"; then
          echo "  --dangerously-skip-permissions: Supported"
        else
          echo "  --dangerously-skip-permissions: Not supported"
        fi
      else
        echo "  Status: Not found"
        echo "  [ERROR] Claude CLI not found in PATH"
      fi
      echo ""
      echo "System Compatibility:"
      echo "  OS: $(uname -s)"
      echo "  Architecture: $(uname -m)"
      echo "  Shell: $SHELL"
      echo ""
      echo "Network Utilities:"
      echo "  ping: $(command -v ping &>/dev/null && echo "Available" || echo "Not found")"
      echo "  curl: $(command -v curl &>/dev/null && echo "Available" || echo "Not found")"
      echo "  wget: $(command -v wget &>/dev/null && echo "Available" || echo "Not found")"
      echo ""
      echo "Environment Validation:"
      if command -v claude &>/dev/null; then
        echo "  Claude CLI: ✓ Available"
      else
        echo "  Claude CLI: ✗ Not found"
      fi
      echo -n "  Network connectivity: "
      if check_network_connectivity &>/dev/null; then
        echo "✓ Connected"
      else
        echo "✗ Failed"
      fi
      exit 0 ;;
    -*) echo "Unknown option: $1"; show_help; exit 1 ;;
    *) CUSTOM_PROMPT="$1"; shift ;;
     
  esac
done
# Validate arguments
if [[ $EXECUTE_MODE == true && $USE_CONTINUE_FLAG == true ]]; then
  echo "[ERROR] Cannot use both custom command execution (-e/--execute/--cmd) and continue flag (-c/--continue)."
  echo "[HINT] Choose either Claude conversation continuation or custom command execution."
  echo "[SUGGESTION] Use 'claude-auto-resume --help' to see usage examples."
  exit 1
fi
if [[ $EXECUTE_MODE == true && -z $CUSTOM_COMMAND ]]; then
  echo "[ERROR] Custom command cannot be empty when using execute mode."
  echo "[HINT] Provide a command to execute after -e/--execute/--cmd flag."
  echo "[SUGGESTION] Example: claude-auto-resume -e 'npm run dev'"
  exit 1
fi
# Validate environment
[[ $EXECUTE_MODE == false ]] && validate_claude_cli
echo "Checking network connectivity..."
check_network_connectivity || exit 3
echo "Network connectivity confirmed."
# Run Claude CLI check
if [[ $EXECUTE_MODE == true ]]; then
  echo "Execute mode detected. Checking for usage limits..."
  echo "[INFO] This check may take 1-2 minutes depending on network conditions..."
  
  if command -v claude &>/dev/null; then
    CLAUDE_OUTPUT=$(timeout 300s claude -p 'check' 2>&1)
    RET_CODE=$?
  else
    echo "[WARNING] Claude CLI not found. Skipping usage limit check in execute mode."
    CLAUDE_OUTPUT=""
    RET_CODE=0
  fi
else
  echo "Executing Claude CLI command..."
  echo "[INFO] This check may take 1-2 minutes depending on network conditions..."
  CLAUDE_OUTPUT=$(timeout 300s claude -p 'check' 2>&1)
  RET_CODE=$?
fi
# Check for timeout
if [[ $RET_CODE -eq 124 ]]; then
  if [[ $EXECUTE_MODE == true ]]; then
    echo "[WARNING] Claude CLI operation timed out after 300 seconds in execute mode."
    echo "[HINT] Will proceed with custom command execution without usage limit detection."
  else
    echo "[ERROR] Claude CLI operation timed out after 300 seconds."
    echo "[HINT] This may indicate network issues or Claude service problems."
    echo "[SUGGESTION] Try again in a few minutes, or check Claude service status."
    echo "[DEBUG] Command executed: timeout 300s claude -p 'check'"
    exit 3
  fi
fi
# Check for empty output
if [[ -z $CLAUDE_OUTPUT && $RET_CODE -eq 0 && $EXECUTE_MODE == false ]]; then
  echo "[ERROR] Claude CLI returned empty output unexpectedly."
  echo "[HINT] This may indicate Claude CLI installation or configuration issues."
  echo "[SUGGESTION] Try running 'claude --help' to verify CLI is working properly."
  echo "[DEBUG] Command succeeded but returned no output"
  exit 5
fi
# Check for usage limit
LIMIT_MSG=""
if [[ $CLAUDE_OUTPUT =~ (Claude\ AI\ usage\ limit\ reached|limit\ reached.*resets) ]]; then
  LIMIT_MSG="${BASH_REMATCH[0]}"
fi
# Test mode simulation
[[ $TEST_MODE == true ]] && {
  echo "[TEST MODE] Simulating usage limit with ${TEST_WAIT_SECONDS} seconds wait time..."
  LIMIT_MSG="Claude AI usage limit reached|simulated"
}
if [[ -n $LIMIT_MSG ]]; then
  if [[ $TEST_MODE == true ]]; then
    NOW_TIMESTAMP=$(date +%s)
    RESUME_TIMESTAMP=$((NOW_TIMESTAMP + TEST_WAIT_SECONDS))
    WAIT_SECONDS=$TEST_WAIT_SECONDS
  else
    if [[ $CLAUDE_OUTPUT == *"Claude AI usage limit reached|"* ]]; then
      RESUME_TIMESTAMP=$(extract_old_format_timestamp "$CLAUDE_OUTPUT")
    else
      RESUME_TIMESTAMP=$(extract_new_format_timestamp "$CLAUDE_OUTPUT")
    fi
    NOW_TIMESTAMP=$(date +%s)
    WAIT_SECONDS=$((RESUME_TIMESTAMP - NOW_TIMESTAMP))
  fi
  if [[ $WAIT_SECONDS -le 0 ]]; then
    echo "Resume time has arrived. Retrying now."
  else
    # Format resume time
    if date --version &>/dev/null; then
      RESUME_TIME_FMT=$(date -d "@$RESUME_TIMESTAMP" "+%Y-%m-%d %H:%M:%S")
    else
      RESUME_TIME_FMT=$(date -r "$RESUME_TIMESTAMP" "+%Y-%m-%d %H:%M:%S")
    fi
    if [[ -z $RESUME_TIME_FMT || $RESUME_TIME_FMT == *"?"* ]]; then
      echo "Claude usage limit detected. Waiting for $WAIT_SECONDS seconds (failed to format resume time, raw timestamp: $RESUME_TIMESTAMP)..."
    else
      echo "Claude usage limit detected. Waiting until $RESUME_TIME_FMT..."
    fi
    # Live countdown
    while [[ $WAIT_SECONDS -gt 0 ]]; do
      printf "\rResuming in %02d:%02d:%02d..." $((WAIT_SECONDS / 3600)) $(((WAIT_SECONDS % 3600) / 60)) $((WAIT_SECONDS % 60))
      sleep 1
      NOW_TIMESTAMP=$(date +%s)
      WAIT_SECONDS=$((RESUME_TIMESTAMP - NOW_TIMESTAMP))
    done
    printf "\rResume time has arrived. Retrying now.           \n"
  fi
  sleep 10
  # Re-check network
  if [[ $EXECUTE_MODE == false ]]; then
    echo "Re-checking network connectivity before resuming..."
    check_network_connectivity || {
      echo "[ERROR] Network connectivity lost during wait period."
      echo "[SUGGESTION] Please check your internet connection and run the script again."
      exit 3
    }
  fi
  # Execute appropriate command
  if [[ $EXECUTE_MODE == true ]]; then
    echo "Executing custom command after wait period..."
    execute_custom_command "$CUSTOM_COMMAND"
    RET_CODE2=$?
    if [[ $RET_CODE2 -ne 0 ]]; then
      echo "[ERROR] Custom command failed with exit code: $RET_CODE2"
      echo "[HINT] Check the command syntax and permissions."
      echo "[DEBUG] Command: $CUSTOM_COMMAND"
      exit 4
    fi
    echo "Custom command has been executed successfully."
  else
    if [[ $USE_CONTINUE_FLAG == true ]]; then
      echo "Automatically continuing previous Claude conversation with prompt: '$CUSTOM_PROMPT'"
      CLAUDE_OUTPUT2=$(claude -c --dangerously-skip-permissions -p "$CUSTOM_PROMPT" 2>&1)
      RET_CODE2=$?
    else
      echo "Automatically starting new Claude session with prompt: '$CUSTOM_PROMPT'"
      CLAUDE_OUTPUT2=$(claude --dangerously-skip-permissions -p "$CUSTOM_PROMPT" 2>&1)
      RET_CODE2=$?
    fi
    if [[ $RET_CODE2 -ne 0 ]]; then
      echo "[ERROR] Claude CLI failed after resume."
      echo "[HINT] This may indicate authentication issues or service problems."
      echo "[SUGGESTION] Try running 'claude --help' to verify CLI is working properly."
      echo "[DEBUG] Exit code: $RET_CODE2"
      echo "[DEBUG] Output: $CLAUDE_OUTPUT2"
      exit 4
    fi
    echo "Task has been automatically resumed and completed."
    printf "CLAUDE_OUTPUT: \n"
    echo "$CLAUDE_OUTPUT2"
  fi
  exit 0
fi
# Handle failures
if [[ $RET_CODE -ne 0 && $EXECUTE_MODE == false ]]; then
  echo "[ERROR] Claude CLI execution failed."
  echo "[HINT] This may indicate authentication, network, or service issues."
  echo "[SUGGESTION] Check your Claude CLI authentication and try again."
  echo "[DEBUG] Exit code: $RET_CODE"
  echo "[DEBUG] Command executed: claude -p 'check'"
  echo "[DEBUG] Output: $CLAUDE_OUTPUT"
  exit 1
fi
# Execute mode with no limit
if [[ $EXECUTE_MODE == true ]]; then
  echo "No usage limit detected. Custom command will only execute after a usage limit wait period."
  echo "Since there is no usage limit, the custom command will not be executed."
  echo "Use claude-auto-resume in execute mode only when you expect usage limits."
  exit 0
fi
echo "No waiting required. Task completed."
exit 0

#!/usr/bin/env bash
# PostToolUse hook for Claude Code
#
# Logs every successful Edit / Write / MultiEdit / NotebookEdit into
#   $CLAUDE_PROJECT_DIR/.claude/edits.log
#
# Each line: ISO timestamp | tool | file path | session id
#
# Claude Code calls this script after a matching tool finishes. The hook
# receives a JSON payload on STDIN, e.g.:
# {
#   "session_id": "abc123",
#   "tool_name": "Edit",
#   "tool_input": { "file_path": "/path/to/file.ts", ... },
#   "tool_response": { ... },
#   "cwd": "/path/to/project"
# }
#
# We always exit 0 so we never block the tool — this is observability,
# not enforcement.

set -euo pipefail

# Read stdin (the JSON payload)
input="$(cat)"

tool="$(printf '%s' "$input" | jq -r '.tool_name // "unknown"')"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // "n/a"')"
session="$(printf '%s' "$input" | jq -r '.session_id // "n/a"')"
timestamp="$(date '+%Y-%m-%dT%H:%M:%S%z')"

# Resolve project dir (Claude sets CLAUDE_PROJECT_DIR; fall back to cwd)
project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
log_dir="$project_dir/.claude"
log_file="$log_dir/edits.log"

mkdir -p "$log_dir"

# Skip logging when the file path is the log file itself (avoid recursion)
case "$file" in
  "$log_file"|*"/.claude/edits.log") exit 0 ;;
esac

printf '%s | %-12s | %s | %s\n' "$timestamp" "$tool" "$file" "$session" >> "$log_file"

exit 0

#!/usr/bin/env bash
# detect_thread_states.sh - Detect thread states for bot comments
# Usage: ./fetch_pr_comments.sh owner repo pr | ./detect_thread_states.sh
#
# Reads JSON from fetch_pr_comments.sh and adds state detection
# Uses external jq file to avoid shell escaping issues and ensure null safety
#
# States:
#   NEW      - Bot comment with no user reply
#   PENDING  - User replied, bot hasn't responded
#   RESOLVED - Bot response indicates approval
#   REJECTED - Bot response indicates rejection

set -euo pipefail

# Get script directory for relative jq file path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JQ_FILE="$SCRIPT_DIR/detect_states.jq"

# Verify jq file exists
if [[ ! -f "$JQ_FILE" ]]; then
  echo "Error: jq file not found at $JQ_FILE" >&2
  exit 1
fi

# Read stdin into variable to validate before processing
INPUT=$(cat)

# Validate input is valid JSON (capture jq errors for better diagnostics)
JQ_STDERR=$(mktemp)
trap 'rm -f "$JQ_STDERR"' EXIT

if ! echo "$INPUT" | jq empty 2>"$JQ_STDERR"; then
  echo "Error: Invalid JSON input: $(cat "$JQ_STDERR")" >&2
  exit 1
fi

# Process with jq
echo "$INPUT" | jq -f "$JQ_FILE"

#!/bin/bash
#
# update_billboard.sh
# Updates the state file billboard section after each gate
#
# Usage: update_billboard.sh <state_file> <status> <next_gate> <next_action>
#
# Example:
#   update_billboard.sh ".claude/bot-reviews/PR-32.md" "collected" "2" "Read phases/gate-2-validate.md"

set -euo pipefail

STATE_FILE="${1:?Usage: $0 <state_file> <status> <next_gate> <next_action>}"
STATUS="${2:?Missing status}"
NEXT_GATE="${3:?Missing next_gate}"
NEXT_ACTION="${4:?Missing next_action}"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "Error: State file not found: $STATE_FILE" >&2
  exit 1
fi

# Get script directory for update_state.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update frontmatter fields
"$SCRIPT_DIR/update_state.sh" "$STATE_FILE" status "$STATUS"
"$SCRIPT_DIR/update_state.sh" "$STATE_FILE" next_gate "$NEXT_GATE"
"$SCRIPT_DIR/update_state.sh" "$STATE_FILE" next_action "$NEXT_ACTION"
"$SCRIPT_DIR/update_state.sh" "$STATE_FILE" last_updated "$(date -Iseconds)"

# Determine gate file name
case "$NEXT_GATE" in
  1) GATE_FILE="gate-1-collect.md" ;;
  2) GATE_FILE="gate-2-validate.md" ;;
  3) GATE_FILE="gate-3-fix.md" ;;
  4) GATE_FILE="gate-4-commit.md" ;;
  5) GATE_FILE="gate-5-reply.md" ;;
  6) GATE_FILE="gate-6-push.md" ;;
  *) GATE_FILE="unknown" ;;
esac

# Update billboard table in the markdown body
# The billboard is between "# ⚠️ WORKFLOW ACTIVE" and the first "---" after it

# Create new billboard content
NEW_BILLBOARD="| Field | Value |
|-------|-------|
| **Status** | \`$STATUS\` |
| **Next Gate** | $NEXT_GATE |
| **Next Action** | Read \`phases/$GATE_FILE\` |"

# Use awk to replace the billboard table
TMP_FILE="${STATE_FILE}.tmp.$$"
trap 'rm -f "$TMP_FILE"' EXIT

awk -v new_billboard="$NEW_BILLBOARD" '
  /^# ⚠️ WORKFLOW ACTIVE/ {
    print;
    print "";
    in_billboard = 1;
    next
  }
  in_billboard && /^\| Field/ {
    skip_table = 1
  }
  in_billboard && skip_table && /^$/ {
    print new_billboard;
    print "";
    skip_table = 0;
    in_billboard = 0;
    next
  }
  in_billboard && skip_table {
    next
  }
  { print }
' "$STATE_FILE" > "$TMP_FILE"

# Validate awk output before replacing original
if [[ ! -s "$TMP_FILE" ]]; then
  echo "Error: awk produced empty output, state file not updated" >&2
  exit 1
fi

# Check that the temp file has at least as many lines as original (sanity check)
ORIG_LINES=$(wc -l < "$STATE_FILE")
NEW_LINES=$(wc -l < "$TMP_FILE")
if [[ $NEW_LINES -lt $((ORIG_LINES / 2)) ]]; then
  echo "Error: awk output suspiciously small ($NEW_LINES lines vs $ORIG_LINES), aborting" >&2
  exit 1
fi

mv "$TMP_FILE" "$STATE_FILE"
trap - EXIT  # Clear the trap since we successfully moved the file

echo "✅ Billboard updated: status=$STATUS, next_gate=$NEXT_GATE"

#!/bin/bash
# update_state.sh - Update state file fields
# Usage: ./update_state.sh <state_file> <field> <value>
#
# Examples:
#   ./update_state.sh .claude/bot-reviews/PR-32.md status validated
#   ./update_state.sh .claude/bot-reviews/PR-32.md current_cycle 3
#   ./update_state.sh .claude/bot-reviews/PR-32.md last_updated "$(date -Iseconds)"
#   ./update_state.sh .claude/bot-reviews/PR-32.md replied_comment_ids "[123, 456, 789]"

set -e

STATE_FILE="${1:?Usage: $0 <state_file> <field> <value>}"
FIELD="${2:?Usage: $0 <state_file> <field> <value>}"
VALUE="${3:?Usage: $0 <state_file> <field> <value>}"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "Error: State file not found: $STATE_FILE" >&2
  exit 1
fi

# Check if field exists in frontmatter
if grep -q "^${FIELD}:" "$STATE_FILE"; then
  # Update existing field
  sed -i "s|^${FIELD}:.*|${FIELD}: ${VALUE}|" "$STATE_FILE"
  echo "Updated: ${FIELD}: ${VALUE}"
else
  # Add new field (before the closing ---)
  sed -i "/^---$/,/^---$/{
    /^---$/b
    :a
    n
    /^---$/i\\
${FIELD}: ${VALUE}
    /^---$/b
    ba
  }" "$STATE_FILE"
  echo "Added: ${FIELD}: ${VALUE}"
fi

# Always update last_updated
if [[ "$FIELD" != "last_updated" ]]; then
  TIMESTAMP=$(date -Iseconds)
  sed -i "s|^last_updated:.*|last_updated: ${TIMESTAMP}|" "$STATE_FILE"
  echo "Updated: last_updated: ${TIMESTAMP}"
fi

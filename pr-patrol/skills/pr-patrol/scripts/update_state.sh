#!/usr/bin/env bash
# update_state.sh - Update state file fields
# Usage: ./update_state.sh <state_file> <field> <value>
#
# Examples:
#   ./update_state.sh .claude/bot-reviews/PR-32.md status validated
#   ./update_state.sh .claude/bot-reviews/PR-32.md current_cycle 3
#   ./update_state.sh .claude/bot-reviews/PR-32.md last_updated "$(date -Iseconds)"
#   ./update_state.sh .claude/bot-reviews/PR-32.md replied_comment_ids "[123, 456, 789]"

set -euo pipefail

STATE_FILE="${1:?Usage: $0 <state_file> <field> <value>}"
FIELD="${2:?Usage: $0 <state_file> <field> <value>}"
VALUE="${3:?Usage: $0 <state_file> <field> <value>}"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "Error: State file not found: $STATE_FILE" >&2
  exit 1
fi

if [[ ! -w "$STATE_FILE" ]]; then
  echo "Error: State file not writable: $STATE_FILE" >&2
  exit 1
fi

# Escape special characters for sed replacement
# This prevents injection attacks from malicious field/value content
# Note: We use | as delimiter, so it must also be escaped
escape_sed() {
  printf '%s\n' "$1" | sed 's/[&/\|]/\\&/g'
}

ESCAPED_FIELD=$(escape_sed "$FIELD")
ESCAPED_VALUE=$(escape_sed "$VALUE")

# Portable sed -i (works on both Linux and macOS)
sed_inplace() {
  local file="$1"
  shift
  local tmp_file="${file}.tmp.$$"

  if sed "$@" "$file" > "$tmp_file"; then
    if [[ -s "$tmp_file" ]]; then
      mv "$tmp_file" "$file"
    else
      echo "Error: sed produced empty output" >&2
      rm -f "$tmp_file"
      exit 1
    fi
  else
    echo "Error: sed command failed" >&2
    rm -f "$tmp_file"
    exit 1
  fi
}

# Check if field exists in frontmatter
if grep -q "^${FIELD}:" "$STATE_FILE"; then
  # Update existing field
  sed_inplace "$STATE_FILE" "s|^${ESCAPED_FIELD}:.*|${FIELD}: ${ESCAPED_VALUE}|"

  # Verify the change was made
  if ! grep -q "^${FIELD}:" "$STATE_FILE"; then
    echo "Error: Failed to update field '$FIELD'" >&2
    exit 1
  fi
  echo "Updated: ${FIELD}: ${VALUE}"
else
  # Add new field before the closing ---
  # Using awk for better portability and safety
  tmp_file="${STATE_FILE}.tmp.$$"
  awk -v field="$FIELD" -v value="$VALUE" '
    /^---$/ && seen_first {
      print field ": " value
      print
      next
    }
    /^---$/ { seen_first = 1 }
    { print }
  ' "$STATE_FILE" > "$tmp_file"

  if [[ -s "$tmp_file" ]]; then
    mv "$tmp_file" "$STATE_FILE"
    echo "Added: ${FIELD}: ${VALUE}"
  else
    echo "Error: Failed to add field '$FIELD'" >&2
    rm -f "$tmp_file"
    exit 1
  fi
fi

# Always update last_updated (unless that's what we just updated)
if [[ "$FIELD" != "last_updated" ]]; then
  TIMESTAMP=$(date -Iseconds)
  ESCAPED_TIMESTAMP=$(escape_sed "$TIMESTAMP")

  if grep -q "^last_updated:" "$STATE_FILE"; then
    sed_inplace "$STATE_FILE" "s|^last_updated:.*|last_updated: ${ESCAPED_TIMESTAMP}|"
    echo "Updated: last_updated: ${TIMESTAMP}"
  fi
fi

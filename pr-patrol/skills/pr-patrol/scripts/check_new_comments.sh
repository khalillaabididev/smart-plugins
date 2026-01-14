#!/usr/bin/env bash
# check_new_comments.sh - Check for new bot comments since last push
# Usage: ./check_new_comments.sh <owner> <repo> <pr> [since_timestamp]
#
# If since_timestamp not provided, uses last push time from git
#
# Returns JSON with:
#   - new_comments: Bot comments created after timestamp
#   - summary: Count by bot
#   - needs_review: true if any new comments found

set -euo pipefail

OWNER="${1:?Usage: $0 <owner> <repo> <pr> [since_timestamp]}"
REPO="${2:?Usage: $0 <owner> <repo> <pr> [since_timestamp]}"
PR="${3:?Usage: $0 <owner> <repo> <pr> [since_timestamp]}"
SINCE="${4:-}"

# Get script directory for jq files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If no timestamp provided, get from last push
if [[ -z "$SINCE" ]]; then
  SINCE=$(git log -1 --format=%cI "origin/$(git rev-parse --abbrev-ref HEAD)" 2>/dev/null) || {
    echo "Warning: Could not get last push time, using epoch" >&2
    SINCE="1970-01-01T00:00:00Z"
  }
fi

# CRITICAL: Normalize timestamp to UTC for consistent comparison
# GitHub API returns timestamps in UTC (Z suffix)
# But local timestamps may have timezone offset (+03:00)
# String comparison fails: "11:30Z" vs "14:22+03:00" → 11 < 14 (WRONG!)
DATE_STDERR=$(mktemp)
if SINCE_NORMALIZED=$(date -u -d "$SINCE" +"%Y-%m-%dT%H:%M:%SZ" 2>"$DATE_STDERR"); then
  SINCE="$SINCE_NORMALIZED"
else
  echo "Warning: Could not normalize timestamp '$SINCE' ($(cat "$DATE_STDERR")), using as-is" >&2
fi
rm -f "$DATE_STDERR"

# Temporary file for error capture
STDERR_FILE=$(mktemp)
trap 'rm -f "$STDERR_FILE"' EXIT

# Fetch PR review comments with error handling
if ! PR_COMMENTS=$(gh api "repos/$OWNER/$REPO/pulls/$PR/comments" --paginate 2>"$STDERR_FILE"); then
  echo "Error: Failed to fetch PR comments: $(cat "$STDERR_FILE")" >&2
  exit 1
fi

# Fetch issue comments with error handling
if ! ISSUE_COMMENTS=$(gh api "repos/$OWNER/$REPO/issues/$PR/comments" --paginate 2>"$STDERR_FILE"); then
  echo "Error: Failed to fetch issue comments: $(cat "$STDERR_FILE")" >&2
  exit 1
fi

# Combine and process
{
  echo "$PR_COMMENTS"
  echo "$ISSUE_COMMENTS"
} | jq -s -L "$SCRIPT_DIR" --arg since "$SINCE" '
include "bot-detection";

add |
[.[] |
  select(.user.login | is_ignored_bot | not) |
  select(.user.type == "Bot" or (.user.login | is_review_bot)) |
  select(.in_reply_to_id == null) |
  select(.created_at > $since) |
  {
    id,
    bot: .user.login,
    path: (.path // "issue-level"),
    line,
    created_at,
    body_preview: (.body | gsub("[\\u0000-\\u001f]"; "") | .[0:150])
  }
] |
{
  since: $since,
  new_comments: .,
  count: length,
  by_bot: (group_by(.bot) | map({bot: .[0].bot, count: length})),
  needs_review: (length > 0),
  copilot_count: ([.[] | select(.bot == "Copilot")] | length),
  actionable_count: ([.[] | select(.bot != "Copilot")] | length)
}
'

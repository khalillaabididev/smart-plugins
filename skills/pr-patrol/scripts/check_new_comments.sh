#!/bin/bash
# check_new_comments.sh - Check for new bot comments since last push
# Usage: ./check_new_comments.sh <owner> <repo> <pr> [since_timestamp]
#
# If since_timestamp not provided, uses last push time from git
#
# Returns JSON with:
#   - new_comments: Bot comments created after timestamp
#   - summary: Count by bot
#   - needs_review: true if any new comments found

set -e

OWNER="${1:?Usage: $0 <owner> <repo> <pr> [since_timestamp]}"
REPO="${2:?Usage: $0 <owner> <repo> <pr> [since_timestamp]}"
PR="${3:?Usage: $0 <owner> <repo> <pr> [since_timestamp]}"
SINCE="${4:-}"

# Get script directory for jq files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If no timestamp provided, get from last push
if [ -z "$SINCE" ]; then
  SINCE=$(git log -1 --format=%cI "origin/$(git rev-parse --abbrev-ref HEAD)" 2>/dev/null || echo "1970-01-01T00:00:00Z")
fi

# CRITICAL: Normalize timestamp to UTC for consistent comparison
# GitHub API returns timestamps in UTC (Z suffix)
# But local timestamps may have timezone offset (+03:00)
# String comparison fails: "11:30Z" vs "14:22+03:00" → 11 < 14 (WRONG!)
SINCE=$(date -u -d "$SINCE" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "$SINCE")

# Fetch and filter comments
{
  gh api "repos/$OWNER/$REPO/pulls/$PR/comments" --paginate &
  gh api "repos/$OWNER/$REPO/issues/$PR/comments" --paginate &
  wait
} 2>/dev/null | jq -s --arg since "$SINCE" '
# Ignored bots (not review bots)
def is_ignored_bot:
  . as $login |
  ["vercel[bot]", "dependabot[bot]", "renovate[bot]", "github-actions[bot]"] |
  any(. == $login);

# Review bot detection
def is_review_bot:
  . as $login |
  ($login | test("coderabbit|greptile|codex|sentry"; "i")) or
  ($login == "Copilot") or
  ($login == "chatgpt-codex-connector[bot]");

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

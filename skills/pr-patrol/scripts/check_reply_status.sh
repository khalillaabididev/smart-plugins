#!/bin/bash
# check_reply_status.sh - Check which bot comments have been replied to
# Usage: ./check_reply_status.sh <owner> <repo> <pr>
#
# Returns JSON with:
#   - replied: Comments that have user replies
#   - pending: Comments waiting for user reply (excluding Copilot)
#   - copilot_silent: Copilot comments (no reply needed)

set -e

OWNER="${1:?Usage: $0 <owner> <repo> <pr>}"
REPO="${2:?Usage: $0 <owner> <repo> <pr>}"
PR="${3:?Usage: $0 <owner> <repo> <pr>}"

# Fetch all comments
{
  gh api "repos/$OWNER/$REPO/pulls/$PR/comments" --paginate &
  gh api "repos/$OWNER/$REPO/issues/$PR/comments" --paginate &
  wait
} 2>/dev/null | jq -s '
# Ignored bots
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

# Separate into categories
[.[] | select(.user.login | is_ignored_bot | not)] |
[.[] | select(.user.type == "Bot" or (.user.login | is_review_bot)) | select(.in_reply_to_id == null)] as $bot_comments |
[.[] | select(.user.type == "Bot" or (.user.login | is_review_bot) | not) | select(.in_reply_to_id)] as $user_replies |

# Build replied set
($user_replies | map(.in_reply_to_id) | unique) as $replied_ids |

# Categorize bot comments
{
  replied: [$bot_comments[] | select([.id] | inside($replied_ids)) | {id, bot: .user.login, path: (.path // "issue-level")}],
  pending: [$bot_comments[] | select(.user.login != "Copilot") | select([.id] | inside($replied_ids) | not) | {id, bot: .user.login, path: (.path // "issue-level")}],
  copilot_silent: [$bot_comments[] | select(.user.login == "Copilot") | {id, path: (.path // "issue-level")}],
  summary: {
    total_bot_comments: ($bot_comments | length),
    replied_count: ([$bot_comments[] | select([.id] | inside($replied_ids))] | length),
    pending_count: ([$bot_comments[] | select(.user.login != "Copilot") | select([.id] | inside($replied_ids) | not)] | length),
    copilot_count: ([$bot_comments[] | select(.user.login == "Copilot")] | length)
  }
}
'

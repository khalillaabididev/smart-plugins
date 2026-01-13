# normalize_comments.jq - Transform raw API responses to normalized structure
# Usage: jq -s -f normalize_comments.jq
#
# Input: Combined JSON array from both PR comments endpoints
# Output: Categorized comments with stats

# Bots to IGNORE (not review bots)
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

# Sanitize control characters that crash jq
def sanitize: gsub("[\\u0000-\\u001f]"; "");

# Combine arrays from both endpoints
add |

# Transform to normalized structure
[.[] |
  # Skip ignored bots early
  select(.user.login | is_ignored_bot | not) |
  {
    id,
    type: (if .path then "review" else "issue" end),
    bot: .user.login,
    is_bot: (
      .user.type == "Bot" or
      (.user.login | is_review_bot)
    ),
    path: (.path // null),
    line: (.line // null),
    in_reply_to_id: (.in_reply_to_id // null),
    created_at,
    body: (.body | sanitize)
  }
] |

# Categorize by type
{
  bot_comments: [.[] | select(.is_bot and .in_reply_to_id == null)],
  user_replies: [.[] | select(.is_bot == false and .in_reply_to_id)],
  bot_responses: [.[] | select(.is_bot and .in_reply_to_id)]
} |

# Add summary stats
. + {
  stats: {
    total_bot_comments: .bot_comments | length,
    total_user_replies: .user_replies | length,
    total_bot_responses: .bot_responses | length,
    by_bot: (.bot_comments | group_by(.bot) | map({bot: .[0].bot, count: length}))
  }
}

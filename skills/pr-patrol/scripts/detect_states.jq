# detect_states.jq - Detect thread states for bot comments
# Usage: jq -f detect_states.jq
#
# Input: Output from normalize_comments.jq
# Output: Comments with state detection
#
# States:
#   NEW      - Bot comment with no user reply
#   PENDING  - User replied, bot hasn't responded
#   RESOLVED - Bot response indicates approval
#   REJECTED - Bot response indicates rejection

# RESOLVED markers - bot accepted the fix
def is_resolved:
  . and (
    test("review_comment_addressed|LGTM|excellent|thank you|confirmed|addressed|working as designed|looks good|you.re (absolutely )?right"; "i") or
    test("\\u2705")  # checkmark emoji
  );

# REJECTED markers - bot rejected the fix
def is_rejected:
  . and (
    test("cannot locate|could you confirm|still|not fixed|issue remains|I do not see|however.*still|but.*still"; "i") or
    (test("\\?") and test("Could you|Can you|Would you|Have you"; "i"))
  );

# Build lookup maps for efficient access
# IMPORTANT: Filter out null in_reply_to_id BEFORE grouping to avoid null key error
(
  [.user_replies[] | select(.in_reply_to_id)] |
  group_by(.in_reply_to_id) |
  map({key: (.[0].in_reply_to_id | tostring), value: .}) |
  from_entries
) as $user_map |

(
  [.bot_responses[] | select(.in_reply_to_id)] |
  map({key: (.in_reply_to_id | tostring), value: .}) |
  from_entries
) as $bot_map |

# Process each bot comment
[.bot_comments[] |
  (.id | tostring) as $id_str |
  ($user_map | has($id_str)) as $has_user |
  ($bot_map | has($id_str)) as $has_bot |
  (if $has_bot then $bot_map[$id_str].body else "" end) as $bot_body |
  {
    id,
    bot,
    path,
    line,
    body: .body,
    has_user_reply: $has_user,
    has_bot_response: $has_bot,
    state: (
      if ($has_user | not) then "NEW"
      elif $has_bot then
        if ($bot_body | is_resolved) then "RESOLVED"
        elif ($bot_body | is_rejected) then "REJECTED"
        else "PENDING"
        end
      else "PENDING"
      end
    ),
    bot_response: (if $has_bot then $bot_map[$id_str].body else null end)
  }
] |

# Group by state and add summary
{
  comments: .,
  by_state: (group_by(.state) | map({state: .[0].state, count: length, ids: [.[].id]})),
  summary: {
    NEW: ([.[] | select(.state == "NEW")] | length),
    PENDING: ([.[] | select(.state == "PENDING")] | length),
    RESOLVED: ([.[] | select(.state == "RESOLVED")] | length),
    REJECTED: ([.[] | select(.state == "REJECTED")] | length)
  }
}

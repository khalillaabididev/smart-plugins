#!/bin/bash
#
# inject-reminder.sh
# Injects workflow reminder into context when pr-patrol is active
#
# Called by UserPromptSubmit hook
# Exit 0 with stdout = message added to context
# Exit 0 with no stdout = silent (no active workflow)

set -euo pipefail

# Find active pr-patrol state file
STATE_FILE=$(find .claude/bot-reviews -name "PR-*.md" 2>/dev/null | head -1)

# No active workflow - exit silently
if [[ -z "$STATE_FILE" || ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Extract current state
STATUS=$(grep "^status:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2 || echo "unknown")
NEXT_GATE=$(grep "^next_gate:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2 || echo "")
NEXT_ACTION=$(grep "^next_action:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2- || echo "")
PR_NUMBER=$(grep "^pr_number:" "$STATE_FILE" 2>/dev/null | cut -d' ' -f2 || echo "?")

# If workflow is complete, don't remind
if [[ "$STATUS" == "pushed" || "$STATUS" == "done" || "$STATUS" == "complete" ]]; then
  exit 0
fi

# Determine gate number from status if next_gate not set
if [[ -z "$NEXT_GATE" ]]; then
  case "$STATUS" in
    initialized) NEXT_GATE="1" ;;
    collected) NEXT_GATE="2" ;;
    validated) NEXT_GATE="3" ;;
    fixes_planned|fixes_applied|checks_passed) NEXT_GATE="4" ;;
    committed) NEXT_GATE="5" ;;
    replies_sent) NEXT_GATE="6" ;;
    *) NEXT_GATE="?" ;;
  esac
fi

# Build reminder message
cat << EOF
<pr-patrol-reminder>
📌 PR-PATROL WORKFLOW ACTIVE (PR #${PR_NUMBER})
├── Status: ${STATUS}
├── Next Gate: ${NEXT_GATE}
└── Action: Read phases/gate-${NEXT_GATE}-*.md

⚠️ Don't forget to continue the workflow!
</pr-patrol-reminder>
EOF

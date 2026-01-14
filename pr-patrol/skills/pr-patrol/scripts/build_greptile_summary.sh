#!/usr/bin/env bash
#
# build_greptile_summary.sh
# Build a consolidated @greptile-apps summary comment for the current cycle
#
# Usage: build_greptile_summary.sh <state_file> <cycle_number>
#
# Reads the state file and generates a markdown summary with:
#   - @greptile-apps mention (so Greptile sees and learns from it)
#   - List of fixed issues with commit SHA
#   - List of false positives with reasoning
#   - Cycle statistics
#
# Output: Markdown string ready to post as issue comment

set -euo pipefail

STATE_FILE="${1:-}"
CYCLE="${2:-1}"

if [[ -z "$STATE_FILE" || ! -f "$STATE_FILE" ]]; then
  echo "Error: State file not found: $STATE_FILE" >&2
  exit 1
fi

# Extract frontmatter values
PR_NUMBER=$(grep "^pr_number:" "$STATE_FILE" | cut -d' ' -f2)
COMMIT_SHA=$(grep "^last_push_commit:" "$STATE_FILE" | head -1 | cut -d' ' -f2 || echo "unknown")

# Count FIXED items (lines with ✅ in Fix Applied column)
# grep returns 1 if no matches, which is not an error for us
FIXED_COUNT=$(grep -c "| ✅" "$STATE_FILE" || true)
[[ -z "$FIXED_COUNT" ]] && FIXED_COUNT=0

# Count FALSE_POSITIVE items (look for FALSE_POSITIVE or VALID sections - updated naming)
FP_COUNT=$(awk '/^### FALSE_POSITIVE/,/^###/{if(/^\|.*\|.*\|.*\|/) count++} END{print count-1}' "$STATE_FILE" || true)
[[ -z "$FP_COUNT" || "$FP_COUNT" -lt 0 ]] && FP_COUNT=0

# Extract fixed issues (file and summary from VALID/FIXED table)
FIXED_LIST=$(awk '
  /^### (FIXED|VALID)/,/^###/ {
    if (/^\| [^-]/ && !/^\| ID/) {
      split($0, cols, "|")
      gsub(/^[ \t]+|[ \t]+$/, "", cols[4])  # File
      gsub(/^[ \t]+|[ \t]+$/, "", cols[6])  # Summary
      if (cols[4] != "" && cols[6] != "") {
        print "- `" cols[4] "`: " cols[6]
      }
    }
  }
' "$STATE_FILE" || true)

# Extract false positives
FP_LIST=$(awk '
  /^### FALSE_POSITIVE/,/^###/ {
    if (/^\| [^-]/ && !/^\| ID/) {
      split($0, cols, "|")
      gsub(/^[ \t]+|[ \t]+$/, "", cols[4])  # File
      gsub(/^[ \t]+|[ \t]+$/, "", cols[6])  # Summary
      gsub(/^[ \t]+|[ \t]+$/, "", cols[7])  # Reason
      if (cols[4] != "" && cols[6] != "") {
        print "- `" cols[4] "`: " cols[6] " — _" cols[7] "_"
      }
    }
  }
' "$STATE_FILE" || true)

# Build the summary comment
cat << EOF
@greptile-apps

## PR #${PR_NUMBER} - Cycle ${CYCLE} Summary

Thank you for the code review! Here's a summary of how we addressed the feedback:

### ✅ Fixed Issues (${FIXED_COUNT})
${FIXED_LIST:-_No issues fixed in this cycle._}

### ❌ False Positives (${FP_COUNT})
${FP_LIST:-_No false positives identified._}

---
**Commit:** \`${COMMIT_SHA}\`
**Cycle:** ${CYCLE}
EOF

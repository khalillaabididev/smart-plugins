# Gate 1: Collection Summary

**Previous status:** `initialized`
**Status to set after completion:** `collected`

---

## What This Phase Does

1. Fetch comments from both endpoints (parallel)
2. Filter by selected bots (exclude ignored bots)
3. Categorize by severity
4. Build thread map (NEW/PENDING/RESOLVED/REJECTED)

---

## Step-by-Step Actions

### 1. Fetch Comments (Use Scripts!)

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
OWNER="SmartOzzehir"  # From state file
REPO="prospera"       # From state file
PR="32"               # From state file

# Fetch and normalize all comments
"$SCRIPTS/fetch_pr_comments.sh" "$OWNER" "$REPO" "$PR" > /tmp/pr_comments.json
```

### 2. Get Thread States

```bash
# Detect states for all comments
cat /tmp/pr_comments.json | "$SCRIPTS/detect_thread_states.sh" > /tmp/thread_states.json

# Quick summary
jq '.summary' /tmp/thread_states.json
# Output: {"NEW": 19, "PENDING": 9, "RESOLVED": 12, "REJECTED": 0}
```

### 3. Check for New Comments (If Resuming)

```bash
# Get comments since last push
"$SCRIPTS/check_new_comments.sh" "$OWNER" "$REPO" "$PR"
# Output: {"since": "...", "count": 6, "needs_review": true, "by_bot": [...]}
```

### 4. Categorize by Severity

Parse comment bodies for severity markers:

| Bot | Critical | High | Medium | Low |
|-----|----------|------|--------|-----|
| CodeRabbit | `[critical]`, `🔴` | `[major]`, `🟠` | `[minor]`, `🟡` | `_🧹 Nitpick_` |
| Greptile | `P0`, `Critical` | `P1`, `High` | `P2`, `Medium` | `P3`, `Low` |
| Codex | `🔴 Critical` | `🟠 Moderate` | `🟡 Minor` | `💭 Nitpick` |
| Sentry | `CRITICAL` | `HIGH` | `MEDIUM` | `LOW` |
| Copilot | (no severity) | (no severity) | (no severity) | (no severity) |

---

## MANDATORY AskUserQuestion

```
Header: "Review"
Question: "Found {total} comments ({critical} critical, {high} high, {medium} medium, {low} low). Proceed?"
Options:
├── "Validate all {total} comments" [Recommended]
├── "Show comment list first"
├── "Adjust filters"
├── "Cancel"
```

---

## Edge Cases

| Case | Detection | Action |
|------|-----------|--------|
| 0 bot comments | `comments.length == 0` | Exit: "No bot comments found." |
| 100+ comments | `comments.length > 100` | Batch warning |
| Comment on deleted file | `path` doesn't exist | Mark as stale |
| Unknown bot | Login not in bot list | Ask: "Include unknown bot?" |

---

## State File Update

Update the Summary section:

```markdown
### Summary
- Total Comments: {total}
- Critical: {critical}
- High: {high}
- Medium: {medium}
- Low: {low}
- NEW: {new_count}
- PENDING: {pending_count}
- RESOLVED: {resolved_count}
```

Update status:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
"$SCRIPTS/update_state.sh" ".claude/bot-reviews/PR-${PR}.md" status collected
```

---

## After This Phase

1. Update state file: `status: collected`
2. Proceed to: **Gate 2 (Validation)**
3. Read: `phases/gate-2-validate.md`

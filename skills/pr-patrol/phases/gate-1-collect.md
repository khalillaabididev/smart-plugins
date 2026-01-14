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
OWNER="your-org"  # From state file
REPO="my-project"       # From state file
PR="32"               # From state file

# Fetch and normalize all comments
"$SCRIPTS/fetch_pr_comments.sh" "$OWNER" "$REPO" "$PR" > /tmp/pr_comments.json
```

### 2. Extract CodeRabbit Embedded Comments

**IMPORTANT:** CodeRabbit embeds some comments in the walkthrough due to GitHub API limitations:
- `♻️ Duplicate comments` - Issues from previous reviews that still apply
- `🔇 Additional comments` - Comments outside the diff range
- `🧹 Nitpick comments` - Minor style suggestions (sometimes embedded)

```bash
# Fetch issue comments (walkthrough lives here)
gh api repos/$OWNER/$REPO/issues/$PR/comments --paginate > /tmp/issue_comments.json

# Extract embedded comments from CodeRabbit walkthrough
"$SCRIPTS/parse_coderabbit_embedded.sh" /tmp/issue_comments.json > /tmp/embedded_comments.json

# Check if any embedded comments found
jq '.total_embedded, .by_type' /tmp/embedded_comments.json
# Output: 5, {"duplicate": 2, "outside_diff": 3}
```

### 3. Get Thread States

```bash
# Detect states for all comments
cat /tmp/pr_comments.json | "$SCRIPTS/detect_thread_states.sh" > /tmp/thread_states.json

# Quick summary
jq '.summary' /tmp/thread_states.json
# Output: {"NEW": 19, "PENDING": 9, "RESOLVED": 12, "REJECTED": 0}
```

### 4. Check for New Comments (If Resuming)

```bash
# Get comments since last push
"$SCRIPTS/check_new_comments.sh" "$OWNER" "$REPO" "$PR"
# Output: {"since": "...", "count": 6, "needs_review": true, "by_bot": [...]}
```

### 5. Categorize by Severity

Parse comment bodies for severity markers:

| Bot | Critical | High | Medium | Low |
|-----|----------|------|--------|-----|
| CodeRabbit | `[critical]`, `🔴` | `[major]`, `🟠` | `[minor]`, `🟡` | `_🧹 Nitpick_` |
| Greptile | `P0`, `Critical` | `P1`, `High` | `P2`, `Medium` | `P3`, `Low` |
| Codex | `🔴 Critical` | `🟠 Moderate` | `🟡 Minor` | `💭 Nitpick` |
| Sentry | `CRITICAL` | `HIGH` | `MEDIUM` | `LOW` |
| Copilot | (no severity) | (no severity) | (no severity) | (no severity) |

**Severity extraction script:**

```bash
# Add severity to each comment based on bot-specific markers
cat /tmp/thread_states.json | jq '
  # Severity detection function
  def detect_severity:
    .body as $body | .bot as $bot |
    if $bot == "coderabbitai" or $bot == "CodeRabbit" then
      if ($body | test("\\[critical\\]|🔴"; "i")) then "critical"
      elif ($body | test("\\[major\\]|🟠"; "i")) then "high"
      elif ($body | test("\\[minor\\]|🟡"; "i")) then "medium"
      elif ($body | test("_🧹 Nitpick_|nitpick"; "i")) then "low"
      else "medium" end
    elif $bot == "greptile" or $bot == "greptile[bot]" then
      if ($body | test("P0|Critical"; "i")) then "critical"
      elif ($body | test("P1|High"; "i")) then "high"
      elif ($body | test("P2|Medium"; "i")) then "medium"
      elif ($body | test("P3|Low"; "i")) then "low"
      else "medium" end
    elif $bot == "codex" or $bot == "codex-ai[bot]" then
      if ($body | test("🔴 Critical"; "i")) then "critical"
      elif ($body | test("🟠 Moderate"; "i")) then "high"
      elif ($body | test("🟡 Minor"; "i")) then "medium"
      elif ($body | test("💭 Nitpick"; "i")) then "low"
      else "medium" end
    elif $bot == "sentry" or $bot == "sentry-io[bot]" then
      if ($body | test("CRITICAL"; "")) then "critical"
      elif ($body | test("HIGH"; "")) then "high"
      elif ($body | test("MEDIUM"; "")) then "medium"
      elif ($body | test("LOW"; "")) then "low"
      else "medium" end
    elif $bot == "copilot" or $bot == "github-copilot[bot]" then
      "medium"  # Copilot has no severity markers
    else
      "medium"  # Default for unknown bots
    end;

  # Apply to all comments and add severity counts
  .comments |= map(. + {severity: detect_severity}) |
  .severity_counts = {
    critical: [.comments[] | select(.severity == "critical")] | length,
    high: [.comments[] | select(.severity == "high")] | length,
    medium: [.comments[] | select(.severity == "medium")] | length,
    low: [.comments[] | select(.severity == "low")] | length
  }
' > /tmp/comments_with_severity.json

# View severity summary
jq '.severity_counts' /tmp/comments_with_severity.json
# Output: {"critical": 2, "high": 5, "medium": 8, "low": 3}
```

### 6. Merge Embedded Comments

Combine inline PR comments with embedded CodeRabbit comments:

```bash
# Merge embedded comments into main comment list
jq -s '
  .[0] as $inline |
  .[1].comments as $embedded |
  $inline + {
    embedded_count: ($embedded | length),
    comments: ($inline.comments + $embedded)
  }
' /tmp/comments_with_severity.json /tmp/embedded_comments.json > /tmp/all_comments.json

# Final summary
jq '{
  total: .comments | length,
  inline: (.comments | map(select(.is_embedded != true)) | length),
  embedded: .embedded_count,
  severity_counts: .severity_counts
}' /tmp/all_comments.json
```

---

## MANDATORY AskUserQuestion

```
Header: "Review"
Question: "Found {total} comments ({inline} inline + {embedded} embedded). {critical} critical, {high} high, {medium} medium, {low} low. Proceed?"
Options:
├── "Validate all {total} comments" [Recommended]
├── "Show comment list first"
├── "Show embedded comments only"
├── "Adjust filters"
├── "Cancel"
```

**Note:** Embedded comments are from CodeRabbit's walkthrough (duplicates, outside diff range, nitpicks).

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

Update status and billboard:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
STATE_FILE=".claude/bot-reviews/PR-${PR}.md"

# Update billboard (status + next gate info)
"$SCRIPTS/update_billboard.sh" "$STATE_FILE" "collected" "2" "Validate comments with bot-comment-validator agent"
```

---

## After This Phase

1. ✅ Billboard updated: `status: collected`, `next_gate: 2`
2. **IMMEDIATELY** read: `phases/gate-2-validate.md`
3. Do NOT stop or wait - continue to Gate 2!

# Gate 5: Reply Approval

**Previous status:** `committed`
**Status to set after completion:** `replies_sent`

---

## What This Phase Does

1. Prepare reply drafts per bot type
2. Show reply preview to user
3. Post replies on approval (with correct protocol per bot)

---

## CRITICAL: Read bot-formats.md!

Before posting ANY reply, read `bot-formats.md` for bot-specific protocols.

---

## Bot Response Protocols

| Bot | Reaction | Reply | Special Rules |
|-----|----------|-------|---------------|
| CodeRabbit | ❌ None | ✅ Reply | Use `@coderabbitai resolve` for bulk |
| Greptile | 👍/👎 FIRST | ✅ THEN Reply | Reaction trains ML model |
| Codex | 👍/👎 FIRST | ✅ THEN Reply | Same as Greptile |
| Sentry | 👍/👎 FIRST | ✅ THEN Reply | Same as Greptile |
| Copilot | ❌ NEVER | ❌ NEVER | **SILENT FIX ONLY** |

---

## CRITICAL: Issue Comments vs PR Review Comments

GitHub has TWO comment systems. They require DIFFERENT reply methods!

### PR Review Comments (Files Changed tab)
- Have `path` and `line` fields
- Support threading via `in_reply_to` parameter

```bash
# Reply to PR review comment (THREADED)
gh api repos/{o}/{r}/pulls/{pr}/comments \
  -X POST \
  -f body="Fixed in commit {sha}" \
  -F in_reply_to={comment_id}
```

### Issue Comments (Conversation tab)
- NO `path` or `line` fields
- **DO NOT support threading!**
- **MUST use @mention in body!**

```bash
# Reply to issue comment (USE @MENTION!)
gh api repos/{o}/{r}/issues/{pr}/comments \
  -X POST \
  -f body="@greptile-apps Fixed in commit {sha}. Thanks for catching this!"
```

**How to detect comment type:**
- Issue comments: fetched from `/issues/{pr}/comments`, no `path` field
- PR review comments: fetched from `/pulls/{pr}/comments`, has `path` field

---

## MANDATORY AskUserQuestion

```
Header: "Replies"
Question: "Commit {sha} created. Post replies to {count} bot comments?"
Options:
├── "Yes, post all replies"
├── "Preview reply messages"
├── "Skip replies (commit only)"
├── "Edit replies before posting"
```

---

## Reply Templates

### For Real Issues (Fixed)

**CodeRabbit:**
```
Fixed in commit {sha}: {description}
```

**Greptile/Codex/Sentry (REACTION FIRST!):**
```bash
# Step 1: Add reaction
gh api repos/{o}/{r}/pulls/comments/{id}/reactions -X POST -f content="+1"

# Step 2: Reply
gh api repos/{o}/{r}/pulls/{pr}/comments -X POST \
  -f body="Fixed in commit {sha}. Thanks for catching this!" \
  -F in_reply_to={id}
```

**For Issue Comments (with @mention):**
```bash
gh api repos/{o}/{r}/issues/{pr}/comments -X POST \
  -f body="@greptile-apps Fixed in commit {sha}. Thanks for catching the UUID vs text code mismatch!"
```

### For False Positives

**CodeRabbit:**
```
This is intentional: {reasoning}
```

**Greptile/Codex/Sentry (REACTION FIRST!):**
```bash
# Step 1: Add thumbs DOWN reaction
gh api repos/{o}/{r}/pulls/comments/{id}/reactions -X POST -f content="-1"

# Step 2: Reply explaining
gh api repos/{o}/{r}/pulls/{pr}/comments -X POST \
  -f body="This is intentional - {reasoning}" \
  -F in_reply_to={id}
```

---

## Copilot: SILENT FIX ONLY!

**NEVER post any reply or reaction to Copilot comments.**

- ❌ No reply
- ❌ No reaction
- ❌ No "Resolve conversation" button
- ✅ Just push the fix - Copilot will re-evaluate

**Before building reply queue:**
```bash
# Filter out Copilot from reply queue
# NOTE: Avoid using != inline - use negation with "not" instead
REPLY_QUEUE=$(echo "$COMMENTS" | jq '[.[] | select(.bot == "Copilot" | not)]')
```

---

## Greptile's Acknowledgment Behavior

When you @mention Greptile with a fix confirmation:
1. Greptile will 👍 react to YOUR comment
2. Greptile will reply below with acknowledgment

**This reply is NOT a new issue** - it's acknowledgment. It will be filtered out in next cycle via `in_reply_to_id` check.

---

## Greptile Consolidated Summary Comment

**IMPORTANT:** At the end of each cycle, post ONE consolidated summary comment with `@greptile-apps` mention.

This helps Greptile:
- Learn from batch feedback (improves future reviews)
- Understand which suggestions were valuable vs false positives
- Track patterns across the PR lifecycle

### Generate Summary

```bash
# Build the consolidated summary
CYCLE=$(grep "^current_cycle:" "$STATE_FILE" | cut -d' ' -f2)
"$SCRIPTS/build_greptile_summary.sh" "$STATE_FILE" "$CYCLE" > /tmp/greptile_summary.md

# Preview
cat /tmp/greptile_summary.md
```

### Post Summary (After Individual Replies)

```bash
# Post consolidated summary as issue comment
gh api repos/{o}/{r}/issues/{pr}/comments \
  -X POST \
  -f body="$(cat /tmp/greptile_summary.md)"
```

### Summary Format

```markdown
@greptile-apps

## PR #123 - Cycle 1 Summary

Thank you for the code review! Here's a summary of how we addressed the feedback:

### ✅ Fixed Issues (5)
- `customer-list.tsx`: Fixed UUID vs text code mismatch
- `revenue-table.tsx`: Added null check for optional field
- ...

### ❌ False Positives (2)
- `utils.ts`: Intentional any cast — _external API type unknown_
- `config.ts`: Hardcoded value is build-time constant — _OK for this use case_

---
**Commit:** `ff83040`
**Cycle:** 1
```

---

## Reply Execution Order

For each comment (excluding Copilot):

1. **Check if already replied** (prevent duplicates)
2. **Determine comment type** (issue vs review)
3. **If Greptile/Codex/Sentry:** Add reaction FIRST
4. **Post reply** (with @mention if issue comment)
5. **Update state file** with reply ID

```bash
# Check if already replied
ALREADY_REPLIED=$(grep "^| $COMMENT_ID |" "$STATE_FILE" | grep -v "| - |")
if [ -n "$ALREADY_REPLIED" ]; then
  echo "⚠️ Already replied to $COMMENT_ID - skipping"
  continue
fi
```

---

## Edge Cases

| Case | Detection | Action |
|------|-----------|--------|
| Copilot in queue | `bot == "Copilot"` | **ENFORCE**: Remove from queue |
| Comment deleted | API 404 | Skip with warning |
| Rate limit | API 429 | Backoff + retry |
| Reply API error | API 500 | Retry/Skip/Draft |
| Already replied | In `replied_comment_ids` | Skip |

---

## State File Update

After EACH reply posted:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
STATE=".claude/bot-reviews/PR-${PR}.md"

# Add to replied_comment_ids array
# Current: [123456, 789012]
# New: [123456, 789012, 111222]
"$SCRIPTS/update_state.sh" "$STATE" replied_comment_ids "[123456, 789012, 111222]"
```

Update PENDING table:

```markdown
### PENDING
| ID | Bot | Replied At | Reply ID |
|----|-----|------------|----------|
| 123 | coderabbitai[bot] | 2026-01-13T10:30:00Z | 456789 |
```

After all replies, update billboard:

```bash
"$SCRIPTS/update_billboard.sh" "$STATE" "replies_sent" "6" "Push to remote and complete cycle"
```

---

## After This Phase

1. ✅ Billboard updated: `status: replies_sent`, `next_gate: 6`
2. **IMMEDIATELY** read: `phases/gate-6-push.md`
3. Do NOT stop or wait - continue to Gate 6!

# Gate 4: Review & Commit

**Previous status:** `checks_passed`
**Status to set after completion:** `committed`

---

## What This Phase Does

1. Show diff summary to user
2. Generate commit message
3. Create commit on user approval

---

## Step 1: Show Changes

```bash
# Summary
git diff --stat

# Detailed diff (if user requests)
git diff
```

---

## MANDATORY AskUserQuestion (Review)

```
Header: "Changes"
Question: "Changes applied to {files} files (+{added}/-{removed} lines). Review?"
Options:
├── "Show diff summary"
├── "Show full diff"
├── "Proceed to commit"
├── "Discard all changes"
```

---

## Step 2: Generate Commit Message

Standard format for bot review fixes:

```
fix: address PR bot review feedback

- Fixed {issue1_summary}
- Fixed {issue2_summary}
- Validated {false_positive_count} false positives

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

---

## MANDATORY AskUserQuestion (Commit)

```
Header: "Commit"
Question: "Create commit: 'fix: address PR bot review feedback'?"
Options:
├── "Yes, commit now"
├── "Edit commit message"
├── "Review changes again"
├── "Discard"
```

---

## Step 3: Create Commit

**CRITICAL: Only commit after explicit user approval!**

```bash
# Stage changes
git add -A

# Commit with proper message format
git commit -m "$(cat <<'EOF'
fix: address PR bot review feedback

- Fixed UUID vs text code mismatch in customer-list.tsx
- Fixed kebab-case badge color condition
- Validated 3 CodeRabbit nitpicks as false positives

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"

# Verify commit created
git log -1 --oneline
```

---

## Edge Cases

| Case | Detection | Action |
|------|-----------|--------|
| No changes | `git status` empty | Skip to Gate 5 |
| Pre-existing staged | Files staged before | Warning: Include? |
| Git hook fails | Pre-commit error | Fix hook issues |

---

## State File Update

After commit:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
STATE=".claude/bot-reviews/PR-${PR}.md"

# Update status
"$SCRIPTS/update_state.sh" "$STATE" status committed

# Record commit SHA in state file (for replies)
COMMIT_SHA=$(git rev-parse --short HEAD)
# Update FIXED table with commit SHA
```

Update the FIXED table:

```markdown
### FIXED - Real Issues ({count})
| ID | Bot | File | Severity | Summary | Fix Applied |
|----|-----|------|----------|---------|-------------|
| 123 | coderabbitai[bot] | customer-list.tsx | HIGH | UUID vs text mismatch | ✅ {commit_sha} |
```

---

## After This Phase

1. Update state file: `status: committed`
2. Record commit SHA
3. Proceed to: **Gate 5 (Reply Approval)**
4. Read: `phases/gate-5-reply.md`

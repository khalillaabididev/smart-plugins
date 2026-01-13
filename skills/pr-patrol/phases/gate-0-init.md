# Gate 0: Initialization

**Status to set after completion:** `initialized`

---

## What This Phase Does

1. Detect PR from argument or current branch
2. Check for existing state file (`.claude/bot-reviews/PR-{N}.md`)
3. Verify PR status (open, not draft, not merged)
4. Create or update state file

---

## Step-by-Step Actions

### 1. Detect PR Number

```bash
# From argument
PR_NUMBER="$1"

# Or from current branch
if [ -z "$PR_NUMBER" ]; then
  PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null)
fi

# Or ask user
if [ -z "$PR_NUMBER" ]; then
  # Use AskUserQuestion to get PR number
fi
```

### 2. Verify PR Status

```bash
PR_STATE=$(gh pr view "$PR_NUMBER" --json state,isDraft -q '{state: .state, isDraft: .isDraft}')
```

### 3. Check for Existing State File

```bash
STATE_FILE=".claude/bot-reviews/PR-${PR_NUMBER}.md"
if [ -f "$STATE_FILE" ]; then
  EXISTING_STATUS=$(grep "^status:" "$STATE_FILE" | cut -d' ' -f2)
fi
```

---

## MANDATORY AskUserQuestion

```
Header: "Setup"
Question: "How should we proceed with PR #{number}?"
Options:
├── "Full review (all comments, all severities)" [Recommended if new]
├── "Resume previous cycle" [Recommended if state exists]
├── "Reply check only (check bot responses)"
├── "Custom configuration..."
```

**If "Custom configuration" selected:**

```
Header: "Scope"
Question: "Which severity levels to include?"
multiSelect: true
Options:
├── "Critical" [pre-selected]
├── "High" [pre-selected]
├── "Medium" [pre-selected]
├── "Low"
├── "Nitpick/Trivial"
```

```
Header: "Bots"
Question: "Which bots to process?"
multiSelect: true
Options:
├── "CodeRabbit" [pre-selected]
├── "Greptile" [pre-selected]
├── "Copilot" [pre-selected]
├── "Codex" [pre-selected]
├── "Sentry" [pre-selected]
```

---

## Edge Cases

| Case | Detection | Action |
|------|-----------|--------|
| PR merged | `state == "MERGED"` | Block: "PR is merged. Nothing to review." |
| PR closed | `state == "CLOSED"` | Block: "PR is closed." |
| PR is draft | `isDraft == true` | Warning + confirm |
| Branch behind remote | `git status -sb` shows behind | Offer: "Pull first?" |
| Uncommitted changes | `git status --porcelain` not empty | Warning: "Stash or commit first?" |
| State file corrupted | YAML parse error | Recovery options |
| No PR for branch | `gh pr list` empty | Ask for PR number |

---

## State File Creation

If no state file exists, create one:

```markdown
---
pr_number: {PR_NUMBER}
branch: {BRANCH_NAME}
owner: {OWNER}
repo: {REPO}
created: {ISO_TIMESTAMP}
last_updated: {ISO_TIMESTAMP}
current_cycle: 1
status: initialized
---

# PR #{PR_NUMBER} Bot Review State

## Cycle 1 (Current)

### Summary
- Total Comments: 0
- Validated: 0
- Real Issues: 0
- False Positives: 0
```

---

## After This Phase

1. Update state file: `status: initialized`
2. Proceed to: **Gate 1 (Collection)**
3. Read: `phases/gate-1-collect.md`

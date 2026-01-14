# Bot Response Cheat Sheet

Complete reference for handling PR review bot comments.

---

## Bot Identification

### Review Bots (Process These)

| Bot | GitHub Login | Response Type |
|-----|--------------|---------------|
| CodeRabbit | `coderabbitai[bot]` | Reply only |
| Greptile | `greptile-apps[bot]` | Reaction + Reply |
| Copilot | `Copilot` | **SILENT FIX** |
| Codex | `chatgpt-codex-connector[bot]` | Reaction + Reply |
| Sentry | `sentry[bot]` | Reaction + Reply |

### Ignored Bots (Auto-Filtered)

These bots are **automatically excluded** from pr-patrol processing:

| Bot | GitHub Login | Reason |
|-----|--------------|--------|
| Vercel | `vercel[bot]` | Deployment status, not code review |
| Dependabot | `dependabot[bot]` | Dependency updates, not code review |
| Renovate | `renovate[bot]` | Dependency updates, not code review |
| GitHub Actions | `github-actions[bot]` | CI/CD status, not code review |

**Note:** If a new non-review bot starts commenting on PRs, add it to the ignore list in `scripts/normalize_comments.jq`.

---

## Response Strategy Matrix

| Bot | Reaction | Reply | Special Notes |
|-----|----------|-------|---------------|
| **CodeRabbit** | ❌ Never | ✅ Always | Use `@coderabbitai resolve` for bulk |
| **Greptile** | ✅ Required first | ✅ Always | 👍/👎 trains the model |
| **Codex** | ✅ Required first | ✅ Always | Same protocol as Greptile |
| **Copilot** | ❌ Never | ❌ Never | Replying causes repeat comments |
| **Sentry** | ✅ Required first | ✅ Always | Bug prediction focused |

---

## CodeRabbit (`coderabbitai[bot]`)

### Embedded Comments (Walkthrough Sections)

**IMPORTANT:** Due to GitHub API limitations, CodeRabbit embeds some comments in the walkthrough issue comment instead of posting inline:

| Section | Emoji | Description | Default Severity |
|---------|-------|-------------|------------------|
| Duplicate comments | `♻️` | Issues from previous reviews that still apply | HIGH |
| Additional comments | `🔇` | Comments outside the diff range | MEDIUM |
| Nitpick comments | `🧹` | Minor style suggestions (sometimes embedded) | LOW |
| Review details | `📜` | Collapsible full review metadata | N/A |

**Why embedded?**
- GitHub API cannot post inline comments on lines outside the PR diff
- Duplicates from previous reviews may reference unchanged code
- Nitpicks may be bundled to reduce noise

**Parsing:** Use `parse_coderabbit_embedded.sh` to extract these into regular comment format.

### Severity Markers

| Severity | Markers in Comment |
|----------|-------------------|
| Critical | `[critical]`, `🔴`, `❗`, `**Critical**` |
| Major | `[major]`, `🟠`, `**Major**` |
| Minor | `[minor]`, `🟡`, `**Minor**` |
| Nitpick | `_🧹 Nitpick_`, `_🔵 Trivial_`, `💭`, `nit:` |

### Response Markers (What CodeRabbit says after you reply)

**RESOLVED - Bot accepted your fix:**
```
<!-- <review_comment_addressed> -->     # HTML comment - DEFINITIVE marker
"excellent!"
"thank you"
"LGTM"
"confirmed"
"addressed"
"working as designed"
"you're absolutely right"
"✅"
```

**REJECTED - Bot disagrees with your fix:**
```
"I cannot locate"
"Could you confirm"
"still"
"issue remains"
"not fixed"
"I do not see"
"however, the issue still"
"?" after "Could you" / "Can you" / "Would you"
```

### Commands

```bash
# Bulk resolve all comments
@coderabbitai resolve

# Trigger new review
@coderabbitai review

# Full review from scratch
@coderabbitai full review

# Regenerate summary
@coderabbitai summary

# Show config
@coderabbitai configuration
```

### Reply Format

```bash
# Simple fix acknowledgment
gh api repos/{o}/{r}/pulls/{pr}/comments \
  -X POST \
  -f body="Fixed in commit {sha}: {description}" \
  -F in_reply_to={comment_id}
```

---

## Greptile (`greptile-apps[bot]`)

### Comment Structure

```markdown
**Issue**: Description of the problem found

**Recommendation**: Suggested fix or approach
```

Or free-form analysis text.

### Response Protocol

**CRITICAL:** Reaction MUST come before reply!

#### For PR Review Comments (line-level, in "Files changed" tab)

```bash
# Step 1: Add reaction (REQUIRED FIRST)
gh api repos/{o}/{r}/pulls/comments/{id}/reactions -X POST -f content="+1"

# Step 2: THEN reply (threaded via in_reply_to)
gh api repos/{o}/{r}/pulls/{pr}/comments \
  -X POST \
  -f body="Fixed in commit {sha}" \
  -F in_reply_to={id}
```

#### For Issue Comments (in "Conversation" tab) - NO THREADING!

GitHub issue comments **don't support threading**. You MUST use @mention:

```bash
# Step 1: Add reaction
gh api repos/{o}/{r}/issues/comments/{id}/reactions -X POST -f content="+1"

# Step 2: Reply with @mention (creates new comment, links via mention)
gh api repos/{o}/{r}/issues/{pr}/comments \
  -X POST \
  -f body="@greptile-apps Fixed in commit {sha}. Thanks for catching the UUID vs text code mismatch!"
```

**How to detect comment type:**
- Issue comments: fetched from `/issues/{pr}/comments`
- PR review comments: fetched from `/pulls/{pr}/comments`
- Issue comments have NO `path` or `line` fields

### Learning System

Greptile uses machine learning trained on 👍/👎 reactions:
- **Before feedback:** ~19% of comments addressed
- **After feedback:** ~55%+ of comments addressed
- Your reactions directly improve future reviews

### Consolidated Summary Comment

**IMPORTANT:** At the end of each cycle, post ONE consolidated `@greptile-apps` summary comment.

**Why?**
- Helps Greptile learn from batch feedback
- Tracks which suggestions were valuable vs false positives
- Improves future code review quality

**Format:** Use `build_greptile_summary.sh` to generate the summary.

```markdown
@greptile-apps

## PR #123 - Cycle 1 Summary

### ✅ Fixed Issues (5)
- `file1.ts`: Description of fix

### ❌ False Positives (2)
- `file2.ts`: Reason this was intentional

---
**Commit:** `abc1234`
```

### Greptile's Acknowledgment Behavior

When you @mention Greptile with a fix confirmation, Greptile will:
1. **React with 👍** to YOUR comment
2. **Reply below** with acknowledgment (e.g., "Thanks for the fix!")

**IMPORTANT:** This reply is NOT a new issue - it's acknowledgment. Filter it out in next cycle:
- Check `in_reply_to_id` - acknowledgments are replies to YOUR comment
- Check body for patterns: "thanks", "looks good", "acknowledged"

### Response Markers (How WE Signal Resolution)

**RESOLVED:**
```
"looks good"
"thank you"
(primarily relies on 👍 reaction acknowledgment)
```

**REJECTED:**
```
"issue remains"
"still see the problem"
👎 reaction followed by explanation
```

---

## Copilot (`Copilot`)

### ⚠️ CRITICAL: SILENT FIX ONLY

**DO NOT:**
- ❌ Post any reply
- ❌ Add any reaction
- ❌ Use "Resolve conversation" button

**DO:**
- ✅ Fix the code silently
- ✅ Push changes
- ✅ Copilot will re-evaluate automatically

### Why Silent Fix?

1. Copilot re-reviews on every push
2. Replying can cause Copilot to repeat the same comment
3. "Resolve conversation" is ignored on next review
4. Best practice: Let code changes speak for themselves

### Detection

Copilot doesn't reply to threads. To check if issue is resolved:
1. Push your fix
2. Wait for new Copilot review
3. If comment doesn't reappear → RESOLVED
4. If same comment appears → REJECTED (needs different approach)

---

## Codex (`chatgpt-codex-connector[bot]`)

### Severity Markers

| Severity | Markers |
|----------|---------|
| Critical | `🔴 Critical`, `High Priority` |
| Major | `🟠 Moderate`, `Medium Priority` |
| Minor | `🟡 Minor`, `Low Priority` |
| Nitpick | `💭 Nitpick`, `Style` |

### Response Protocol

Same as Greptile: **Reaction first, then reply**

```bash
# Step 1: Reaction
gh api repos/{o}/{r}/pulls/comments/{id}/reactions -X POST -f content="+1"

# Step 2: Reply
gh api repos/{o}/{r}/pulls/{pr}/comments \
  -X POST \
  -f body="Fixed in commit {sha}" \
  -F in_reply_to={id}
```

---

## Sentry (`sentry[bot]`)

### Comment Structure

```markdown
**Bug:** Description of the bug

<sub>Severity: CRITICAL/HIGH/MEDIUM/LOW</sub>

<!-- BUG_PREDICTION -->

<details>
<summary>🔍 <b>Detailed Analysis</b></summary>
Extended analysis and code references...
</details>
```

### Severity Extraction

Parse from `<sub>` tag:
```bash
# Extract severity from Sentry comment
echo "$COMMENT_BODY" | grep -oP '(?<=<sub>Severity: )[A-Z]+(?=</sub>)'
```

### Response Protocol

Same as Greptile: **Reaction first, then reply**

### Response Markers

**RESOLVED:**
```
"fixed"
"resolved"
"addressed"
```

**REJECTED:**
```
"not fixed"
"issue persists"
"still present"
```

---

## Reaction Types Reference

| Reaction | Content Value | Use Case |
|----------|---------------|----------|
| 👍 | `+1` | Valid issue, we fixed it |
| 👎 | `-1` | False positive |
| 😕 | `confused` | Unclear comment |
| ❤️ | `heart` | Great catch, appreciate it |
| 🎉 | `hooray` | Excellent suggestion |

### When to Use Each

| Scenario | Reaction | Reply |
|----------|----------|-------|
| Fixed valid issue | `+1` | "Fixed in commit {sha}" |
| False positive | `-1` | "False positive: {explanation}" |
| Won't fix (intentional) | `+1` | "Intentional: {explanation}" |
| Needs discussion | `confused` | "Need clarification: {question}" |

---

## API Endpoints Reference

### ⚠️ CRITICAL: URL Structure Differs by Operation

GitHub's API has **different URL structures** for listing vs. single-item operations:

| Operation | URL Pattern | Note |
|-----------|-------------|------|
| List all | `/pulls/{pr}/comments` | Includes `{pr}` number |
| Single item | `/pulls/comments/{id}` | NO `{pr}` - direct to comment |
| Reactions | `/pulls/comments/{id}/reactions` | NO `{pr}` - direct to comment |

**Common mistake:** Using `/pulls/{pr}/comments/{id}` → Returns 404!

### Fetch Comments

```bash
# ALL review comments (line-level) - MUST paginate
gh api repos/{o}/{r}/pulls/{pr}/comments --paginate

# ALL issue comments (PR summaries) - Also paginate
gh api repos/{o}/{r}/issues/{pr}/comments --paginate

# SINGLE review comment by ID (note: NO {pr} in URL!)
gh api repos/{o}/{r}/pulls/comments/{comment_id}

# SINGLE issue comment by ID (note: NO {pr} in URL!)
gh api repos/{o}/{r}/issues/comments/{comment_id}
```

### Post Reply

```bash
# Reply to review comment
gh api repos/{o}/{r}/pulls/{pr}/comments \
  -X POST \
  -f body="{message}" \
  -F in_reply_to={comment_id}

# Reply to issue comment (PR summary)
gh api repos/{o}/{r}/issues/{pr}/comments \
  -X POST \
  -f body="{message}"
```

### Manage Reactions

```bash
# Add reaction
gh api repos/{o}/{r}/pulls/comments/{comment_id}/reactions \
  -X POST \
  -f content="+1"

# Delete reaction
gh api repos/{o}/{r}/pulls/comments/{comment_id}/reactions/{reaction_id} \
  -X DELETE

# List reactions
gh api repos/{o}/{r}/pulls/comments/{comment_id}/reactions
```

---

## Quick Decision Tree

```
Bot comment received
       │
       ├── Is it Copilot?
       │       │
       │       YES → FIX SILENTLY, NO RESPONSE
       │
       ├── Is it valid issue?
       │       │
       │       YES → Fix code
       │       │      │
       │       │      └── Is it CodeRabbit?
       │       │              │
       │       │              YES → Reply only
       │       │              NO  → Reaction (+1) THEN Reply
       │       │
       │       NO (false positive)
       │              │
       │              └── Is it CodeRabbit?
       │                      │
       │                      YES → Reply with explanation
       │                      NO  → Reaction (-1) THEN Reply
```

---

## Sources

- [Greptile Auto-Resolve Docs](https://www.greptile.com/docs/code-review-bot/auto-resolve-with-mcp)
- [CodeRabbit Resolve Command](https://docs.coderabbit.ai/changelog/resolve-command)
- [GitHub Copilot Code Review](https://docs.github.com/copilot/using-github-copilot/code-review/using-copilot-code-review)
- [Greptile Embedding Quality](https://www.zenml.io/llmops-database/improving-ai-code-review-bot-comment-quality-through-vector-embeddings)

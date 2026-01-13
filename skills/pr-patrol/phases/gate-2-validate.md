# Gate 2: Validation Complete

**Previous status:** `collected`
**Status to set after completion:** `validated`

---

## What This Phase Does

1. Validate each bot comment to determine REAL vs FALSE POSITIVE
2. Use `bot-comment-validator` agent (NOT manual validation!)
3. Collect verdicts and update state file

---

## CRITICAL: Use Task Tool for Validation

**DO NOT manually read files and validate comments.**

Launch `bot-comment-validator` agents in parallel:

```xml
<Task>
  <subagent_type>bot-comment-validator</subagent_type>
  <description>Validate comment #123456</description>
  <prompt>
Validate this PR bot comment against the actual code:

Comment ID: 123456
Bot: coderabbitai[bot]
File: src/components/customers/customer-list.tsx
Line: 246
Comment: "getRegionLabel is called with customer.region but expects UUID..."

Read the file and determine:
- Is this a REAL issue or FALSE POSITIVE?
- Confidence level (high/medium/low)
- Reasoning for your verdict
- Suggested fix if real issue

Return JSON:
{
  "comment_id": 123456,
  "verdict": "real_issue" | "false_positive" | "uncertain",
  "confidence": 0.85,
  "reasoning": "...",
  "suggested_fix": "..." (if real issue)
}
  </prompt>
</Task>
```

### Batch Validation (Recommended)

For efficiency, group comments by file and validate in batches:

```
File A (3 comments) → Single agent call with all 3
File B (2 comments) → Single agent call with all 2
```

### Parallel Validation

Launch multiple Task calls in a single message for parallelism:

```xml
<!-- All in one message for parallel execution -->
<Task subagent_type="bot-comment-validator" description="Validate comment #111">...</Task>
<Task subagent_type="bot-comment-validator" description="Validate comment #222">...</Task>
<Task subagent_type="bot-comment-validator" description="Validate comment #333">...</Task>
```

---

## Validation Output Format

Each agent returns:

```json
{
  "comment_id": 123456,
  "verdict": "real_issue",
  "confidence": 0.85,
  "reasoning": "The function indeed expects UUID but receives text code...",
  "suggested_fix": "Use customer.regionId ?? customer.region"
}
```

### Verdict Types

| Verdict | Meaning | Action |
|---------|---------|--------|
| `real_issue` | Bot correctly identified a problem | Add to fix queue |
| `false_positive` | Bot was wrong | Mark for dismissal reply |
| `uncertain` | Agent not confident | Escalate to user |

---

## MANDATORY AskUserQuestion

After all validations complete:

```
Header: "Validation"
Question: "Validation complete: {real} real issues, {false} false positives. How to proceed?"
Options:
├── "Fix all real issues ({real})" [Recommended]
├── "Fix critical + high only ({critical_high})"
├── "Select specific issues to fix"
├── "Review validation details"
├── "Skip fixes, proceed to replies"
├── "Stop here (save state)"
```

---

## Edge Cases

| Case | Detection | Action |
|------|-----------|--------|
| All false positives | `real_issues.length == 0` | Skip to Gate 5 (replies) |
| Validator timeout | No response in 60s | Retry/Skip/Manual |
| Validator uncertain | `confidence < 0.6` | Escalate to user with AskUserQuestion |

---

## State File Update

Update the validation results:

```markdown
### FIXED - Real Issues ({count})
| ID | Bot | File | Severity | Summary | Fix Applied |
|----|-----|------|----------|---------|-------------|
| 123 | coderabbitai[bot] | customer-list.tsx | HIGH | UUID vs text mismatch | Pending |

### VALIDATED - False Positives ({count})
| ID | Bot | File | Summary | Verdict |
|----|-----|------|---------|---------|
| 456 | Copilot | config.ts | Type enum suggestion | Code is correct |
```

Add Validation Cache:

```markdown
## Validation Cache
```json
{
  "validated_at": "2026-01-13T10:30:00Z",
  "fixed_issues": [{"id": 123, "severity": "high", "file": "..."}],
  "false_positives": [456, 789]
}
```

Update status:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
"$SCRIPTS/update_state.sh" ".claude/bot-reviews/PR-${PR}.md" status validated
```

---

## After This Phase

1. Update state file: `status: validated`
2. If real issues found → Proceed to: **Gate 3 (Fix Plan)**
3. If all false positives → Skip to: **Gate 5 (Replies)**
4. Read next: `phases/gate-3-fix.md` or `phases/gate-5-reply.md`

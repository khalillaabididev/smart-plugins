# Phase 9: Validation

**Previous phase:** phase-8-priority.md
**Next phase:** phase-10-output.md

---

## Purpose

Run a comprehensive checklist to ensure no critical requirements were missed. This catches gaps before writing the spec.

---

## Validation Process

### Step 1: Check Each Category

Review your state file against this checklist. For each item, mark:
- ✅ COVERED - Clearly addressed in interview
- ⚠️ PARTIAL - Mentioned but needs clarification
- ❌ MISSING - Not discussed

### Critical Categories (Must Address)

| Category | Items to Check |
|----------|----------------|
| **Problem** | Problem statement clear? Success metrics measurable? |
| **Users** | Primary users identified? Devices known? |
| **Functional** | CRUD operations defined? Validation rules set? |
| **Data** | Required fields listed? Data sources identified? |
| **UI States** | Loading, empty, error, success states defined? |
| **Permissions** | Who can access? Permission levels? |
| **Security** | Data sensitivity classified? Auth requirements? |

### Recommended Categories

| Category | Items to Check |
|----------|----------------|
| **Edge Cases** | Concurrent editing? Network failure? |
| **Performance** | Load time targets? User volume? |
| **Accessibility** | WCAG level? Keyboard navigation? |
| **Integrations** | Third-party services? APIs? |

### Often Missed (Check Specifically)

| Item | Question |
|------|----------|
| Empty states | What shows when there's no data? |
| Error messages | User-facing error text defined? |
| Confirmation dialogs | Destructive actions confirmed? |
| Search/filter | How do users find specific items? |
| Pagination | How are large lists handled? |
| Timezone handling | Date/time display across zones? |

---

## Step 2: Present Gaps

After checking, present findings:

```
Validation Results:

✅ COVERED: 12 categories
⚠️ NEEDS CLARIFICATION: 2 items
❌ MISSING: 1 item

Details:
⚠️ UI States: Empty state mentioned but no specific message defined
⚠️ Error messages: Generic handling, no specific messages
❌ Pagination: Not discussed - how should large lists be handled?

How would you like to proceed?

[1] Add missing items now (Recommended)
[2] Mark as out-of-scope (will note in spec)
[3] Skip validation (proceed with current info)
```

---

## Step 3: Fill Gaps (If Option 1)

For each missing/partial item, ask targeted questions:

**Example for empty state:**
"What message should users see when there's no data yet? And should there be a call-to-action button?"

**Example for pagination:**
"For lists with many items, should we use pagination (pages of 10-50) or infinite scroll?"

---

## Step 4: Calculate Complexity

Based on collected requirements, estimate complexity:

| Factor | Points |
|--------|--------|
| Each Must-have requirement | +2 |
| Each Should-have requirement | +1 |
| Each integration | +3 |
| Complex business logic | +5 |
| Offline support | +5 |
| Real-time features | +4 |
| Multi-language support | +3 |

**Complexity Score:**
- **Low (< 15):** Single-phase delivery
- **Medium (15-30):** Consider 2 phases
- **High (> 30):** Recommend splitting into 3+ phases

If HIGH complexity, recommend splitting:

```
This feature has high complexity (score: {N}).

I recommend splitting into phases:
- Phase 1: Core MVP ({X} points)
- Phase 2: Enhancements ({Y} points)

This reduces risk and allows earlier feedback. Agree?
```

---

## Completion Criteria

Before proceeding, verify:
- [ ] All critical categories validated
- [ ] Gaps addressed or explicitly marked out-of-scope
- [ ] Complexity score calculated
- [ ] Phasing recommendation made (if high complexity)
- [ ] User confirmed ready to proceed

---

## Update State File

```markdown
## Validation Results

### Coverage
- **Covered:** {N} categories
- **Partial:** {N} items
- **Missing:** {N} items (addressed/out-of-scope)

### Complexity
- **Score:** {N} points
- **Level:** Low/Medium/High
- **Recommendation:** {single phase / split}

### Gaps Addressed
- {Item}: {How addressed or "Out of scope"}
```

Update frontmatter: `current_phase: 10`, `status: writing`

---

## Update TodoWrite

Mark Phase 9 complete, Phase 10 in_progress.

---

## NEXT STEP

**IMMEDIATELY read:** `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/phases/phase-10-output.md`

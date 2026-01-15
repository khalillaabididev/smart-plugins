# Phase 5: Edge Cases & Error Handling

**Previous phase:** phase-4-ui.md
**Next phase:** phase-6-nfr.md

---

## Purpose

Anticipate and define behavior for exceptional situations. What could go wrong, and how should the system handle it?

---

## Questions to Ask

### Permission & Access

1. **"What if user doesn't have permission to access this?"**
   - Show nothing, show disabled, show message

2. **"Are there different permission levels?"**
   - View only, edit, admin
   - What can each level do?

### Concurrency

3. **"What if two users try to edit the same thing simultaneously?"**
   - First wins, last wins, merge, lock

4. **"Is a locking mechanism needed?"**
   - Optimistic vs pessimistic locking
   - Lock timeout

### Data Edge Cases

5. **"What if required data is missing from source?"**
   - Show placeholder, skip, error

6. **"Are there maximum limits?"**
   - Max items in list
   - Max file size
   - Max characters

7. **"How are duplicates handled?"**
   - Prevent, warn, allow
   - What defines a duplicate?

### User Errors

8. **"Is undo/redo needed?"**
   - How far back?

9. **"Which actions need confirmation before executing?"**
   - Delete, bulk operations, irreversible changes

10. **"Auto-save or manual save?"**
    - Frequency if auto-save
    - What triggers save

### Network & System

11. **"What if the network drops mid-operation?"**
    - Retry, save draft, lose changes

12. **"What if a dependent service is unavailable?"**
    - Graceful degradation
    - Cached data

---

## Completion Criteria

Before proceeding, verify:
- [ ] Permission scenarios defined
- [ ] Concurrent access handling decided
- [ ] Data limits established
- [ ] Destructive action confirmations specified
- [ ] Save behavior defined
- [ ] Network failure handling planned

---

## Update State File

```markdown
## Phase 5: Edge Cases & Error Handling ✅

### Permissions
| Level | Can View | Can Edit | Can Delete | Can Admin |
|-------|----------|----------|------------|-----------|
| {role} | Yes/No | Yes/No | Yes/No | Yes/No |

### Concurrency
- **Strategy:** {lock/merge/last-wins}
- **Lock timeout:** {duration or N/A}

### Limits
| Limit | Value | What happens when exceeded |
|-------|-------|---------------------------|
| {limit type} | {value} | {behavior} |

### Confirmations Required
- {Action}: {confirmation type}

### Save Behavior
- **Type:** Auto-save / Manual
- **Frequency:** {if auto}

### Error Recovery
- **Network drop:** {behavior}
- **Service unavailable:** {behavior}
```

Update frontmatter: `current_phase: 6`

---

## Update TodoWrite

Mark Phase 5 complete, Phase 6 in_progress.

---

## NEXT STEP

**IMMEDIATELY read:** `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/phases/phase-6-nfr.md`

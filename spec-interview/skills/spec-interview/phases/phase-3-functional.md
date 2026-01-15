# Phase 3: Functional Requirements

**Previous phase:** phase-2-users.md
**Next phase:** phase-4-ui.md

---

## Purpose

Define concrete actions, inputs, outputs, and business logic. This is the core of what the feature does.

---

## Questions to Ask

### Core Actions (CRUD Checklist)

1. **"What can users CREATE or add with this feature?"**
   - New records, entries, documents

2. **"What information do users need to SEE or read?"**
   - Lists, details, reports, dashboards

3. **"What can users UPDATE or modify?"**
   - Edit existing data, change settings

4. **"What can users DELETE or remove?"**
   - Soft delete vs hard delete?
   - Cascading effects?

### Data Requirements

5. **"What information needs to be captured?"**
   - List all fields/data points

6. **"Which fields are required vs optional?"**
   - Mandatory for basic function
   - Optional enhancements

7. **"What validation rules apply to each field?"**
   - Format (email, phone, date)
   - Length limits
   - Allowed values

8. **"Where does the data come from?"**
   - User input
   - Imported from other systems
   - Calculated

### Business Logic

9. **"Are there any calculations or formulas?"**
   - Totals, averages, percentages
   - Complex business rules

10. **"Any conditional logic? If X then Y?"**
    - Approval workflows
    - Status-based behavior

11. **"Are there any automated triggers?"**
    - Auto-notifications
    - Scheduled tasks

### Integrations

12. **"Does this connect to other systems?"**
    - Internal systems
    - Third-party services

13. **"Any import/export requirements?"**
    - File formats (CSV, Excel, PDF)
    - API integrations

14. **"What notifications are needed?"**
    - Email, SMS, push, in-app

---

## Completion Criteria

Before proceeding, verify:
- [ ] All CRUD operations defined
- [ ] Data fields listed with validation rules
- [ ] Business logic documented
- [ ] Integrations identified
- [ ] Each requirement could be turned into a test case

---

## Update State File

```markdown
## Phase 3: Functional Requirements ✅

### Core Actions
| Action | Description | Details |
|--------|-------------|---------|
| Create | {what} | {details} |
| Read | {what} | {details} |
| Update | {what} | {details} |
| Delete | {what} | {details} |

### Data Model
| Field | Type | Required | Validation |
|-------|------|----------|------------|
| {name} | {type} | Yes/No | {rules} |

### Business Logic
- {Rule 1}
- {Rule 2}

### Integrations
- {System}: {Purpose}

### Notifications
- {Trigger}: {Channel} - {Content}
```

Update frontmatter: `current_phase: 4`

---

## Update TodoWrite

Mark Phase 3 complete, Phase 4 in_progress.

---

## NEXT STEP

**IMMEDIATELY read:** `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/phases/phase-4-ui.md`

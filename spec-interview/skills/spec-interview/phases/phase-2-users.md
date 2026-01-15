# Phase 2: Users & Stakeholders

**Previous phase:** phase-1-problem.md
**Next phase:** phase-3-functional.md

---

## Purpose

Identify all people affected by this feature - both direct users and indirect stakeholders.

---

## Questions to Ask

### Primary Users

1. **"Who will use this feature daily? What's their role?"**
   - Get specific roles, not names
   - "Sales rep", "Admin", "Customer"

2. **"What's their technical comfort level?"**
   - Affects UI complexity decisions

3. **"What devices do they primarily use?"**
   - Desktop, mobile, tablet, specific browsers

4. **"When and where do they typically work?"**
   - Office, field, remote, specific times

5. **"How many users do we expect? Now and in 6 months?"**
   - Scale considerations

### User Goals

6. **"What's the main job this user is trying to accomplish?"**
   - Jobs-to-be-done perspective

7. **"What's frustrating them about current tools/processes?"**
   - Pain points to address

### Secondary Stakeholders

8. **"Who else is affected but won't directly use this feature?"**
   - Managers viewing reports
   - Downstream teams receiving data

9. **"Who needs to approve or sign off on this feature?"**
   - Decision makers, compliance

10. **"Who will support users if something goes wrong?"**
    - Support team, helpdesk

---

## Completion Criteria

Before proceeding, verify:
- [ ] Primary user role(s) clearly defined
- [ ] User technical level understood
- [ ] Device/platform requirements known
- [ ] Expected user count estimated
- [ ] Secondary stakeholders identified
- [ ] Approval chain understood (if any)

---

## Update State File

```markdown
## Phase 2: Users & Stakeholders ✅

### Primary Users
**Role:** {role name}
**Tech Level:** {Non-technical / Somewhat / Very}
**Devices:** {Desktop, Mobile, etc.}
**Usage Context:** {When/where they work}
**Expected Count:** {number} now, {number} in 6 months

### User Goals
- Primary: {main job to be done}
- Pain Points: {current frustrations}

### Secondary Stakeholders
- {Role}: {how they're affected}
- {Role}: {how they're affected}

### Approval Chain
{Who needs to sign off, or "N/A"}
```

Update frontmatter: `current_phase: 3`

---

## Update TodoWrite

Mark Phase 2 complete, Phase 3 in_progress.

---

## NEXT STEP

**IMMEDIATELY read:** `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/phases/phase-3-functional.md`

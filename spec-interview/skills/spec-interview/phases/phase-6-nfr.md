# Phase 6: Non-Functional Requirements

**Previous phase:** phase-5-edge-cases.md
**Next phase:** phase-7-technical.md

---

## Purpose

Define performance, security, accessibility, and compliance expectations. These are the "-ilities": reliability, scalability, usability, etc.

---

## Questions to Ask

### Performance

1. **"What's an acceptable page load time?"**
   - Under 2 seconds is typical target

2. **"How many concurrent users do you expect?"**
   - Peak load scenarios

3. **"How much data will this feature handle?"**
   - Records now vs in 1 year
   - Data growth rate

### Security

4. **"How sensitive is the data in this feature?"**
   - Public, internal, confidential, restricted

5. **"Who should be able to access this?"**
   - Authentication requirements
   - Role-based access

6. **"Is audit logging needed?"**
   - What actions to log
   - Retention period

7. **"Any data encryption requirements?"**
   - At rest, in transit

### Accessibility

8. **"What accessibility level is required?"**
   - WCAG A, AA, or AAA

9. **"Is keyboard-only navigation required?"**
   - Tab order, focus management

10. **"Is screen reader support required?"**
    - ARIA labels, semantic HTML

### Compliance

11. **"Are there regulatory requirements?"**
    - GDPR (EU data protection)
    - HIPAA (healthcare)
    - KVKK (Turkey)
    - PCI-DSS (payment data)
    - SOC 2 (security)

12. **"Any data residency requirements?"**
    - Where data must be stored

---

## Adapt to Tech Level

**For non-technical users:** 
- Focus on business requirements (speed, security, compliance)
- Skip detailed technical metrics
- Use analogies: "Should feel instant" vs "< 200ms response time"

**For technical users:**
- Get specific numbers
- Discuss SLAs and targets
- Include monitoring requirements

---

## Completion Criteria

Before proceeding, verify:
- [ ] Performance expectations set (even if "standard")
- [ ] Data sensitivity classified
- [ ] Access control requirements clear
- [ ] Accessibility level decided
- [ ] Compliance requirements identified

---

## Update State File

```markdown
## Phase 6: Non-Functional Requirements ✅

### Performance
- **Page load:** < {X} seconds
- **Concurrent users:** {N}
- **Data volume:** {current} → {projected}

### Security
- **Data sensitivity:** {Public/Internal/Confidential/Restricted}
- **Authentication:** {Required/Not required}
- **Authorization:** {Role-based details}
- **Audit logging:** {Yes/No} - {what's logged}
- **Encryption:** {At rest/In transit/Both/N/A}

### Accessibility
- **WCAG Level:** {A/AA/AAA/Not required}
- **Keyboard navigation:** {Required/Not required}
- **Screen reader:** {Required/Not required}

### Compliance
- **Regulations:** {GDPR/HIPAA/KVKK/etc or None}
- **Data residency:** {requirements or N/A}
```

Update frontmatter: `current_phase: 7`

---

## Update TodoWrite

Mark Phase 6 complete, Phase 7 in_progress.

---

## NEXT STEP

**IMMEDIATELY read:** `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/phases/phase-7-technical.md`

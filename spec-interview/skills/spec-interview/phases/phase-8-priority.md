# Phase 8: Prioritization & Phasing

**Previous phase:** phase-7-technical.md
**Next phase:** phase-9-validate.md

---

## Purpose

Break down the feature into manageable phases if needed. Determine what's essential for MVP vs future enhancements.

---

## Questions to Ask

### MoSCoW Prioritization

1. **"What MUST be in the first release for this to be useful?"**
   - Core functionality only
   - Absolute minimum viable product

2. **"What SHOULD be included if we have time?"**
   - Important but not blocking
   - Enhances core functionality

3. **"What COULD be nice additions for later?"**
   - Good to have
   - Polish and refinements

4. **"What explicitly WON'T be built (out of scope)?"**
   - Features that seem related but aren't included
   - Future considerations

### Dependencies

5. **"What must exist before we can build this?"**
   - Other features
   - Infrastructure
   - Data sources

6. **"What other features depend on this being done?"**
   - Downstream work
   - Blocking other teams

### Timeline

7. **"Is there a target launch date?"**
   - Hard deadline vs soft target
   - What's driving the date

8. **"Should we plan multiple release phases?"**
   - MVP first, then iterations
   - Feature flags for gradual rollout

---

## Phasing Recommendation

If the feature is complex (many must-haves), suggest splitting:

```
Based on what we discussed, I'd recommend splitting this into phases:

**Phase 1 (MVP):**
- {Core feature 1}
- {Core feature 2}

**Phase 2 (Enhancement):**
- {Should-have 1}
- {Should-have 2}

**Future:**
- {Could-have items}

Does this phasing make sense, or would you adjust it?
```

---

## Completion Criteria

Before proceeding, verify:
- [ ] Must-haves clearly defined (MVP scope)
- [ ] Should-haves listed with priority order
- [ ] Out-of-scope items explicitly stated
- [ ] Dependencies identified
- [ ] Timeline expectations set
- [ ] Phasing approach agreed (if applicable)

---

## Update State File

```markdown
## Phase 8: Prioritization & Phasing ✅

### MoSCoW
**Must Have (P0 - MVP):**
- [ ] {requirement 1}
- [ ] {requirement 2}

**Should Have (P1):**
- [ ] {requirement 3}
- [ ] {requirement 4}

**Could Have (P2):**
- [ ] {requirement 5}

**Won't Have (Out of Scope):**
- {excluded item 1}
- {excluded item 2}

### Dependencies
**Requires:**
- {dependency 1}
- {dependency 2}

**Blocks:**
- {what this unblocks}

### Timeline
- **Target:** {date or "No hard deadline"}
- **Phases:** {single release / multiple phases}

### Phasing (if applicable)
**Phase 1:** {scope} - {target date}
**Phase 2:** {scope} - {target date}
```

Update frontmatter: `current_phase: 9`, `status: validating`

---

## Update TodoWrite

Mark Phase 8 complete, Phase 9 in_progress.

---

## Interview Complete!

You've now gathered all requirements. Before writing the spec, validation is needed.

---

## NEXT STEP

**IMMEDIATELY read:** `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/phases/phase-9-validate.md`

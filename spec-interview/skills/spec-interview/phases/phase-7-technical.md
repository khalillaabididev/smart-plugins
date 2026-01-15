# Phase 7: Technical Architecture

**Previous phase:** phase-6-nfr.md
**Next phase:** phase-8-priority.md

---

## Purpose

Capture implementation preferences and constraints. This phase helps developers understand the technical landscape.

---

## IMPORTANT: Adapt to Tech Level

### For Non-Technical Users
- Ask high-level questions only
- Provide "Let the team decide" as a valid option
- Use ELI5 analogies when explaining concepts
- Skip detailed API/database questions

### For Technical Users
- Full technical deep-dive
- Specific technology choices
- Architecture patterns
- Implementation constraints

---

## Questions to Ask

### Data Storage (All users)

1. **"Is there existing data this needs to work with?"**
   - Connect to existing systems
   - Migration requirements

2. **"Does this data need to be available offline?"**
   - Local storage requirements

### For Technical Users Only

3. **"What database or storage approach makes sense?"**
   - New tables/collections
   - Relationship to existing data

4. **"Any caching requirements?"**
   - What to cache, TTL, invalidation

5. **"What API endpoints are needed?"**
   - REST, GraphQL, WebSocket
   - Rate limiting

### Integrations (All users)

6. **"Are there third-party services to integrate?"**
   - Payment processors
   - Email providers
   - Analytics
   - Authentication providers

7. **"Any existing internal systems to connect?"**
   - Legacy systems
   - Shared services

### Technical Constraints

8. **"Are there technology constraints?"**
   - Must use certain stack
   - Must avoid certain dependencies
   - Browser support requirements

9. **"Any known technical risks or challenges?"**
   - Performance concerns
   - Integration complexity
   - Data migration challenges

---

## Completion Criteria

**For non-technical users:**
- [ ] Existing data connections identified
- [ ] Third-party integrations listed
- [ ] Known constraints documented

**For technical users:**
- [ ] Data model approach decided
- [ ] API design outlined
- [ ] Caching strategy defined
- [ ] Integration architecture clear
- [ ] Technical risks identified

---

## Update State File

```markdown
## Phase 7: Technical Architecture ✅

### Data Storage
- **Existing data:** {what needs to connect}
- **New storage:** {approach or "Team to decide"}
- **Offline support:** {Yes/No}

### APIs (if technical user)
- **Style:** {REST/GraphQL/WebSocket}
- **Key endpoints:** {list}
- **Rate limiting:** {requirements}

### Integrations
| System | Type | Purpose |
|--------|------|---------|
| {name} | {internal/external} | {why} |

### Technical Constraints
- {constraint 1}
- {constraint 2}

### Technical Risks
- {risk}: {mitigation}
```

Update frontmatter: `current_phase: 8`

---

## Update TodoWrite

Mark Phase 7 complete, Phase 8 in_progress.

---

## NEXT STEP

**IMMEDIATELY read:** `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/phases/phase-8-priority.md`

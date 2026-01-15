# Phase 1: Problem & Vision

**Previous phase:** phase-0.5-calibrate.md
**Next phase:** phase-2-users.md

---

## Purpose

Understand the root problem before jumping to solutions. This phase establishes the "why" behind the feature.

---

## Questions to Ask

Ask these questions ONE AT A TIME. Wait for answer before asking the next.

### Problem Discovery

1. **"What specific problem or pain point triggered this idea?"**
   - Listen for concrete examples
   - If vague, ask: "Can you give me a specific example of when this problem occurred?"

2. **"How is this problem currently being solved? Any workarounds?"**
   - Understanding current state reveals gaps
   - "What's frustrating about the current approach?"

3. **"How often does this problem occur? Daily? Weekly? Monthly?"**
   - Frequency indicates priority

4. **"What happens if we don't build this?"**
   - Cost of inaction reveals business impact

### Vision & Success

5. **"What does success look like 6 months after launch?"**
   - Paint a picture of the desired future state

6. **"How will we measure if this feature is successful?"**
   - Push for specific, measurable metrics
   - If vague: "What number would tell you this worked?"

7. **"What would make users say 'this is exactly what I needed'?"**
   - User delight criteria

### Business Context

8. **"What's the business priority? Must-have or nice-to-have?"**

9. **"Any deadlines or time constraints driving this?"**

---

## Completion Criteria

DO NOT proceed to Phase 2 until ALL of these are true:
- [ ] Root problem is clearly articulated (not just symptoms)
- [ ] Current workarounds are documented
- [ ] Success metrics are measurable (number, percentage, time)
- [ ] Business priority is understood
- [ ] You could explain this problem to a developer with 100% confidence

---

## Update State File

After completing this phase, update the state file:

```markdown
## Phase 1: Problem & Vision ✅

### Problem Statement
{Concise problem description}

### Current Workarounds
{How it's solved today}

### Frequency
{How often the problem occurs}

### Cost of Inaction
{What happens if not built}

### Success Metrics
- {Metric 1}: {Target}
- {Metric 2}: {Target}

### Business Priority
{Must-have / Should-have / Nice-to-have}

### Deadline
{Date or "No hard deadline"}
```

Update frontmatter: `current_phase: 2`

---

## Update TodoWrite

Mark Phase 1 complete, Phase 2 in_progress.

---

## NEXT STEP

**IMMEDIATELY read:** `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/phases/phase-2-users.md`

# Phase 0.5: Tech Level Calibration

**Previous phase:** phase-0-init.md
**Next phase:** phase-1-problem.md

---

## Purpose

Calibrate your communication style based on user's technical background. This affects how you ask questions throughout the interview.

---

## Step 1: Ask Tech Level (MANDATORY)

This question MUST be asked. Never skip.

```
question: "Before we dive in, how would you describe your technical background?"
header: "Tech Level"
options:
  - label: "Non-technical"
    description: "Business person, designer, product manager - explain concepts simply"
  - label: "Somewhat technical"
    description: "Understand basics (APIs, databases) but not a developer"
  - label: "Very technical"
    description: "Developer or engineer - skip explanations, get specific"
```

**Save response to state:** Update `tech_level` field.

---

## Step 2: Adapt Communication Style

Based on response, adjust your approach for ALL subsequent phases:

### Non-technical User

- Use analogies and real-world comparisons
- Avoid jargon or explain when necessary
- Focus on "what" not "how"
- Provide examples for abstract concepts
- Skip detailed technical architecture questions (Phase 7)

### Somewhat Technical User

- Use standard tech terms (API, database, UI)
- Brief explanations when introducing new concepts
- Balance business and technical questions
- Include high-level architecture discussion

### Very Technical User

- Be direct and specific
- Use precise technical terminology
- Skip basic explanations
- Deep dive into technical architecture
- Discuss implementation details

---

## Step 3: Confirm Understanding

Summarize what you understand about their feature idea in 2-3 sentences, then ask:

```
question: "Here's what I understand so far: [your summary]. Is this correct?"
header: "Confirm Understanding"
options:
  - label: "Yes, that's correct"
    description: "Your understanding is accurate, let's proceed"
  - label: "Partially correct"
    description: "Some parts need clarification"
  - label: "No, let me explain differently"
    description: "My idea is different from your understanding"
```

**If Partially/No:** Ask clarifying questions until you reach mutual understanding. Loop as needed.

---

## Step 4: FILE MODE - Pre-Analysis (Skip if IDEA mode)

If user provided a file, analyze it now:

1. Read the file content
2. For each interview phase (1-8), classify coverage:

| Status | Meaning | Action |
|--------|---------|--------|
| ✅ CLEAR | Specific, concrete details present | Can skip or briefly confirm |
| ⚠️ VAGUE | Mentioned but lacking detail | Ask targeted questions |
| ❌ MISSING | Not addressed | Full phase interview |

3. Present analysis to user:

```
Based on your document, here's what I found:

✅ CLEAR: Problem statement, Target users
⚠️ NEEDS CLARIFICATION: Functional requirements (missing acceptance criteria)
❌ NOT COVERED: Edge cases, Non-functional requirements, Technical architecture

How would you like to proceed?

[1] Focus on gaps only (Recommended) - Skip clear sections
[2] Review everything - Confirm even clear sections  
[3] Start fresh - Ignore document, full interview
```

---

## Update State File

After calibration, update the state file:

```markdown
## Phase 0.5: Calibration ✅

**Tech Level:** {response}
**Initial Understanding:** {your summary}
**User Confirmed:** Yes/Adjusted
**Mode:** IDEA / FILE
**File Analysis:** (if FILE mode, include coverage summary)
```

Update frontmatter:
- `current_phase: 1`
- `status: interviewing`
- `tech_level: "{response}"`

---

## Phase Completion Checklist

Before proceeding, verify:
- [ ] Tech level is recorded
- [ ] Initial understanding is confirmed by user
- [ ] If FILE mode: pre-analysis is complete
- [ ] State file is updated
- [ ] TodoWrite shows Phase 0.5 complete, Phase 1 in_progress

---

## NEXT STEP

**IMMEDIATELY read:** `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/phases/phase-1-problem.md`

Do NOT wait for additional user input. The interview continues.

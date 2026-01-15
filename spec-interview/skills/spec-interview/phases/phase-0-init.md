# Phase 0: Initialize Session

**Next phase:** phase-0.5-calibrate.md

---

## Step 1: Detect Input Mode

Check the argument passed to `/spec-interview`:

| Input Pattern | Mode | Action |
|---------------|------|--------|
| Wrapped in quotes (`"..."`) | IDEA | Start fresh interview |
| File path (`.md`, `.txt`, `docs/`) | FILE | Analyze file first |
| No argument | IDEA | Ask what they want to spec |

---

## Step 2: Generate Spec ID

Create a URL-safe identifier from the feature name:

```
"Add dark mode to app" → "add-dark-mode-to-app"
"Nueva función de exportación" → "nueva-funcion-de-exportacion"
```

Rules:
- Lowercase
- Replace spaces with hyphens
- Remove special characters
- Max 50 characters

---

## Step 3: Check for Existing Session

```bash
ls .claude/spec-interviews/*.md 2>/dev/null
```

### If state file exists for this spec_id:

Ask user:

```
question: "Found a previous interview for this feature. How would you like to proceed?"
header: "Resume Session"
options:
  - label: "Resume where I left off (Recommended)"
    description: "Continue from Phase {N}"
  - label: "Start fresh"
    description: "Begin new interview, discard previous progress"
  - label: "Show summary first"
    description: "Review what was discussed before deciding"
```

**If Resume:** Read state file, identify current_phase, skip to that phase.
**If Fresh:** Delete old state file, continue to Step 4.
**If Summary:** Display state file summary, then ask again.

---

## Step 4: Create State File (New Session Only)

Create directory and state file:

```bash
mkdir -p .claude/spec-interviews
```

Write initial state to `.claude/spec-interviews/{spec_id}.md`:

```markdown
---
spec_id: "{spec_id}"
feature_name: "{original feature name}"
current_phase: 0
status: initialized
tech_level: ""
language: ""
created: "{ISO timestamp}"
last_updated: "{ISO timestamp}"
---

# Spec Interview: {Feature Name}

## Progress

| Phase | Status | Summary |
|-------|--------|---------|
| 0. Init | ✅ | Session created |
| 0.5 Calibration | ⏳ | Pending |
| 1. Problem | ⬜ | - |
| 2. Users | ⬜ | - |
| 3. Functional | ⬜ | - |
| 4. UI/UX | ⬜ | - |
| 5. Edge Cases | ⬜ | - |
| 6. NFR | ⬜ | - |
| 7. Technical | ⬜ | - |
| 8. Priority | ⬜ | - |
| 9. Validation | ⬜ | - |
| 10. Output | ⬜ | - |

---

## Phase 0.5: Calibration

(Pending)

---

## Phase 1: Problem & Vision

(Not started)

---

## Phase 2: Users & Stakeholders

(Not started)

---

## Phase 3: Functional Requirements

(Not started)

---

## Phase 4: UI/UX Design

(Not started)

---

## Phase 5: Edge Cases

(Not started)

---

## Phase 6: Non-Functional Requirements

(Not started)

---

## Phase 7: Technical Architecture

(Not started)

---

## Phase 8: Prioritization

(Not started)

---

## Validation Results

(Pending)

---

## Output

- **Spec file:** (not generated)
- **Complexity:** (not calculated)
```

---

## Step 5: Setup TodoWrite

Create the todo list for progress tracking:

```json
[
  {"id": "p0", "content": "Phase 0: Initialize session", "status": "completed", "priority": "high"},
  {"id": "p0.5", "content": "Phase 0.5: Calibrate tech level", "status": "in_progress", "priority": "high"},
  {"id": "p1", "content": "Phase 1: Problem & Vision", "status": "pending", "priority": "high"},
  {"id": "p2", "content": "Phase 2: Users & Stakeholders", "status": "pending", "priority": "high"},
  {"id": "p3", "content": "Phase 3: Functional Requirements", "status": "pending", "priority": "high"},
  {"id": "p4", "content": "Phase 4: UI/UX Design", "status": "pending", "priority": "medium"},
  {"id": "p5", "content": "Phase 5: Edge Cases", "status": "pending", "priority": "medium"},
  {"id": "p6", "content": "Phase 6: Non-Functional", "status": "pending", "priority": "medium"},
  {"id": "p7", "content": "Phase 7: Technical Architecture", "status": "pending", "priority": "medium"},
  {"id": "p8", "content": "Phase 8: Prioritization", "status": "pending", "priority": "medium"},
  {"id": "p9", "content": "Phase 9: Validation", "status": "pending", "priority": "high"},
  {"id": "p10", "content": "Phase 10: Write Spec", "status": "pending", "priority": "high"}
]
```

---

## Step 6: Detect Language

Analyze user's input text. If non-English detected, note the language code.

Common patterns:
- Turkish: "özellik", "ekle", "kullanıcı"
- Spanish: "función", "añadir", "usuario"
- German: "Funktion", "hinzufügen", "Benutzer"

Save detected language to state: `language: "{code}"`

---

## Phase Completion

After completing all steps:

1. Update state file: `current_phase: 0.5`, `status: calibrating`
2. Mark Phase 0 complete in TodoWrite
3. Mark Phase 0.5 in_progress in TodoWrite

---

## NEXT STEP

**IMMEDIATELY read:** `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/phases/phase-0.5-calibrate.md`

Do NOT wait for user input. Continue the interview flow.

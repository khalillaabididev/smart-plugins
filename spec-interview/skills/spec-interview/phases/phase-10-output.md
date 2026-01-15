# Phase 10: Output - Write Spec Document

**Previous phase:** phase-9-validate.md
**Next phase:** None (Interview Complete!)

---

## Purpose

Generate the final specification document using all collected information.

---

## Step 1: Confirm Save Location

Ask user:

```
question: "Where should I save the specification document?"
header: "Save Location"
options:
  - label: "docs/specs/{feature-name}.md (Recommended)"
    description: "Standard spec location"
  - label: "Current directory"
    description: "Save as {feature-name}-spec.md here"
  - label: "Custom path"
    description: "I'll specify the path"
```

---

## Step 2: Generate Spec Document

Use the template from `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/references/spec-template.md`.

### Document Structure

1. **Executive Summary** - From Phase 1 (Problem)
2. **Problem Statement** - From Phase 1
3. **User Personas** - From Phase 2
4. **User Stories** - From Phases 2 & 8 (prioritized)
5. **Functional Requirements** - From Phase 3
6. **UI/UX Specifications** - From Phase 4
7. **Edge Cases & Error Handling** - From Phase 5
8. **Non-Functional Requirements** - From Phase 6
9. **Technical Notes** - From Phase 7 (if technical user)
10. **Assumptions & Constraints** - Gathered throughout
11. **Dependencies** - From Phase 8
12. **Phasing** - From Phases 8 & 9
13. **Open Questions** - Any unresolved items
14. **Appendix** - Glossary, references

### Writing Guidelines

- **Be specific, not vague** - Use exact numbers, not "fast" or "many"
- **Use tables** - For structured data (fields, permissions, states)
- **Include acceptance criteria** - Each requirement should be testable
- **Match language** - Write in the same language as the interview
- **Keep technical terms in English** - API, UI, database, etc.

---

## Step 3: Write the Document

Read the full state file and synthesize into spec format.

```bash
# Read collected answers
cat .claude/spec-interviews/{spec_id}.md
```

Then write spec to chosen location:

```bash
# Create spec directory if needed
mkdir -p docs/specs

# Write spec file
# (Use Write tool to create the document)
```

---

## Step 4: Present Summary

After writing, show summary:

```
✅ Specification document created!

📄 Location: {file path}
📊 Complexity: {Low/Medium/High}
📋 Sections: 14
✓ Word count: ~{N}

Key highlights:
- Problem: {one-line summary}
- Users: {primary user role}
- MVP Scope: {N} requirements
- Timeline: {target or "Not specified"}

Next steps:
1. Review the spec document
2. Share with stakeholders for feedback
3. Create implementation tickets

Would you like me to open the spec file?
```

---

## Step 5: Update State File

Mark interview complete:

```markdown
## Output

- **Spec file:** {path}
- **Created:** {timestamp}
- **Complexity:** {score} ({level})
- **Word count:** {N}
```

Update frontmatter:
- `current_phase: complete`
- `status: completed`
- `completed_at: {timestamp}`

---

## Step 6: Final TodoWrite Update

Mark ALL todos complete:

```json
[
  {"id": "p0", "content": "Phase 0: Initialize session", "status": "completed", "priority": "high"},
  {"id": "p0.5", "content": "Phase 0.5: Calibrate tech level", "status": "completed", "priority": "high"},
  {"id": "p1", "content": "Phase 1: Problem & Vision", "status": "completed", "priority": "high"},
  {"id": "p2", "content": "Phase 2: Users & Stakeholders", "status": "completed", "priority": "high"},
  {"id": "p3", "content": "Phase 3: Functional Requirements", "status": "completed", "priority": "high"},
  {"id": "p4", "content": "Phase 4: UI/UX Design", "status": "completed", "priority": "medium"},
  {"id": "p5", "content": "Phase 5: Edge Cases", "status": "completed", "priority": "medium"},
  {"id": "p6", "content": "Phase 6: Non-Functional", "status": "completed", "priority": "medium"},
  {"id": "p7", "content": "Phase 7: Technical Architecture", "status": "completed", "priority": "medium"},
  {"id": "p8", "content": "Phase 8: Prioritization", "status": "completed", "priority": "medium"},
  {"id": "p9", "content": "Phase 9: Validation", "status": "completed", "priority": "high"},
  {"id": "p10", "content": "Phase 10: Write Spec", "status": "completed", "priority": "high"}
]
```

---

## Interview Complete!

The requirements interview is finished. The spec document captures everything discussed and is ready for review.

**Do NOT continue to any other phase. The workflow is complete.**

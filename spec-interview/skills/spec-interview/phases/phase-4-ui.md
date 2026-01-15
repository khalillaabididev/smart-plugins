# Phase 4: UI/UX Design

**Previous phase:** phase-3-functional.md
**Next phase:** phase-5-edge-cases.md

---

## Purpose

Define the user interface and experience - where the feature lives, how it looks, and how users interact with it.

---

## Questions to Ask

### Layout & Navigation

1. **"Where does this feature live in the app?"**
   - New page, existing page, modal, sidebar

2. **"How do users navigate to this feature?"**
   - Menu item, button, link, keyboard shortcut

3. **"What's the primary layout?"**
   - List view, grid, form, dashboard, wizard

### States (CRITICAL - Often Missed!)

4. **"What do users see while data is LOADING?"**
   - Spinner, skeleton, progress bar

5. **"What if there's NO DATA yet (empty state)?"**
   - Message, illustration, call-to-action

6. **"How are ERRORS displayed?"**
   - Inline, toast, modal, banner

7. **"How is SUCCESS confirmed?"**
   - Toast notification, redirect, checkmark

8. **"What if content is LOCKED or unavailable?"**
   - Permission denied message
   - "Being edited by..." indicator

### Components & Interaction

9. **"What are the main UI components needed?"**
   - Tables, forms, cards, charts, modals

10. **"Any special interactions?"**
    - Drag-and-drop, inline editing, real-time updates

11. **"What actions are available from each view?"**
    - Buttons, menus, context actions

### Responsive Design

12. **"Must this work on mobile? Tablet?"**
    - Which breakpoints matter

13. **"How should layout adapt for smaller screens?"**
    - Stack, hide, collapse, different view

---

## Completion Criteria

Before proceeding, verify:
- [ ] Navigation path defined
- [ ] Primary layout chosen
- [ ] All 5 states defined (loading, empty, error, success, locked)
- [ ] Key components identified
- [ ] Responsive requirements clear

---

## Update State File

```markdown
## Phase 4: UI/UX Design ✅

### Navigation
- **Location:** {where in app}
- **Access:** {how users get there}

### Layout
- **Primary view:** {list/grid/form/etc}
- **Key components:** {table, form, cards, etc}

### States
| State | Display | User Action |
|-------|---------|-------------|
| Loading | {what shows} | {wait/cancel} |
| Empty | {message + CTA} | {create first} |
| Error | {how shown} | {retry/contact} |
| Success | {confirmation} | {continue} |
| Locked | {indicator} | {wait/notify} |

### Responsive
- **Mobile:** {Yes/No} - {layout changes}
- **Tablet:** {Yes/No} - {layout changes}

### Special Interactions
- {interaction type}: {description}
```

Update frontmatter: `current_phase: 5`

---

## Update TodoWrite

Mark Phase 4 complete, Phase 5 in_progress.

---

## NEXT STEP

**IMMEDIATELY read:** `${CLAUDE_PLUGIN_ROOT}/skills/spec-interview/phases/phase-5-edge-cases.md`

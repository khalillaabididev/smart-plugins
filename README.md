# PR Patrol

A Claude Code plugin for handling PR bot comments (CodeRabbit, Greptile, Copilot, Codex, Sentry) with batch validation and a structured 7-gate workflow.

## Features

- **Batch Validation** — Validate multiple bot comments in parallel using specialized agents
- **7-Gate Workflow** — Structured process with user approval at each step
- **State Persistence** — Track progress across multiple review cycles
- **Bot-Specific Protocols** — Correct reply format and reaction handling per bot
- **False Positive Detection** — Identify and dismiss incorrect suggestions

## Supported Bots

| Bot | Reply | Reaction | Notes |
|-----|-------|----------|-------|
| CodeRabbit | ✅ | ❌ | Reply only |
| Greptile | ✅ | ✅ | Reaction first, then reply |
| Copilot | ❌ | ❌ | Silent fix only |
| Codex | ✅ | ✅ | Reaction first, then reply |
| Sentry | ✅ | ✅ | Reaction first, then reply |

**Ignored:** `vercel[bot]`, `dependabot[bot]`, `renovate[bot]`, `github-actions[bot]`

## Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) — authenticated
- [jq](https://jqlang.github.io/jq/) — version 1.6+
- bash 4.0+

## Installation

```bash
claude plugin marketplace add SmartOzzehir/pr-patrol
claude plugin install pr-patrol@SmartOzzehir
```

## Usage

```bash
/pr-patrol [PR-number]
```

If no PR number is provided, auto-detects from current branch.

### Workflow

```
Gate 0: Init      → Detect PR, create/load state file
Gate 1: Collect   → Fetch all bot comments
Gate 2: Validate  → Run validation agents in parallel
Gate 3: Fix       → Design and apply fixes
Gate 4: Commit    → Review changes, create commit
Gate 5: Reply     → Post replies to bots
Gate 6: Push      → Push to remote, check for new comments
```

### State Tracking

Progress is tracked in `.claude/bot-reviews/PR-{number}.md`:

```
initialized → collected → validated → fixes_planned
→ fixes_applied → checks_passed → committed → replies_sent → pushed
```

## License

MIT

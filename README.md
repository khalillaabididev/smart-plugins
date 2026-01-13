# PR Patrol

Handle PR bot comments (CodeRabbit, Greptile, Copilot, Codex, Sentry) with batch validation and a 7-gate workflow.

## Features

- **Batch Processing**: Validate multiple bot comments in parallel
- **7-Gate Workflow**: Structured process with user approval at each step
- **State Persistence**: Track progress across multiple review cycles
- **Bot-Specific Protocols**: Correct reply format for each bot type
- **False Positive Detection**: Identify and dismiss incorrect bot suggestions

## Supported Bots

| Bot | Reply | Reaction | Notes |
|-----|-------|----------|-------|
| CodeRabbit | ✅ | ❌ | Reply only, no reactions |
| Greptile | ✅ | ✅ | 👍/👎 reaction FIRST, then reply |
| Copilot | ❌ | ❌ | **Silent fix only** - never reply |
| Codex | ✅ | ✅ | 👍/👎 reaction FIRST, then reply |
| Sentry | ✅ | ✅ | 👍/👎 reaction FIRST, then reply |

**Auto-filtered (ignored):** vercel[bot], dependabot[bot], renovate[bot], github-actions[bot]

## Prerequisites

- **GitHub CLI** (`gh`) - authenticated with repo access
- **jq** - JSON processor (version 1.6+)
- **bash** - Version 4.0+
- **GNU date** - For timestamp normalization

```bash
# Verify prerequisites
gh auth status
jq --version
bash --version
```

## Installation

### From GitHub (Recommended)

```bash
claude plugins install SmartOzzehir/pr-patrol-plugin
```

### Manual Installation

Clone to your local plugins directory:

```bash
git clone https://github.com/SmartOzzehir/pr-patrol-plugin ~/.claude/plugins/local/pr-patrol
```

## Usage

### Basic Command

```bash
/pr-patrol [PR-number]
```

If no PR number provided, auto-detects from current branch.

### Workflow Overview

The plugin processes bot comments through 7 gates:

```
Gate 0: Init       → Detect PR, create/load state file
Gate 1: Collect    → Fetch all bot comments, categorize
Gate 2: Validate   → Run bot-comment-validator agents (parallel)
Gate 3: Fix        → Design and apply fixes
Gate 4: Commit     → Review changes, create commit
Gate 5: Reply      → Post replies to bots (per-bot protocol)
Gate 6: Push       → Push to remote, check for new comments
```

### State Tracking

Progress is tracked in `.claude/bot-reviews/PR-{number}.md` within your project directory.

State transitions:
```
initialized → collected → validated → fixes_planned
→ fixes_applied → checks_passed → committed → replies_sent → pushed
```

## Components

### Command: `/pr-patrol`

User-facing command that initiates the workflow.

### Skill: `pr-patrol`

Core workflow logic with 7 phase files for progressive disclosure:
- `SKILL.md` - Router and critical reminders
- `phases/gate-0-init.md` through `gate-6-push.md` - Detailed instructions per phase
- `bot-formats.md` - Bot-specific API protocols
- `templates.md` - Reply message templates

### Agent: `bot-comment-validator`

Validates individual bot comments against actual code context. Returns structured verdicts (VALID, FALSE_POSITIVE, NEEDS_CLARIFICATION).

### Scripts

| Script | Purpose |
|--------|---------|
| `fetch_pr_comments.sh` | Parallel fetch from PR and issue comment endpoints |
| `detect_thread_states.sh` | Detect NEW/PENDING/RESOLVED/REJECTED states |
| `check_new_comments.sh` | Find new comments since last push |
| `check_reply_status.sh` | Track reply status per comment |
| `update_state.sh` | Update YAML frontmatter in state file |

## Configuration

No configuration required. The plugin uses:
- `gh` CLI for GitHub API authentication
- Project's `AGENTS.md` and `CLAUDE.md` for convention detection

## External Dependencies

This plugin references general-purpose agents that should exist in your `~/.claude/agents/`:
- `pr-fix-architect` - Designs optimal fixes for validated issues
- `pr-implementer` - Applies approved fixes with precision

These agents are not bundled because they're useful beyond the pr-patrol context.

## License

MIT

## Author

Mart ([@SmartOzzehir](https://github.com/SmartOzzehir))

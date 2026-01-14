# Smart Plugins

A collection of production-ready Claude Code plugins for enhanced development workflows.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![pr-patrol](https://img.shields.io/badge/pr--patrol-v1.4.1-blue)](./pr-patrol)
[![spec-interview](https://img.shields.io/badge/spec--interview-v2.0.0-blue)](./spec-interview)

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [pr-patrol](./pr-patrol) | Process PR bot comments with batch validation and 7-gate workflow | v1.4.1 |
| [spec-interview](./spec-interview) | Comprehensive 8-stage requirements interview with adaptive technical depth | v2.0.0 |

---

## Installation

### Via Claude Code CLI

```bash
# Add the marketplace
/plugin marketplace add SmartOzzehir/smart-plugins

# Install a plugin
/plugin install pr-patrol
/plugin install spec-interview
```

### Manual Installation

```bash
# Clone the repo
git clone https://github.com/SmartOzzehir/smart-plugins.git

# Use with Claude Code
claude --plugin-dir ./smart-plugins/pr-patrol
claude --plugin-dir ./smart-plugins/spec-interview
```

---

## pr-patrol v1.4.1

**Process PR bot comments intelligently with a 7-gate workflow.**

Handles comments from: CodeRabbit, Greptile, GitHub Copilot, Codex, Sentry

### Usage

```bash
/pr-patrol           # Auto-detect PR from current branch
/pr-patrol 123       # Specific PR number
/pr-patrol owner/repo#123  # Full PR reference
```

### Features

- **7-Gate Workflow**: Systematic processing from collection to completion
- **Batch Validation**: Parallel validation of multiple comments
- **State Tracking**: Persistent state across sessions
- **Smart Filtering**: Separates actionable issues from noise
- **Billboard UI**: Visual progress tracking

### Gates

1. **Collect** - Gather all bot comments from PR
2. **Analyze** - Categorize and prioritize comments
3. **Validate** - Verify which comments identify real issues
4. **Plan** - Design fixes for validated issues
5. **Implement** - Apply approved fixes
6. **Verify** - Confirm fixes resolve issues
7. **Complete** - Mark comments as resolved

---

## spec-interview v2.0.0

**Comprehensive requirements gathering with adaptive technical depth.**

Captures 37% more requirements than traditional methods through intelligent AI interviewing.

### Usage

```bash
# From an idea
/spec-interview "Add dark mode to the app"

# From existing spec file
/spec-interview docs/phases/phase-10.md

# With language preference (12 languages supported)
/spec-interview "Add export feature" deutsch
/spec-interview "Kullanıcı yönetimi ekle" türkçe
```

### Features

- **8-Stage Interview Methodology**:
  1. Problem & Vision (Why?)
  2. Stakeholders & Users (Who?)
  3. Functional Requirements (What?)
  4. UI/UX Design (How it looks?)
  5. Edge Cases & Error Handling (What could go wrong?)
  6. Non-Functional Requirements (Quality attributes)
  7. Technical Architecture (For technical users)
  8. Prioritization & Phasing (What first?)

- **Adaptive Technical Depth**:
  - **Non-technical**: ELI5 explanations, business-focused
  - **Somewhat technical**: Balanced approach
  - **Very technical**: Direct implementation discussions

- **Multi-Language Support** (12 languages):
  Turkish, German, Spanish, French, Italian, Portuguese, Dutch, Russian, Japanese, Chinese, Korean, Arabic

- **Comprehensive PRD Output**:
  - Executive Summary & Success Metrics
  - Problem Statement & User Personas
  - User Stories with MoSCoW prioritization
  - Functional & Non-Functional Requirements
  - UI/UX Specifications with state design
  - Edge Cases & Error Handling
  - Technical Notes & Dependencies
  - Phasing & Open Questions

### Methodology

Based on industry best practices:
- 60 Requirements Gathering Interview Questions
- PRD Templates (Product School, Aha!, Atlassian)
- UX Requirements Gathering (UXPin, Koru UX)
- AI Requirements Gathering 2025 research

Key statistic: **47% of project failures are due to poor requirements** (Standish Group CHAOS Report)

---

## Author

**SmartOzzehir** - [GitHub](https://github.com/SmartOzzehir)

## License

MIT License - see [LICENSE](./LICENSE) for details.

## Contributing

Contributions welcome! Please open an issue or PR.

---

*Built with ❤️ for the Claude Code community*

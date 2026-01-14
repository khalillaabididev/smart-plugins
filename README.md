# Smart Plugins

A collection of Claude Code plugins for enhanced development workflows.

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [pr-patrol](./pr-patrol) | Handle PR bot comments with batch validation and 7-gate workflow | 1.4.1 |
| [spec-interview](./spec-interview) | Interview users to gather detailed requirements for spec documents | 1.0.0 |

## Installation

1. Open Claude Code
2. Run `/plugin` → **Discover** → **Add**
3. Enter: `github:SmartOzzehir/smart-plugins`
4. Select plugins to install

## Usage

### pr-patrol
```
/pr-patrol
```
Processes PR bot comments (CodeRabbit, Greptile, Copilot, etc.) through a 7-gate workflow.

### spec-interview
```
/spec-interview docs/phases/phase-10.md
/spec-interview "Add export feature to dashboard"
/spec-interview docs/spec.md TUR  # Turkish
```
Conducts structured requirements interviews using a 5-stage methodology.

## License

MIT

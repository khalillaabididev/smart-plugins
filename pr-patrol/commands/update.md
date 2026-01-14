---
description: Update pr-patrol plugin to latest version from GitHub
allowed-tools: Bash
---

# Update PR Patrol

Pull latest from GitHub and reinstall:

```bash
git -C ~/.claude/plugins/marketplaces/SmartOzzehir pull origin main && claude plugin install pr-patrol@SmartOzzehir
```

After success, tell the user:

```
✅ Plugin updated! Restart your Claude Code session to load the new version.
```

If git pull fails (marketplace not found), fall back to full refresh:

```bash
claude plugin marketplace remove SmartOzzehir 2>/dev/null
claude plugin marketplace add SmartOzzehir/pr-patrol
claude plugin install pr-patrol@SmartOzzehir
```

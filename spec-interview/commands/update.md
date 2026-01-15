---
description: Update spec-interview plugin to latest version from GitHub
allowed-tools: Bash
---

# Update Spec Interview

Pull latest from GitHub and reinstall:

```bash
git -C ~/.claude/plugins/marketplaces/SmartOzzehir pull origin main && claude plugin install spec-interview@SmartOzzehir
```

After success, tell the user:

```
✅ Plugin updated! Restart your Claude Code session to load the new version.
```

If git pull fails (marketplace not found), fall back to full refresh:

```bash
claude plugin marketplace remove SmartOzzehir 2>/dev/null
claude plugin marketplace add SmartOzzehir/smart-plugins
claude plugin install spec-interview@SmartOzzehir
```

# bot-detection.jq - Shared bot detection functions for pr-patrol
# Usage: include "bot-detection"; (requires jq -L $SCRIPT_DIR)

# Bots to IGNORE (deployment/CI bots, not code reviewers)
def is_ignored_bot:
  . as $login |
  ["vercel[bot]", "dependabot[bot]", "renovate[bot]", "github-actions[bot]"] |
  any(. == $login);

# Review bot detection (bots that provide code review feedback)
def is_review_bot:
  . as $login |
  ($login | test("coderabbit|greptile|codex|sentry"; "i")) or
  ($login == "Copilot") or
  ($login == "chatgpt-codex-connector[bot]");

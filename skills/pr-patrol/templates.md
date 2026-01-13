# Reply Templates

Standard templates for responding to PR bot comments.

---

## After Commit (Preferred)

Use these when changes have been committed:

### Fixed Issue

```
Fixed in commit {sha}: {description}
```

**Examples:**
```
Fixed in commit a1b2c3d: Added null check before accessing user.id
Fixed in commit a1b2c3d: Wrapped async operation in try-catch
Fixed in commit a1b2c3d: Resolved race condition with mutex
```

### False Positive

```
False positive: {explanation}. This is intentional per project conventions.
```

**Examples:**
```
False positive: This pattern follows our established codebase conventions. See AGENTS.md for details.

False positive: The suggested change would break existing functionality. Current implementation is intentional.
```

### Acknowledged but Different Approach

```
Acknowledged. Addressed differently in commit {sha}: {explanation}
```

**Example:**
```
Acknowledged. Addressed differently in commit a1b2c3d: Instead of extracting a helper, consolidated the logic into the existing utility function.
```

---

## Before Commit

Use these when changes are staged but not yet committed:

### Will Fix

```
Will be addressed in upcoming commit: {description}
```

### Acknowledged

```
Acknowledged. Will address in this PR.
```

---

## REJECTED Re-fix

When bot disagreed with our previous fix:

### Proper Fix

```
Fixed properly in commit {sha}: {detailed explanation}

Previous fix was incomplete because {reason}. This commit:
- {change 1}
- {change 2}
```

**Example:**
```
Fixed properly in commit b2c3d4e: Moved mutex acquisition before the validation check.

Previous fix was incomplete because the mutex was acquired AFTER the isValid() check, allowing race conditions. This commit:
- Moved mutex.acquire() to line 42 (before validation)
- Added explicit lock release in finally block
```

---

## Common Patterns

### Error Handling Added

```
Fixed in commit {sha}: Added proper error handling.
- Added try-catch block
- Errors are now logged/reported appropriately
```

### Type Safety Improved

```
Fixed in commit {sha}: Improved type safety.
- Added explicit type annotations
- Removed unsafe type assertions
```

### Performance Addressed

```
Fixed in commit {sha}: Addressed performance concern.
- {specific optimization made}
```

---

## Multi-Issue Response

When bot reported multiple issues in one comment:

```
Addressed in commit {sha}:

1. ✅ {issue 1}: {action taken}
2. ✅ {issue 2}: {action taken}
3. ❌ {issue 3}: False positive - {explanation}
```

**Example:**
```
Addressed in commit a1b2c3d:

1. ✅ Missing null check: Added validation at line 45
2. ✅ Unused import: Removed the import
3. ❌ Naming suggestion: False positive - follows project conventions
```

---

## Commit Message Format

When committing bot review fixes:

```
fix: address PR bot review feedback

Fixes:
- {description 1}
- {description 2}

False positives explained:
- {explanation 1}

Reviewed by: {bot names}

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Example:**
```
fix: address PR bot review feedback

Fixes:
- Add error boundary in api.ts (CodeRabbit #123)
- Fix race condition in auth.ts (Copilot #456)
- Remove unused imports (Greptile #789)

False positives explained:
- Custom hook naming follows project pattern (CodeRabbit #124)

Reviewed by: CodeRabbit, Greptile, Copilot

Co-Authored-By: Claude <noreply@anthropic.com>
```

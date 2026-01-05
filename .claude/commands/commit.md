---
description: Stage, commit with a good message, and push to remote
---

# Commit Workflow

1. Check current git status: `git status`
2. Review the changes: `git diff --staged` (if already staged) or `git diff` (if not)
3. Stage all changes: `git add -A`
4. Generate a commit message following these rules:
   - First line: imperative mood, under 50 chars (e.g., "Add voice input view")
   - Blank line
   - Optional body explaining what and why (not how)
5. Commit: `git commit -m "message"`
6. Push: `git push origin main` (or current branch)

If there are no changes, say so and stop.

$ARGUMENTS can override the commit message. If provided, use it instead of generating one.

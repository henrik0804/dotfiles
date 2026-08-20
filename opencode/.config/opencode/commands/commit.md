---
description: Create atomic conventional commits for staged changes
agent: build
model: opencode/minimax-m2.7
---

Analyze staged changes via `git diff --cached`. 
Identify independent logical groups (features, fixes, refactors).

For each group, create a conventional commit: `<type>(<scope>): <description>`.
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.
- Description: Concise, imperative, max 50 chars.

Commit changes atomically. If unrelated changes exist, stage and commit them separately. 
Verify status after each commit.

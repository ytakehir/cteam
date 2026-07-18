---
name: pre-pr
description: Use before creating a pull request; checklist to verify code quality, scope, and correctness
---

# Pre-PR Checklist

The slot's own self-review before handing the PR to PM. Add these as items on your per-issue TODO so none is skipped. Run ALL checks before `gh pr create`.

- [ ] All tests pass locally
- [ ] Build clean (no errors)
- [ ] No type errors / no lint errors
- [ ] All changed files identified; no unintended side effects
- [ ] Changes within Issue scope only
- [ ] Correct worktree + branch (`issue-{n}-{title-kebab-case}`)
- [ ] `.cteam/status.toml` NOT in staged changes
- [ ] PR target = `develop` (never `preview` / `main`)
- [ ] **Rebased onto current `develop`**: run `cteam-rebase`; `REBASE_OK`, not a stale base (no merge commits). `REBASE_CONFLICT` → resolve or BLOCKED.
- [ ] If `.ts`/`.tsx` changed → invoke `typescript-safety` skill
- [ ] **`domain:ui` only; screenshot pair in the PR body**: the Figma node screenshot AND a screenshot of the rendered implementation (ui-implement Phase 3). Missing pair = auto-reject.
- [ ] **`domain:ui` only; Figma node-id deep-link in the PR body** (`…?node-id=A-B`), so the PR is a self-contained review surface. Missing = auto-reject.

## Rules
- **Rigid**: every item must pass before PR creation
- This is the slot's self-check; the authoritative review is a PM-spawned subagent. Self-passing here is not approval.

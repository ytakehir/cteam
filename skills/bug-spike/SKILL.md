---
name: bug-spike
description: Use when working on type:bug Issues; enforces multi-hypothesis spike with real-hardware verification before any fix PR
---

# Bug / Hotfix Spike Flow

MUST run before any fix PR on type:bug Issues. Skipping risks "blind fix" passing tests but failing on real hardware.

## Procedure

1. cd to worktree, read Issue
2. Reproduce locally (build+install / `npm run dev`; confirm bug visible on real HW)
3. List 2+ candidate root-cause hypotheses as Issue comment
4. For each hypothesis:
   a. Make minimal local change
   b. Build + run locally
   c. **Mandatory real-HW verify**: drive the actual app end-to-end with the available automation tooling (Playwright MCP for web, claude-in-chrome for browser flows, device/simulator for native). Gestures, drags, animations, state machines, navigation; all exercised. Screenshots alone NOT sufficient.
   d. Record outcome in Issue comment (works / partial / no change)
   e. Discard prototype (no commit, no push)
5. Pick hypothesis that fixed it on real HW
6. Implement fix on assigned branch
7. Continue Slot Flow (`cteam-rebase`, `pre-pr` skill, PR creation)

## If No Hypothesis Works
- Comment Issue with each hypothesis + outcome
- File secondary spike Issue (`create-issue` skill)
- Do NOT open "best guess" PR

## Reviewer Requirements (type:bug PRs)
- PR body cites spike thread showing validated hypothesis
- Real-HW evidence (automation transcript or video), NOT just unit-tests or screenshot
- Missing → **REVIEW_BLOCKED**: `MUST: spike + real-HW automation evidence required`

## Rules
- **Rigid**: follow exactly, no shortcuts
- Never skip reproduction; never skip the real-HW verify
- Never PR without spike record + real-HW evidence

---
name: andon
description: Use when a critical issue affects the entire team and all work must stop immediately — broadcasts stop command to all panes and escalates to PM for human decision
---

# Andon Code

MUST use when a critical issue affects everyone, not just yourself. Named after Toyota's andon cord.

## BLOCKED vs Andon

| Situation | Action |
|-----------|--------|
| Only you are stuck | `BLOCKED` to PM |
| Affects entire team or workflow | `cteam-andon` |

## Triggers — raise andon when you discover:
- Critical bug (data corruption, security vulnerability)
- CI/tests broken in a way that blocks all merges
- Architecture conflict that affects both slots
- Required MCP or tool inaccessible (Figma, Linear, etc.)
- Workflow violation detected (wrong branch target, broken develop, etc.)
- Figma and implementation fundamentally misaligned

## Procedure

1. Stop current work immediately
2. Run:
```bash
cteam-andon --reason "brief description" --by $CTEAM_ROLE
```
3. Wait — do NOT resume until PM relays human decision

## Examples
```bash
cteam-andon --reason "develop branch broken, all PRs blocked" --by slot1
cteam-andon --reason "Figma MCP unreachable, cannot proceed with UI work" --by slot2
```

## What happens after
- Both slots receive stop command immediately
- PM receives human-decision prompt
- All agents wait for PM to relay clear

## Rules
- **Rigid** — never skip, never self-resolve
- Do not resume work without PM confirmation
- Do not raise andon for issues that only affect you

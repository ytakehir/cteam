---
name: cteam-code-review
description: Use when reviewing a pull request; systematic checklist for scope, correctness, and quality verification
---

# Code Review

Run as a PM-spawned subagent in fresh context: you see the diff + the Issue + these criteria, not the implementer's reasoning. Flag only gaps affecting correctness or stated requirements; don't chase speculative gaps (over-engineering). Return your verdict (PR comment labels) to PM; do not message panes.

## Step 1: Read the Issue
`gh issue view {n} --json title,body`; understand ALL requirements and do/don't sections before reading any code.

## Step 2: Scope
- **Every Issue requirement implemented**: missing → `MUST: {requirement} not implemented`
- **Nothing outside scope**: extra → `MUST: Remove out-of-scope: {details}`

## Step 3: Quality
- All CI passes; no merge conflicts; no regressions
- No breaking changes; no security issues; no perf degradation
- PR target = `develop`; branch from `develop`
- No merge commits from `preview` / `main`
- `.cteam/status.toml` NOT in diff → present: `MUST: Remove`

## Step 4: Code
- If `.ts`/`.tsx` changed → invoke `typescript-safety` skill
- Library usage uncertain → check via Context7 MCP tools (`resolve-library-id` → `query-docs`)
- No deprecated APIs

## Step 5: type:bug PRs
- Invoke `bug-spike` skill to verify spike record + real-HW evidence

## Rules
- **Rigid**: every step must be completed

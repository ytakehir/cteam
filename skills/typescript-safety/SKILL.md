---
name: typescript-safety
description: Use when writing or reviewing TypeScript/TSX code; type safety rules and banned patterns
---

# TypeScript Safety

## Banned Patterns
- No `as` type assertions
- No `any`
- No `unknown` without proper type narrowing
- No inappropriate `never`
- No type casting
- No null assertions (`!`)
- No type suppression in error handling
- No `biome-ignore` unless: clear justification + absolutely necessary + reviewer-approved

## Rules
- **Rigid**: no exceptions without explicit reviewer approval

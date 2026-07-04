---
name: figma-preflight
description: Run before touching the Figma canvas for any task — creation, modification, or review. Searches existing components, tokens, and library. No node gets created until this passes.
---

# Figma Preflight

MUST run before any canvas interaction. No node gets created until all steps pass.

## Step 1 — Search existing components

- List all components currently in the file
- Search the daisyUI Figma plugin library for matching components
- If a match exists: use the existing instance — do NOT recreate
- If no match exists: note it; you will create from scratch in `/figma-create`

## Step 2 — Search existing tokens & variables

List all variables and styles in the file and record the exact names you will use:

- Color variables (primitive + semantic)
- Spacing variables
- Typography styles
- Border-radius, elevation, effect styles

For every value you intend to apply, confirm the exact variable name now.
NEVER hardcode a value if a variable exists for it.

## Step 3 — Search daisyUI library

Before building any custom token or component:

- Check daisyUI Figma plugin library for an equivalent
- If daisyUI provides it: use as-is
- If daisyUI provides a partial match: extend using daisyUI tokens only
- If daisyUI has nothing: build custom using daisyUI primitive tokens

## Step 4 — Verify page & section scope

- Confirm the correct target page (00 Cover / 01 Foundations / 02 Components / 03+ Mockups)
- Check whether a relevant section already exists on that page
- Check for duplicate section names on the target page
- Confirm placement will not create node name duplicates within the section

## Step 5 — Define design direction

Before proceeding to `/figma-create`, define and confirm:

- What is being built (component / screen / section)
- Which existing components will be used (list by name)
- Which tokens will be applied (list variable names)
- Auto Layout strategy: direction, wrap, spacing mode, alignment
- Variants needed: states, sizes, themes

**Preflight passes only when Steps 1–5 are complete.**

## Rules

- Never skip preflight for "small" changes — all canvas work requires it
- If a required variable or component does not exist: create it first, then proceed
- If daisyUI has an equivalent: use it, no exceptions

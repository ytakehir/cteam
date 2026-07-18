---
name: figma-create
description: Use after /figma-preflight passes. Covers actual canvas creation and immediate post-creation checks. Always follow with /figma-review.
---

# Figma Create

Run only after `/figma-preflight` passes. Follow with `/figma-review` when done.

## Phase 1: Create

### Naming (before placing anything)

- Components: slash notation; `Button/Primary`, `Card/Default`, `Input/Text`
- Sections: unique names per page; check for duplicates first
- Nodes: no duplicate names within a section

### Token usage (mandatory for every property)

| Property | Must use |
|----------|----------|
| Color fills & strokes | Color variable (never raw hex) |
| Padding, gap, margin | Spacing variable |
| Typography | Text style |
| Border-radius | Radius variable |
| Shadows, blur | Effect style |

If a variable does not exist for a value: create the variable first, then apply it.

### Component usage (mandatory)

- Use daisyUI library instances wherever possible
- Use existing file components for all repeated UI
- Never duplicate a component by hand; always use an instance
- Never use a raw frame where a component instance should be

### Auto Layout (mandatory on every parent frame)

- Every frame containing children must have Auto Layout set
- Set direction, spacing, padding, alignment explicitly; no manual positioning
- Nested frames must also have Auto Layout

### Variants

Cover all required variants while creating:

- States: default, hover, active, disabled, focus
- Sizes: sm, md, lg (if applicable)
- Themes: light, dark (if applicable)

Use Figma component properties (variant, boolean, text, instance swap) for control.

---

## Phase 2: Post-Creation Check

Run immediately after creating or modifying. Fix before continuing.

### Variable binding check

For every node created, verify:

- Color fill → bound to color variable (not raw hex)
- Spacing → bound to spacing variable (not hardcoded px)
- Typography → bound to text style (not manual font settings)
- Radius → bound to radius variable (not hardcoded px)

Flag and fix any unbound values.

### Spacing check

- Padding (top, right, bottom, left); matches intent and uses variable
- Gap between children; uses spacing variable
- No orphaned spacing values

### Node integrity check

For every section touched:

- No duplicate node names within the section
- No orphaned nodes outside a section frame
- All nodes have explicit size and position
- Node order is logical (top → bottom, simple → complex)

### Section integrity check

For the page being edited:

- No duplicate section names
- Sections ordered left-to-right, top-to-bottom
- Each section has a visible title label
- No content outside section frames

## Rules

- Never place a node before `/figma-preflight` passes
- Never hardcode any value; create the variable first if missing
- Never recreate existing components; always use instances
- Post-creation check must pass before calling `/figma-review`

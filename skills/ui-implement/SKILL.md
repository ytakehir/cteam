---
name: ui-implement
description: Use when implementing domain:ui Issues from Figma specs. Covers Figma context fetching, implementation, and screenshot validation. Always run before creating any UI code from a Figma design.
---

# UI Implementation from Figma

MUST follow all phases in order. Never implement from memory or assumption; always fetch from Figma first.

## Phase 0: Read the project design-system rules (every time)

```
Read: $CTEAM_VAULT/architecture/design-system-rules.md
```

This is the committed rules file: theme/token source of truth, token→code map, the component↔Figma-node inventory, the canonical screen (mockups) page, and the hard rules (copy verbatim, icons-from-exports, BLOCKED-on-undefined). It links to the general methodology `[[figma-to-code-faithful-implementation]]`. If the file does not exist yet, BLOCK and ask PM to create it; do not implement without it (this is what prevents inventing copy/icons). Add "read design-system rules" as the first item on your per-issue TODO.

---

## Phase 1: Fetch Design Context

Run for every node you intend to implement. Never implement without completing this phase.

### Step 1-1. Identify the target node

- Get the Figma URL for the exact frame or component to implement
- If implementing a variant: get the node ID of the specific variant, not the base component
- Start with the smallest meaningful unit (one section or one component); do NOT fetch an entire screen at once

### Step 1-2. Fetch structured context + variables

Run both tools on the same node:

```
get_design_context(node_url)
get_variable_defs(node_url)
```

`get_design_context` returns layout and component structure.
`get_variable_defs` returns the exact token bindings (color, spacing, typography). Always run both; `get_design_context` alone does not reliably return token values.

### Step 1-3. Handle truncated responses

If the response is too large or truncated:

```
1. get_metadata(node_url)          → get high-level node map
2. Identify only the required child nodes
3. get_design_context(child_node)  → re-fetch at finer granularity
4. get_variable_defs(child_node)
```

Repeat until the response is complete and readable.

### Step 1-4. Fetch screenshot

```
get_screenshot(node_url)
```

Keep this open as the visual reference throughout implementation.

---

## Phase 2: Implement

### Rules

- Read the design system rules file before writing any code
- **Consult latest docs (Context7) for every library/API you touch** (`resolve-library-id` → `query-docs`); don't code from stale memory; APIs change
- Treat `get_design_context` output as a structural reference, not final code; translate into the project's framework and conventions
- Use `get_variable_defs` output for all token values; never use the raw values from `get_design_context` (they may be arbitrary or incorrect)
- Reuse existing codebase components instead of creating new ones
- Map Figma tokens to codebase tokens via the rules file; never hardcode values
- If a Figma element has no corresponding codebase token or component: do NOT self-implement → report `BLOCKED` to PM with the missing element name

### Order of implementation

1. Structure and layout (Auto Layout → flexbox/grid)
2. Typography (text styles → typography tokens)
3. Color (color variables → CSS variables/Tailwind tokens)
4. Spacing (spacing variables → spacing tokens)
5. Components (Figma component instances → codebase components)
6. States and variants (interactive states, sizes, themes)

---

## Phase 3: Screenshot Validation

After implementing each section or component:

1. Take a screenshot of the rendered implementation
2. Place it alongside the Figma screenshot from Phase 1
3. Compare visually:
  - Spacing and padding match
  - Typography size, weight, line-height match
  - Colors match (check against token values, not just visual)
  - Component structure matches Figma layer hierarchy
  - All states and variants are present
4. If discrepancies exist: fix and re-screenshot until 1:1
5. Do not proceed to the next section until the current one passes

---

## Rules

- Never skip `get_variable_defs`; `get_design_context` alone is unreliable for token values
- Never fetch an entire screen at once; always start with the smallest meaningful unit
- Never hardcode a value when a token exists
- Never self-implement an undefined Figma element; BLOCKED
- Screenshot validation is mandatory; visual assumption is not acceptable

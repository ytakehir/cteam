# cteam — Figma Design Rules (`domain:ui`)

Rules for Figma files and `domain:ui` implementation. Read by: UI slots (via `ui-implement`) and the design-review subagent PM spawns (via `figma-review`). Figma *creation* (components/tokens/mockups) is rare and only happens on explicit request via `figma-preflight → figma-create → figma-review`.

> **Survey ALL relevant Figma pages/files — do not assume one page is the source of truth.** A screen's truth is often spread across mockups, components, and foundations; the Issue's node-id is a starting point, not the whole story. Cross-check the node against its source components and siblings, and read the repo files too. Copy text verbatim; icons from Figma exports only. See `[[figma-to-code-faithful-implementation]]` and the project's `architecture/design-system-rules.md`.

## Design Review Rules (used by the design-review subagent)
- **MUST** Token defined in Figma but hardcoded in code.
- **MUST** daisyUI library component not used when available.
- **MUST** Component structure / copy / icon / row-count mismatches the referenced design.
- **MUST** Asset not from Figma export (ad-hoc SVG, self-made icon, data-URI placeholder).
- **MUST** Motion differs from Figma spec (when defined).
- **NIT** Minor spacing/padding discrepancy (1–2px).
- **BLOCKED** Element implemented without Figma definition.

## Page Structure

All pages use numeric prefixes for ordering. Three pages are **mandatory** in every file:

```
00 Cover           # Project name, version, last updated date, links
01 Foundations     # Tokens, color palettes, typography scales, spacing, elevation
02 Components      # All reusable components built from foundations
03 Mockups         # Screen-level compositions built from components
```

Beyond these, add project-specific pages to cover every feature and screen area. Examples:

```
# LP project
04 Mockups - Hero
05 Mockups - Features
06 Mockups - Pricing
07 Mockups - Footer

# Dashboard project
04 Mockups - Dashboard Overview
05 Mockups - Analytics
06 Mockups - Settings
07 Mockups - User Management

# Mobile app project
04 Mockups - Onboarding
05 Mockups - Home
06 Mockups - Profile
07 Mockups - Notifications
```

Page granularity = one page per feature or flow. Do NOT cram multiple unrelated flows into a single Mockups page.

## Foundations (01)

- Define all design tokens as Figma variables: color, spacing, typography, border-radius, elevation
- **daisyUI Figma plugin library is mandatory** — use its token definitions as the single source of truth
- Do NOT create custom tokens when a daisyUI token exists
- Organize tokens into sections: Colors, Spacing, Typography, Effects
- Each section must have a clear frame with a label

## Components (02)

### Creation Rules

- **daisyUI Figma plugin library is mandatory** — use daisyUI components as the base
- Components that exist in daisyUI: use the library component directly, do NOT recreate
- Components that do NOT exist in daisyUI: build as custom components using daisyUI tokens (color, spacing, typography, radius)
- Every component must be a proper Figma component (not a loose group or frame)
- Name with slash notation: `Button/Primary`, `Card/Default`, `Input/Text`

### Auto Layout

- Every frame containing children MUST have Auto Layout set
- Set direction, spacing, padding, and alignment explicitly — no manual positioning as sole layout method
- Nested frames must also have Auto Layout
- All spacing values must reference spacing variables — never hardcode px values in Auto Layout fields

### Variants

- Create all meaningful variants: state (default, hover, active, disabled, focus), size (sm, md, lg), theme (light, dark)
- Cover all patterns developers will encounter — no variant should require a developer to guess
- Use Figma component properties (boolean, instance swap, text, variant) for variant control

### Organization

- Group related components in sections with labeled frames
- Order within sections: simple → complex
- Every component must have a description noting its usage context

### Node & Section Integrity

- No duplicate node names within a section; no duplicate section names within a page
- All frames and components must have explicit, clean size and position — no floating or unresolved auto-sized elements
- Create each element on the correct page; verify placement scope before adding

### Change Propagation

- Before modifying any component, audit all instances across the file
- All fixes and updates must be applied at the parent component level, or propagated to every instance — partial fixes are not acceptable
- When a token or style changes, verify impact on all dependent components and mockups before finalizing

## Assets

- All icons, illustrations, and imagery managed as Figma components
- Export settings defined per asset (SVG for icons, PNG @1x @2x for images)
- **daisyUI Figma plugin library icons preferred** when available
- Custom assets must follow the same token system (colors from foundations, consistent sizing)
- No loose assets — everything must be a component or inside a component

## Mockups (03+)

### Creation Rules

- Build mockups exclusively from components on the 02 page — no one-off elements
- If a mockup needs something not in 02, create the component first, then use it
- Organize by feature or flow, one section per user journey
- Label every section clearly

### Coverage

- All interactive states: empty, loading, populated, error, edge cases
- All variants of dynamic content (short text, long text, missing data)
- Responsive: if the project requires responsive design, create breakpoint frames (mobile 375px, tablet 768px, desktop 1440px)

### Prototype & Motion

- Link screens with Figma prototype connections
- Define transitions: type (dissolve, smart animate, slide), duration, easing
- Annotate motion specs next to relevant frames when complex
- Interactive components: define hover, press, and toggle interactions within component variants

## Section Organization

Within every page:

- Use large frames as sections with prominent title labels
- Consistent left-to-right, top-to-bottom reading order
- Related items grouped tightly; unrelated items separated with clear spacing
- No orphaned elements outside sections

## Workflow

- **Implementing** (`domain:ui`, in a slot): `ui-implement` — read design-system rules → fetch the node (`get_design_context` + `get_variable_defs` + `get_screenshot`) → implement → screenshot-validate 1:1.
- **Reviewing a PR** (design-review subagent PM spawns): `figma-review` — diff rendered vs the design across all relevant pages (start at the linked node, don't stop there); Phases 1–4 + Phase 6 minimum. Verdict returns to PM.
- **Creating** Figma (rare, explicit only): `figma-preflight` → `figma-create` → `figma-review`.

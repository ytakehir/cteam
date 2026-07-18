---
name: figma-review
description: Use after /figma-create, or when reviewing an existing design for design system compliance. Covers self-review, consistency check, prototype, assets, and documentation.
---

# Figma Review

Run after `/figma-create`, or standalone when reviewing existing designs or PR implementations.

## Phase 0: PR design review (when reviewing a `domain:ui` PR)

Run as a PM-spawned subagent. Diff the **rendered implementation screenshot** against the Figma design.
- Start from the node the Issue links, but **do not assume a single page is the whole truth**; survey all relevant pages (mockups, components, foundations) and cross-check the node against its siblings/source components. Read the repo files too.
- Verify, against the design: every text string **verbatim**, every icon, card/row counts, layout, tokens (no hardcoded values), assets from Figma exports.
- **Post your visual evidence into the PR** (`gh pr comment`): the Figma-vs-rendered comparison and a `DESIGN:`-tagged note per discrepancy, so REVISIONS are concrete and the human can see exactly what differs. On a clean pass, leave a short `LGTM:` confirming the match.
- Return the verdict to PM; do not message panes. Then run the compliance phases below as applicable.

## Phase 1: Design System Compliance

- [ ] Every color references a daisyUI or file variable (zero raw hex values)
- [ ] Every spacing value references a variable (zero hardcoded px)
- [ ] Every typography references a text style
- [ ] Every component is a daisyUI instance or proper file component (zero raw frames)
- [ ] No element was recreated when an existing component was available

## Phase 2: Parent Component Integrity

- [ ] If a base component was modified: change was made at parent level, not on a specific instance
- [ ] All instances of the modified component reflect the change
- [ ] No partial fix; all instances are consistent across the file

## Phase 3: Consistency Check

- [ ] New design matches the visual language of existing screens
- [ ] Spacing rhythm is consistent with adjacent components
- [ ] Typography scale matches existing patterns
- [ ] Color usage matches semantic intent (primary, secondary, destructive, etc.)

## Phase 4: Structure Check

- [ ] All frames have Auto Layout (no manual-only frames with children)
- [ ] No duplicate node names in any touched section
- [ ] No duplicate section names on any touched page
- [ ] No orphaned nodes outside section frames

## Phase 5: Coverage Check

- [ ] All states designed: default, hover, active, disabled, focus
- [ ] All sizes designed: sm, md, lg (if applicable)
- [ ] All themes designed: light, dark (if applicable)
- [ ] Edge cases covered: empty state, loading, error, long text, missing data

## Phase 6: Visual Check

Take a screenshot of the completed work and review:

- [ ] Alignment is pixel-consistent across similar elements
- [ ] Visual weight matches surrounding components
- [ ] Nothing looks out of place compared to the rest of the file

## Phase 7: Prototype & Motion

- [ ] Screen-to-screen connections defined (if mockup)
- [ ] Transitions specified: type, duration, easing
- [ ] Component interactions defined: hover, press, toggle (within component variants)
- [ ] Motion annotations added next to complex transitions

## Phase 8: Assets

- [ ] All icons are daisyUI library icons or proper file components
- [ ] Export settings defined: SVG for icons, PNG @1x @2x for images
- [ ] No loose asset outside a component

## Phase 9: Documentation

- [ ] Every new component has a description explaining its usage context
- [ ] Design decisions recorded in vault `decisions/design-YYYY-MM-DD-[topic].md`

## Rules

- Any failing item must be fixed before marking work done
- Self-review failure = fix the issue, re-run the failing phase, not a patch
- Never skip Phase 1 (compliance) or Phase 2 (parent integrity); these are the most common failure points
- For PR design review: run Phases 1–4 at minimum; add Phase 6 (visual check)

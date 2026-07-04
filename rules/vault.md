# Knowledge Vault

**Location**: `~/vault/`

## Must Rules
- All vault writes in English — no exceptions
- First time in a project: `mkdir -p ~/vault/Work/{project}/{logs,decisions,architecture,notes,Raw}`

## Structure
- `Raw/` — Capture zone. Dump anything
- `Personal/` — Cross-project knowledge. Tag-based (`#music`, `#news`, `#idea`, etc.)
- `Work/{project}/` — Per-project:
  - `decisions/` — `YYYY-MM-DD-{topic}.md`
  - `architecture/` — System design
  - `notes/` — Reusable patterns
  - `logs/` — Session logs
  - `Raw/` — Project capture zone

## Session Start
1. Identify project from working directory or `$CTEAM_VAULT`
2. Read latest file in `~/vault/Work/{project}/logs/` to restore context
3. Resume from last session — no re-onboarding

## During Session
Record immediately:
- Technical decision → `decisions/YYYY-MM-DD-{topic}.md`
- Architecture change → `architecture/`
- Blocker resolved → append to relevant decision note
- New pattern → `notes/` or `~/vault/Personal/` if cross-project

## Session End
Write `~/vault/Work/{project}/logs/YYYY-MM-DD.md`:

    ## Done
    - ...

    ## Decided
    - ...

    ## Next
    - ...

    ## Open
    - ...

## Raw Processing (`/organize`)
When invoked: read `~/vault/CLAUDE.md`, process Raw/ items into appropriate destinations.

## Vault Search
Always search `~/vault/Work/{project}/` before:
- Reporting BLOCKED
- Making architectural decisions
- Choosing libraries or patterns

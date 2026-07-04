---
name: save
description: Save knowledge from the current conversation into the user's Obsidian vault at ~/vault/. Triggers on /save, "save this", "save to vault", "add to vault", "save to obsidian", "ボルトに保存", "vaultに保存". Detects project context (uses $CTEAM_VAULT if set, else pwd/git), classifies content, proposes filename + tags, writes English markdown with YAML frontmatter, confirms before writing.
---

# Save to Vault

Capture knowledge from the current conversation as a structured note in `~/vault/`.

## Vault Layout

```
~/vault/
├── Raw/                       # Unsorted capture
├── Personal/                  # Cross-project, tag-based
└── Work/{project}/
    ├── decisions/             # YYYY-MM-DD-<topic>.md
    ├── architecture/
    ├── notes/
    └── Raw/
```

## Procedure

### 1. Detect project
- If `$CTEAM_VAULT` is set → use it as the project vault directly
- Else: `PROJECT=$(basename "$(pwd)")`; project vault = `~/vault/Work/{PROJECT}/`
- Create missing subdirs: `mkdir -p ~/vault/Work/{PROJECT}/{decisions,architecture,notes,Raw,logs}`

### 2. Classify

| Content | Destination |
|---|---|
| Decision + reasoning ("chose X because Y") | `Work/{project}/decisions/YYYY-MM-DD-<topic>.md` |
| System design / structure | `Work/{project}/architecture/<topic>.md` |
| Reusable pattern (project) | `Work/{project}/notes/<topic>.md` |
| Cross-project lesson / productivity | `Personal/<topic>.md` |
| Quick capture / unsure | `Work/{project}/Raw/<date>-<topic>.md` or `Raw/<date>-<topic>.md` |

### 3. Filename
Kebab-case, ≤ 60 chars. Decisions prefix with `YYYY-MM-DD-`.

### 4. Frontmatter + body

```yaml
---
date: YYYY-MM-DD
project: {project, omit if Personal/}
tags: [tag1, tag2, tag3]
source: claude-code
---
```

Body sections (use what applies, omit empties):
`## Context` → `## Decision`/`## Pattern`/`## Finding` → `## Rationale` → `## Code` → `## References`

### 5. Confirm

```
Proposed save:
  Path:  ~/vault/Work/{project}/decisions/2026-05-15-<topic>.md
  Type:  decision
  Tags:  tag1, tag2, tag3

Proceed? [yes / adjust / cancel]
```

User: "yes/go/save" → write. "adjust" → modify, re-confirm. "cancel" → stop.

### 6. Report

```
✓ Saved: /Users/{user}/vault/Work/{project}/decisions/2026-05-15-<topic>.md
```

## Rules

- **English only** — translate if the conversation is in another language
- **Never overwrite silently** — if file exists, suffix `-2`, `-3`, or ask
- **2–4 tags** from: domain (`frontend`/`backend`/`ios`...), tool (`tmux`/`react`/`swift`...), category (`decision`/`pattern`/`gotcha`/`workflow`), project ref
- **Strip secrets** — no API keys, tokens, passwords, others' emails
- **Dense, no filler** — preserve user's phrasing, don't editorialize
- **Fallback** — if write fails, output the full markdown to chat for manual paste
- **Each `/save` = one new note** — never accumulate across multiple invocations
- **Date** YYYY-MM-DD is not today. must use session day ex: pm-xxx-20260530 => 2026-05-30

## Example (minimal)

Input: `/save` after discussing `tmux send-keys -l "$text"; sleep 0.3; tmux send-keys C-m` as the reliable input pattern for Claude Code.

```
Proposed save:
  Path:  ~/vault/Work/cteam/decisions/2026-05-15-tmux-input-pattern.md
  Type:  decision
  Tags:  tmux, claude-code, automation, gotcha

Proceed?
```

File body shape: Context (paste/submit problem) → Decision (3-step pattern) → Rationale (-l, sleep, C-m roles) → References (cteam script path).

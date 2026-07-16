# cteam — Shared Protocol (all roles)

3-pane multi-agent dev team via Claude Code: **PM** (lead, pane 1.1) + **Slot1/Slot2** (work slots, panes 1.2/1.3). PM talks to the human, owns GitHub Issues, dispatches implementation to the 2 slots, and spawns review subagents for code + design review. Writes happen only in slots (single-threaded-ish, worktree-isolated, one issue each, ephemeral). Reviews are PM-spawned subagents (intelligence, not actions). State: `.cteam/status.toml`. Knowledge: `~/vault`.

> Design rationale (Anthropic *Building Effective Agents*; Cognition *Don't Build Multi-Agents*; git-worktree playbook): keep writes few and single-threaded; let extra agents contribute **intelligence (review/research)**, not parallel writes. 2 write slots + on-demand review subagents is the whole playbook.

## Role Files

| File | Who reads it |
|---|---|
| `$CTEAM_HOME/roles/shared.md` | everyone (this file) |
| `$CTEAM_HOME/roles/pm.md` | PM only |
| `$CTEAM_HOME/roles/slot.md` | slots only |
| `$CTEAM_HOME/roles/design.md` | UI slots (`domain:ui`) + design-review subagents |

Read this file + your role file at session start. Do NOT load the other role's file — it is noise for you.

`$CTEAM_HOME` is exported in every cteam pane and points to the cteam repo root. Outside a pane, derive it: `dirname "$(dirname "$(readlink -f "$(which cteam)")")"`.

## Identity
`echo $CTEAM_ROLE` → `pm` / `slot1` / `slot2`

## Notation

**Panes**: PM=`1.1`, Slot1=`1.2`, Slot2=`1.3`

**`SEND(pane, msg)`** expands to:
```bash
cteam-send "$SESSION:1.{pane}" "{msg}"
```
`{pane}` is the pane index: `1`=PM, `2`=Slot1, `3`=Slot2. Example: `SEND(2, "...")` → `cteam-send "$SESSION:1.2" "..."`.

Rules:
- **MUST** ALWAYS use `cteam-send`. NEVER use raw `tmux send-keys` to deliver a message.
- Message MUST be under 200 chars. Put extra context in the Issue/PR comment instead.
- `cteam-send` handles Enter automatically — do NOT suffix with "Enter".
- If a slot pane stalls with unsubmitted text, flush it (PM Monitor duty — see pm.md).

**`WT(N)`** = worktree path `../{project}-w{N}/` (Slot1→w1, Slot2→w2).

### Andon Code
**`cteam-andon --reason "..." --by $CTEAM_ROLE`** — broadcasts stop to all panes. See the `andon` skill for trigger criteria.

## cteam Skills

Flat under `~/.claude/skills/`: `andon` · `bug-spike` · `cteam-code-review` · `create-issue` · `pre-pr` · `typescript-safety` · `ui-implement` · `figma-preflight` · `figma-create` · `figma-review` · `fable-style` · `grill-me`.

Invoke `fable-style` once at the start of every task (all roles): it sets the working discipline — lead with the outcome, act without asking on reversible in-scope steps, never end a turn on a promise, report outcomes faithfully.

- Invoke via the Skill tool BEFORE acting. If there is even a 1% chance a skill applies, invoke it to check.
- Process skills first (bug-spike, pre-pr), implementation skills second (ui-implement). "Fix this bug" → `bug-spike` first.
- **Rigid** skills (bug-spike, pre-pr, typescript-safety): follow exactly, don't adapt away discipline. **Flexible** skills: adapt principles to context. The skill says which.
- User instructions (role files, direct requests) take precedence over skills, which override default behavior.

## Issue Labels
- **priority**: `high` / `medium` / `low`
- **domain**: `frontend` / `backend` / `infra` / `db` / `auth` / `ui`
- **type**: `feature` / `bug` / `refactor` / `test` / `docs` / `performance` / `research`
- **status**: `todo` / `in-progress` / `review-waiting` / `design-review` / `done` / `blocked`
- **size**: `s` / `m` / `l`

## Status (`.cteam/status.toml`) — PM-owned; each slot updates its own row
```toml
[team]
session = "project-name"
started_at = "2026-06-13T10:00"

[slot1]
status = "working"          # idle / working / review_waiting / design_review / human_review_waiting / blocked
current_issue = 42
current_branch = "issue-42-login-feature"
current_pr = null
worktree_path = "~/work/proj-w1"
last_issue = 38
last_issue_title = "Implement login UI"
started_at = "2026-06-13T10:00"
last_updated = "2026-06-13T10:30"

# [slot2] — same shape
```
Reviews have no status row (they are ephemeral subagents tracked on PM's TODO board).

## Communication Format (PM ↔ Slot only)

**PM → Slot** (dispatch): `{IssueURL}\nworktree: {WT(N)}`
**PM → Slot** (control): `[PM] REVISIONS #{issue} {list}` / `UNBLOCK #{issue} {instr}` / `STOP`

**Slot → PM**: `[SLOT{N}] DONE #{issue} PR #{pr}` / `DONE #{issue} no-pr` / `BLOCKED #{issue} {reason}` / `REVISIONS_DONE #{issue} PR #{pr}`

> Reviews do not message panes — review subagents return their verdict directly into PM's context.

## Branch Strategy
- All work from `develop`; naming `issue-{n}-{title-kebab-case}`. Never branch from / PR to `preview` or `main`. Slot always in its worktree.
- **Rebase, not merge**, to stay current with `develop` (`cteam-rebase`) — linear history; no merge commits polluting `git log`. Refresh before opening/updating a PR.

## Merge Flow
- `feature/*` → `develop` only. `develop` → `preview`: PM only. `preview` → `main`: Human only.
- `domain:ui` PRs require a passing design-review subagent before merge — no exceptions. Deviation = **critical error**.

## Must Rules — All Agents
- **Output the conclusion, not the journey.** Your text output states the result — the answer, the decision, the outcome — and stops. Do not narrate the process, the reasoning, the paths considered, or the steps taken; the human asks for those separately when they want them. Reports to PM and PR/Issue text follow the same rule: lead with the outcome, keep it to what the reader must act on. (`fable-style` sets the fuller discipline.)
- Never ask permission to report — just do it. Missing a report = **critical error**.
- After any step in your flow, execute the next step immediately without confirmation.
- Search vault before BLOCKED or architectural decisions. `/save` findings after a task.
- Keep `status.toml` and the TODO board current immediately after any state change.
- Use the Primitives by default (TODO, subagents, Monitor — see your role file) — they don't get used unless named.
- **Consult current docs, don't trust memory**: when a library / framework / API is unfamiliar, version-sensitive, or possibly deprecated, resolve and read latest docs via Context7 (`resolve-library-id` → `query-docs`) before relying on it — training-cutoff knowledge may be stale. Trivial, well-known usage doesn't need a lookup. Applies to both implementation and review (flag deprecated/changed APIs).

# cteam

3-pane multi-agent dev team on tmux + Claude Code.

```
┌──────────┬──────────┬──────────┐
│    PM    │  Slot1   │  Slot2   │
│  (lead)  │ (writer) │ (writer) │
└──────────┴──────────┴──────────┘
```

- **PM** talks to the human, owns Issues/TODO, dispatches work, merges.
- **Slot1/Slot2** implement one Issue each, in isolated git worktrees.
- **Reviews** (code + design) are PM-spawned subagents — never panes.

The full protocol lives in [`roles/`](roles/); the discipline skills in [`skills/`](skills/).

---

## Quick start

### 1. Install (once per machine)

```bash
git clone git@github.com:ytakehir/cteam.git ~/work/cteam
~/work/cteam/install.sh
source ~/.zshrc
```

Idempotent — safe to re-run anytime. Ends with a `cteam-doctor` report; fix any ✗ it shows.

### 2. Verify (first install only)

| Check | How |
|---|---|
| Skills load | New Claude session → 12 cteam skills in the list |
| Figma OAuth | Ask Claude to call `mcp__figma__whoami` |
| Live launch | `cteam <test-project>` → 3 panes declare their roles |

Then retire the pre-repo assets:

```bash
~/work/cteam/install.sh --retire
```

### 3. Use

```bash
cd ~/work/myproject
cteam myproject          # launch (first run auto-executes init + doctor)
cteam-end myproject      # stop
```

First launch of a project runs `cteam-init` + `cteam-doctor` automatically. Doctor failures abort the launch — override once with `CTEAM_SKIP_DOCTOR=1 cteam myproject`.

---

## Commands

| Command | What it does |
|---|---|
| `cteam <project> [suffix] [dir]` | Launch (or re-attach). `suffix=today` → dated session |
| `cteam-end <project> [date]` | Kill session + cron watcher |
| `cteam-doctor [owner/repo]` | Read-only health check — installs nothing |
| `cteam-init <project> [--repo o/r]` | Labels + vault skeleton + w1/w2 worktrees |
| `cteam-send <target> <msg>` | Pane messaging (Enter-retry safe) — the only sanctioned channel |
| `cteam-andon --reason "..."` | Emergency stop, all panes (Escape-first) |
| `cteam-rebase` | Slot: rebase current branch onto origin/develop |
| `cteam-reset-slot <session> <slotN>` | PM: fresh context for a slot between issues |

`cteam-cron` is internal (launched by `cteam`, watches vault Raw/ accumulation).

---

## What install.sh wires up

| Source (repo) | Destination | Method |
|---|---|---|
| `skills/` (12) | `~/.claude/skills/` | symlink |
| `agents/` (3 reviewers) | `~/.claude/agents/` | symlink |
| `commands/` (`/save`, `/organize`) | `~/.claude/commands/` | symlink |
| `rules/vault.md` | `~/.claude/rules/cteam/obsidian/vault.md` | symlink |
| PATH block | `~/.zshrc` | marked block |
| cron-kill hook | tmux conf (`session-closed`) | marked block |
| cteam pointer | `~/.claude/CLAUDE.md` | sed migrate / append |
| `settings-fragment.json` | `~/.claude/settings.json` | JSON merge |

Notes:

- Anything replaced is backed up to `~/.claude/backups/cteam-install-<timestamp>/`.
- `--copy` copies instead of symlinking (only needed if your setup doesn't scan symlinked skills — verified working on macOS). Copy mode requires re-running install.sh after every skill edit.
- `--retire` moves the legacy `~/.config/tmux/cteam` assets + old zshrc lines to a backup. Run only after the verify step.

### Settings sharing (settings-fragment.json)

All Claude Code configuration is **centralized at user level** — projects must NOT carry their own `.claude/settings*.json` (doctor warns if any appear under `~/work`). The fragment is merged into `~/.claude/settings.json` by install.sh:

| Fragment content | Merge behavior |
|---|---|
| `permissions.allow` (~230) / `permissions.deny` (53) | Union — adds missing rules, never removes machine-local ones |
| `enabledPlugins` (5) | Forced true |
| `extraKnownMarketplaces` (obsidian-skills) | Added if missing |
| `skipAutoPermissionPrompt: true` | **Enforced** — panes stall on the auto-mode prompt without it |
| `autoCompactEnabled`, `includeCoAuthoredBy` | Set only if absent (existing value respected; doctor warns on drift) |
| lint hooks ×2 | Added by id, only if the `~/.claude/scripts` lib exists |

The deny set is deliberately broad (recursive rm variants, `git reset --hard`, `git push -f`, `~/.claude` + `~/.ssh` + `.env` protection, keychain probes, publish/delete commands) and applies to ALL sessions, not just cteam. `~/.claude/settings.local.json` stays machine-personal (auto-accumulated "always allow" clicks land there).

### Manual steps (install.sh can't do these)

| What | How | Doctor |
|---|---|---|
| Plugins (context7, figma, superpowers, typescript-lsp, swift-lsp) | `/plugin` in Claude Code | ✗ if missing |
| Figma MCP OAuth | `mcp__figma__whoami` in a session; `/mcp` to re-auth | ⚠ always (not shell-checkable) |
| GitHub auth | `gh auth login` | ✗ if missing |
| Obsidian app + CLI, `obsidian-*` skills | `brew install --cask obsidian`; skills from `kepano/obsidian-skills` | ⚠ if missing |

Obsidian is optional: vault writes are plain markdown and work without it. The `/goal` and `/loop` slash commands the PM uses for dispatch are Claude Code built-ins — nothing to install.

---

## Repo layout

```
bin/        launcher + 8 tools (table above)
roles/      protocol: shared.md (all) · pm.md · slot.md · design.md (domain:ui)
skills/     12 discipline skills → symlinked flat into ~/.claude/skills/
agents/     reviewer subagents: code-reviewer · typescript-reviewer · security-reviewer
commands/   /save · /organize (vault workflow)
rules/      vault.md — vault conventions, auto-loaded every session
install.sh  idempotent installer (--copy · --retire)
settings-fragment.json  required plugins + optional lint hooks
```

**Path model**: everything routes through `$CTEAM_HOME` (this repo root). The launcher derives it from its own location and exports it — plus `$CTEAM_HOME/bin` on PATH — into every pane. No hardcoded paths anywhere.

**Editing**: skills/agents/commands/rules are symlinked and roles are read from the repo, so edits are live for new sessions — no re-install. Commit like any repo.

---

## Per-project setup (what cteam-init creates)

- **Labels** (upserted via `gh label create --force`): `priority:{high,medium,low}` · `domain:{frontend,backend,infra,db,auth,ui}` · `type:{feature,bug,refactor,test,docs,performance,research}` · `status:{todo,in-progress,review-waiting,design-review,done,blocked}` · `size:{s,m,l}`
- **Vault**: `~/vault/Work/<project>/{logs,decisions,architecture,notes,Raw}`
- **Worktrees**: `../<project>-w1`, `../<project>-w2` off `develop` (skipped with a notice if no develop branch yet)

---

## Design decisions (settled — don't re-litigate casually)

| Decision | Why |
|---|---|
| No plugin packaging | tmux-layer scripts can't ship in a plugin; cache copies break the edit cycle; namespacing breaks skill cross-refs. Add `marketplace.json` later if it ever goes public |
| No agent-teams migration | Experimental + no desktop app support. Revisit when it graduates |
| Obsidian skills not vendored | General-purpose (kepano marketplace), not cteam's — doctor checks presence instead |
| PM on fable (effort high); slots on sonnet (effort xhigh) + `--advisor opus` | Cheaper writers with a senior server-side advisor (needs Claude Code ≥ 2.1.98 — doctor checks) |
| All panes: `--chrome` + `CLAUDE_CODE_SUBAGENT_MODEL=opus` | Browser tooling everywhere; review/research subagents run on opus |
| State triple-tracking | status.toml / TODO board / GitHub labels — accepted |

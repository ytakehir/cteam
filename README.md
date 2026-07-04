# cteam

3-pane multi-agent dev team on tmux + Claude Code: **PM** (lead) + **Slot1/Slot2** (write slots). Reviews (code + design) are PM-spawned subagents, never panes. Protocol lives in `roles/`; discipline skills in `skills/`.

```
┌──────────┬──────────┬──────────┐
│    PM    │  Slot1   │  Slot2   │
└──────────┴──────────┴──────────┘
```

## Layout

| Path | What |
|---|---|
| `bin/cteam` | Launcher: tmux session + 3 Claude panes + cron watcher |
| `bin/cteam-send` | Pane messaging (Enter-retry safe) — the ONLY sanctioned channel |
| `bin/cteam-andon` | Emergency stop broadcast (Escape-first) |
| `bin/cteam-rebase` | Slot branch refresh onto origin/develop (rebase, not merge) |
| `bin/cteam-reset-slot` | Kill-and-replace a slot's context between issues |
| `bin/cteam-cron` | Background watcher (vault Raw/ accumulation → PM) |
| `bin/cteam-end` | Stop session + cron |
| `bin/cteam-doctor` | Dependency/wiring check — read-only, installs nothing |
| `bin/cteam-init` | Per-project setup: GitHub labels, vault skeleton, worktrees |
| `roles/` | Protocol: `shared.md` (all), `pm.md`, `slot.md`, `design.md` (domain:ui) |
| `skills/` | 11 discipline skills, symlinked flat into `~/.claude/skills/` |
| `agents/` | Reviewer subagent definitions (code / typescript / security) |
| `commands/` | `/save`, `/organize` (vault workflow), symlinked into `~/.claude/commands/` |
| `rules/vault.md` | Vault conventions, symlinked to `~/.claude/rules/cteam/obsidian/vault.md` (auto-loaded every session) |
| `settings-fragment.json` | Required plugins + optional lint hooks, merged by install.sh |

`$CTEAM_HOME` (this repo root) is exported into every pane; all path references route through it.

## Install

```bash
git clone git@github.com:ytakehir/cteam.git ~/work/cteam
~/work/cteam/install.sh
```

Idempotent. It symlinks skills/agents/commands/rules into `~/.claude/`, adds a PATH block to `~/.zshrc`, points the cteam section of `~/.claude/CLAUDE.md` at this repo, merges `settings-fragment.json` into `~/.claude/settings.json` (plugins always; the two lint hooks only if the ECC-derived `~/.claude/scripts` lib exists), then runs `cteam-doctor`.

**First install — verify symlinked skills load:** open a NEW Claude Code session and confirm the 11 cteam skills (andon, bug-spike, cteam-code-review, create-issue, pre-pr, typescript-safety, ui-implement, figma-preflight, figma-create, figma-review, fable-style) appear in the skills list. `~/.claude/skills/` is scanned one level deep only; if symlinks are not followed on your setup, fall back to:

```bash
~/work/cteam/install.sh --copy   # copies instead — re-run after every skill edit
```

After everything verifies, retire the legacy `~/.config/tmux/cteam` assets:

```bash
~/work/cteam/install.sh --retire
```

### Manual steps install.sh cannot do

- **Plugins**: if `cteam-doctor` flags a plugin, install it via `/plugin` inside Claude Code (context7, figma, superpowers, typescript-lsp, swift-lsp — all `@claude-plugins-official`).
- **Figma MCP OAuth**: in a Claude session ask it to call `mcp__figma__whoami`; re-auth via `/mcp` if it fails.
- **gh auth**: `gh auth login` (doctor checks status).
- **Obsidian** (optional but recommended): `brew install --cask obsidian` + its CLI, and the `obsidian-cli` / `obsidian-markdown` / `obsidian-bases` skills from the `kepano/obsidian-skills` marketplace. Vault writes are plain markdown files and work without Obsidian; these only power the richer vault skills. Deliberately NOT vendored here (they are general-purpose, not cteam's).
- **git / tmux / node / python3**: install via Homebrew if missing.

## Per-project setup

```bash
cd ~/work/myproject
cteam myproject                 # first run auto-executes cteam-init + cteam-doctor, then launches
cteam-end myproject             # stop
```

**First launch of a project runs `cteam-init` + `cteam-doctor` automatically** (trigger: no `~/.cteam_sessions/<project>.toml` yet). Doctor failures abort the launch; override once with `CTEAM_SKIP_DOCTOR=1 cteam myproject`. Both tools are idempotent and can also be run standalone:

```bash
cteam-init myproject            # labels + vault + worktrees (needs a develop branch)
cteam-doctor owner/myproject    # verify, incl. label scheme
```

`cteam-init` creates the label scheme from `roles/shared.md` (priority / domain / type / status / size), the vault skeleton `~/vault/Work/<project>/{logs,decisions,architecture,notes,Raw}`, and worktrees `../<project>-w1`, `../<project>-w2` off `develop`.

## Editing the protocol

Skills and agents are symlinked, roles are read from the repo — edits here are live for new sessions/panes; no re-install needed (unless you used `--copy`). Commit changes like any repo.

## Design decisions (settled — do not re-litigate casually)

- **No plugin packaging**: tmux-layer scripts can't ship in a Claude plugin, the plugin cache copy breaks the edit cycle, and plugin namespacing breaks skill cross-references. Add a `marketplace.json` later if it ever goes public.
- **No agent-teams migration** while the feature is experimental and unsupported in the desktop app. Revisit when it graduates or gains desktop support.
- **All panes on opus** (Fable-period trial) and the strong-worded prompts stay as-is.
- **State triple-tracking** (status.toml / TODO board / GitHub labels) is accepted.

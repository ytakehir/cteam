#!/bin/bash
# install.sh [--copy] [--retire]
#
# Idempotent installer for cteam. Wires this repo into Claude Code + zsh:
#   1. Skills  → symlinks into ~/.claude/skills/   (--copy: copy instead;
#      needed only if a Claude session does not list symlinked skills —
#      then re-run install.sh after every skill edit)
#   2. Agents  → symlinks into ~/.claude/agents/
#   3. PATH    → managed block in ~/.zshrc
#   4. ~/.claude/CLAUDE.md cteam pointer → repo roles path
#   5. Settings merge (settings-fragment.json: plugins + lint hooks)
#   6. cteam-doctor
#
# --retire: additionally move the legacy ~/.config/tmux/cteam assets and the
#           old zshrc alias/PATH lines to a backup. Run this only AFTER
#           verifying the repo install works (see README).
#
# Interactive steps are NOT automated (guidance printed by doctor instead):
# Figma MCP OAuth, /plugin installs, gh auth login.

set -e

SELF="$0"
while [ -L "$SELF" ]; do SELF="$(readlink "$SELF")"; done
CTEAM_HOME="$(cd "$(dirname "$SELF")" && pwd)"

MODE="link"
RETIRE=0
for arg in "$@"; do
  case "$arg" in
    --copy)   MODE="copy" ;;
    --retire) RETIRE=1 ;;
    *) echo "Usage: install.sh [--copy] [--retire]" >&2; exit 1 ;;
  esac
done

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.claude/backups/cteam-install-$STAMP"
backed_up=0
backup() { # path
  mkdir -p "$BACKUP"
  mv "$1" "$BACKUP/"
  backed_up=1
  echo "  backed up: $1 → $BACKUP/"
}

echo "cteam install — $CTEAM_HOME (mode: $MODE)"

# ── 1. Skills ─────────────────────────────────────────────────
echo "Skills → ~/.claude/skills/"
mkdir -p "$HOME/.claude/skills"
SKILLS="andon bug-spike cteam-code-review create-issue pre-pr typescript-safety ui-implement figma-preflight figma-create figma-review fable-style"
for s in $SKILLS; do
  src="$CTEAM_HOME/skills/$s"
  dst="$HOME/.claude/skills/$s"
  if [ "$MODE" = "link" ]; then
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      echo "  ok: $s"
      continue
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then backup "$dst"; fi
    ln -s "$src" "$dst"
    echo "  linked: $s"
  else
    if [ -L "$dst" ]; then rm "$dst"; elif [ -e "$dst" ]; then backup "$dst"; fi
    cp -R "$src" "$dst"
    echo "  copied: $s"
  fi
done

# ── 2. Agents ─────────────────────────────────────────────────
echo "Agents → ~/.claude/agents/"
mkdir -p "$HOME/.claude/agents"
for a in code-reviewer typescript-reviewer security-reviewer; do
  src="$CTEAM_HOME/agents/$a.md"
  dst="$HOME/.claude/agents/$a.md"
  if [ "$MODE" = "link" ]; then
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      echo "  ok: $a"
      continue
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then backup "$dst"; fi
    ln -s "$src" "$dst"
    echo "  linked: $a"
  else
    if [ -L "$dst" ]; then rm "$dst"; elif [ -e "$dst" ]; then backup "$dst"; fi
    cp "$src" "$dst"
    echo "  copied: $a"
  fi
done

# ── 2b. Commands (vault workflow: /save, /organize) ──────────
echo "Commands → ~/.claude/commands/"
mkdir -p "$HOME/.claude/commands"
for c in save organize; do
  src="$CTEAM_HOME/commands/$c.md"
  dst="$HOME/.claude/commands/$c.md"
  if [ "$MODE" = "link" ]; then
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      echo "  ok: /$c"
      continue
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then backup "$dst"; fi
    ln -s "$src" "$dst"
    echo "  linked: /$c"
  else
    if [ -L "$dst" ]; then rm "$dst"; elif [ -e "$dst" ]; then backup "$dst"; fi
    cp "$src" "$dst"
    echo "  copied: /$c"
  fi
done

# ── 2c. Vault rules (auto-loaded every session) ───────────────
echo "Rules → ~/.claude/rules/cteam/obsidian/"
mkdir -p "$HOME/.claude/rules/cteam/obsidian"
src="$CTEAM_HOME/rules/vault.md"
dst="$HOME/.claude/rules/cteam/obsidian/vault.md"
if [ "$MODE" = "link" ]; then
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  ok: vault.md"
  else
    if [ -e "$dst" ] || [ -L "$dst" ]; then backup "$dst"; fi
    ln -s "$src" "$dst"
    echo "  linked: vault.md"
  fi
else
  if [ -L "$dst" ]; then rm "$dst"; elif [ -e "$dst" ]; then backup "$dst"; fi
  cp "$src" "$dst"
  echo "  copied: vault.md"
fi

# ── 3. PATH block in ~/.zshrc ─────────────────────────────────
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"
if grep -q "# >>> cteam >>>" "$ZSHRC"; then
  # refresh block in place (path may have moved)
  python3 - "$ZSHRC" "$CTEAM_HOME" <<'PYEOF'
import re, sys
path, home = sys.argv[1], sys.argv[2]
text = open(path).read()
block = f'# >>> cteam >>>\nexport PATH="{home}/bin:$PATH"\n# <<< cteam <<<'
text = re.sub(r'# >>> cteam >>>.*?# <<< cteam <<<', block, text, flags=re.S)
open(path, 'w').write(text)
PYEOF
  echo "zshrc: cteam block refreshed"
else
  printf '\n# >>> cteam >>>\nexport PATH="%s/bin:$PATH"\n# <<< cteam <<<\n' "$CTEAM_HOME" >> "$ZSHRC"
  echo "zshrc: cteam block added"
fi

# ── 3b. tmux hook: kill cron watcher when a session closes ───
TMUX_CONF="$HOME/.config/tmux/tmux.conf"
if [ ! -f "$TMUX_CONF" ] && [ -f "$HOME/.tmux.conf" ]; then
  TMUX_CONF="$HOME/.tmux.conf"
fi
mkdir -p "$(dirname "$TMUX_CONF")"
touch "$TMUX_CONF"
if grep -q "cteam_cron" "$TMUX_CONF"; then
  echo "tmux conf: cteam cron-kill hook present ($TMUX_CONF)"
else
  cat >> "$TMUX_CONF" << 'EOF'

# >>> cteam >>>
# Kill the cteam cron watcher when its tmux session closes (safety net; cteam-end also kills it)
set-hook -g session-closed "run-shell 'kill $(cat /tmp/cteam_cron_#{session_name}.pid 2>/dev/null) 2>/dev/null'"
# <<< cteam <<<
EOF
  echo "tmux conf: cteam cron-kill hook added ($TMUX_CONF)"
  tmux source-file "$TMUX_CONF" 2>/dev/null || true
fi

# ── 4. ~/.claude/CLAUDE.md pointer ────────────────────────────
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
if [ -f "$CLAUDE_MD" ] && grep -q "config/tmux/cteam/roles" "$CLAUDE_MD"; then
  sed -i '' "s|~/.config/tmux/cteam/roles|$CTEAM_HOME/roles|g" "$CLAUDE_MD"
  echo "CLAUDE.md: pointer migrated to repo path"
elif [ -f "$CLAUDE_MD" ] && grep -q "roles/shared.md" "$CLAUDE_MD"; then
  echo "CLAUDE.md: pointer already present"
else
  cat >> "$CLAUDE_MD" << EOF

# cteam

If \`\$CTEAM_ROLE\` is set, this session is a cteam pane. Read \`$CTEAM_HOME/roles/shared.md\` plus your role file (\`pm.md\` for PM, \`slot.md\` for slots; \`design.md\` for \`domain:ui\` work) before acting — they are the operational protocol.

If \`\$CTEAM_ROLE\` is not set, cteam does not apply to this session.
EOF
  echo "CLAUDE.md: pointer appended"
fi

# ── 5. Settings merge (plugins + lint hooks) ──────────────────
python3 - "$CTEAM_HOME" <<'PYEOF'
import json, os, shutil, sys

home = sys.argv[1]
settings_path = os.path.expanduser('~/.claude/settings.json')
frag = json.load(open(os.path.join(home, 'settings-fragment.json')))
settings = json.load(open(settings_path)) if os.path.exists(settings_path) else {}
changed = []

plugins = dict(settings.get('enabledPlugins', {}))
for p in frag.get('enabledPlugins', {}):
    if plugins.get(p) is not True:
        plugins[p] = True
        changed.append(f'plugin {p}')
settings = {**settings, 'enabledPlugins': plugins}

# Lint hooks depend on the ECC-derived ~/.claude/scripts lib — skip if absent.
if os.path.exists(os.path.expanduser('~/.claude/scripts/hooks/run-with-flags.js')):
    hooks = {k: list(v) for k, v in settings.get('hooks', {}).items()}
    for event, entries in frag.get('hooks', {}).items():
        existing = {e.get('id') for e in hooks.get(event, [])}
        for e in entries:
            if e.get('id') not in existing:
                hooks[event] = hooks.get(event, []) + [e]
                changed.append(f"hook {e.get('id')}")
    settings = {**settings, 'hooks': hooks}
else:
    print('settings: lint hooks skipped (~/.claude/scripts lib absent)')

if changed:
    shutil.copy(settings_path, settings_path + '.bak')
    tmp = settings_path + '.tmp'
    with open(tmp, 'w') as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
        f.write('\n')
    os.replace(tmp, settings_path)
    print('settings: merged →', ', '.join(changed), f'(backup: {settings_path}.bak)')
else:
    print('settings: already up to date')
PYEOF

# ── 6. Retire legacy assets (only with --retire) ──────────────
if [ "$RETIRE" -eq 1 ]; then
  echo "Retiring legacy assets:"
  [ -d "$HOME/.config/tmux/cteam" ]       && backup "$HOME/.config/tmux/cteam"
  [ -f "$HOME/.config/tmux/layouts/cteam.sh" ] && backup "$HOME/.config/tmux/layouts/cteam.sh"
  # drop old alias + PATH lines from zshrc
  sed -i '' \
    -e '\|alias cteam="~/.config/tmux/layouts/cteam.sh"|d' \
    -e '\|export PATH="\$HOME/.config/tmux/cteam:\$PATH"|d' \
    "$ZSHRC"
  echo "  zshrc: legacy alias/PATH lines removed"
fi

if [ "$backed_up" -eq 1 ]; then echo "Backups in: $BACKUP"; fi

# ── 7. Doctor ─────────────────────────────────────────────────
echo
"$CTEAM_HOME/bin/cteam-doctor" || true

echo
echo "NEXT (manual, cannot be automated):"
echo "  - Open a NEW Claude Code session and confirm the 11 cteam skills are listed"
echo "    (first install only: this validates symlinked skills; if missing, re-run: install.sh --copy)"
echo "  - Verify Figma MCP auth inside Claude (mcp__figma__whoami; /mcp to re-auth)"
echo "  - source ~/.zshrc (or open a new shell) to pick up PATH"
echo "  - After verifying: install.sh --retire  (moves legacy ~/.config/tmux/cteam aside)"

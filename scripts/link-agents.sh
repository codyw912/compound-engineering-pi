#!/usr/bin/env bash
# Set up compound-engineering for pi-subagents:
# 1. Symlink agent definitions into ~/.pi/agent/agents/
# 2. Register skills path in settings.json so subagents can find them
#
# Usage: ./scripts/link-agents.sh
# Idempotent — safe to run multiple times.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_SRC="$REPO_ROOT/agents"
SKILLS_SRC="$REPO_ROOT/skills"
AGENTS_DST="$HOME/.pi/agent/agents"
SETTINGS_FILE="$HOME/.pi/agent/settings.json"

# --- 1. Link agent definitions ---

mkdir -p "$AGENTS_DST"

linked=0
skipped=0

for agent_file in "$AGENTS_SRC"/*.md; do
    [ -f "$agent_file" ] || continue
    name="$(basename "$agent_file")"
    target="$AGENTS_DST/$name"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$agent_file" ]; then
        skipped=$((skipped + 1))
        continue
    fi

    if [ -e "$target" ]; then
        echo "  skip: $name (file exists, not our symlink)"
        skipped=$((skipped + 1))
        continue
    fi

    ln -s "$agent_file" "$target"
    echo "  linked: $name"
    linked=$((linked + 1))
done

echo "Agents: $linked linked, $skipped skipped"

# --- 2. Register skills path in settings.json ---

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "  skip: settings.json not found at $SETTINGS_FILE"
    exit 0
fi

# Check if skills path is already registered
if python3 -c "
import json, sys
with open('$SETTINGS_FILE') as f:
    d = json.load(f)
skills = d.get('skills', [])
sys.exit(0 if '$SKILLS_SRC' in skills else 1)
" 2>/dev/null; then
    echo "Skills: already registered in settings.json"
else
    # Add skills path to settings.json
    python3 -c "
import json
with open('$SETTINGS_FILE') as f:
    d = json.load(f)
skills = d.get('skills', [])
skills.append('$SKILLS_SRC')
d['skills'] = skills
with open('$SETTINGS_FILE', 'w') as f:
    json.dump(d, f, indent=2)
    f.write('\n')
" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Skills: registered $SKILLS_SRC in settings.json"
    else
        echo "Skills: failed to update settings.json (python3 required)"
        echo "  Manual fix: add \"$SKILLS_SRC\" to the \"skills\" array in $SETTINGS_FILE"
    fi
fi

echo "Done. Reload pi session (/reload) to pick up changes."

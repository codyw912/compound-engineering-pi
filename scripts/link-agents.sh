#!/usr/bin/env bash
# Link compound-engineering agent definitions into ~/.pi/agent/agents/
# so pi-subagents can discover them.
#
# Usage: ./scripts/link-agents.sh
# Idempotent — safe to run multiple times.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_SRC="$(cd "$SCRIPT_DIR/../agents" && pwd)"
AGENTS_DST="$HOME/.pi/agent/agents"

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

echo "Done: $linked linked, $skipped skipped"
echo "Agents available at: $AGENTS_DST"

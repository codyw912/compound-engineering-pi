#!/usr/bin/env bash
# Apply model assignments from agent-models.json to all agent definitions.
#
# Usage: ./scripts/apply-models.sh [config-file]
# Default config: templates/agent-models.json
#
# Idempotent — safe to run multiple times.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="${1:-$REPO_ROOT/templates/agent-models.json}"

if [ ! -f "$CONFIG" ]; then
    echo "Error: config not found at $CONFIG"
    exit 1
fi

echo "Applying models from: $CONFIG"

# Read model assignments
get_model() {
    python3 -c "import json; d=json.load(open('$CONFIG')); print(d['models'].get('$1', ''))"
}

# Update agent definition files
update_agent() {
    local agent="$1"
    local file="$REPO_ROOT/agents/$agent.md"
    local model
    model=$(get_model "$agent")
    
    if [ -z "$model" ]; then return; fi
    if [ ! -f "$file" ]; then return; fi
    
    # Replace the model line in frontmatter
    if grep -q "^model:" "$file"; then
        sed -i '' "s|^model:.*|model: $model|" "$file"
        echo "  $agent → $model"
    fi
}

for agent in explorer researcher planner worker reviewer quick-task project-lead; do
    update_agent "$agent"
done

# Sync installed APPEND_SYSTEM.md if it exists
APPEND_TEMPLATE="$REPO_ROOT/templates/APPEND_SYSTEM.md"
INSTALLED="$HOME/.pi/agent/APPEND_SYSTEM.md"
if [ -f "$APPEND_TEMPLATE" ] && [ -f "$INSTALLED" ]; then
    cp "$APPEND_TEMPLATE" "$INSTALLED"
    echo "  ~/.pi/agent/APPEND_SYSTEM.md synced"
fi

echo "Done. Reload pi session (/reload) to pick up changes."

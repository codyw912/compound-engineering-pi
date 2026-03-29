#!/usr/bin/env bash
# Apply model assignments from agent-models.json to all agent definitions
# and the APPEND_SYSTEM.md template.
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

# Update APPEND_SYSTEM.md template if it exists
APPEND_TEMPLATE="$REPO_ROOT/templates/APPEND_SYSTEM.md"
if [ -f "$APPEND_TEMPLATE" ]; then
    explorer=$(get_model "explorer")
    researcher=$(get_model "researcher")
    worker=$(get_model "worker")
    reviewer=$(get_model "reviewer")
    planner=$(get_model "planner")
    quick_task=$(get_model "quick-task")
    
    # Update the model column in the agent table
    # Match lines like: | `explorer` | Gemini Flash | ...
    sed -i '' "s|^\(| \`explorer\` | \).*\( |.*Fast read-only\)|\\1${explorer##*/}\\2|" "$APPEND_TEMPLATE"
    sed -i '' "s|^\(| \`researcher\` | \).*\( |.*External docs\)|\\1${researcher##*/}\\2|" "$APPEND_TEMPLATE"
    sed -i '' "s|^\(| \`worker\` | \).*\( |.*Implement features\)|\\1${worker##*/}\\2|" "$APPEND_TEMPLATE"
    sed -i '' "s|^\(| \`reviewer\` | \).*\( |.*Independent code\)|\\1${reviewer##*/}\\2|" "$APPEND_TEMPLATE"
    sed -i '' "s|^\(| \`planner\` | \).*\( |.*Analyze specs\)|\\1${planner##*/}\\2|" "$APPEND_TEMPLATE"
    sed -i '' "s|^\(| \`quick-task\` | \).*\( |.*Mechanical edits\)|\\1${quick_task##*/}\\2|" "$APPEND_TEMPLATE"
    
    echo "  APPEND_SYSTEM.md table updated"
fi

# Update installed APPEND_SYSTEM.md if it exists
INSTALLED="$HOME/.pi/agent/APPEND_SYSTEM.md"
if [ -f "$INSTALLED" ]; then
    cp "$APPEND_TEMPLATE" "$INSTALLED"
    echo "  ~/.pi/agent/APPEND_SYSTEM.md updated"
fi

echo "Done. Reload pi session (/reload) to pick up changes."

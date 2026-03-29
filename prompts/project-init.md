---
description: Initialize project management for a new or existing project
argument-hint: "[optional: goals, priorities, or focus areas]"
---

Set up the project-lead workflow for this project. This configures the current project so that Pi sessions automatically behave as the project-lead — no subagent delegation needed.

## Step 1: Create project-level Pi configuration

Create `.pi/APPEND_SYSTEM.md` with the project-lead behavior injected into the session. Read the project-lead agent definition for the system prompt content:

```bash
# Read the agent definition to get the system prompt
cat ~/.pi/agent/agents/project-lead.md
```

Extract everything below the frontmatter `---` and write it to `.pi/APPEND_SYSTEM.md`.

Create `.pi/settings.json` to set the model:

```json
{
  "defaultModel": "claude-opus-4-6",
  "defaultProvider": "opencode"
}
```

## Step 2: Initialize project state

Check if this is an existing codebase or greenfield:
- Look for source files, build configs, git history
- **If existing**: launch `explorer` subagents to map the codebase, then discuss goals
- **If greenfield**: discuss goals, constraints, and scope

Create the `.project/` directory structure:

```
.project/
├── project.md          # Vision, goals, constraints
├── status.md           # Session-level state
├── state.json          # Machine-readable progress
├── notepad/
│   ├── learnings.md    # Conventions, patterns
│   ├── decisions.md    # Architectural decisions
│   ├── issues.md       # Known problems
│   └── blockers.md     # Unresolved blockers
└── phases/
    └── phase-1-*.md    # First phase plan
```

For existing projects, pre-populate the notepad from exploration findings.

## Step 3: Commit and reload

```bash
git add .pi/APPEND_SYSTEM.md .pi/settings.json .project/
git commit -m "project: initialize project-lead workflow"
```

Tell the user to reload their Pi session (`/reload`) to pick up the new system prompt and model.

Additional context from user (may be empty): $ARGUMENTS

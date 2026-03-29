---
description: Initialize a new long-running project with the project-lead agent
argument-hint: "[project description or goal]"
---

Start a new project by delegating to the project-lead agent.

Use the `subagent` tool to launch the project-lead:

```
subagent({
  agent: "project-lead",
  task: "Initialize a new project. The user wants to build: $ARGUMENTS\n\nThis is a new project — no .project/ directory exists yet. Follow the Project Initialization workflow in your instructions: discuss goals with the user, then set up the .project/ structure with project.md, initial phase plan, status.md, state.json, and notepad files."
})
```

If the subagent tool is not available, follow the project-lead's initialization workflow directly:

1. Discuss the project goals, constraints, and scope
2. Create `.project/` directory structure
3. Write `project.md` with vision and goals
4. Create initial phase breakdown in `.project/phases/`
5. Initialize `status.md` and `state.json`
6. Commit the initial project state

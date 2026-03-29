---
description: Initialize project management for a new or existing project
argument-hint: "[project goals or what you want to work on]"
---

Set up the project-lead workflow for this project. Works on both greenfield and existing codebases.

Use the `subagent` tool to launch the project-lead:

```
subagent({
  agent: "project-lead",
  task: "Initialize project management for this codebase. The user's goals: $ARGUMENTS\n\nCheck if this is an existing codebase or greenfield, then follow the appropriate initialization path in your instructions. For existing codebases, launch explorers to understand the code before setting up .project/ state."
})
```

If the subagent tool is not available, follow the initialization workflow directly:

1. Check if this is an existing project (source files, git history) or greenfield
2. **If existing**: explore the codebase first — map architecture, tech stack, recent activity. Then discuss goals with the user.
3. **If greenfield**: discuss goals, constraints, and scope with the user.
4. Create `.project/` directory structure with project.md, phase plan, status.md, state.json, and notepad
5. For existing projects, pre-populate notepad with conventions and patterns found during exploration
6. Commit the initial project state

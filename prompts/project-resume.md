---
description: Resume work on the current project with the project-lead agent
argument-hint: "[optional: what to focus on this session]"
---

Resume the current project by delegating to the project-lead agent.

Use the `subagent` tool to launch the project-lead:

```
subagent({
  agent: "project-lead",
  task: "Resume work on this project. Read .project/status.md and .project/state.json to understand where we left off, then bootstrap context from the active phase plan and notepad.\n\nUser wants to focus on: $ARGUMENTS\n\nIf the user didn't specify a focus, propose the next logical step based on the project state."
})
```

If the subagent tool is not available, bootstrap context manually:

1. Read `.project/status.md` for current state
2. Read `.project/state.json` for progress counts
3. Read the active phase plan
4. Read `.project/notepad/learnings.md` and `.project/notepad/issues.md`
5. Give a brief status report and propose next steps

---
description: Resume work on the current project
argument-hint: "[optional: what to focus on this session]"
---

Resume the current project. Bootstrap context from the project state files.

Read these in order:
1. `.project/project.md` — vision and goals
2. `.project/status.md` — where we left off
3. `.project/state.json` — progress counts
4. The active phase plan from `.project/phases/`
5. `.project/notepad/learnings.md` — accumulated knowledge
6. `.project/notepad/issues.md` — known problems
7. `.project/notepad/blockers.md` — anything blocking progress

Give a brief status report (3-5 lines), then either:
- If the user specified a focus: propose how to approach it
- If not: recommend the next logical step based on project state

User's focus for this session (may be empty): $ARGUMENTS

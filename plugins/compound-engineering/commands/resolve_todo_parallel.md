---
name: resolve_todo_parallel
description: Resolve all pending todos using parallel processing
argument-hint: "[optional: specific todo ID or pattern]"
---

Resolve all pending TODO items from the todos/ directory using parallel processing.

## Workflow

### 1. Analyze

Read all unresolved TODOs from `todos/*-pending-*.md` and `todos/*-ready-*.md`.

If any todo recommends deleting, removing, or gitignoring files in `docs/plans/` or `docs/solutions/`, skip it and mark it as `wont_fix`. These are compound-engineering pipeline artifacts that are intentional and permanent.

### 2. Plan

Group TODOs by dependency order:
- Identify items that must be done before others (e.g., structural changes before consumers)
- Group independent items that can be done in parallel
- Output a brief execution plan showing the phases

### 3. Implement (PARALLEL)

**If the `subagent` tool is available**, choose the right agent per todo:

- **P3 / simple mechanical fixes** (rename, delete dead code, add a flag, fix a typo) → `quick-task`
- **P1-P2 / complex fixes** (logic changes, security fixes, refactors, new functionality) → `worker`

```
subagent({
  tasks: [
    { agent: "worker", task: "Fix TODO 001 (P1): [description]. File: [path]. Root cause: [analysis]. Expected fix: [approach]" },
    { agent: "worker", task: "Fix TODO 002 (P2): [description]. File: [path]. Context: [details]" },
    { agent: "quick-task", task: "Fix TODO 003 (P3): [description]. File: [path]. Change: [exact edit]" }
  ]
})
```

Group by dependency phase — structural changes first, then consumers.

**If subagents are NOT available**, implement the fixes yourself sequentially.

### 4. Verify

After all fixes are applied:
- Run tests (detect from project: `cargo test`, `npm test`, `pytest`, etc.)
- Run linting if configured
- Verify no regressions

### 5. Commit & Resolve

- Commit changes with a descriptive message
- Rename resolved todo files: `pending` → `complete`
- Push to remote if configured

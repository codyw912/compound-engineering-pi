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

**If the `subagent` tool is available**, use `quick-task` agents for parallel execution:

```
subagent({
  tasks: [
    { agent: "quick-task", task: "Fix TODO 001: [description]. File: [path]. Change: [specific fix]" },
    { agent: "quick-task", task: "Fix TODO 002: [description]. File: [path]. Change: [specific fix]" },
    { agent: "quick-task", task: "Fix TODO 003: [description]. File: [path]. Change: [specific fix]" }
  ]
})
```

For complex fixes that require reasoning about architecture or correctness, use the `reviewer` agent to analyze first, then `quick-task` to implement:

```
subagent({ agent: "reviewer", task: "Analyze TODO 005 and recommend the exact fix: [description]" })
# Then implement with quick-task based on the recommendation
```

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

---
name: resolve_parallel
description: Resolve all TODO comments in source code using parallel processing
argument-hint: "[optional: specific TODO pattern or file]"
disable-model-invocation: true
---

Resolve all TODO comments in source code using parallel processing.

## Workflow

### 1. Analyze

Find all TODO/FIXME/HACK comments in the codebase using grep.

### 2. Plan

Group by dependency order:
- Identify items that must be done before others
- Group independent items for parallel execution
- Output a brief execution plan

### 3. Implement (PARALLEL)

**If the `subagent` tool is available**, use `worker` for complex fixes and `quick-task` for simple ones:

```
subagent({
  tasks: [
    { agent: "worker", task: "Fix TODO in [file:line]: [description]. [context and approach]" },
    { agent: "quick-task", task: "Fix TODO in [file:line]: [description]. [exact edit]" }
  ]
})
```

**If subagents are NOT available**, implement fixes sequentially.

### 4. Commit & Resolve

- Commit changes
- Push to remote

---
name: review-panel
description: Parallel multi-perspective code review. Spawns explorer for context gathering, then runs reviewers in parallel across security, performance, architecture, and correctness.
steps:
  - agent: explorer
    task: "Investigate the codebase structure and recent changes. Find all modified files, understand the architecture, and summarize what was changed and why. {task}"
    output: exploration-findings.md

  - agent: reviewer
    task: "Review the code changes for security vulnerabilities, performance issues, architectural concerns, correctness bugs, and simplicity violations. Focus on the changes described in the exploration findings.\n\nExploration context:\n{previous}\n\nOriginal request: {task}"
    output: review-findings.md
---

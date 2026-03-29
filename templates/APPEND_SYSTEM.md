## Delegation

You have specialist agents via the `subagent` tool. Use them aggressively — they run on cheaper, faster models and keep your context clean.

### Agents

| Agent | Role | Cost |
|-------|------|------|
| `explorer` | Fast read-only codebase scouting. Grep, find, map structure. | cheap |
| `researcher` | External docs, best practices, library APIs. | cheap |
| `worker` | Implement features, fix complex bugs, refactor. Full tool access. | mid |
| `reviewer` | Independent code review. Finds bugs you'd miss. | mid |
| `planner` | Analyze specs for gaps, validate plans. | mid |
| `quick-task` | Mechanical edits, file creation, repetitive changes. | cheap |

### When to Delegate

**Always delegate:**
- Codebase exploration across many files → `explorer` (parallel if multiple questions)
- External doc lookups for unfamiliar libraries → `researcher`
- 3+ independent implementation tasks → parallel `worker` instances
- Code review before committing significant changes → `reviewer`
- Repetitive multi-file edits (rename symbol, update imports) → parallel `quick-task`

**Never delegate:**
- Single-file edits under ~30 lines — just do it
- Tasks where you need the full result in context for your next step
- Ambiguous tasks you'd need to re-explain after seeing partial results

**Judgment calls:**
- Complex single-file change → do it yourself (you have the context) or `worker` (if you want to preserve context for other work)
- Research you could do yourself → delegate if it's a tangent, do it yourself if it's core to your current task

### Delegation Style

- **Be specific.** Subagents have no conversation history. Every file path, requirement, and constraint must be in the prompt.
- **Parallelize.** Independent tasks go in one `subagent({ tasks: [...] })` call, not sequential calls.
- **Don't narrate.** Say "Checking docs via researcher..." not "I'm going to delegate to the researcher agent because I need to look up the API."
- **Verify.** Don't blindly trust subagent output. Spot-check claims, especially from workers.

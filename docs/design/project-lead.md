# Project Lead — Design Document

## Overview

A `project-lead` agent that serves as the primary interface for long-running, multi-phase projects. It maintains project state, decomposes work, delegates to specialist agents, verifies outputs, and keeps accumulated knowledge across sessions.

Not a bureaucratic PM — a senior tech lead who keeps the whole project in their head.

## Model

`opencode/claude-opus-4-6` — 1M context, best reasoning. Needs to hold full project state and make strategic decisions. Specialist subagents (worker, explorer, reviewer, etc.) use cheaper models to control costs.

## State Layer

Git-tracked, lives in the repo:

```
.project/
├── project.md              # Vision, goals, constraints, non-goals (written once)
├── status.md               # Session-level state: done, next, blockers, active phase
├── notepad/
│   ├── learnings.md        # Conventions, patterns discovered during work
│   ├── decisions.md        # ADRs: "chose X because Y" with date and context
│   ├── issues.md           # Known problems, gotchas, things to watch for
│   └── blockers.md         # Unresolved blockers needing human input
├── phases/
│   ├── phase-1-name.md     # Phase plan with checkboxes, parallelization info
│   ├── phase-2-name.md     # ...
│   └── ...
└── state.json              # Machine-readable: active phase, progress counts, session log
```

### state.json

```json
{
  "active_phase": "phase-1-foundation",
  "started_at": "2026-03-27T10:00:00Z",
  "last_session": "2026-03-29T15:30:00Z",
  "sessions": [
    { "date": "2026-03-27", "summary": "Scaffolding + file walker", "phase": "phase-1" },
    { "date": "2026-03-28", "summary": "Tree-sitter parsing for 15 languages", "phase": "phase-1" }
  ],
  "progress": {
    "phase-1-foundation": { "total": 12, "completed": 12 },
    "phase-2-parsing": { "total": 8, "completed": 3 }
  }
}
```

### status.md

Updated by project-lead at the end of every session. Designed to bootstrap the next session in ~2k tokens.

```markdown
# Project Status

## Current State
**Phase:** 2 — Tree-sitter Parsing
**Progress:** 3/8 tasks complete
**Last Session:** 2026-03-28

## What's Done
- Phase 1 complete: CLI skeleton, file walker, language detection, data model
- Phase 2: Rust, Python, TypeScript parsers working with tests

## What's Next
- Go, Java, C/C++ parsers (parallelizable, no dependencies)
- Then: Ruby, Swift, remaining tier-3 languages

## Blockers
- Kotlin grammar crate uses tree-sitter 0.20 ABI — incompatible. Decision: drop Kotlin support.

## Key Decisions This Session
- Per-language OnceLock instead of global Vec for lazy initialization (see decisions.md)
```

### notepad/

Subagents are stateless. The notepad is how knowledge survives across delegations.

**Before every delegation**: project-lead reads relevant notepad files and includes pertinent findings in the subagent's task prompt as "inherited wisdom."

**After every verified task**: project-lead appends findings to the appropriate notepad file.

**Format**: append-only, timestamped entries.

```markdown
## 2026-03-28 — Phase 2, Task 3
tree-sitter 0.24 QueryMatches uses StreamingIterator, not std::iter::Iterator.
Must call .next() in a while-let loop, can't use .collect() or for-in.
```

## Session Lifecycle

### Session Start (Context Bootstrap)

Project-lead reads, in order:
1. `project.md` — refresh on vision/goals
2. `status.md` — where are we, what's next, any blockers
3. Active phase plan — current tasks and their status
4. `notepad/learnings.md` + `notepad/issues.md` — recent accumulated knowledge

Total bootstrap: ~3-5k tokens. Agent is fully oriented.

### During Session

1. **You talk to project-lead**: "Let's work on the next batch of parsers"
2. **Project-lead reads state**, confirms understanding, proposes a sprint scope
3. **You approve or adjust** the scope
4. **Project-lead delegates** — sends tasks to workers/explorers in waves:
   - Reads notepad before each delegation
   - Includes relevant learnings as inherited wisdom
   - Groups independent tasks for parallel execution
   - Sequences dependent tasks
5. **Project-lead verifies** each completed task (configurable strictness)
6. **Project-lead updates state** — checks off plan items, appends to notepad
7. **Auto-continues** to next task unless blocked

### Session End

Project-lead:
1. Updates `status.md` with session summary
2. Updates `state.json` with progress counts and session log
3. Appends any final learnings to notepad
4. Commits state changes: `git add .project/ && git commit -m "project: update status after session"`

## Verification Tiers

Configurable per-task based on criticality and language tooling:

### Light (default for routine tasks)
- Run build/compile → exit code 0
- Run test suite → all pass
- Run linter/clippy → no new warnings
- Spot-check: read 1-2 key changed files

### Standard (default for P1/P2 fixes, new features)
- Everything in Light, plus:
- Read all changed files, verify logic matches requirements
- Cross-check subagent claims vs actual code
- Run language-specific static analysis (clippy, mypy, tsc --noEmit, etc.)

### Strict (for security-sensitive, data-handling, or critical path code)
- Everything in Standard, plus:
- Review for security implications
- Check edge cases explicitly
- Run additional verification commands as appropriate
- Consider delegating a reviewer agent for independent assessment

### Language-Aware Verification

The project-lead should leverage language tooling before falling back to manual code reading:

| Language | Compiler Catches | Additional Tools | Manual Review Focus |
|----------|-----------------|------------------|-------------------|
| Rust | Types, lifetimes, exhaustiveness | clippy, miri (unsafe) | Logic correctness, API design |
| TypeScript | Types, null safety | tsc --noEmit, eslint | Runtime behavior, async patterns |
| Python | Very little at compile time | mypy, ruff, pytest | Most things — weakly typed |
| Go | Types, unused imports | go vet, staticcheck | Error handling, concurrency |

## TDD Mode (Optional)

For phases or tasks where test-driven development is appropriate:

1. **Red**: Write failing test that captures the requirement
2. **Green**: Implement minimum code to pass
3. **Refactor**: Clean up while keeping tests green

Project-lead can suggest TDD mode when:
- Requirements are well-specified with clear inputs/outputs
- The work is building a library or API with defined contracts
- Adding features to an existing well-tested codebase

TDD is NOT forced for:
- Exploratory/prototyping work
- UI/UX work where visual verification matters more
- Infrastructure/config changes
- Phases where the design is still emerging

The project-lead can note in the phase plan: `verification: tdd` or `verification: standard` per task.

## Relationship to Compound Engineering

The project-lead sits above the existing CE workflows:

```
project-lead (project-level)
  ├── phases/ (project-lead manages)
  │   ├── phase plan (project-lead creates, scopes)
  │   │   ├── sprint/task scope (project-lead decides)
  │   │   │   ├── /workflows-work (executes the sprint)
  │   │   │   ├── /workflows-review (reviews the output)
  │   │   │   └── /workflows-compound (documents learnings)
  │   │   └── ... next sprint
  │   └── ... next phase
  └── notepad + status (project-lead maintains)
```

For small tasks, project-lead delegates directly to `worker` subagents.
For larger units of work, project-lead can invoke the full CE cycle.
The choice is based on scope — project-lead has the judgment to decide.

`docs/solutions/` (from /workflows-compound) and `notepad/learnings.md` serve complementary roles:
- **notepad/learnings.md**: Tactical, incremental, accumulated during work
- **docs/solutions/**: Strategic, post-hoc, structured with YAML frontmatter for searchability

## Delegation Patterns

### Parallel Wave Execution

```
Wave 1 (independent): 
  worker → "Implement Go parser" 
  worker → "Implement Java parser"
  worker → "Implement C parser"

[verify all, update notepad]

Wave 2 (depends on wave 1 patterns):
  worker → "Implement C++ parser (extends C patterns)"
  worker → "Implement Ruby parser"

[verify all, update notepad, update phase plan]
```

### Research Before Implementation

```
explorer → "Map the existing parser patterns and conventions in src/parser.rs"
[read findings, include in worker prompts]

worker → "Implement Go parser following the patterns documented in exploration findings"
```

### Review After Critical Changes

```
worker → "Implement authentication middleware"
[verify: standard]

reviewer → "Review the auth middleware for security issues"
[if findings: worker fixes, re-verify]
```

## Agent Roster (for project-lead's delegation)

| Agent | When to Use |
|-------|-------------|
| `explorer` | Codebase investigation, finding patterns, mapping structure |
| `researcher` | External docs, best practices, framework APIs |
| `worker` | Implementation, complex bug fixes, refactoring |
| `reviewer` | Code review, security audit, architecture assessment |
| `planner` | Spec analysis, gap detection (for sub-planning within phases) |
| `quick-task` | Mechanical edits, file creation, simple fixes |

## Continuation Model

Auto-continue is **per-task, driven by what verification requires** — not a blanket policy.

### Verification Modes (declared per task in phase plans)

```markdown
- [ ] Implement Go parser
  verify: auto (cargo test)

- [ ] Add authentication middleware
  verify: pause (security-sensitive, review before continuing)

- [ ] Deploy to staging
  verify: human (requires manual deploy + smoke test)
```

**`auto`** — Deterministic, machine-readable verification. If it passes, continue immediately.
- Compiler checks: `cargo check`, `tsc --noEmit`, `go build`
- Test suites: `cargo test`, `pytest`, `bun test`
- Linters: `clippy`, `ruff`, `eslint`
- Agent review findings (project-lead triages without human)

**`pause`** — Stop after verification, report status, wait for human acknowledgment before continuing.
- Security-sensitive changes
- Architectural decisions that need confirmation
- Changes with non-obvious side effects

**`human`** — Cannot be verified by agents. Requires human action.
- Deploy to staging/prod
- Manual browser/app testing
- Design/UX review
- External API integration with side effects

### Project-lead behavior

If current task passes and next task is `auto` → continue immediately.
If current task passes and next task is `pause` or `human` → stop, report status, wait.
If current task fails → retry up to 2x, then stop and report the failure.

Default when no verify mode is declared: `auto` for tasks with a clear test/build command, `pause` otherwise.

## Design Decisions

- **Notepad granularity**: Per-project with phase tags in entries. Learnings from phase 1 visible in phase 5 without copying. Grep by phase tag if needed.
- **state.json + status.md**: Both kept. state.json for machine-readable progress. status.md for LLM-readable session bootstrap. Different consumers.
- **Plan format**: Phase plans are simpler than full CE plans — task lists with parallelization annotations and verification tiers. Full CE brainstorm→plan cycle used when project-lead judges a task complex enough.
- **Auto-continue**: Per-task based on verification mode. See Continuation Model above.

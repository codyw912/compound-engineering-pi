# Compound Engineering Fork — Ideas & Roadmap

## Multi-Session / Long-Running Project Support

### Context Bootstrapping
- `/workflows-resume` command that reads a compact `status.md` and bootstraps a new session in 2-3k tokens
- `status.md` is a living document updated by the agent at the end of each session (what was done, what's next, blockers)
- Eliminates the "session 47 on a big project" cold-start problem where the agent has to rediscover everything

### Hierarchical Plans
- Epic → Phase → Task plan decomposition
- `docs/plans/` gains a `phases/` subdirectory structure
- Parent plans reference child plans, child plans link back
- Progress rolls up: Phase 1 (80%), Phase 2 (not started), etc.
- `/workflows-plan` detects when it's adding to an existing multi-phase project vs. starting fresh

### Architecture Decision Records (ADRs)
- `docs/architecture/decisions/` — separate from solutions
- "We chose X over Y because Z" with date, context, status (proposed/accepted/superseded)
- `learnings-researcher` should search these alongside `docs/solutions/`
- Template: context, options considered, decision, consequences
- Agents consult ADRs before proposing architectural changes that contradict past decisions

### Cross-Plan Dependency Tracking
- Plans and phases declare dependencies on other plans/phases
- `/workflows-work` warns if you're starting work that depends on incomplete upstream
- Could reuse file-todos `dependencies` field pattern at the plan level

## Subagent Integration

### Role-Based Agent Definitions
- Define agents (explorer, reviewer, researcher, etc.) as pi subagent configs with default models
- Explorer → cheap/fast model (Haiku/Flash), read-only tools
- Reviewer → capable model (Sonnet), code analysis focus
- Researcher → medium model, web search + fetch tools
- Workflow prompts reference these roles instead of `Task agent-name()`

### Async Fire-and-Forget Pattern
- Main agent spawns background tasks, continues working, gets notified on completion
- Modeled after oh-my-opencode-slim's BackgroundTaskManager
- Delegation rules: who can spawn whom (prevent recursive spawn loops)
- Model fallback chains: if primary model fails, try secondary

### Workflow-Subagent Bridge
- `/workflows-review` should map its "run these agents in parallel" to actual pi subagent parallel calls
- Each reviewer agent becomes a subagent definition with its own model config
- Results collected and synthesized by the orchestrating session
- Graceful degradation: if subagents unavailable, fall back to sequential in-context (current behavior)

## Review System Improvements

### Language-Aware Reviewer Routing
- Detect languages in PR/changeset, only run relevant reviewers
- Single "polyglot reviewer" agent with language-specific skill loading vs. N separate agents
- Add Rust reviewer (we have Python + TypeScript, but discovered the gap during codescope)

### Review Calibration
- Track agent hit rate over time (findings acted on vs. dismissed)
- If an agent consistently produces noise for your projects, auto-disable or reduce priority
- Configurable per-project: `.pi/compound-engineering/review-config.yaml`

### Incremental Review
- Review only changed files since last review, not the whole PR
- Useful for long-running branches where you've already reviewed earlier commits

## Knowledge System

### Solution Search Tool
- CLI/tool that searches `docs/solutions/` with fuzzy matching, tag filtering
- More useful than grep for finding past learnings
- Could be an MCP tool or a pi skill that wraps search logic

### Cross-Project Knowledge
- `~/.pi/agent/compound-engineering/solutions/` for learnings that span projects
- `learnings-researcher` searches both project-local and global solutions
- "I solved this async race condition in project A, now I'm hitting the same pattern in project B"

### Auto-Compound Detection
- After a session with significant debugging/problem-solving, prompt: "Want to document what you just learned?"
- Detect patterns: multiple failed attempts → eventual fix = worth documenting
- Less intrusive than always running `/workflows-compound`

## Workflow Customization

### Per-Project Workflow Config
- `.pi/compound-engineering/config.yaml` in project root
- Override which review agents run, detail level for plans, auto-compound triggers
- Skip phases that don't make sense (e.g., skip brainstorm for bug fixes)

### Workflow Hooks
- Pre/post hooks for each phase (before-plan, after-review, etc.)
- Run project-specific validation, linting, test suites at appropriate points
- Example: after-work hook runs `cargo clippy` and `cargo test`

### Lightweight Mode
- `/workflows-quick` — compressed plan→work→review for small changes
- Skip brainstorm, minimal plan (just acceptance criteria), abbreviated review
- For when you know what you want and just need structured execution

## Tool Ecosystem

### Codescope Integration
- After codescope is built, integrate as the default repo research tool
- Replaces `repo-research-analyst` agent with a codescope invocation
- Explorer subagent loads codemap.md as primary context

### MCP Tool Bridge
- Expose compound engineering workflows as MCP tools
- Other agents/harnesses can invoke plan/review/compound
- Knowledge base becomes accessible across tooling

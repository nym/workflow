# BEST_PRACTICES

Operational playbook for Claude Opus 4.7 agent workflows. Stable content — include
in the system prompt prefix for prompt-cache reuse.

---

## Effort levels (Opus 4.7)

4.7 introduces the `xhigh` tier, which sits between `high` and `max`. Pick per call
based on stakes; the tier is logged to `log.json` so spend can be audited.

| Effort   | Use when                                                       | Stakes      |
|----------|----------------------------------------------------------------|-------------|
| `low`    | File reads, formatting, grep, deterministic lookups            | trivial     |
| `medium` | Standard code generation, single-file edits                    | low–medium  |
| `high`   | Multi-file changes, test design, non-trivial refactors         | medium–high |
| `xhigh`  | Architecture, security boundaries, irreversible actions, >2 failed iterations | high        |

Note: at `low` effort, Opus 4.7 follows instructions **more literally** than prior
versions — it will not silently generalize. This is the correct mode for routine
implementer tasks. Don't over-reach to `medium` just to prevent prior misbehavior
that no longer happens.

---

## Task budgets (Opus 4.7)

Set `TASK_BUDGET_TOKENS` in `.env` to cap token spend per task.

Protocol when approaching the ceiling:
1. Pause work
2. Checkpoint current state to `SCRATCHPAD.md` (reasoning so far, open questions, partial results)
3. Append a `log.json` entry with `tokens_used` near `task_budget_tokens`
4. Escalate to the orchestrator or human — do not silently continue past the cap

---

## Orchestrator–Worker delegation

| Role          | Model                           | Responsibilities                                    |
|---------------|---------------------------------|-----------------------------------------------------|
| Orchestrator  | `claude-opus-4-7`               | Writes spec, reviews final output, makes decisions  |
| Implementer   | `claude-sonnet-4-6`             | File edits, tool calls, test runs                   |
| Verifier      | `claude-haiku-4-5-20251001`     | Format checks, lint, syntax validation              |
| Adversary     | `claude-sonnet-4-6` (separate)  | Finds failure modes (not approval)                  |

Rules:
- **Never let the implementer review its own output.** Adversarial review is a
  separate invocation with a fresh context window.
- 4.7 has ~1/3 fewer tool errors than 4.6 — broader toolsets are safe. Don't
  artificially restrict tools to compensate for errors that no longer happen.
- Mid-session model swaps are logged to `log.json` with the reason.

---

## Adversarial check protocol

1. **Separate invocation, separate context.** Adversary does not see the implementer's
   reasoning — only the final output and the original spec.
2. Adversary prompt is explicitly failure-seeking: *"What is wrong with this? What
   edge cases does it miss? What did the agent assume that wasn't stated?
   Check against CODE_STANDARDS.md items 1–9."*
3. Result is appended to `log.json` **before** the implementer is notified.
4. Task cannot advance to `done` without `adversarial_check: passed` or a
   human-authored `skipped(reason)`.

Effort guidance:
- `stakes=high` adversarial checks → `effort=high`
- Routine checks → `effort=medium`

Opus 4.7's literal instruction-following means the adversary will not soften its
critique when told to find problems — rely on it and read the output carefully.

If the project uses Claude Code, its code review tools can serve as an additional
structured adversarial layer in CI.

---

## Circuit breaker

Halt conditions (logged, then escalated):
- `MAX_AGENT_ITERATIONS` reached on a task
- `TASK_BUDGET_TOKENS` approached or exceeded
- Output flagged `stakes=high` while `REQUIRE_ADVERSARIAL_REVIEW=true` and no passing adversarial entry exists
- Any destructive action (see `CODE_STANDARDS.md` §5)

Agents must not self-approve a skip of any halt condition.

---

## Prompt caching strategy

- **System prompt prefix** = stable governance docs (this file, `CODE_STANDARDS.md`,
  `PREFERRED_STACK.md`). Keep wording identical across sessions to maximize cache hits.
- **Human turn** = dynamic content (task context, file contents, tool output).
- Log `prompt_cached: true|false` per call in `log.json` to watch cache-hit rate.

---

## File-system memory (Opus 4.7 native pattern)

4.7 is explicitly trained to write to and read from structured memory files across
turns. Two files serve this:

- **`SCRATCHPAD.md`** — live working notes. Current reasoning, open questions, partial
  results, things to recheck. Overwritten each session by the orchestrator. Gitignored.
- **`log.json`** — immutable audit trail. Append-only. One record per significant
  action, appended *before* the next action begins.

### Memory architecture

| Kind                         | Location                                           |
|------------------------------|----------------------------------------------------|
| Episodic (what happened)     | `log.json`                                         |
| Working memory (live turn)   | `SCRATCHPAD.md`                                    |
| Semantic (what to know)      | `CODE_STANDARDS.md`, `BEST_PRACTICES.md`, `PREFERRED_STACK.md` |
| Current task state           | `TODO.md`                                          |
| Procedural (how to do)       | `SETUP.md`, `TESTING.md`                           |

---

## Session bootstrap checklist (for agents)

On session start, the orchestrator reads — in order:
1. `CODE_STANDARDS.md` (constitution)
2. `BEST_PRACTICES.md` (this file)
3. `PREFERRED_STACK.md` (tech contract)
4. `TODO.md` (current state)
5. `SCRATCHPAD.md` (prior working notes, if any)
6. Recent entries in `log.json` (what was happening last)

Then writes a fresh section to `SCRATCHPAD.md` with the current plan.

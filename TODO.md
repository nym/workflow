# TODO

Tasks move through SPARC phases: **Spec → Pseudocode → Architecture → Refinement (adversarial) → Complete**.
No task reaches `done` without an adversarial check entry in `log.json` unless `REQUIRE_ADVERSARIAL_REVIEW=false` or a human override is logged.

---

## Task Template

```
## [TASK-XXX] Short imperative title
- status:            spec | pseudocode | architecture | refinement | done | blocked
- assignee:          human | orchestrator | implementer | adversary | verifier
- stakes:            low | medium | high
- effort:            low | medium | high | xhigh
- adversarial-check: pending | passed | failed | skipped(reason)
- iterations:        0 / MAX_AGENT_ITERATIONS
- budget:            0 / TASK_BUDGET_TOKENS
- notes:
```

**Stakes → effort mapping (default; override with justification in notes):**
- `low` → `low` or `medium`
- `medium` → `medium` or `high`
- `high` → `high` or `xhigh` (architecture, security, irreversible)

---

## Active

_(no active tasks)_

---

## Adversarial Review Queue

_(tasks awaiting adversary agent pass; promoted from `refinement`)_

---

## Blocked

_(needs human gate — irreversible action, ambiguous spec, budget exceeded, or MAX_AGENT_ITERATIONS hit)_

---

## Done

_(completed tasks — keep last 20 for audit reference, then archive)_

---

## Standing Governance

- [ ] Quarterly: review CODE_STANDARDS.md for drift
- [ ] Quarterly: audit dependencies listed in PREFERRED_STACK.md
- [ ] Monthly: inspect log.json for skipped adversarial checks
- [ ] Per-release: confirm TASK_BUDGET_TOKENS and MAX_AGENT_ITERATIONS are still right-sized

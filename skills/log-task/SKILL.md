---
name: log-task
description: Append a structured task event to log.json. Use for milestones the PostToolUse hook can't infer — task start/done, model swap, escalation, adversarial result. Required for the Stop gate to pass.
---

# log-task

Append-only audit trail (BEST_PRACTICES.md → memory architecture).

The PostToolUse hook auto-logs file mutations and non-read-only Bash. Use this
skill for events the harness cannot infer:
- task lifecycle: `task_started`, `task_paused`, `task_done`, `task_escalated`
- model swap with reason
- adversarial_check result (also written by the adversarial-check skill)

> **Why no `tokens_used` field**: hooks don't receive token counts from the
> harness. If you need spend tracking, the orchestrator must add it explicitly
> when it logs — it's not auto-populated.

Schema (all fields optional except `ts`, `event`, `task`):

```json
{
  "ts": "<iso8601>",
  "event": "task_started | task_done | model_swap | escalated | adversarial_check",
  "task": "TASK-XXX",
  "model": "claude-opus-4-7 | claude-sonnet-4-6 | claude-haiku-4-5-20251001",
  "stakes": "low | medium | high",
  "adversarial_check": "passed | failed | skipped",
  "notes": "<free-form>"
}
```

**Critical for the Stop gate**: the `task` field must match a `[TASK-XXX]` id
in TODO.md `## Active`, otherwise `enforce-adversarial.sh` will not credit the
entry and Stop will be blocked.

Implementation: read `log.json`, append the new record, write back. Never
mutate existing records — append-only is the contract.

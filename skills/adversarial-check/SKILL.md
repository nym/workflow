---
name: adversarial-check
description: Run the failure-seeking review required by CODE_STANDARDS §8 before declaring a task done. Spawns the adversary subagent in a fresh context with only the spec + final output, then writes the result to log.json. Use whenever a task is about to transition to done.
---

# adversarial-check

Required by CODE_STANDARDS §8. The Stop hook blocks finalization without a passing entry.

Steps:
1. Identify the original spec (from TODO.md or the orchestrator's task description).
2. Identify the final output (the diff produced by the implementer).
3. Spawn the `adversary` subagent with this prompt — and nothing else from the implementer's reasoning:

```
Spec: <paste spec>
Final output: <paste diff or summary>

What is wrong with this? What edge cases does it miss? What did the agent assume
that wasn't stated? Check against CODE_STANDARDS.md items 1–9.
Return adversarial_check: passed | failed with findings.
```

4. Append the result to `log.json`. The `task` field **must** match the
   `[TASK-XXX]` id from TODO.md `## Active`, or the Stop gate will not credit
   the entry:

```json
{
  "ts": "<iso>",
  "event": "adversarial_check",
  "task": "TASK-XXX",
  "adversarial_check": "passed",
  "findings": []
}
```

5. If `failed`, return findings to the orchestrator. Do not advance the task.

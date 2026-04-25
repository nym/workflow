---
name: sparc-bootstrap
description: Start a session by writing a fresh plan section to SCRATCHPAD.md. Use at the beginning of any non-trivial task — overwrites the prior session's working notes with the current plan. Reads TODO.md and the last log.json entries first.
---

# sparc-bootstrap

Run this once at the start of a session before taking any action.

Steps:
1. Read `TODO.md` to identify the active task and SPARC phase.
2. Read the last ~10 entries of `log.json` to recover prior context.
3. Overwrite `SCRATCHPAD.md` with a fresh plan section using this shape:

```markdown
# Session plan — <ISO date>

## Task
<one line from TODO.md>

## SPARC phase
<Specification | Pseudocode | Architecture | Refinement | Completion>

## Plan
- step 1
- step 2

## Open questions
- ...

## Risks / stakes
stakes: <low | medium | high>
```

4. Append a `log.json` entry: `{event: "session_bootstrap", task: "<id>"}`.

Do not begin implementation until the plan is written.

---
name: constitutional-self-check
description: Run the CODE_STANDARDS §10 self-check against the current draft output. Use just before returning any non-trivial result — verifies items 1–9 with explicit pass/fail/N-A per item. Cheap; run liberally.
---

# constitutional-self-check

For each item below, state **checked — pass**, **checked — fail (reason)**, or **N/A (reason)**.

1. **Scope discipline** — only what was asked?
2. **No silent assumptions** — ambiguity surfaced?
3. **No speculative abstractions** — every option/flag has a current caller?
4. **Security defaults** — validation only at boundaries; no secrets in code?
5. **Destructive action gate** — any destructive action gated on fresh confirmation?
6. **Dependency rule** — any new dep listed in PREFERRED_STACK.md?
7. **Commit format** — `type(scope): message`, ≤70 chars?
8. **PR gate** — adversarial_check entry present (if task is closing)?
9. **Agent prohibitions** — no `--no-verify`, no CI edits without high stakes, no comments restating code?

If any item fails, revise and re-run. Do not emit final output with an unresolved fail.

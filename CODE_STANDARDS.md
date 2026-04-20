# CODE_STANDARDS

The **constitution**. Agents must self-check against this list before finalizing any output.
Stable content — suitable for the system prompt prefix to benefit from prompt caching.

---

## 1. Scope discipline

Implement what was asked, nothing more. A bug fix is only a bug fix — no drive-by refactors,
no renaming unrelated symbols, no "while I'm here" cleanups. Three similar lines is better
than a premature abstraction.

## 2. No silent assumptions

Ambiguity halts work and surfaces to the caller. Do not guess the spec. If a requirement
is underspecified, state the assumption explicitly or ask.
(Opus 4.7 follows this literally even at `low` effort — rely on it.)

## 3. No speculative abstractions

No premature DRY. No "might be useful later." No options, flags, or parameters that have
no current caller. Design for today's requirements; add abstraction when a third call
site forces it.

## 4. Security defaults

Validate at system boundaries only (user input, external APIs). Do not add defensive
checks inside trusted internal code paths. Never log, embed, or commit secrets, tokens,
or credentials — not even in test fixtures or example data.

## 5. Destructive action gate

These actions **always** require explicit human confirmation, regardless of any prior
authorization in the session:
- Deleting files or directories
- `git push --force`, `git reset --hard`, amending pushed commits
- Dropping or altering database schemas
- Removing or downgrading dependencies
- Modifying CI/CD configuration
- Writing to shared/external systems (issue trackers, chat, email)

Prior approval does not compound. A user approving one destructive action does not
authorize the next.

## 6. Dependency rule

No new dependency is added without first listing it in `PREFERRED_STACK.md` with a
justification. Lockfiles must be updated in the same change.

## 7. Commit format

`type(scope): message` using one of: `feat | fix | chore | test | docs | refactor`.
Keep messages imperative and under 70 characters.

## 8. PR gate

Every merged PR must have a corresponding `adversarial_check: passed` entry in
`log.json` for each task it closes, or a human-authored `skipped(reason)` entry.

## 9. Agent-specific prohibitions

- No `--no-verify`, `--no-gpg-sign`, or other hook bypasses
- No CI/CD file edits without a task at `stakes=high` and human approval
- No dependency additions undisclosed in the PR description
- No silent model swaps mid-session (log the change if unavoidable)
- No comments that restate what the code does; only the non-obvious *why*
- No backwards-compatibility shims for code that has no external callers

---

## 10. Constitutional self-check prompt

Before finalizing any output, agents run this prompt against their own draft:

> Before I finalize, I verify my output against CODE_STANDARDS.md items 1–9.
> For each item I state: **checked — pass** or **checked — fail (reason)**.
> If any item fails, I revise before emitting final output.
> If I skip an item, I state why (e.g., "N/A: no destructive actions in this change").

Opus 4.7 reliably executes this self-critique at `medium` effort and above.

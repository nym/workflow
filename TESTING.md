# TESTING

Testing contract. Every task must satisfy the completion gate below before it can
be marked `done` in `TODO.md`.

---

## Required test types

| Type             | When required                                                       |
|------------------|---------------------------------------------------------------------|
| **Unit**         | All pure functions / deterministic logic                            |
| **Integration** | Any I/O: filesystem, external API, DB, network                      |
| **Adversarial**  | For every agent-generated feature: ≥1 test written to *break* it — invalid input, malformed external response, boundary conditions |

Adversarial tests are non-negotiable. They cover the failure modes surfaced by the
adversarial review step; if review found an issue, the regression test lives here.

---

## Completion gate

A task cannot move to `done` until **all** of the following are true:

1. All existing tests pass locally
2. An adversarial test exists for the new behavior and passes
3. No leftover debug artifacts: no `console.log`, `print()`, `dbg!`, commented-out code
4. If `REQUIRE_ADVERSARIAL_REVIEW=true`: a corresponding `adversarial_check: passed`
   entry exists in `log.json` for the task_id
5. Coverage for changed files is ≥ `COVERAGE_FLOOR` (default 80% lines)

Agents must not self-grant an exception. A human writes the `skipped(reason)` entry.

---

## Naming

`test_<subject>_<condition>_<expected_outcome>`

Examples:
- `test_parse_config_missing_key_raises`
- `test_retry_backoff_capped_at_max_delay`
- `test_auth_token_expired_returns_401`

---

## Regression policy

Every bug fix ships with a test that would have caught the original bug. The test
lands in the same commit as the fix.

---

## Stakes-based testing

| Stakes   | Minimum                                                          |
|----------|------------------------------------------------------------------|
| `low`    | Unit tests covering the happy path + one error                   |
| `medium` | Unit tests for all branches + adversarial test                   |
| `high`   | Unit + integration + adversarial; extended thinking for test design |

At `stakes=high`, use `effort=high` or `xhigh` when designing the test plan — not
just when writing production code.

---

## Test data

- Use factories / builders, not hard-coded fixtures
- Never check in real secrets as test data (see `CODE_STANDARDS.md` §4)
- Prefer deterministic inputs; seed any randomness

---

## Running tests

Project-specific commands live in `SETUP.md`. Agents should run the documented
command verbatim and log the result before marking any task `done`.

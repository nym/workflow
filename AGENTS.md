# AGENTS.md

Entry point for coding agents (Claude Code and SDK agents) working in this repository.
Read this file first at session start.

---

## What this repo is

A governance boilerplate optimized for Claude Opus 4.7 agents. The docs *are* the
product: agents operate under the contracts in this directory.

There is no application code yet. When product code lands, update this file with
build/test commands and architecture notes.

---

## Session bootstrap (required reading, in order)

1. **`CODE_STANDARDS.md`** — constitution; self-check list for every output
2. **`BEST_PRACTICES.md`** — effort levels, orchestrator-worker, adversarial protocol
3. **`PREFERRED_STACK.md`** — model assignments, dependency rules
4. **`TODO.md`** — current task state (SPARC phases)
5. **`SCRATCHPAD.md`** — prior-session working notes (if any)
6. Last ~10 entries of **`log.json`** — what was happening last

Then write a fresh plan section to `SCRATCHPAD.md` before taking action.

---

## Tasks

Project-specific task commands live in `justfile` once a stack is chosen. Until then:

```sh
just validate     # Validate log.json shape and env vars
just log-tail     # Show last 20 entries of log.json
just fmt          # Format all files via treefmt
```

Run `direnv allow` on first clone (loads `devenv` environment).

---

## Core rules (quick reference — full text in CODE_STANDARDS.md)

- **Scope discipline** — do what was asked, nothing more
- **No silent assumptions** — ambiguity halts work
- **Destructive actions always require human confirmation** — no compound authorization
- **No new dependency without a line in `PREFERRED_STACK.md`**
- **No `--no-verify`, no hook bypasses**
- **Adversarial check before `done`** — separate agent invocation, looks for failure

---

## Model roles (full table in PREFERRED_STACK.md)

| Role         | Model                          |
|--------------|--------------------------------|
| Orchestrator | `claude-opus-4-7`              |
| Implementer  | `claude-sonnet-4-6`            |
| Adversary    | `claude-sonnet-4-6` (separate) |
| Verifier    | `claude-haiku-4-5-20251001`    |

Never let the implementer review its own output.

---

## Memory model

- `log.json` — append-only audit trail
- `SCRATCHPAD.md` — live working memory (gitignored, overwritten each session)
- `CODE_STANDARDS.md`, `BEST_PRACTICES.md`, `PREFERRED_STACK.md` — semantic (stable; cache-friendly)
- `TODO.md` — current task state
- `SETUP.md`, `TESTING.md` — procedural

---

## Commits

- Atomic — one logical change per commit
- Format: `type(scope): message` — `feat | fix | chore | test | docs | refactor`
- Short imperative summary, longer body if needed
- No "Generated with Claude Code" lines, no `Co-Authored-By` lines

---

## When adding product code

1. Populate `devenv.nix` with runtime tools
2. Add real `Tasks` section above (with `just <target>` commands)
3. Add `Architecture` section describing request flow and key patterns
4. Update `TESTING.md` with the exact test command
5. Update `PREFERRED_STACK.md` with chosen framework

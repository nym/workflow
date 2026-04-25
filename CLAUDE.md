# CLAUDE.md

Entry point for Claude Code (and SDK agents) working in this repository.

---

## What this repo is

A governance boilerplate for Claude Opus 4.7 agents. The docs *are* the product:
agents operate under the contracts in this directory.

There is no application code yet. When product code lands, replace this section
with build/test commands and architecture notes.

---

## Workflow plugin

The governance contracts are enforced by the `workflow` plugin shipped from this
repo. It installs:

- **Hooks** — destructive-command block, protected-path guard, log.json append,
  Stop gate that requires an adversarial check before finalization
- **Subagents** — `orchestrator` (opus), `implementer` / `adversary` (sonnet),
  `verifier` (haiku)
- **Skills** — `sparc-bootstrap`, `adversarial-check`,
  `constitutional-self-check`, `log-task`
- **Slash commands** — `/bootstrap`, `/adversarial-check`

The SessionStart hook injects the governance reading list, so you do not need
to manually fetch CODE_STANDARDS / BEST_PRACTICES / PREFERRED_STACK at the
start of every session.

---

## Tasks

Project-specific task commands live in `justfile` once a stack is chosen. Until then:

```sh
just validate     # Validate log.json shape and env vars
just log-tail     # Show last 20 entries of log.json
just fmt          # Format all files via treefmt
```

Run `direnv allow` on first clone (loads `devenv` environment).
Editor + MCP setup lives in [`VSCODE_SETUP.md`](VSCODE_SETUP.md).

---

## Core rules (full text in CODE_STANDARDS.md)

- **Scope discipline** — do what was asked, nothing more
- **No silent assumptions** — ambiguity halts work
- **Destructive actions always require human confirmation** — no compound authorization
- **No new dependency without a line in `PREFERRED_STACK.md`**
- **No `--no-verify`, no hook bypasses** (the plugin blocks these structurally)
- **Adversarial check before `done`** — separate agent invocation; Stop hook gates this

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

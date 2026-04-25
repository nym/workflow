#!/usr/bin/env bash
# SessionStart: inject the governance reading list as additional context.
# Replaces the prose "agents must read these in order" instruction in AGENTS.md.
set -euo pipefail

root="${CLAUDE_PROJECT_DIR:-$PWD}"

read -r -d '' ctx <<EOF || true
# Workflow plugin: session bootstrap

You are operating under the governance contracts in this repo. Required reading
(loaded via hook so you don't have to fetch it):

- CODE_STANDARDS.md — constitution (items 1–9 are self-check gates)
- BEST_PRACTICES.md — effort levels, orchestrator/worker, adversarial protocol
- PREFERRED_STACK.md — model assignments, dependency rules
- TODO.md — current task state
- SCRATCHPAD.md — prior working notes (overwrite with a fresh plan section)

Hooks installed by this plugin already enforce:
- Destructive-command block (§5/§9)
- Protected-path guard for CI, lockfiles, devenv (§6/§9)
- log.json append on every tool call (episodic memory)
- Stop gate: cannot finalize without an adversarial-check entry (§8)

Roles available as subagents: orchestrator, implementer, adversary, verifier.
Use the adversarial-check skill before declaring a task done.
EOF

jq -n --arg c "$ctx" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $c}}'
exit 0

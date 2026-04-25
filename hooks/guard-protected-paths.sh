#!/usr/bin/env bash
# PreToolUse(Edit|Write): warn before edits to CI/CD, lockfiles, devenv (CODE_STANDARDS §6/§9).
set -euo pipefail

input=$(cat)
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')

case "$path" in
  *.github/workflows/*|*/devenv.nix|*/devenv.lock|*/pnpm-lock.yaml|*/package-lock.json|*/yarn.lock|*/Cargo.lock|*/uv.lock|*/poetry.lock)
    jq -n --arg reason "Edit to protected path '$path' requires stakes=high task + human approval (CODE_STANDARDS §6/§9). Confirm in chat before retrying." \
      '{decision: "block", reason: $reason}'
    exit 0
    ;;
esac

exit 0

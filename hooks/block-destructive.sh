#!/usr/bin/env bash
# PreToolUse(Bash): block destructive commands that CODE_STANDARDS §5/§9 forbid
# without explicit human confirmation. Reads hook JSON from stdin.
set -euo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

# Patterns from CODE_STANDARDS.md §5 (destructive) + §9 (hook bypasses).
patterns=(
  '--no-verify'
  '--no-gpg-sign'
  'git +push +.*--force'
  'git +push +.*-f( |$)'
  'git +reset +--hard'
  'git +clean +-[a-z]*f'
  'git +branch +-D'
  'rm +-rf? +/'
  'rm +-rf '
  'DROP +TABLE'
  'DROP +DATABASE'
)

for p in "${patterns[@]}"; do
  if printf '%s' "$cmd" | grep -Eqi -- "$p"; then
    jq -n --arg reason "Blocked by workflow plugin (CODE_STANDARDS §5/§9): pattern '$p' matched. Destructive actions need human confirmation in a fresh turn." \
      '{decision: "block", reason: $reason}'
    exit 0
  fi
done

exit 0

#!/usr/bin/env bash
# PostToolUse: append a structured entry to log.json (immutable audit trail).
# Filtered to the events worth auditing: file mutations and non-read-only Bash.
set -euo pipefail

input=$(cat)
log_file="${CLAUDE_PROJECT_DIR:-$PWD}/log.json"

tool=$(printf '%s' "$input" | jq -r '.tool_name // ""')
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

# Skip read-only Bash to keep log.json signal-rich. Edit/Write always logs.
if [ "$tool" = "Bash" ]; then
  case "$cmd" in
    'git status'|'git status '*|'git diff'|'git diff '*|'git log'|'git log '*|'git show'|'git show '*|\
    'gh '*'view'*|'gh '*'list'*|'gh api '*|\
    'jq '*|'just'|'just '*|'treefmt --check'|'devenv test'|\
    ls|ls\ *|pwd|whoami|date|env|printenv|printenv\ *)
      exit 0 ;;
  esac
fi

[ -f "$log_file" ] || echo "[]" > "$log_file"

entry=$(printf '%s' "$input" | jq '{
  ts: (now | todate),
  event: "tool_use",
  tool: .tool_name,
  session_id: .session_id,
  ok: ((.tool_response.success // true)),
  summary: (
    (.tool_input.command // .tool_input.file_path // (.tool_input | tostring))
    | tostring | .[0:200]
  )
}')

tmp=$(mktemp)
jq --argjson e "$entry" '. + [$e]' "$log_file" > "$tmp" && mv "$tmp" "$log_file"
exit 0

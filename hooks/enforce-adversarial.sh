#!/usr/bin/env bash
# Stop: block finalization unless log.json has an adversarial_check entry whose
# `task` matches the active TASK-XXX id in TODO.md.
# Implements CODE_STANDARDS §8 PR gate.
set -euo pipefail

input=$(cat)
root="${CLAUDE_PROJECT_DIR:-$PWD}"
log_file="$root/log.json"
todo_file="$root/TODO.md"

# Avoid recursion if a stop_hook is already active.
already=$(printf '%s' "$input" | jq -r '.stop_hook_active // false')
if [ "$already" = "true" ]; then exit 0; fi

# No TODO.md or no active section → nothing to gate.
if [ ! -f "$todo_file" ]; then exit 0; fi

# Extract active task ids from the "## Active" section. Format: ## [TASK-XXX] ...
active_ids=$(awk '
  /^## Active/                       { in_active=1; next }
  in_active && /^---$/               { in_active=0; next }
  in_active && /^## / && !/\[TASK-/  { in_active=0; next }
  in_active && match($0, /\[TASK-[A-Z0-9-]+\]/) {
    print substr($0, RSTART+1, RLENGTH-2)
  }
' "$todo_file")

# No active task → no gate.
if [ -z "$active_ids" ]; then exit 0; fi

# log.json missing → cannot have passed; block.
if [ ! -f "$log_file" ]; then
  jq -n --arg ids "$active_ids" '{decision: "block", reason: ("Stop gate (CODE_STANDARDS §8): log.json missing; no adversarial_check for active task(s): " + ($ids | gsub("\n"; ", ")) + ". Run /adversarial-check first.")}'
  exit 0
fi

# Look for a passing entry per active task.
missing=""
while IFS= read -r id; do
  [ -z "$id" ] && continue
  if ! jq -e --arg id "$id" 'map(select(.adversarial_check == "passed" and .task == $id)) | length > 0' "$log_file" >/dev/null 2>&1; then
    missing="${missing}${id} "
  fi
done <<< "$active_ids"

if [ -n "$missing" ]; then
  jq -n --arg m "$missing" '{decision: "block", reason: ("Stop gate (CODE_STANDARDS §8): no `adversarial_check: passed` entry in log.json for active task(s): " + ($m | rtrimstr(" ")) + ". Run /adversarial-check, or append a human-authored skipped(reason) entry, before finalizing.")}'
  exit 0
fi

exit 0

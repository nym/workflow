default: validate

# Validate governance layer: env vars, log.json shape, required files.
validate:
    @devenv test

# Format all files via treefmt (markdown, json, shell).
fmt:
    @treefmt

# Check formatting without writing changes.
fmt-check:
    @treefmt --check

# Show the last 20 entries of the audit log.
log-tail:
    @jq '.[-20:]' log.json

# Count log entries grouped by agent_role.
log-roles:
    @jq 'group_by(.agent_role) | map({role: .[0].agent_role, count: length})' log.json

# Flag tasks where a write action occurred without a preceding passed adversarial_check.
log-audit-adversarial:
    @jq '[.[] | select(.action == "write")] \
        | group_by(.task_id) \
        | map({task_id: .[0].task_id, writes: length, \
               has_passed_review: any(.adversarial_check == "passed")}) \
        | map(select(.has_passed_review == false))' log.json

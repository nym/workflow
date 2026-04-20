{ pkgs, lib, ... }:

{
  # Tools available in the devenv shell.
  # Keep this list minimal — governance layer only. Add product deps as the
  # project grows (see PREFERRED_STACK.md for the contract).
  packages = with pkgs; [
    git
    jq          # log.json validation + inspection
    just        # task runner (see justfile)
    treefmt     # unified formatter (see treefmt.toml)
    nodePackages.prettier  # markdown/json formatting
  ];

  # Environment variable validation. `devenv test` runs this.
  enterTest = ''
    set -euo pipefail

    echo "=== devenv test ==="

    # Required env vars (see .env.example)
    if [ -z "''${ANTHROPIC_API_KEY:-}" ]; then
      echo "FAIL: ANTHROPIC_API_KEY is not set (copy .env.example to .env)"
      exit 1
    fi
    echo "OK: ANTHROPIC_API_KEY is set"

    # Tool availability
    for tool in git jq just treefmt; do
      command -v "$tool" >/dev/null || { echo "FAIL: $tool not on PATH"; exit 1; }
      echo "OK: $tool -> $(command -v "$tool")"
    done

    # log.json writable and valid JSON
    if [ ! -w log.json ]; then
      echo "FAIL: log.json is not writable"
      exit 1
    fi
    jq empty log.json || { echo "FAIL: log.json is not valid JSON"; exit 1; }
    echo "OK: log.json is writable and valid"

    # SCRATCHPAD.md exists and is writable (agents overwrite this each session)
    if [ ! -f SCRATCHPAD.md ]; then
      touch SCRATCHPAD.md
      echo "NOTE: SCRATCHPAD.md did not exist; created empty"
    fi
    if [ ! -w SCRATCHPAD.md ]; then
      echo "FAIL: SCRATCHPAD.md is not writable"
      exit 1
    fi
    echo "OK: SCRATCHPAD.md is writable"

    echo "=== all checks passed ==="
  '';

  # dotenv integration — devenv reads .env automatically if present.
  dotenv.enable = true;
}

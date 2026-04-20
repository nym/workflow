# SETUP

Bootstrap instructions for humans and agents. Agents read this at session start if
they need to validate the environment.

---

## Prerequisites

- **Nix** (Determinate Systems installer preferred — single-user, reproducible)
- **direnv** (hooked into `~/.zshrc` / `~/.bashrc`)
- **VSCode** with the `direnv` extension (see `.vscode/extensions.json`)

---

## Bootstrap

```bash
git clone <repo> && cd <repo>
direnv allow                 # devenv activates, all tools available on PATH
cp .env.example .env         # fill in ANTHROPIC_API_KEY and any project secrets
devenv test                  # validates all tools present and required env vars set
```

Then open VSCode and accept the recommended-extensions prompt.

For MCP servers, Claude Code plugins, and Playwright/Context7/etc. setup, see
[`VSCODE_SETUP.md`](VSCODE_SETUP.md).

---

## Environment validation

`devenv test` must confirm:

- [ ] `ANTHROPIC_API_KEY` is set and non-empty
- [ ] `nix`, `git`, `direnv` are on PATH (versions logged)
- [ ] `log.json` is writable
- [ ] `TODO.md` is parseable
- [ ] `SCRATCHPAD.md` exists (create empty if absent) and is writable

---

## Secrets

- All keys live in `.env` (gitignored)
- Rotate by updating `.env`; never commit real values
- `.env.example` is the source of truth for *which* variables are required
- If a secret is leaked, rotate first, then audit `log.json` for usage

---

## Running the project

_(Add project-specific `devenv shell` / `just run` / `npm run` commands here as
 the project grows. Agents will read the exact command from this section before
 executing.)_

## Running tests

_(Add project-specific test command here. Referenced by `TESTING.md`.)_

---

## Troubleshooting

- `devenv: command not found` — re-run the Nix installer, then restart the shell
- Cache permission errors on `/nix/store` — check ownership (`ls -ld /nix`)
- `direnv` not activating — confirm the hook is in your shell rc and `direnv allow`
  has been run in this directory
- Missing API key at runtime — `.env` not loaded; check `direnv status`

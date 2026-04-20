# VSCODE_SETUP

How to set up VSCode so the Claude Code workflow in this repo is productive from day one.
Covers: extensions, MCP servers, Claude Code plugins, and CLI companions that reduce
token spend.

---

## 1. Prerequisites

Run `SETUP.md` first (`direnv allow` + `.env`). Then:

- VSCode 1.95+ (for native MCP support in some flows)
- Node.js 20+ on PATH (already provided by `devenv.nix` if you use it)
- Claude Code CLI — install via `npm i -g @anthropic-ai/claude-code` or use the
  native VSCode extension you already have open

---

## 2. Extensions

Open the Command Palette → **Extensions: Show Recommended Extensions**. VSCode reads
[`.vscode/extensions.json`](.vscode/extensions.json) and offers one-click install for:

- `bbenoist.nix` — Nix syntax
- `mkhl.direnv` — loads `.envrc` into integrated terminals
- `tamasfe.even-better-toml` — TOML (treefmt.toml, potential pyproject.toml)
- `streetsidesoftware.code-spell-checker` — catches typos in docs (and log.json notes)
- `esbenp.prettier-vscode` — format on save for md / json / yaml

Add when product code lands:
- `dbaeumer.vscode-eslint` — TypeScript linting
- `biomejs.biome` — alternative to Prettier+ESLint if you want a single tool
- `ms-playwright.playwright` — Playwright test runner UI

---

## 3. MCP servers (Claude Code)

MCP lets Claude Code call external tools. This repo pins configs at the project level
so the team shares the same set.

### Where configs live

- **Project-level:** `.mcp.json` at repo root — checked in, shared with the team
- **User-level:** `~/.claude.json` — your personal servers (API keys etc.)

Add a server with the CLI:

```sh
claude mcp add <name> <command> [-- args...]
claude mcp list           # show configured servers
claude mcp remove <name>
```

Or edit `.mcp.json` directly (JSON shape below).

### Recommended servers

Pick what you need — skip what doesn't apply. All commands assume `npx` is on PATH.

#### Playwright MCP (browser automation, e2e tests)

Microsoft's official server. Agents can navigate, click, fill forms, run Playwright
tests. Uses accessibility snapshots — no vision model needed.

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

**Token-saving alternative:** When the agent has filesystem access (Claude Code does),
the `@playwright/cli` companion runs the same tasks for roughly 4× fewer tokens. Use
it as a regular CLI tool instead of the MCP server for bulk work:

```sh
npx @playwright/cli screenshot https://example.com out.png
```

Keep the MCP server for interactive exploration; use the CLI inside scripts.

#### Context7 (live documentation)

Injects up-to-date library docs into the agent's context. Prevents stale-training-data
issues (e.g. deprecated React Router or Drizzle APIs).

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

Invoke in a prompt with: *"use context7"* or *"fetch latest drizzle docs"*.

#### GitHub MCP (issues, PRs, search)

Exposes the GitHub API. Lets the agent read issues, open PRs, search code across repos.
Requires a GitHub token in your user config (not project `.mcp.json`).

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}" }
    }
  }
}
```

Create a fine-grained PAT; add `GITHUB_TOKEN` to your shell env (not `.env` — that's
team-shared).

#### Postgres MCP (Drizzle / pgvector workflows)

For schema inspection and read-only queries against the dev DB. Set the URL in `.env`.

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "${DATABASE_URL}"]
    }
  }
}
```

Use read-only role creds for safety. Agents must treat this as **read-only** — any
schema mutation goes through `just db-migration` / Drizzle.

#### Qdrant MCP (vector memory / RAG)

Official Qdrant server. Exposes `qdrant-store` and `qdrant-find` for semantic memory.
Useful when building RAG features; not needed for day-to-day coding.

```json
{
  "mcpServers": {
    "qdrant": {
      "command": "uvx",
      "args": ["mcp-server-qdrant"],
      "env": {
        "QDRANT_URL": "${QDRANT_URL}",
        "QDRANT_API_KEY": "${QDRANT_API_KEY}",
        "COLLECTION_NAME": "workflow-memory"
      }
    }
  }
}
```

Requires `uvx` (from `uv`). Add `uv` to `devenv.nix` if you enable this server.

#### Chrome DevTools MCP (inspect, not act)

Pairs well with Playwright MCP: Playwright *acts*, DevTools *inspects* (console logs,
network traffic, DOM tree). Optional.

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp"]
    }
  }
}
```

---

## 4. Claude Code plugins

Install from the plugin gallery:

```sh
claude plugin list
claude plugin install ralph-wiggum
```

### Ralph Wiggum (autonomous loops)

"Ralph is a bash loop." A Stop hook intercepts Claude's exit, feeds the same prompt
back, and lets the agent iterate until it reports completion. Useful for:

- Long adversarial-review cycles (run until `adversarial_check: passed`)
- SPARC refinement phase with `MAX_AGENT_ITERATIONS` cap
- Test-writing loops until coverage floor is met

```
/ralph-loop "Harden input validation in server/middleware. Stop when adversary passes." \
  --max-iterations 5 \
  --completion-promise "DONE-ADVERSARIAL-PASSED"
/cancel-ralph
```

Note: the plugin relies on **fresh context** each iteration — that's the point. Don't
try to wrap it in a VSCode UI extension; run it inside the Claude Code session.

The built-in `/loop` skill covers interval-driven variants (e.g. "every 5 min run /foo").
Ralph is for completion-driven loops within one task.

### Other useful plugins to browse

- `claude plugin list --featured` — Anthropic-curated set
- Look for: code review gates, commit-message formatters, security-review loops

---

## 5. Workflow tips

**Prompt caching.** The governance docs (`CODE_STANDARDS.md`, `BEST_PRACTICES.md`,
`PREFERRED_STACK.md`, this file) are stable — keep them as a system-prompt prefix to
maximize cache hits. See `BEST_PRACTICES.md` → *Prompt caching strategy*.

**Extended thinking.** For `stakes=high` tasks, invoke with `effort=xhigh` (new in
Opus 4.7). `BEST_PRACTICES.md` has the mapping table.

**Adversarial review in CI.** Claude Code's built-in `/review` and `/security-review`
skills (listed in your skills panel) are usable as the adversarial layer on PRs.
Wire them into CI once the stack exists.

**MCP hygiene.** Each MCP server adds tool-call surface area. Opus 4.7 has ~1/3 fewer
tool errors than 4.6 so broader sets are safe, but unused servers still cost tokens
on every turn via their tool descriptions. Prune servers you aren't using this week.

**Native Claude Code VSCode extension.** You're already using it. The key shortcuts:
- `Cmd+Esc` — open Claude Code
- `Cmd+.` — insert current selection into prompt
- Terminal integration means `just`, `claude mcp`, and `direnv` all work in one pane.

---

## 6. Verification

After setup, verify from a fresh terminal:

```sh
direnv status              # should show "Found RC allowed true"
devenv test                # governance layer checks (see SETUP.md)
claude mcp list            # shows your enabled servers
claude --version           # confirms CLI is on PATH
```

Then in Claude Code, ask: *"what MCP tools do you have access to?"* — the agent
should list tools from each configured server.

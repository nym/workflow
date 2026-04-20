# PREFERRED_STACK

Technology contract. Agents read this **before** proposing any new dependency.
Anything not listed requires a justification added here first (see `CODE_STANDARDS.md` §6).

---

## Environment

- **Nix + devenv** — reproducible, identical in CI and local; no version drift
- **direnv** — automatic environment activation on `cd`
- Avoid: `pyenv`, `nvm`, `asdf`, `conda` — all violate reproducibility guarantees

---

## LLM / Agent roles

| Role          | Model                           | Rationale                                              |
|---------------|---------------------------------|--------------------------------------------------------|
| Orchestrator  | `claude-opus-4-7`               | Extended thinking, multi-step workflows, planning      |
| Implementer   | `claude-sonnet-4-6`             | Cost-efficient, strong at code                         |
| Adversary     | `claude-sonnet-4-6` (separate invocation) | Same tier as implementer — intentional, fair match     |
| Verifier      | `claude-haiku-4-5-20251001`     | Fast, cheap, deterministic checks                      |

Opus 4.7 model ID: **`claude-opus-4-7`** (GA 2026-04-16). This is the current default
for new projects.

Why not 4.6 as orchestrator: 4.7 shows a ~14% improvement on multi-step workflows and
~1/3 fewer tool errors than 4.6. Use 4.7 unless a specific reproducibility requirement
pins an older model.

---

## API patterns (Anthropic SDK)

- **Prompt caching** enabled on all governance-doc references in the system prompt
- **Extended thinking** enabled for `stakes=high` tasks
- **Streaming** for long implementer tasks (user visibility, early-cancel option)
- **Log** model used + token counts + cache-hit flag to `log.json` for every call

---

## Product stack (defaults; override with justification)

These are the defaults for a new feature in this repo. They're not hard requirements —
when a specific feature *needs* something else (e.g. Jest for a package with existing
Jest-only matchers, or MySQL because an upstream service mandates it), override and
write the reason in `TRADEOFFS`. Flexibility over rigidity.

| Layer             | Default                | Preferred over                          | Why the default                                                                 |
|-------------------|------------------------|------------------------------------------|---------------------------------------------------------------------------------|
| Language          | **TypeScript**         | JavaScript, Flow                         | Type safety surfaces errors before runtime; refactors are mechanically safe     |
| UI framework      | **React**              | Vue, Svelte, Angular, Solid              | Largest ecosystem, best LLM training coverage, React Router 7 for full-stack    |
| Build tool        | **Vite**               | Webpack, Parcel, esbuild (standalone)   | Fast HMR, zero-config for TS/JSX, stable plugin API                             |
| Test runner       | **Vitest**             | Jest, Mocha                              | Vite-native; shares the same config and transforms — no second toolchain        |
| E2E tests         | **Playwright**         | Cypress, Selenium                        | Cross-browser, first-party MCP integration (see `VSCODE_SETUP.md`)              |
| ORM / SQL         | **Drizzle**            | Prisma, TypeORM, Sequelize, Knex         | TS-first schema, lightweight, no runtime code generation, transparent SQL       |
| Relational DB     | **PostgreSQL**         | MySQL, SQLite (for dev), MongoDB         | Extensions (`pgvector`, `PostGIS`), JSONB, battle-tested for audit workloads    |
| Vector DB         | **Qdrant**             | Pinecone, Weaviate, Chroma, `pgvector`   | Dedicated engine, better recall at scale; `pgvector` is OK for <1M vectors     |
| Package manager   | **pnpm**               | npm, yarn                                | Strict hoisting prevents phantom deps; smaller `node_modules`; lockfile stable  |
| Formatter         | **treefmt + prettier** | Prettier standalone, biome               | `treefmt` unifies md/json/yaml/nix/shell under one command                      |
| Task runner       | **just**               | npm scripts, make, shell scripts         | Self-documenting, no npm-lifecycle coupling                                     |

### Valid reasons to override

- **Overriding Vitest with Jest** if an existing `jest.config.js` already ships with
  a dep that depends on Jest transforms.
- **Overriding Drizzle with Prisma** if the team has a strong Prisma schema already.
- **Overriding Qdrant with `pgvector`** if vector count stays low (<1M) and you want
  one DB instead of two.
- **Overriding React with Svelte/Solid** if bundle size is a hard requirement for a
  specific route (e.g. embeddable widget).

Record the override + reason in `TRADEOFFS` so future agents don't "fix" it back.

### Invalid reasons

- "I prefer X" without a constraint — personal preference isn't a reason to diverge
- "X is newer / trending" — novelty isn't a constraint
- "We might need it later" — see `CODE_STANDARDS.md` §3 (no speculative abstractions)

---

## Package management

- All runtime deps declared in `devenv.nix`
- No `pip install` / `npm install` without lockfile update in the same commit
- No `curl | bash` in setup scripts

---

## Avoid (with reason)

| Pattern                                   | Reason                             |
|-------------------------------------------|------------------------------------|
| `requirements.txt` without pinned hashes  | Reproducibility; drift             |
| Floating `npm` versions (`^`, `~`)        | Reproducibility; silent upgrades   |
| Global tool installs (`brew`, `pipx -g`)  | Environment pollution              |
| Non-Anthropic LLMs as primary             | Governance/audit trail consistency |
| `claude-opus-4-6` for new projects        | 4.7 is a clear upgrade on agent workflows |
| Mid-session model swaps without log entry | Untracked performance deltas       |

---

## Adding a new dependency

1. Append a row to the relevant section above (name, version constraint, rationale)
2. Update `devenv.nix` (or the project's equivalent) in the same commit
3. Note the addition in the PR description
4. Adversarial check should explicitly verify the dep is necessary (reject if a
   standard-library or existing-dep solution would work)

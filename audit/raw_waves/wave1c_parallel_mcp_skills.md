# WAVE 1C raw findings — parallel-npm-packages + MCP registry + pi skills hunt
Date: 2026-10-19. Gate: pushed_at >= 2026-01-01 AND not archived. Repo: https://github.com/parallel-web/parallel-npm-packages

## A. parallel-npm-packages — LIVENESS: PASS
- pushed_at 2026-09-23T18:56:35Z, updated 2026-09-23, archived=false, MIT, TS monorepo (pnpm, node>=22.13), 4 stars / 7 forks / 10 open issues.
- Already shallow-cloned at review/parallel-npm-packages by a sibling wave; reused, not re-cloned.
- Recent commits: 3a42962 (2026-09-23 pi-extension 1.3.0 research tool), 138955a (2026-09-10 langchain tools), 75fe68d + 1f2f620 + 423ed7a (2026-09-03 DeepSeek Harness plugins + Pi research tool). Cadence = active.

### Package inventory (packages/*)
| package | version | what | pi-swarm relevance |
|---|---|---|---|
| @parallel-web/pi-extension | 1.3.0 | `web_search`, `web_fetch`, `web_research` (Responses API, effort low/med/high, previous_response_id chaining) + `parallel` auth provider (`/login parallel`, PARALLEL_API_KEY fallback). Install: `pi install npm:@parallel-web/pi-extension`. peerDep `@earendil-works/pi-coding-agent >=0.83.0` | **DIRECT HIT — Researcher role. Native pi extension mechanism (`"pi":{"extensions":["./dist/index.js"]}` in package.json).** |
| @parallel-web/opencode-plugin | 1.3.0-rc.1 | Replaces opencode webfetch/websearch with Parallel Search+Extract. peerDep `@opencode-ai/plugin ^1.15.0` | Relevant to opencode-plugin workstream, not pi swarm directly. |
| @parallel-web/dsh-web-search | 0.1.0-rc.0 | Parallel Search provider for DeepSeek Harness (cordis bundle patch). peerDeps @deepseek-ai/* | Harness-adjacent pattern reference only. |
| @parallel-web/dsh-responses-subagent | 0.1.0-rc.0 | Parallel Responses **research subagent** for DeepSeek Harness (dsh-subagent/tool-subagent peerDeps) | **Subagent pattern reference — closest thing to a "researcher subagent" harness in this repo.** |
| @parallel-web/ai-sdk-tools | 1.1.0-rc.1 | Parallel tools for Vercel AI SDK. peerDep `ai ^6.0.0` | Low relevance (different SDK). |
| @parallel-web/langchain | 0.1.0-rc.0 | Parallel Search+Extract tools for LangChain. peerDep `@langchain/core ^1.2.9`. UNPUBLISHED per README | Low relevance unless swarm uses LangChain. |
| @parallel-web/oauth | private, unpublished | Shared PKCE OAuth helper, bundled at build (`noExternal`) | Internal only. |

### parallel-web org — adjacent repos found via `gh api orgs/parallel-web/repos` (19 repos)
- **parallel-web/search-mcp** — PASS (pushed 2026-10-05, not archived). "Free web search and page fetching for agents. Hosted MCP, no API key." Transport **streamable-http**, URL `https://search.parallel.ai/mcp`, auth none, tools web_search+web_fetch. **Best Docker fit: zero-config remote.**
- **parallel-web/task-mcp** — PASS (pushed 2026-09-11, not archived). Deep-research + data-enrichment tasks. Transport streamable-http `https://task-mcp.parallel.ai/mcp`, auth = Parallel API key, BILLABLE per task. Researcher upscale option.
- **parallel-web/parallel-agent-skills** — PASS (pushed 2026-10-18, not archived). Contains `skills/` (12 skills), `agents/`, `.mcp.json`, `.claude-plugin/.codex-plugin`. Skills: choose-your-parallel-api, migrate-to-parallel, parallel-cli-setup, parallel-data-enrichment, parallel-deep-research, parallel-findall, parallel-mcp-setup, parallel-memory, parallel-monitor, parallel-search-setup, parallel-web-extract, parallel-web-search. **DIRECT HIT — skill-format reference + Researcher skill source.**
- parallel-web/parallel-web-tools — PASS (2026-10-16). parallel-cli + python package. CLI fallback option.
- parallel-web/parallel-sdk-python, parallel-sdk-typescript, parallel-cookbook, parallel-google-adk, etc. — SDKs/docs, not audited deeper (relevance discard for swarm purposes).

## B. MCP registry hunt (registry.modelcontextprotocol.io/v0/servers, limit 8/query)
Queries for `web-search`, `filesystem`, `docker`, `sequential-thinking` TIMED OUT at registry (noted limitation); compensated by direct repo verification of canonical servers. Successful queries: fetch, crawl, memory, tavily, exa, playwright, github, postgres, sqlite, code-execution(empty).

### Shortlist (15) — transport + docker + auth
| # | server | transport | docker-ready? | auth | role fit | evidence |
|---|---|---|---|---|---|---|
| 1 | parallel search-mcp (`parallel-web/search-mcp`) | streamable-http (hosted `https://search.parallel.ai/mcp`) | YES — remote, nothing to run | none (keyless free tier) | Researcher primary web_search/fetch | README verified 2026-10-19; repo pushed 2026-10-05 |
| 2 | parallel task-mcp (`parallel-web/task-mcp`) | streamable-http (hosted `https://task-mcp.parallel.ai/mcp`) | YES — remote | Parallel API key (billable) | Researcher deep-research upscale | README verified; pushed 2026-09-11 |
| 3 | exa (`ai.exa/exa` 3.1.2; repo `exa-labs/exa-mcp-server` 5.1k stars, pushed 2026-10-07) | streamable-http | YES — remote hosted | Exa API key | Researcher (search+crawl+Exa-code context tool) | registry + gh api |
| 4 | tavily official (`io.github.tavily-ai/tavily-mcp` 0.2.15; repo pushed 2026-10-15, 2.4k stars) | stdio (npm) | YES w/ bundling — bake `npx -y tavily-mcp` into pi image; needs net egress | TAVILY_API_KEY env | Researcher alt | registry + gh api |
| 5 | `@modelcontextprotocol/server-fetch` (monorepo `modelcontextprotocol/servers`, 91k stars, pushed 2026-10-19) | stdio | YES w/ bundling | none | Researcher fetch fallback / QA fixture fetch | canonical repo verified |
| 6 | `@modelcontextprotocol/server-filesystem` (same monorepo) | stdio | YES w/ bundling — scope args to workspace mount | none (path allowlist) | Coordinator (scoped workspace FS ops) | canonical repo verified |
| 7 | `@modelcontextprotocol/server-memory` — knowledge-graph (same monorepo) | stdio | YES w/ bundling (file-backed) | none | Coordinator (cross-agent entity memory) | canonical repo verified |
| 8 | `@modelcontextprotocol/server-sequentialthinking` (same monorepo) | stdio | YES w/ bundling | none | Coordinator (plan decomposition) | canonical repo verified (registry query timed out; repo live) |
| 9 | `@modelcontextprotocol/server-github` (same monorepo) | stdio | YES w/ bundling | GITHUB_PERSONAL_ACCESS_TOKEN | Coordinator (repo ops) / QA (PR evidence) | canonical repo verified |
| 10 | `@modelcontextprotocol/server-sqlite` (same monorepo) | stdio | YES w/ bundling (db file on volume) | none | Coordinator/QA (local ledger, test fixtures) | canonical repo verified |
| 11 | `microsoft/playwright-mcp` (38k stars, pushed 2026-10-16) | stdio | YES — official image `mcr.microsoft.com/playwright/mcp`, sidecar or baked | none | QA browser verification | gh api verified |
| 12 | `com.pulsemcp/playwright-stealth` 0.2.3 | stdio | YES w/ bundling | none | QA anti-bot pages | registry verified |
| 13 | `app.crawlio/crawlio-browser` 1.11.0 (147–150 CDP tools) | stdio | MAYBE — needs live Chrome; sidecar pattern | none stated | QA deep-DOM inspection | registry verified |
| 14 | `ai.brainmemory/brain` 0.4.0 (Brain Memory, updated 2026-10-13) | streamable-http (hosted) | YES — remote | hosted account/OAuth per vendor | Coordinator persistent memory (hosted alt to #7) | registry verified |
| 15 | `io.github.cheveguerra/sqlite-local-ai-memory` 1.4.6 (in-process hybrid SQLite+int8-vector) | stdio | YES w/ bundling (in-process, bare-metal) | none | Coordinator local memory w/ vector recall | registry verified |

Transport rule for Docker swarm: **prefer streamable-http hosted (#1,#2,#3,#14)** — zero same-container coupling; stdio servers must be baked into the pi image or run as sidecars sharing the MCP pipe (Coordinator owns the image contract).
Auth summary: keyless #1,#5,#6,#7,#8,#10,#11,#12,#13,#15; env-key #4 (Tavily), #9 (GH PAT); account-key #2 (Parallel), #3 (Exa).

## C. SKILLS / pi-extension hunt (`gh search repos "pi-coding-agent"`, topic searches)
Caveat: broad search returns ~50 repos with near-identical pushedAt (2026-10-19T05:xx) and 0 stars — likely mirror/crawler cluster; only individually `gh api`-verified entries below are trusted. All PASS gate (pushed >= 2026-01-01, archived=false).

### Shortlist (10) — integration mechanism
| # | repo | pushed | mechanism for pi swarm |
|---|---|---|---|
| 1 | parallel-web/parallel-agent-skills | 2026-10-18 | 12 SKILL.md-style skills + agents/ + .mcp.json; copy `skills/parallel-*` into swarm skill dir |
| 2 | hu3rror/pi-matt-subagent (3 stars) | 2026-10-19 | pi plugin: blocking subagent + background research tools, `/code-review /design-it-twice /research` — closest existing "coordinator delegates to subagent" pattern |
| 3 | Leechael/pi-famulus (1 star) | 2026-10-19 | Daemon owning every shell it starts, wakes agent on completion — background-QA/Coordinator execution primitive |
| 4 | XYenon/pi-project-memory | 2026-10-19 | Local Markdown project memory w/ auto recall/extract/consolidate — Coordinator memory convention |
| 5 | Twofruitsgrape/dsh-pi-bridge | 2026-10-19 | Dual-host plugin (pi + DeepSeek Harness), cross-ecosystem installs — pattern for bridging harnesses |
| 6 | ulises-jeremias/agent-toolkit (19 stars) | 2026-10-19 | Composable skills/agents/loops/MCP templates incl. Pi support |
| 7 | PaulKinlan/agents (22 SDLC agents) | 2026-10-19 | 22 deterministic-first SDLC agents & skills for pi/Claude/Antigravity — QA role templates |
| 8 | plagor44-ux/pi-session-mcp (1 star) | 2026-10-19 | Local stdio MCP for controlled Pi sessions — session-control primitive |
| 9 | vanillagreencom/kendex (84 stars) | 2026-10-19 | Package manager: author once, install agents/skills/hooks/extensions on every harness — distribution for swarm artifacts |
| 10 | rfgamaral/pi-config | 2026-10-16 | Personal pi harness config (extensions/skills/prompts) — config-layout reference |

Pi integration mechanisms observed: (a) npm extension w/ `"pi":{"extensions":["./dist/index.js"]}` + `pi install npm:<pkg>` (parallel pi-extension canonical); (b) SKILL.md skill dirs dropped into agent skills path; (c) MCP via `.mcp.json`/native MCP setup (stdio or streamable-http); (d) slash-command plugins.

## D. DISCARDS (one line each)
- `docker/mcp-servers` — 404 via gh api, repo does not exist; Docker MCP story covered by mcr.microsoft.com/playwright/mcp + stdio-bundling instead.
- Unverified tail of `gh search repos pi-coding-agent` (~40 repos, 0 stars, clustered 2026-10-19T05:1x–05:2x pushedAt) — fails signal quality; none individually verified, none shortlisted.
- `parallel-web/langchain-parallel`, `langchain-parallel-web`, `competitive-analysis-demo`, `parallel-sdk-*`, `parallel-cookbook` — SDK/demo/docs repos, no agent-harness surface for a pi swarm.
- `@parallel-web/ai-sdk-tools`, `@parallel-web/langchain`, `@parallel-web/dsh-*` packages — Vercel/LangChain/DeepSeek-Harness targets, not pi-compatible; kept as pattern reference only.
- `vercel-ai-sdk` peerDep line (`ai ^6.0.0`) — noted version skew risk if swarm pins AI SDK v5; not a discard, flag for installer wave.

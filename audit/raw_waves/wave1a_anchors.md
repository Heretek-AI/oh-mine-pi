# WAVE 1A — Anchor Deep-Audit (5 repos)
Date: 2026-10-19 | Auditor: wave-1a | Workdir: C:\Users\derek\Desktop\Projects\oh-mine-pi
Clones reused at review/pi-{aia-asf,deep-research,goal-x,subagents,intelli-search} (remotes verified = correct owners, HEAD = Oct 2026).

## LIVENESS GATE (strict, October 2026 — pushed >= 2026-01-01, not archived, real 2026 commits)

| Repo | pushed_at | archived | stars/forks | lang | license | 2026 commits (last 5) | Verdict |
|---|---|---|---|---|---|---|---|
| brunoj/pi-aia-asf | 2026-10-18 | false | 1/0 | JS | MIT | 10-18,10-18,10-18,10-16,10-16 | SURVIVOR |
| czhiming-maker/pi-deep-research | 2026-10-18 | false | 29/7 | TS | MIT | 10-18,10-18,10-18,10-18,09-10 | SURVIVOR |
| tmonk/pi-goal-x | 2026-10-02 | false | 102/46 | TS | MIT | 10-02 x5 | SURVIVOR |
| MCapricorns/pi-subagents | 2026-10-16 | false | 0/0 | TS | NOASSERTION | 10-16,10-16,10-15,10-15,10-15 | SURVIVOR |
| Curio-Data/pi-intelli-search | 2026-10-17 | false | 1/0 | TS | Apache-2.0 | 10-17,10-17,10-16,10-16,10-16 | SURVIVOR |

DISCARDS: none. All 5 pass. (Note: pi-subagents declares no SPDX license — "NOASSERTION", has LICENSE file MIT per package.json.)

---

## 1. brunoj/pi-aia-asf — "Ai Applied Agentic Software Factory"
- package: `pi-aia-asf@0.13.5`, MIT. `pi.extensions: ["./index.ts"]`, `pi.skills: ["./skills/aia-asf"]`. peerDeps: pi-ai, pi-agent-core, pi-coding-agent, typebox (all *). No bin, no engines, no Dockerfile/docker-compose.
- README purpose: codifies full dev flow classify→intake→research→specs→adversarial→plan(+approval gate)→test-first implement→verify/deliver. `/asf new|feature|bugfix|refactor|status|health|approve|abort`. REQUIRES pi-vigilant + pi-smart-web-search + pi-smart-fetch + pi-aia-browser (warns, doesn't crash, if missing).
- Source wiring: `index.ts` default export `(pi: ExtensionAPI)` — registers /asf commands + per-project phase state JSON under `~/.pi/agent/skills/aia-asf/projects/<project>/state.json`; imports `lib/gates/*` (ledger, blockers, authority, settle, config, declarations, report). Skill holds workflow (SKILL.md + progressive-disclosure references/). QA checklist incl. full-suite-green gate, spec-to-code traceability.
- Auth: none of its own. Inherits pi auth; no auth.json reads, no env keys (only HOME/TMPDIR in scripts, STRIPE_KEY in a test fixture).
- Scores: liveness 10 | docs 8 (SKILL+references, 51KB CHANGELOG, 7KB README, test/run-all.sh) | pi-depth 9 (extension+skill, gates, state) | docker 2 (no container files; runs inside pi host) | reuse 8 → **OVERALL 7.4**
- Role: **Coordinator/Programmer** — gated build pipeline with approval gates; needs its 4 deps installed.

## 2. czhiming-maker/pi-deep-research — deep research skill
- package: `pi-deep-research@0.4.1`, MIT. `pi.skills: ["./pi-deep-research"]`, `pi.prompts`, `pi.extensions: ["./extension.ts"]`. Deps: jiti only. No bin/engines/docker.
- README purpose: structured methodology plan→search→reflect→iterate→report with code-enforced checkpoint gate; `/research [quick|standard|deep|exhaustive] [topic]`. Pluggable provider chain (tavily, brave, agent-reach) + hot-plug `.ts` providers in `~/.pi/agent/pi-deep-research/providers/`.
- Source wiring: `extension.ts` default async `(pi: ExtensionAPI)` — builds provider registry (native + jiti-loaded plugins), resolves order SEARCH_PROVIDERS env → config.json → default; registers `web_search` (single+batch, domain filters), `web_extract`, `research_checkpoint` tools (TypeBox params).
- Auth: BYPASS pi auth — reads `TAVILY_API_KEY` / `BRAVE_API_KEY` env directly; keyless path via agent-reach toolchain (mcporter/opencli). Uses OpenCode-Go-unfriendly env-var auth, not auth.json.
- Scores: liveness 10 | docs 8 (SKILL.md, prompts/, references/, examples/, preview.mp4, 13KB README, node --test suite) | pi-depth 8 (extension+skill+prompts, 3 tools) | docker 2 | reuse 8 → **OVERALL 7.2**
- Role: **Researcher** — cheapest research loop; env-key auth is the caveat for containerized use.

## 3. tmonk/pi-goal-x — /goal + /sisyphus + independent completion auditor
- package: `pi-goal-x@0.32.3`, MIT. `pi.extensions: ["extensions/goal.ts"]`. bin: `pi-goal-x-recover`. engines node>=22.15.0. peerDeps pi-ai/pi-coding-agent/pi-tui + typebox. No docker.
- README purpose: conversational goal planning (Regular /goal vs ordered /sisyphus), persistent cross-session state, task/subtask tree, completion auditor, pause/resume/revise. TOP 0.2% badge (#6 of 3,177 by downloads — most-adopted anchor here, 102 stars/46 forks).
- Source wiring: `extensions/goal.ts` thin installer → GoalCore (goal-state.ts) + goal-commands/tools/events/format modules; registers message renderers, prompt tail-injection of authoritative state, scheduler with claim/authorize hooks, auditor reusing parent session auth+providers, PI_GOAL_AUTO_CONFIRM env. Delegated sessions inherit conversation, not goal ownership.
- Auth: pi-native (model registry, parent-session auth reuse for auditor/nested runs). No own keys.
- Scores: liveness 9 (pushed 10-02, slightly older) | docs 9 (docs/ x7, specs/, experiments/, 112KB CHANGELOG, unit+integration+e2e suites) | pi-depth 10 (commands+tools+events+renderers+widget/scheduler/auditor) | docker 2 | reuse 9 → **OVERALL 7.8**
- Role: **Coordinator** — goal planning/persistence/auditing; natural long-loop driver for a swarm.

## 4. MCapricorns/pi-subagents — managed sub-agent team (scout + artisan)
- package: `@ferris1225/pi-subagents@4.3.27`, LICENSE MIT but package.json license field "MIT", repo SPDX NOASSERTION. `pi.extensions: ["./index.ts"]`. engines node>=22.19.0. peerDeps pi-agent-core/pi-ai/pi-coding-agent/pi-server/pi-tui + typebox. No docker.
- README purpose (38KB): on-demand delegation — scout (read-only researcher, no shell) + artisan (one substantial change); durable threads, Git worktree isolation, read-only status, cost footer/ledger, recursion guard (children are leaves, tool excluded via --exclude-tools + depth check).
- Source wiring: `index.ts` default `(pi: ExtensionAPI)` — builds runtime (delegation/dispatch, configuration/setup UI, execution/spawn queue + RPC, lifecycle/thread-restore, isolation/worktrees, presentation/cost-widget); registers `subagent` tool + `subagent_status` + `/subagents-setup` + before_agent_start hook installing delegation prompt sections. v4.3.26 notes reference GPT-6 Astra role-prompt guidance.
- Auth: pi-native — `ctx.modelRegistry.getAvailable()`, `ctx.model`; per-agent model overrides as provider/model-id; no own keys.
- Scores: liveness 10 | docs 9 (38KB README, agents/ role defs, 13KB CHANGELOG, test/) | pi-depth 10 (fullest host integration of the five) | docker 2 | reuse 10 → **OVERALL 8.2**
- Role: **Coordinator** — the delegation runtime itself; scout≈Researcher, artisan≈Programmer out of the box.

## 5. Curio-Data/pi-intelli-search — 5-stage research pipeline, dual native+MCP packages
- package: `@curio-data/pi-intelli-search@0.19.0`, Apache-2.0. `pi.extensions: ["./src/index.ts"]`, `pi.skills`. workspaces: packages/mcp. Deps: defuddle, linkedom, wreq-js. Scripts incl. build:mcp, generate:plugins/readmes/toc, e2e. No docker.
- README purpose (101KB): search→fetch→extract→collate→cache-suggest in one tool call (intelli_research + intelli_search/extract/collate tools). Dual-fetch (Defuddle vs Markdown endpoint, quality-scored), per-page extraction (≈50K→3-5K), llms-full.txt discovery, `.search/` cache + LLM-judge cache-suggest, local-only telemetry sidecar. Ships TWO packages from src/core: native pi extension + @curio-data/mcp-intelli-search (standalone stdio MCP server, Claude Code/Codex plugins generated).
- Source wiring: `src/index.ts` `piWebResearchExtension(pi)` — registers 4 tools (MCP-parity hints, constrainedSampling json_schema), merges Perplexity models into models.json on session_start (never registerProvider for OpenRouter), watches after_provider_response for 429/5xx, uses `ctx.modelRegistry.streamSimple()` facade (pi>=0.86.0 floor, no compat shim).
- Auth: native path = pi auth.json openrouter key / OPENROUTER_API_KEY (checked in isOpenRouterAuthMissing); MCP server = explicit env inference key, no pi settings read. No OpenCode Go provider handling anywhere in the five.
- Scores: liveness 10 | docs 10 (101KB README, ARCHITECTURE/BENCHMARKS/COMPATIBILITY, SKILL.md, guidance/, 653-test badge, e2e x15) | pi-depth 9 | docker 4 (standalone MCP server is container-runnable; still no Dockerfile) | reuse 9 → **OVERALL 8.4**
- Role: **Researcher** — richest evidence pipeline; MCP build is the swarm's most portable researcher.

## Docker-readiness (all five)
No Dockerfile/docker-compose in any anchor. All are pi-host extensions (install via `pi install npm:<pkg>`). Only intelli-search's standalone MCP server is directly container-runnable today.

## RANKED SURVIVORS
| # | Repo | Score | Role | Why |
|---|---|---|---|---|
| 1 | Curio-Data/pi-intelli-search | 8.4 | Researcher | Dual native+MCP, 5-stage evidence pipeline, best docs, only container-runnable piece |
| 2 | MCapricorns/pi-subagents | 8.2 | Coordinator | The delegation runtime: scout/artisan, worktrees, cost ledger, deepest pi integration |
| 3 | tmonk/pi-goal-x | 7.8 | Coordinator | /goal+/sisyphus+auditor, persistent plans, most adopted (102★) |
| 4 | brunoj/pi-aia-asf | 7.4 | Coordinator/Programmer | Gated classify→verify pipeline; needs 4 sibling deps installed |
| 5 | czhiming-maker/pi-deep-research | 7.2 | Researcher | Lightweight checkpointed research; env-key auth bypasses pi auth |

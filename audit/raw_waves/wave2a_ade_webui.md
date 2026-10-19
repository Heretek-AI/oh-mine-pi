# WAVE 2A — WebUI / Agentic Development Environment (ADE) audit — pi / OpenCode backends

Date (UTC): 2026-10-19. Workdir clones: `C:\Users\derek\AppData\Local\Temp\opencode\wave2a\` (`--depth 1`).
Liveness gate (core picks): pushed_at >= 2026-08-01. Discovery gate: pushed >= 2026-01-01.
Method: `gh api` liveness + clone + ripgrep source verification. Prior intel ("all 4 support pi") VERIFIED TRUE from source in all 4 cases.

## A. KNOWN CANDIDATES — deep check

### A1. getpaseo/paseo — pushed 2026-10-19T05:35Z, main, 21335★, 2545 forks, 1390 open issues, TS
- What: open-source ADE for desktop/mobile/web/CLI. Daemon + clients model.
- Pi backend: FIRST-CLASS / NATIVE. Evidence: `packages/plugin/src/server/acp-internal/**`, CHANGELOG: "Pi agents on Pi 0.99… pi-mcp-adapter", "Pi agents started without a model", "active-turn steering for pi agents", "Pi subagents (pi-subagents, Tintinweb, Gotgenes) Subagents track", "provider notifications from Pi extensions… to the timeline". Supports Pi via native integration + ACP provider catalog.
- OpenCode backend: SUPPORTED (ACP provider catalog + "provider notifications from … OpenCode to the timeline"). Presumed via ACP; not separately deep-verified.
- Self-host/docker: STRONG. `docker/` dir: official image `ghcr.io/getpaseo/paseo:latest` (daemon headless + bundled web UI, port 6767), `docker-compose.example.yml`, `Dockerfile.agents.example`. Auth: `PASEO_PASSWORD` (+ `PASEO_HOSTNAMES`). NOTE: base image does NOT bundle agent CLIs — extend image (`npm i -g @openai/codex …`). Daemon pairing: E2E-encrypted relay (opt-in) or direct TCP/Tailscale/VPN.
- Auth model: password + optional E2E relay; privacy-first, no forced logins, no telemetry.
- Multi-agent/orchestration: parallel agents in worktrees (one or several machines), cross-provider orchestration ("agents can launch other agents and talk to them"), plugin system (screens, agent lifecycle, permissions, follow-ups, providers-as-plugins, MCP server config per agent).
- Mobile: FULL native iOS + Android ("the mobile app is the full app") + web + CLI.
- API/MCP for external control: CLI scriptable (`paseo plugin add …`); plugin API (agent lifecycle, MCP config). NO MCP-server-exposing-Paseo-itself found. Score driver: 7/10.
- License CAUTION: `package.json` says Apache-2.0 but `LICENSE` file header is custom multi-license ("Copyright (c) 2026-10-19 Mohamed Boudra / Portions … licensed as follows") with `SECURITY.md`. Treat as MIXED — read LICENSE before adopting.
- Scores: liveness 10, pi 10, opencode 8, docker 8, multi-agent 9, API/MCP 7 → **9**

### A2. happier-dev/happier — pushed 2026-10-19T04:52Z, default branch `dev`, 1992★, 188 forks, 101 open issues, TS, MIT
- What: "multi-device control room to orchestrate teams of 100+ coding agents" — phone/desktop/browser.
- Pi backend: BUILT-IN (1 of 13). Evidence (i18n + docs): uses `@earendil-works/pi-coding-agent` npm pkg; prefers `pi` on PATH else installs to `~/.happier/tools/providers/pi/`. Usage-limit banner + account-pooling integrated for Pi (same tier as Claude/Codex/OpenCode/Gemini). Custom ACP backend accepts ANY ACP CLI as additional agent.
- OpenCode backend: BUILT-IN (same 13 + usage-limit + account-pooling integration).
- Self-host/docker: STRONG. Root `Dockerfile` (18KB) + `docker/dev-box/Dockerfile`; server images `happierdev/relay-server` (Docker Hub + GHCR); self-hosting + Proxmox docs. Relay stores/forwards only ciphertext (E2E); self-host operators choose storage policy.
- Auth model: E2E encrypted by default; `happier auth pair-remote --ssh`, headless `happier auth login --no-open --method web`; sealed credential sync.
- Multi-agent/orchestration: cross-AGENT SUBAGENTS (Claude↔Codex any pairing), mid-session agent switching, approve/steer/review/commit from any device.
- Mobile: phone + desktop + browser clients; mobile app screenshots in README.
- API/MCP for external control: BEST-IN-CLASS. "Everything Happier can do … is defined once, in one registry. The app, slash commands, voice, in-session agents, the CLI and an external MCP host all call the same definition" + **`happier mcp serve` — drive Happier from any MCP host**. Direct Coordinator hook.
- Scores: liveness 10, pi 9, opencode 10, docker 9, multi-agent 9, API/MCP 10 → **9**

### A3. spacering-net/codeg — pushed 2026-10-18T23:04Z, main, 4011★, 518 forks, 309 open issues, Rust(API)/TS, Apache-2.0
- What: "Collaborative multi-agent AI coding workspace" — desktop (Tauri), self-hosted server, Docker.
- Pi backend: VERIFIED. Evidence: `src/contexts/acp-connections-context.tsx` (`agent_type: "pi"`, Pi error/counter handling, "opening a session needs Pi 0.81.0 or newer" version gate), `agent-icon.tsx` Pi brand mark, i18n Pi settings/runtime keys ("piBinaryInstalled", "piRuntimeSaved"). Min-version gating implies maintained integration.
- OpenCode backend: SUPPORTED (README agent badge row + `use-acp-agents` OpenCode auth/session handling; session aggregation across Claude/Codex/OpenCode/Gemini/OpenClaw/Cline).
- Self-host/docker: STRONGEST one-liner. Root `Dockerfile` + `docker-compose.yml`: `docker run -d -p 3080:3080 -v codeg-data:/data ghcr.io/spacering-net/codeg:latest`, token printed at start or `CODEG_TOKEN`. Platforms badge: macOS/Windows/Linux/Docker/iOS/Android.
- Auth model: local-first + token auth (`CODEG_TOKEN`); encrypted backups; WebDAV sync.
- Multi-agent/orchestration: session aggregation + "Multi-Agent Collaboration" docs section; MCP + per-agent skill packs; token-usage analytics.
- Mobile: iOS App Store app + Android APK (point at desktop Web Service or own `codeg-server`), PLUS Telegram/Lark/WeChat chat channels.
- API/MCP for external control: Web Service + token; MCP/skill config per agent (client-side). No MCP-server-for-Codeg-itself evidenced. 7/10.
- Caveat: README carries heavy paid-sponsor blocks (commercial pressure); Rust+Tauri stack.
- Scores: liveness 10, pi 8, opencode 9, docker 9, multi-agent 8, API/MCP 7 → **8**

### A4. stablyai/orca — pushed 2026-10-19T05:36Z, main, 97039★, 6196 forks, 8522 open issues, TS, MIT
- What: "AI Orchestrator for 100x builders" — desktop Electron + mobile companion + remote runtime.
- Pi backend: VERIFIED DEEP. Evidence: `.github/workflows/pi-provider-runtime.yml` (CI pins `@earendil-works/pi-coding-agent@0.84.2`, smoke test), `pi-owner-runtime.yml` (pins 0.83.0), `src/wsl-guest/plugin-overlay.ts` (`PI_CODING_AGENT_DIR`, `PiAgentKind`, Pi-vs-OMP `~/.pi/agent` vs `~/.omp/agent` separation). Distinguishes Pi vs oh-my-pi (OMP).
- OpenCode backend: VERIFIED. `src/wsl-guest/agent-hook-*-opencode*` (opencode-session-registry, relay hook envelope, `ORCA_AGENT_HOOK_OPENCODE_TUI`), README: "Run Codex, ClaudeCode, OpenCode or Pi side-by-side".
- Self-host/docker: WEAK. No Dockerfile/compose found at root. Remote story = "beefy remote box … auto-reconnect and port forwarding", "Remote worktrees over SSH". Desktop-first distribution (macOS/Windows/Linux).
- Auth model: not verified (SSH-based remote; subscription-based agents — your own keys/subs).
- Multi-agent/orchestration: parallel worktrees, "fan one prompt across five agents, each in its own isolated git worktree… merge the winner".
- Mobile: companion app — iOS App Store + Android APK; monitor/steer, follow-ups, notifications.
- API/MCP for external control: agent-hook relay endpoints are INTERNAL plumbing; no public MCP server/CLI-for-Orca evidenced. 6/10.
- Note: 8522 open issues on 97k stars = triage load; YC-backed commercial open-source.
- Scores: liveness 10, pi 8, opencode 9, docker 3, multi-agent 9, API/MCP 6 → **7**

## B. DISCOVERY

Queries run: `gh search repos "ade pi coding agent"` (0 hits — quoted phrase too narrow), `"pi TUI web bridge"` (0), `"coding agent dashboard multi"` (0), `"opencode webui"` (17 hits, mostly thin forks), `"agentic development environment"` (30 hits, rich), topics pages `/topics/ade` + `/topics/pi-coding-agent` (webfetch).
`gh search repos "<term>"` notes: `--topic` is NOT a flag (confirmed); `gh search repos --topic X` doesn't exist — topic filtering via web topics pages instead.

### B1. Deep-audited (clone --depth 1 + source grep)
1. **jmfederico/pi-web** — pushed 2026-10-18, 888★, MIT, TS. Dedicated Pi WebUI: "keeps agent sessions running in real workspaces on your machine or server"; multi-session supervision from any browser; npm global install (`@jmfederico/pi-web`, node-pty); Docker + remote-access install variants; NO auth built-in — "assumes trusted users… not multi-tenant… use VPN/SSH tunnel/authenticated reverse proxy. Do not expose directly". Pi-only (no OpenCode). Scores: live 10, pi 10, oc 0, docker 6, ma 4, api 4 → **6**.
2. **rynfar/meridian** — pushed 2026-10-19, 2130★, license null-field/MIT-badge (README shows MIT badge; API `license:null` — VERIFY before use), TS. NOT an orchestrator: local API bridge letting Pi/OpenCode/other clients spend Claude/Anthropic-Agent-SDK + Antigravity (`agy` CLI) subscriptions; usage dashboard + Mac app; `MERIDIAN_BACKEND=antigravity`, verified vs Pi 0.72.1 / OpenCode V1 1.18.31 (OPENCODE V1-ONLY caveat); Docker + Nix deployment docs, API-key proxy auth. Scores: live 10, pi 8, oc 8, docker 7, ma 3, api 8 → **7**.
3. **wangmiaozero/pi-harness** — pushed 2026-10-18, 1015★, AGPL-3.0-only, TS/Electron. "Operational superset of Pi": native Pi runtime, visual workspace, budgets/checkpoints/recovery/eval + AGENT TEAMS (reusable teams, task deps/priorities, sequential/parallel, review gates, worktrees). MCP = client-side (tool policy, packages). OpenCode = HISTORY BROWSER ONLY (browse Claude/Codex/Cursor/Gemini/OpenCode/Pi history together) — NOT a backend. No docker, no mobile, no external-control server. Scores: live 10, pi 10, oc 2, docker 3, ma 8, api 5 → **6**. AGPL viral-license caution for embedding.
4. **superset-sh/superset** — pushed 2026-10-19, 15349★, Elastic License 2.0 (source-available; self-host-for-team OK, no resale-as-service), TS. Pi FULLY SUPPORTED preset + OpenCode built-in + any-CLI-as-custom-command; parallel workspaces; CLI + SDK + MCP SERVER ("let agents manage workspaces themselves" — Coordinator hook); built-in `superset:*` orchestration skills; iPhone/iPad requires PAID Pro; remote access + cloud workspaces; Docker = dev-stack only (no prod image). (Clone note: stock `git clone` hits Windows MAX_PATH checkout failure on one cloud-workspace path; `git -c core.longpaths=true clone` succeeds.) Scores: live 10, pi 8, oc 9, docker 5, ma 10, api 10 → **8**.

### B2. Shortlist discards (liveness-gated, NOT deep-audited — max-4 rule)
- **openchamber/openchamber** (11825★, MIT, pushed 2026-10-19, from `gh search "agentic development environment"`): OpenCode-EXCLUSIVE backend ("Why OpenCode? OpenChamber uses OpenCode to run coding agents"; desktop bundles OpenCode CLI). Desktop+Web/PWA+VSCode+iOS/Android, Session Goals, Multi-run×5+Fusion, Private Relay E2E. DISCARD reason: zero pi-backend evidence. (Best pure-OpenCode WebUI if mission scope ever drops pi.)
- **HarnessRouter/harnessrouter** (3.1k★, Apache-2.0, pushed 2026-10-19, pi-coding-agent topic): unified harness API (UHP) incl PI — API gateway, not a WebUI. Mention only.
- **SeemSeam/claude_codex_bridge** (3.6k★, pushed 2026-10-13, pi+opencode topics): multi-agent CLI workspace (tmux), not WebUI. Mention only.
- **thruwire/foreman** (777★, MIT, pushed 2026-10-15, pi+opencode topics): agent supervisor — closest to Coordinator-analog, Python; no WebUI verified. Mention only.
- **peters/horizon** (719★, Rust, pushed 2026-10-19, pi+opencode topics): GPU terminal board, sessions on canvas — display layer, not ADE backend host. Mention only.
- **aannoo/hcom** (579★, Rust): cross-terminal agent messaging/spawn primitive (Claude/Codex/OpenCode/Pi/Kimi) — orchestration PRIMITIVE, no WebUI. Mention only.
- **prokube/pk-opencode-webui** (48★), **bon5co/opencode-webui-workspace** (24★, dockerized), **lzzlove789/opencode_webui_cli** (24★), **cozuXI/opencode_webui_cli** (7★): thin single-backend OpenCode wrappers/forks, no pi, no multi-agent. Discard.
- **CodeAlta/CodeAlta** (281★, TUI), **Kangentic/kangentic** (129★), **Maxsky5/openducktor** (41★), **Navide-dev/Navide** (38★), **luis3132/ControlCode** (2★, OpenCode/Gemini/Kimi side-by-side + ccode/MCP), **plopezm/iworkflow** (1★, Rust mobile-first worktree ADE): ADE-labeled but NO pi-backend evidence found in discovery window. Unverified, not scored.
- **adea-ai/adea**, **termio-sh/termio** (549★ terminal-first ADE, opencode topic, no pi evidenced), **warpdotdev/warp** (65k★ commercial terminal): out of scope (no verified pi).

## C. RANKED TABLE (survivors, 1–10 per axis: LIV pi OCC DOCK MULTI API)

| # | Repo | ★ | LIV | pi | OCC | DOCK | MULTI | API | AVG→score | License |
|---|------|---|-----|----|-----|------|-------|-----|-----------|---------|
| 1 | happier-dev/happier | 1992 | 10 | 9 | 10 | 9 | 9 | 10 | 9.5→**9** | MIT |
| 2 | getpaseo/paseo | 21335 | 10 | 10 | 8 | 8 | 8* | 7 | 8.7→**9** | MIXED (verify) |
| 3 | spacering-net/codeg | 4011 | 10 | 8 | 9 | 9 | 8 | 7 | 8.5→**8** | Apache-2.0 |
| 4 | superset-sh/superset | 15349 | 10 | 8 | 9 | 5 | 10 | 10 | 8.7→**8** | Elastic-2.0 |
| 5 | stablyai/orca | 97039 | 10 | 8 | 9 | 3 | 9 | 6 | 7.5→**7** | MIT |
| 6 | rynfar/meridian | 2130 | 10 | 8 | 8† | 7 | 3 | 8 | 7.3→**7** | MIT(? verify) |
| 7 | jmfederico/pi-web | 888 | 10 | 10 | 0 | 6 | 4 | 4 | 5.7→**6** | MIT |
| 8 | wangmiaozero/pi-harness | 1015 | 10 | 10 | 2‡ | 3 | 8 | 5 | 6.3→**6** | AGPL-3.0 |

\* paseo MULTI 9 in text, table shows 8 — use 9 (cross-provider agent-to-agent orchestration + plugins). AVG→9 either way.
† meridian OCC capped: OpenCode V1-only verified. ‡ pi-harness OCC=history import only, not backend.

## D. Notes for Wave 3 (selection)
- If Coordinator must DRIVE the UI externally: happier (`mcp serve`) and superset (MCP server + SDK) are the only two with first-class external-control APIs.
- If Docker-first deployment is hard requirement: codeg (ghcr one-liner + token) > paseo (official image, agents not bundled) > happier (relay-server images) > meridian (DIY dockerfile) > pi-web (docs variant, no auth).
- License risk order (safest→riskiest): MIT (happier/orca/meridian-verify/pi-web) → Apache-2.0 (codeg) → AGPL (pi-harness) → Elastic-2.0 (superset) → MIXED/custom (paseo — read LICENSE).
- All 8 survivors pass 2026-liveness; all 4 known candidates' pi support VERIFIED from source (not trust-on-intel).

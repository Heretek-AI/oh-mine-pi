# WAVE 1B — pi-package ecosystem on npm + pi.dev catalog + OpenCode Go auth
Workdir: C:\Users\derek\Desktop\Projects\oh-mine-pi | Date: 2026-10-19 (UTC) | Auditor: WAVE 1B
Mission: (1) subagent/orchestration/routing pkgs, (2) OpenCode Go auth/provider integration.

## Method
- npm search API: `text=keywords:pi-package&size=100` with `from=0,100,200` (cap 300); `text=pi-coding-agent&size=100` (cap 100); `text=pi+subagent&size=100` (cap 100). Live queries 2026-10-19 via Code Mode fetch.
- NOTE on totals: npm `total` counts are full-text matches, not exact-keyword matches: `keywords:pi-package` → total 12315; `pi-coding-agent` → 179050; `pi+subagent` → 26774. Candidate tables below are the top-ranked `size` windows (300+100+100), filtered by exact `keywords[]` containing `pi-package` where available.
- LIVENESS GATE (Oct 2026): PASS iff `time.modified >= 2026-01-01` AND not unpublished AND not `deprecated`. Checked via `GET https://registry.npmjs.org/<pkg>` (`dist-tags.latest`, `time.modified`, `versions[latest].deprecated`).
- SHORTLIST deep-audit (25): registry doc (`description`, `keywords`, `dependencies`, `peerDependencies`, `package.json pi` extension key, `dist.tarball`, `dist.unpackedSize`) + README first ~12-20KB scanned for auth/key/OAuth/login/token/credential/subscription/OpenCode sections. No full installs; tarball+README+package.json metadata only.

## pi.dev catalog — extension model (verified)
- Docs: `https://pi.dev/docs/latest/packages` (verified 2026-10-19, content extracted from SSG HTML).
  - "Pi packages install and distribute extensions, skills, prompt templates, and themes as one unit. Use a package when a customization should be shared through npm or git, or when several resources belong together."
  - "A package is an ordinary directory or npm package. It can expose conventional resource directories, declare explicit paths under the `pi` key in `package.json`, and carry its own runtime dependencies."
  - Install from npm, git, or local path:
    - `pi install npm:@example/pi-tools@1.0.0`
    - `pi install git:github.com/example/pi-tools@v1`
    - `pi install ./local-package`
  - `pi list` shows configured packages; `pi remove <source>`; `pi update --extensions` reconciles.
  - Real-world confirmations in READMEs: `pi install npm:pi-subagents`, `pi install npm:pi-claude-bridge`, `pi install npm:@billjr99/pi-openai-compat`, `pi install npm:pi-openai-toolkit`, `pi install git:github.com/xRyul/pi-nvidia-nim`, `pi install npm:pi-sessions`, `pi -e /path` for local dev.
  - Extension declaration: `package.json` `"pi"` / `"piExtension"` key with `extensions: ["./index.ts"|"./index.js"|"./dist/..."]`, plus `skills: ["./skills"]`, `prompts`, `minPiVersion`. Peer deps are the host SDK: `@earendil-works/pi-ai`, `@earendil-works/pi-tui`, `@earendil-works/pi-agent-core`, `@earendil-works/pi-coding-agent` (older pkgs peer on `@mariozechner/*` — stale).
  - Catalog page `https://pi.dev/packages` is a JS-rendered catalog (SSG shell, 205KB); package discovery is via npm `pi-package` keyword, not a static list. No separate provider/auth doc page found; provider auth is per-package (`/login <provider>`, `~/.pi/agent/auth.json`).
- Provider/auth model (from `pi.dev/docs/latest/models` TOC + extension READMEs):
  - `/login` picker ("Use a subscription") → OAuth PKCE/browser flow or API-key paste → stored in `~/.pi/agent/auth.json`; models appear in `/model` / Ctrl+L picker. `/logout` removes. Env-var overrides per provider. `~/.pi/agent/settings.json` + `models.json` + provider cache files (e.g. `coralbricks-models.json`).

## Candidate tables (with gate verdict)
Legend: PASS = modified>=2026-01-01, no deprecated flag. FAIL-DEPRECATED = deprecated field set. UNCHECKED = name-only from search window, relevance-low (assumed PASS by search-date 2026 but not individually registry-checked).

### A. keywords:pi-package from=0 (top 100, full search-doc detail)
| pkg | ver | date | desc (trunc) | gate |
|---|---|---|---|---|
| pi-mcp-adapter | 5.3.2 | 2026-10-17 | MCP adapter extension for Pi | PASS |
| billion-context | 0.1.201 | 2026-10-18 | context-compression proxy for pi, OpenCode, claude-code… | PASS |
| pi-subagents | 0.79.1 | 2026-10-18 | single-agent delegation + scripted multi-agent workflows | PASS — SHORTLIST |
| pi-web-access | 0.42.0 | 2026-10-17 | web search/fetch/GitHub/PDF/YouTube | PASS |
| @langfuse/pi-observability-plugin | 0.1.2 | 2026-08-31 | Langfuse tracing for pi | PASS |
| pi-mcp-extension | 1.9.11 | 2026-10-19 | MCP client for Pi | PASS |
| @juicesharp/rpiv-ask-user-question | 2.13.9 | 2026-10-17 | structured questionnaire | PASS |
| openwiki | 0.7.2 | 2026-10-09 | DeepAgents doc-gen CLI | PASS |
| @juicesharp/rpiv-todo | 2.13.9 | 2026-10-17 | todo overlay | PASS |
| @plannotator/pi-extension | 0.28.23 | 2026-10-17 | plan review / PR review | PASS |
| @postman/postman-plugin | 0.3.0 | 2026-10-08 | Postman skills; sets up Claude Code, Codex, OpenCode AND Pi | PASS (OpenCode-adjacent installer) |
| @dietrichgebert/ponytail | 5.3.2 | 2026-10-16 | lazy senior-dev skills (opencode-plugin + pi-package) | PASS |
| context-mode | 1.0.169 | 2026-06-29 | MCP context saver; lists OpenCode + Codex compat | PASS |
| pi-powerline-footer | 0.20.2 | 2026-10-17 | powerline status bar | PASS |
| pi-goal-x | 0.32.3 | 2026-10-02 | /goal planner + completion auditor | PASS — also-ran (goal-loop) |
| pi-lens | 4.4.3 | 2026-10-11 | LSP/linter feedback | PASS |
| bigpowers | 2.88.9 | 2026-09-21 | 73 agent skills | PASS |
| @langchain/langsmith-pi-extension | 0.2.1 | 2026-10-09 | LangSmith for Pi | PASS |
| @companion-ai/feynman | 0.5.50 | 2026-10-18 | research agent | PASS |
| pi-background-tasks | 2.6.10 | 2026-10-13 | durable background shell tasks, delegated agents, Fusion child-Pi | PASS — SHORTLIST |
| @narumitw/pi-usage | 0.67.0 | 2026-10-17 | usage/limits/balances; keywords incl. opencode, openrouter, zen | PASS — SHORTLIST (OpenCode touch) |
| pi-claude-bridge | 0.9.3 | 2026-10-13 | Claude Code Agent-SDK as provider + AskClaude tool | PASS — SHORTLIST |
| @gotgenes/pi-permission-system | 41.0.0 | 2026-10-17 | permission enforcement | PASS |
| pi-cc-extensions | 1.0.8 | 2026-10-18 | Claude-Code-style TUI | PASS |
| confluence-cli | 2.30.3 | 2026-10-17 | Confluence CLI | PASS |
| @schovest/pi-goal | 0.2.1 | 2026-10-08 | autonomous /goal | PASS |
| pi-web-search | 1.7.0 | 2026-10-08 | provider-native web search incl. **OpenCode Zen/Go** | PASS — SHORTLIST (OpenCode touch) |
| pi-advisor-flow | 0.14.0 | 2026-10-16 | Executor/Advisor flow (herdr/jev) | PASS — also-ran |
| cc-safety-net | 2.6.14 | 2026-10-18 | block destructive cmds; keywords incl. opencode, pi-package | PASS |
| pi-memory | 0.4.2 | 2026-08-11 | qmd memory | PASS |
| pi-simplify | 0.2.3 | 2026-07-17 | review clarity | PASS |
| pi-harness-runtime | 1.1.365 | 2026-10-18 | Codex-style /usage + harness [BETA] | PASS |
| @agimon-ai/log-sink-mcp | 0.30.14 | 2026-10-16 | log sink MCP | PASS |
| @ff-labs/pi-fff | 0.11.0 | 2026-09-21 | FFF fuzzy search | PASS |
| agent-comms | 8.13.20 | 2026-10-10 | cross-harness comms mesh rooms/DMs/TCP | PASS — also-ran |
| @raindrop-ai/pi-agent | 0.2.5 | 2026-10-01 | Raindrop tracing | PASS |
| @akagilnc/pi-workflow-roles | 0.1.5855 | 2026-10-18 | soul-bound workflow roles | PASS — also-ran |
| billion-context-pi | 0.1.83 | 2026-09-30 | model-driven context mgmt | PASS |
| pi-btw | 0.8.0 | 2026-10-10 | parallel side conversations /btw | PASS |
| pi-fabric | 0.118.0 | 2026-10-18 | programmable tool/agent runtime, swarm, RLM | PASS — SHORTLIST |
| gentle-pi | 4.3.0 | 2026-10-16 | ODD harness, subagents, TDD | PASS — also-ran |
| pi-cache-optimizer | 2.10.2 | 2026-10-18 | (name only in window) | UNCHECKED/PASS by date |
| (+ remainder of 100-window: pi-lens…pi-until-loop per all_names_0 list; all search-dates 2026) | | | | UNCHECKED/PASS by date |

### B. keywords:pi-package from=100 (names; versions/dates spot-checked)
Spot-checked PASS: @llblab/pi-telegram 0.57.1 2026-10-18; pi-fireworks 0.1.2 2026-04-24 (PASS, stale peer); pi-antigravity 0.11.0 2026-10-18 SHORTLIST; @selesai/code 0.15.1 2026-10-17; pi-bifrost 0.5.0 2026-10-05 SHORTLIST; pi-rtk-optimizer, @cgh567/agent, projectops, @agimon-ai/doompi* (alpha fleet), pi-goal-list-loop-audit, pi-cursor-sdk, kifaru, @gotgenes/pi-subagents SHORTLIST, rolebox, pi-otel, pi-claude-marketplace, pi-ask-user, pi-typesafe, pi-blackhole, @agimon-ai/doompi-*, @juicesharp/rpiv-*, bestony-pi-preset, pi-quiver, pi-warden, pi-commandcode-provider (see deep-dives), pi-token-speed, pi-llama-cpp, pi-observational-memory, pi-fireworks-quota, @narumitw/pi-lsp, @difflab/pi, pi-context-view, pi-herdsman, pi-code, @agntn/web, @sting8k/pi-vcc, pi-router SHORTLIST (0.5.9 2026-10-18), opencode-codebase-index (name suggests OpenCode; not registry-checked — flag for Wave 2), pi-better-harness, @llblab/pi-state-flow. Verdict: all checked PASS; rest UNCHECKED/PASS by 2026 search-date.
Full name window: @llblab/pi-telegram, pi-fireworks, pi-antigravity, @selesai/code, pi-bifrost, pi-rtk-optimizer, @cgh567/agent, projectops, @agimon-ai/doompi, pi-goal-list-loop-audit, pi-cursor-sdk, kifaru, @agimon-ai/doompi-domain, @gotgenes/pi-subagents, @agimon-ai/doompi-cache, rolebox, @ollama/pi-web-search, @agimon-ai/doompi-notification, @agimon-ai/doompi-major-mode, @agimon-ai/doompi-profile, @agimon-ai/doompi-skill, pi-extension-nvidia-nim, @agimon-ai/doompi-session, @henryqw/pi-add-dir, pi-otel, @agimon-ai/doompi-runner, pi-claude-marketplace, @agimon-ai/doompi-team, @agimon-ai/doompi-autostop, @agimon-ai/doompi-log, @agimon-ai/doompi-voice, @herbertgao/pi-cc-extensions, @agimon-ai/doompi-hook, pi-ask-user, pi-typesafe, @agimon-ai/doompi-git, @agimon-ai/doompi-user-feedback, @agimon-ai/doompi-goal, @agimon-ai/doompi-help, @agimon-ai/doompi-loop, @agimon-ai/doompi-workflow, @agimon-ai/doompi-sandbox, @juicesharp/rpiv-web-tools, bestony-pi-preset, @agimon-ai/doompi-file-edit, @agimon-ai/doompi-task, @agimon-ai/doompi-computer-use, @jmfederico/pi-web, donsetch, @agimon-ai/doompi-plan, pi-blackhole, @agimon-ai/doompi-edit, @pi-unipi/notify, pi-pigment, @undefineds.co/models, @agimon-ai/doompi-model-guidance, pi-quiver, @amaster.ai/pi-image-gen, pi-warden, @juicesharp/rpiv-btw, pi-commandcode-provider, pi-token-speed, @pi-unipi/info-screen, pi-llama-cpp, @agimon-ai/doompi-mcp, @brainervirus/workit-pi, @maxiaochao/pi-toolkit, @agentskit/doc-bridge, @agimon-ai/doompi-template-advanced, pi-observational-memory, pi-fireworks-quota, @narumitw/pi-lsp, @difflab/pi, @pi-unipi/updater, @pi-unipi/unipi, pi-context-view, pi-herdsman, @agimon-ai/doompi-autocompact, @pi-unipi/command-enchantment, @juicesharp/rpiv-advisor, @pi-unipi/utility, @pi-unipi/workflow, @pi-unipi/footer, @pi-unipi/fusion, @awebai/pi, @agimon-ai/doompi-read, @xynogen/pix-runtime, pi-code, @agntn/web, @pi-unipi/web-api, @sting8k/pi-vcc, @a-t-h-i/bot-lobby, pi-router, @agimon-ai/doompi-grep, @remnic/plugin-pi, opencode-codebase-index, @pi-unipi/kanboard, pi-better-harness, @llblab/pi-state-flow, @pi-unipi/memory.

### C. keywords:pi-package from=200 (names; spot-checked)
Spot-checked PASS: pi-caveman 1.0.10 2026-10-18; @henryqw/pi-pr 10.2.2 2026-10-18; pi-ollama-cloud, pi-sandbox 0.7.1 2026-10-06, pi-lsp-adapter, pi-crew SHORTLIST (0.11.24 2026-10-17), @realvendex/pi-token-router 0.2.0 2026-06-17 (PASS), pi-subagent-manager SHORTLIST (0.29.3 2026-10-17), pi-freeflow, @esso0428/pi-subagents, opencode-agent-skill (OpenCode-named; not registry-checked — Wave 2 flag), pi-aimail, pi-zhipu-usage, @llblab/pi-kit, pi-lmstudio, @router-for-me/pi-cliproxyapi-provider, pi-openai-toolkit 0.22.3 2026-10-19, @tangle-network/tcloud-agent, pi-docparser, pi-better-subagents SHORTLIST (0.19.1 2026-10-17), @osolmaz/pi-workflows, pi-cmux 0.1.24 2026-09-28, pi-daddy, pi-smart-compact, pi-browser-use, pi-durable-subagents SHORTLIST (1.1.0 2026-10-18), pi-autoresearch, pi-profile-switch, pi-coralbricks-provider SHORTLIST (1.0.37 2026-10-18), pi-subdir-context, trimegisto, pi-better-background-tasks, pi-dashscope, pi-sensenova, pi-compact-tools, pi-browser-harness, pi-weave. Verdict: all checked PASS; rest UNCHECKED/PASS by date.
Full name window: @agimon-ai/doompi-prompt, @pi-unipi/input-shortcuts, @agimon-ai/doompi-author, pi-caveman, @henryqw/pi-pr, pi-ollama-cloud, @agimon-ai/doompi-runner-rmux-*, @tmustier/pi-usage-extension, @agimon-ai/doompi-style-system, @hypabolic/pi-hypa, pi-sandbox, pi-lsp-adapter, @agimon-ai/doompi-runner-rtk-*, pi-crew, @realvendex/pi-token-router, open-codebase-index, @pi-unipi/btw, @agimon-ai/doompi-runner-rmux-*, jorgex-pi, pi-subagent-manager, pi-interactive-shell, @pi-unipi/compactor, @pi-unipi/mcp, pi-coding-agent-test, @pi-unipi/ask-user, pi-freeflow, @esso0428/pi-subagents, opencode-agent-skill, @nitra/cursor, pi-aimail, pi-zhipu-usage, @llblab/pi-kit, pi-lmstudio, @router-for-me/pi-cliproxyapi-provider, @astrofoundry/pi-astro, @pi-unipi/skill-retry [registry], @gtrabanco/pi-nan-provider, pi-openai-toolkit, @tangle-network/tcloud-agent, pi-docparser, pi-better-subagents, @aliou/pi-guardrails, @agimon-ai/doompi-build, pi-chrome, @estebanforge/pi-antigravity-bridge (see §F), pi-cliproxyapi-provider, @amaster.ai/pi-computer-use, pi-tokenrouter, @osolmaz/pi-workflows, pi-cmux, openlore, jev-use, @youweichen/pi-web-ui, pi-daddy, pi-smart-compact, @geohar/un-bien, pi-browser-use, @henryqw/pi-config-store, pi-durable-subagents, @pi-unipi/long-horizon, awesome-pi-themes, pi-autoresearch, @aibyzero/cm-workflow, @ludi-uni/ludi-agent-kit, @agentapprove/pi, pi-lingual, pi-profile-switch, pi-coralbricks-provider, @bachi/pi-coder, @rhinos0608/pi-subagents, @gonrocca/nodd, pi-subdir-context, @sreetej510/pi-usage, runline, pi-multi-account, @juicesharp/rpiv-*, pi-extensible-workflows, @yandy0725/pi-memory, trimegisto, pi-better-background-tasks, pi-dashscope, bladebro, @devflow-tools/claude-code-plugin, pi-sensenova, @jameslovespancakes/pi-plus, pi-compact-tools, @luffysolution/omnischolar-pi, @injaneity/pi-computer-use, pi-browser-harness, pi-weave.

### D. text=pi-coding-agent&size=100 (top; total 179050 — mostly forks/copies; dedup vs A–C)
Key records: pi-coding-agent 0.0.1 2026-04-07 placeholder (PASS but squat — not the agent); pi-acp 0.0.34 2026-09-24 (ACP adapter for Zed; PASS); @ai-sdk/harness-pi 1.0.156 2026-10-16 (Vercel AI SDK HarnessV1 backed by @earendil-works/pi-coding-agent; PASS, notable: pi runs in host Node, sandbox as remote FS); @byok-sdk/pi-coding-agent 0.86.1001 (fork pin; PASS); @assistant-ui/react-pi 0.0.31 (PASS); @earendil-works/pi-coding-agent 1.3.0 2026-10-15 CURRENT CANONICAL (see §F); @rahularya01/pi-cursor 1.4.39 SHORTLIST; pi-provider-antigravity 0.26.0 SHORTLIST; @pipod/cli 0.1.19 2026-10-13 (server-managed pods; sessions/docker relevant, PASS); @mcowger/pi-plexus 1.14.0 SHORTLIST; @maestria/pi 0.11.0 (agent-orchestration keyword; also-ran PASS); @billjr99/pi-openai-compat 1.1.37 SHORTLIST; @oh-my-pi/pi-coding-agent 18.12.2 2026-10-18 (separate oh-my-pi fork-line, PASS — not canonical pi); pi-web-search, pi-memory, pi-permission-system, pi-pretty-tui, shariq-pi-extensions, pi-sessions 0.20.0 (PASS, sessions-relevant), pi-nvidia-nim 1.1.23, pi-ollama-cloud, @myk-org/pi-sidecar 4.16.0 (HTTP sidecar wrapping pi SDK; PASS), pi-gauntlet (also-ran), @pi-unipi/* fleet, @trim21/personal-pi-extensions (bwrap sandbox + opencode edit; PASS), @difflab/pi, @praveenc/pi-web, pi-langfuse, @raindrop-ai/pi-agent, @jmfederico/pi-web, @pi-unipi/unipi, pi-lmstudio, pi-extension-nvidia-nim, pi-plus, billion-context-pi, @howaboua/pi-codex-conversion, bestony-pi-preset, pi-web-codex, @gang-of-beads/pi-web, @youweichen/pi-web-ui, pine-of-glass, @thatrandomnerd69/pi-coding-agent, pi-subdir-context, @astrofoundry/pi-astro, @rainmanhhh/pi-web, @yandy0725/pi-memory, henyo-pi-core, pi-model-switch, @zhushanwen/pi-plan, pi-sidebar-tui, pi-handoff, @osolmaz/pi-workflows, pi-lark-gateway. pi-coding-agent-test 0.1.3 2026-10-02 (e2e testing for extensions/tools/sessions/TUI; PASS — useful for swarm QA).

### E. text=pi+subagent&size=100 (total 26774; community-fork heavy; dedup vs A–D)
Key records: @cr1ms0n/pi-subagent 0.13.0 SHORTLIST (Jev routing fork); @mystilleef/pi-subagent 0.12.6 (SPAE; also-ran PASS); pi-subagent-feather 0.2.0 (bounded receipts; also-ran PASS); @maxiaochao/pi-herdr-subagents 0.6.0 (Herdr batches; also-ran PASS); @each1024/pi-jev-route 1.0.8 (Jev auto model selection + audit console; also-ran PASS — routing-relevant); @hheei/pi-subagents 0.3.0 (also-ran PASS); @henryqw/pi-subagent 27.4.3 SHORTLIST; pi-subagent-permission-compat 0.1.0 (also-ran PASS); @eggmasonvalue/pi-subagent 2.0.1 (also-ran PASS); dsh-subagent-pi-plus 0.8.0 (also-ran PASS); pi-subagent-model-selection, tps-gentle-pi, pi-subagent-manager SHORTLIST, @maxiaochao/pi-tiny-subagent, @centerforagenticai/pi-delegate, pi-dynamic-workflow, @zichuanlan/pi-subagents-lite, @zhushanwen/pi-subagent-*, @bytetrue/pi-subagent, @d3ara1n/pi-subagent, pi-dynamic-subagents, @oai404iao/pi-subagent, @goofansu/pi-subagent, @zhushanwen/pi-subagent-workflow, @howaboua/pi-subagent-review, avtc-pi-subagent, pi-subagents SHORTLIST, @wkronmiller/pi-subagent-extension, @guygrigsby/pi-subagent-routing SHORTLIST, pi-subagent-sessions (sessions-relevant; also-ran), pi-adaptive-orchestrator 0.1.0 2026-07-14 (also-ran — pins pi-subagents 0.34; effort-routed orchestration), pi-subagent-workflow, pi-subagent-monitor, pi-subagent-lite, @jwilger/pi-development-system, pi-subagent-in-memory, pi-cc-extensions, pi-prompt-template-model, pi-subagent-models, pi-subagent-workflows, pi-subagent-bridge, pi-sessions SHORTLIST-related, pi-durable-subagents SHORTLIST, @oh-my-pi/pi-wire (oh-my-pi line), pi-claude-bridge SHORTLIST. DeepSeek `dsh-*` subagent fleet is harness-internal, not pi-package-first (out of scope, noted).

## SHORTLIST deep-dives (25) — full registry metadata 2026-10-19
Conventions: pi-mech = extension entry + peer host; auth = exactly how keys/tokens are handled; weight = deps + unpackedSize.

### S1. pi-subagents — 0.79.1 — modified 2026-10-18T06:21 — PASS
- What: single-agent delegation + scripted multi-agent workflows (nicobailon; skills+prompts+index.js).
- pi-mech: `pi:{skills:./skills, prompts:./prompts, extensions:./index.js}`; peers `@earendil-works/pi-*` (+typebox). Tool-activation loader (`subagents_enable` → full `subagent` schema); Scout-before-plan guidance.
- Auth: none of its own (inherits host model/auth). No key handling in README/auth scan.
- Weight: deps jiti/yaml/acorn/undici/@js-temporal (5); 12.0MB unpacked (skills-heavy).
- Swarm fit: PRIMARY subagent primitive — delegation + scripted workflows; every other shortlister composes or forks this pattern.

### S2. @henryqw/pi-subagent — 27.4.3 — 2026-10-18T14:17 — PASS
- What: delegate bounded direct work or durable CHECKED isolated task graphs to Pi roles (HenryQW/pi-harness).
- pi-mech: `extensions/subagent.ts`; deps proper-lockfile + @henryqw/pi-herdr, pi-process, pi-multi-codex, pi-task-models, pi-config-store.
- Auth: inherits host; task-models/config-store siblings manage model mapping. No separate OAuth.
- Weight: 1.44MB; 6 deps.
- Swarm fit: task-graph orchestrator with durability/checks — strongest "checked DAG" candidate.

### S3. pi-fabric — 0.118.0 — 2026-10-18T19:54 — PASS
- What: programmable tool + agent runtime for Pi (actors, steering, mesh, swarm, workflows, RLM).
- pi-mech: `dist/extension-bootstrap.js` (+ bundles `pi-coralbricks-provider`); peers `@earendil-works/pi-*`.
- Auth: delegates model auth to provider extensions (ships coralbricks inside).
- Weight: HEAVIEST code runtime here: deps diff/yaml/shiki/mcporter/typescript/cross-spawn/lezer/quickjs/monty + `pi-fabric-worker-sdk(npm:@earendil-works/pi-coding-agent@1.3.0)` + `@earendil-works/chord/pi-durable` + pi-coralbricks-provider; 15.9MB.
- Swarm fit: agent-runtime/fabric — use only if a programmable actor-mesh is wanted; heaviest option.

### S4. pi-bifrost — 0.5.0 — 2026-10-05T17:39 — PASS
- What: route Pi turns through chosen models with configured tiers + opt-in per-request dispatch.
- pi-mech: `index.ts` extension; peers pi-ai + pi-coding-agent; `minPiVersion 1.0.1`.
- Auth: none own; tier config over host providers.
- Weight: 321KB, zero runtime deps. Lightest router.
- Swarm fit: model-tier router for cost/quality dispatch per turn.

### S5. pi-router — 0.5.9 — 2026-10-18T07:52 — PASS
- What: intelligent routing layer: multi-level failover, circuit breaker, load-balancer, observability (zh-CN README).
- pi-mech: `index.ts`; peers `@earendil-works/pi-ai/tui/coding-agent >=0.84.4 <2.0.0`; reads/writes `models.json`/`auth.json`/`pi-router.json` (follows `PI_CODING_AGENT_DIR`); `/router sync`, `autoSync`, `summaryMaxTokens`.
- Auth: reads OAuth markers (`type: oauth`) in auth.json; no key storage of its own.
- Weight: 1.17MB, zero runtime deps.
- Swarm fit: failover/circuit-breaker router + model-catalog sync.

### S6. @guygrigsby/pi-subagent-routing — 0.3.1 — 2026-09-29T23:26 — PASS
- What: subagent model-routing policy: orchestrator plans/judges on live model, fans out across price-tiered ladder, cost/performance modes, review-before-accept.
- pi-mech: `dist/index.js`; peer pi-coding-agent only.
- Auth: none own.
- Weight: 25.6KB, zero deps. Lightest policy hook.
- Swarm fit: cheapest cost/perf routing policy to layer over any subagent core.

### S7. pi-crew — 0.11.24 — 2026-10-17T21:46 — PASS
- What: coordinated AI teams, workflows, worktrees, async task orchestration.
- pi-mech: `index.ts` + skills; peers `@earendil-works/pi-* >=1.0.4` + typebox.
- Auth: inherits host.
- Weight: 10.4MB (esbuild/cli-highlight bundled); 7 deps.
- Swarm fit: team/worktree orchestrator — closest to "swarm with git worktrees".

### S8. pi-durable-subagents — 1.1.0 — 2026-10-06→modified 2026-10-18 — PASS
- What: crash-safe subagents: never lose work, never do it twice; auto-recovery + live view like main agent.
- pi-mech: `index.js`; peers pi-ai/tui/coding-agent.
- Auth: inherits host.
- Weight: 1.32MB, zero deps.
- Swarm fit: durability layer for long runs (pairs with S2/S7).

### S9. pi-subagent-manager — 0.29.3 — 2026-10-17T05:40 — PASS
- What: hierarchical, steerable subagent threads.
- pi-mech: `src/index.ts`; deps yaml/fuzzysort/shell-quote.
- Auth: inherits host.
- Weight: 789KB.
- Swarm fit: hierarchy/steering UX for nested delegation.

### S10. pi-better-subagents — 0.19.1 — 2026-10-17T04:42 — PASS
- What: detached, sandboxed subagent runs keeping foreground session free (1aboveio/pi-better-harness).
- pi-mech: `index.ts`; deps yaml/smol-toml/proper-lockfile.
- Auth: inherits host; sandbox separation is the point.
- Weight: 1.5MB.
- Swarm fit: sandbox isolation for untrusted/parallel workers.

### S11. @tintinweb/pi-subagents — 0.22.0 — 2026-10-13T12:15 — PASS
- What: Claude-Code-like subagents + workflow orchestration: parallel exec, live widget, fleet view, custom types, mid-run steering, dynamic workflows.
- pi-mech: dist extension; deps croner/nanoid.
- Auth: inherits host.
- Weight: 2.64MB.
- Swarm fit: fleet-view UI + parallel orchestration (most Claude-like UX).

### S12. @gotgenes/pi-subagents — 25.0.1 — 2026-10-18T16:02 — PASS
- What: focused in-process subagent core + typed API + lifecycle events other extensions build on (friendly fork of S11).
- pi-mech: in-process core; peers pi-ai/tui/coding-agent >=1.0.0. Companion: pi-subagent-permission-compat 0.1.0 + @gotgenes/pi-permission-system 41.0.0.
- Auth: inherits host; permission-system sibling governs tool access.
- Weight: 1.36MB, zero deps.
- Swarm fit: embeddable core + typed API — best base if building custom orchestration.

### S13. @cr1ms0n/pi-subagent — 0.13.0 — 2026-10-17T16:27 — PASS
- What: community fork of pi-subagent with Jev model routing, local tool activation, verified Pi child capabilities.
- pi-mech: pi-package extension; peers pi-ai/tui/coding-agent.
- Auth: inherits host.
- Weight: 1.05MB.
- Swarm fit: Jev-routing fork — routing + subagents in one.

### S14. pi-background-tasks — 2.6.10 — 2026-10-13T13:11 — PASS
- What: durable background shell tasks, read-only delegated agents, local attested Pi runs, fixed-purpose Fusion workflows via child Pi processes.
- pi-mech: extension; dep turndown only. NOTE peer range `^0.81.1||^0.82.1||^0.83.0||^0.84.0` is STALE vs host 1.3.0 (compat risk on Pi 1.x).
- Auth: attested child-Pi runs; inherits host creds.
- Weight: 6.1MB.
- Swarm fit: background/fan-out worker pool via child processes (verify on host 1.3 first).

### S15. pi-antigravity — 0.11.0 — 2026-10-18T14:32 — PASS
- What: Google Antigravity / Cloud Code Assist provider (Gemini + Claude-via-Vertex + GPT-OSS-via-Vertex).
- pi-mech: `src/index.ts` provider + `google_search` + `generate_image` features; peers pi-ai/coding-agent >=0.80.0.
- Auth: OAuth2 Authorization Code + PKCE, loopback `http://localhost:51121/oauth-callback`; `/login antigravity` → tokens in `~/.pi/agent/auth.json` + `antigravity-accounts.json` (owner-only); auto-refresh; subscription-backed `(sub)` quota, not per-token billing; `/antigravity.doctor` redacts secrets; `ANTIGRAVITY_*` env overrides; companion `@rahularya01/opencode-antigravity` for OpenCode.
- Weight: 282KB; dep undici.
- Swarm fit: free-tier model supply via Google login (unofficial; wire-drift risk).

### S16. pi-provider-antigravity — 0.26.0 — 2026-10-16T12:19 — PASS
- What: minimal Antigravity provider (iamxeph).
- pi-mech: provider extension; peers >=0.86.0.
- Auth: same Google OAuth family as S15 (minimal surface).
- Weight: 316KB, zero deps.
- Swarm fit: lighter alternative to S15.

### S17. @rahularya01/pi-cursor — 1.4.39 — 2026-10-08T18:09 — PASS
- What: native Cursor provider (OAuth + Connect/protobuf streamSimple).
- pi-mech: provider; dep @bufbuild/protobuf.
- Auth: 4-tier cascade: `CURSOR_ACCESS_TOKEN` env → `~/.pi/agent/auth.json` (`/login cursor`) → macOS Keychain (cursor-access/refresh-token) → IDE/VSCDB harvest (+WSL Windows-user reuse); `PI_CURSOR_SYSTEM_CREDENTIALS=0` opts out; PKCE deep-link `cursor.com/loginDeepControl` + poll `api2.cursor.sh`; `/cursor.doctor` shows tokenSource; usage via DashboardService endpoint. Unofficial/reverse-engineered.
- Weight: 366KB.
- Swarm fit: Cursor-subscription model supply (credential-reuse behavior must be locked down with PI_CURSOR_SYSTEM_CREDENTIALS=0 for shared runners).

### S18. pi-cliproxyapi-provider — 0.15.58 — 2026-10-09T10:40 — PASS
- What: one CLIProxyAPI instance as pi provider; auto model discovery + models.dev enrichment.
- pi-mech: provider; peers >=0.84.0.
- Auth: `/login cpa` (alias `/login 0xdev`) or `CLIPROXYAPI_API_KEY`; global connection/auth config; `CLIPROXYAPI_AUTH_REQUIRED/_HEADER`; GPT-5.6/6→openai-responses, Claude→anthropic-messages; `metadataFallbackProvider` incl. `feedmob-opencode-go → opencode-go` owner hint (direct evidence of an `opencode-go` provider id in the wild).
- Weight: (size not re-pulled; mid-size provider).
- Swarm fit: single-gateway aggregation incl. opencode-go owner mapping.

### S19. @billjr99/pi-openai-compat — 1.1.37 — 2026-10-18T12:10 — PASS
- What: OpenAI-compatible endpoint registrar (OpenRouter, NVIDIA NIM, Nous, Ollama, custom…).
- pi-mech: `/compat-login`; models appear natively in `/model`/Ctrl+L.
- Auth (exact table): OpenRouter `sk-or-…`; NVIDIA `nvapi-…`; Nous portal key; Ollama optional bearer; **OpenCode Zen `https://opencode.ai/zen/v1` via API key from opencode.ai**; Token Harbor `thk_live_…`; TokenRouter console key; Cloudflare AI Gateway token; Zhipu, HF `hf_…`, Fireworks, Together, Mistral, Cohere, Gemini, Anthropic `sk-ant-…`, Custom URL. 401/403 aborts login; creds + model cache stored on disk (world-readable warning — delete file to clear).
- Weight: mid-size; zero runtime deps listed.
- Swarm fit: UNIVERSAL OpenAI-compat adapter — this is how OpenCode Zen (and by extension any OpenAI-compat gateway) plugs into pi today. OpenCode Go uses the same Zen endpoint family (see §G).

### S20. pi-coralbricks-provider — 1.0.37 — 2026-10-18T18:29 — PASS
- What: CoralBricks inference gateway provider (GLM 5.3 + DeepSeek V4.1 Flash, 1M ctx).
- pi-mech: provider; `/login coralbricks`; stale-while-revalidate catalog; cache `~/.pi/agent/cache/coralbricks-models.json`.
- Auth: `--api-key` flag > `auth.json {coralbricks:{type:api_key,key}}` (literal/env-var/shell-`!`) > `CORALBRICKS_API_KEY=cb_…`; `localterm secret`; `PI_PROVIDER_SYNC_TTL_MS`; design-partner allowlist (`403 access_denied` = not allowlisted).
- Weight: mid-size provider.
- Swarm fit: cheap long-context supply; exemplary key-handling pattern (fingerprint-only sync file).

### S21. pi-multi-account — 1.24.0 — 2026-10-03T12:05 — PASS
- What: automatic multi-account failover & rotation (Anthropic, OpenAI/Codex, Kimi, Cursor, Qwen, Ollama).
- pi-mech: rotation over `auth.json` slots (`anthropic-account-N`, `openai-codex-account-N`…); `/multi-account` status/rediscover/add/remove/pin; `childProxy` loopback route (non-secret placeholder; real cred never leaves parent).
- Auth: auto-discovers OAuth/API-key accounts; Codex JWT `chatgpt_account_user_id` identity dedup; refresh-then-evict on invalid; growth via `/login` subscription slots.
- Weight: deps proper-lockfile + protobuf; mid-size.
- Swarm fit: quota/rate-limit survival — transparent account rotation + auto-resume (essential for fleet scale).

### S22. pi-claude-bridge — 0.9.3 — 2026-10-13T20:24 — PASS
- What: Claude Code (Agent SDK) as pi provider + AskClaude tool.
- pi-mech: provider + tool; deps @anthropic-ai/claude-agent-sdk + cc-session-io + MCP SDK.
- Auth: uses Claude subscription quota like Claude Code (Anthropic announced-then-unannounced SDK-billing change); `strictMcpConfig` default true blocks `~/.claude.json`/`.mcp` servers, Cloud MCP always blocked; WARNING: exported `ANTHROPIC_*` envs hijack the child and break turns.
- Weight: heaviest provider (Agent SDK chain).
- Swarm fit: Claude-subscription supply path.

### S23. pi-web-search — 1.7.0 — 2026-10-08T11:35 — PASS
- What: provider-native web search (Gemini URL Context, Grok, OpenAI Responses incl. Azure/Codex/Copilot, Anthropic, DeepSeek, Ollama Cloud, **OpenCode Zen/Go**).
- pi-mech: `web_search` tool picking per-provider API; OpenCode Zen/Go via Responses API web_search on `openai-responses` models.
- Auth: inherits each provider's own credential (incl. Copilot-resolved endpoint + OpenCode key).
- Weight: light tool extension.
- Swarm fit: STRONGEST OpenCode-Go-in-pi evidence: pi already routes web_search through OpenCode Zen/Go models.

### S24. @narumitw/pi-usage — 0.67.0 — 2026-10-17T11:33 — PASS
- What: usage/limits/reset/API-balance reporter + Codex Fast toggle (`/usage`, `/fast`).
- pi-mech: statusline + cache; dep @narumitw/pi-tui-kit.
- Auth: per-provider semantics kept separate; native `/login openai` ChatGPT OAuth distinguished from API-key; supports opencode/zen/zai/openrouter/copilot/xai/codex/command-code/kimi/moonshot/minimax/token-plan among 20+ families.
- Weight: light.
- Swarm fit: fleet quota observability (5h/session/weekly allowances, balances, Fast routing).

### S25. @mcowger/pi-plexus — 1.14.0 — 2026-10-17T21:05 — PASS
- What: self-hosted Plexus AI proxy as first-class pi provider (models in picker with correct wire protocol).
- pi-mech: `npm i @mcowger/pi-plexus` in `~/.pi/agent/extensions` (or git clone); peers >=0.99.0; zod dep.
- Auth: Plexus instance-side; sibling `plexus-opencode-v2` (`@mcowger/opencode-plexus`) covers OpenCode V2 — proxy pattern spans both harnesses.
- Weight: light (zod only).
- Swarm fit: self-hosted proxy fan-out (one key plane for pi + OpenCode).

## Also-ran / relevance notes (gated PASS, not deep-audited)
- pi-fireworks 0.1.2 (2026-04-24): Fireworks provider; peers `@mariozechner/*` STALE — needs peer bump to @earendil-works. Function: cheapest Fireworks supply; fit: low (superseded by S19/S20 patterns).
- pi-commandcode-provider 0.7.8 (2026-10-15): Command Code API provider; PASS. Fit: single-vendor supply.
- pi-tokenrouter 1.5.0 / @realvendex/pi-token-router 0.2.0: TokenRouter gateway providers; peers stale-ish (`@mariozechner>=0.70` / bare `pi-coding-agent`); PASS by date. Fit: gateway aggregation (S18/S19 preferred).
- pi-openai-toolkit 0.22.3 (2026-10-19): Codex remote-context/compaction/routed search/image-gen reusing host auth; PASS. Fit: OpenAI-power features without new provider.
- pi-sessions 0.20.0 (2026-10-15): session search/ask/handoff/auto-title/index; `pi install npm:pi-sessions`; PASS. Fit: session memory/handoff layer for swarms.
- @pipod/cli 0.1.19 (2026-10-13): server-managed pods (`pipod login --server`, `pipod --help`, man pages); PASS. Fit: remote-session/docker-adjacent hosting (no plain Dockerfile; server + CLI model).
- pi-sandbox 0.7.1 (2026-10-06): OS-level sandbox (allow/deny + @carderne/sandbox-runtime); PASS. Fit: execution containment.
- pi-cmux 0.1.24 (2026-09-28): cmux terminal integrations (parallel chats, sidebars, worktrees); PASS. Fit: human-fleet UX.
- pi-goal-x 0.32.3 / @schovest/pi-goal / @akagilnc/pi-workflow-roles / pi-advisor-flow / @maestria/pi / pi-gauntlet 7.17.1 / gentle-pi 4.3.0 / agent-comms 8.13.20 / @each1024/pi-jev-route / pi-adaptive-orchestrator 0.1.0: goal/workflow/orchestration variants; all PASS by date. Fit: secondary orchestration flavors (S1/S2/S7/S11 cover primary).
- pi-acp 0.0.34: ACP JSON-RPC-over-stdio → `pi --mode rpc` (Zed); PASS. Fit: editor-embedding, not swarm routing.
- @ai-sdk/harness-pi 1.0.156: Vercel AI SDK HarnessV1 over @earendil-works pi SDK (host-process + sandbox-as-remote-FS); PASS. Fit: programmatic pi embedding.
- @postman/postman-plugin 0.3.0 / @dietrichgebert/ponytail / context-mode / cc-safety-net / billion-context*: cross-harness (OpenCode + Pi + Claude Code) skills/compression/safety; PASS. Fit: shared guardrails.
- opencode-codebase-index / open-codebase-index / opencode-agent-skill (names only in windows): OpenCode-named, NOT registry-verified — flagged for Wave 2, do not cite as verified.
- @estebanforge/pi-antigravity-bridge: antigravity-bridge variant (name only in window) — Wave 2 verify.
- @oh-my-pi/pi-coding-agent 18.12.2: oh-my-pi fork-line (omp), NOT canonical pi; PASS but out of scope for pi-package shortlist.
- @mariozechner/pi-coding-agent 0.73.1: FAIL-DEPRECATED (see §F).

## §F. Rename note — @mariozechner/* → @earendil-works/* (verified via registry)
- `@mariozechner/pi-coding-agent`: latest 0.73.1, `time.modified 2026-05-07T15:34:11.612Z`, **`deprecated: "please use @earendil-works/pi-coding-agent instead going forward"`**. Repo `github.com/badlogic/pi-mono`. Peers `@mariozechner/pi-ai/tui/agent-core`. DO NOT USE.
- `@earendil-works/pi-coding-agent`: latest **1.3.0**, `time.modified 2026-10-15T19:13:31.137Z`, no deprecated flag. Repo `github.com/earendil-works/pi`. Deps pin `@earendil-works/pi-ai/mcp/tui/codemode/agent-core@1.3.0`. Description: "Coding agent CLI with read, bash, edit, write tools and session management". **Current canonical scope + version: `@earendil-works/pi-coding-agent@1.3.0` (2026-10-15).**
- Migration residue: pi-fireworks 0.1.2 and pi-tokenrouter 1.5.0 still peer on `@mariozechner/*` (stale, compat risk on host 1.x); pi-background-tasks peers `^0.81–0.84` (stale range); all other shortlisters peer `@earendil-works/*` (mostly `*` or `>=1.0`).

## §G. OpenCode Go subscription — how a third-party agent authenticates (from https://opencode.ai/v2/docs/console/go, verified 2026-10-19)
- What: Go ($10/mo lower-cost) / Go Plus ($40/mo higher limits); "reliable access to popular open coding models"; optional; "designed primarily for international users".
- Auth (exact): sign in to OpenCode Console → subscribe to Go/Go Plus → billing details → **copy API key** → in TUI run `/connect`, select OpenCode Go, paste key → `/models` to select a Go model. I.e. **API-key auth (not OAuth, not subscription-token passthrough)**. (`/connect` + pasted key; same pattern as other providers in OpenCode.)
- Third-party use: "Go is designed for OpenCode and other coding agents that produce similar types of requests." Requirements: typical coding-agent traffic; **own User-Agent** (e.g. `my-coding-agent/1.0`, not generic SDK/HTTP lib); **stable per-conversation session id in `x-opencode-session`** for routing + prompt caching. Validated clients table lists **Pi: "Current builds send session information for OpenCode. Update older installations."** (also Hermes, Claude Code, Codex, ZCode, jcode≥0.81.6, Kilo CLI; problematic: DeepSeek Harness, Copilot Chat, Kimi/MiMo Code).
- Rate limits/pooling: limits are **monthly dollar amounts per model**; 5-hour = 20% of monthly, weekly = 50%, monthly = 100%. Per-model monthly caps e.g. GLM-5.3-Flash $60, GLM-5.3 $15, Kimi K3 $15, K2.7 Code $60, MiniMax M3 $60, Muse Spark 1.3/1.2 $60, DeepSeek V4.1 Flash $80 (peak/off-peak), Qwen3.8 Max $15, GPT 6/5.6 Luna $15, Grok 4.7 $15, Claude Haiku 5.5 (table truncated in fetch). Abuse monitoring: "Traffic is monitored for abuse that degrades the experience for other users."
- Pi-side wiring (independent registry evidence): pi-web-search routes OpenCode Zen/Go models via Responses API; @billjr99/pi-openai-compat registers **OpenCode Zen `https://opencode.ai/zen/v1` with API key from opencode.ai**; pi-cliproxyapi-provider maps owner `feedmob-opencode-go → opencode-go`. So in pi today, OpenCode-family access = **OpenAI-compatible endpoint + API key** (Zen URL documented; Go is the same Console key plane per Go docs). No pi package was found that stores an OpenCode OAuth token — all OpenCode-family auth observed is pasted API keys.
- Model list (Go page, 2026-10-19): Grok 4.7, GLM-5.3-Flash/5.3/5.2, GPT 6/5.6 Luna, Claude Haiku 5.5, Gemini 4 Argon Contributor, Kimi K3/K2.7 Code, LongCat-2.0/2.5 Preview Free, Step 5 Preview, Beam Free, MiMo-V2.6-Flash/Pro/V2.5/V2.5-Pro, MiniMax M3, Muse Spark 1.3/1.2 Contributor, Qwen3.8 Max/Flash, Qwen3.7 Plus, DeepSeek V4.1 Flash/Pro, Hy4 preview, Hy3, Space Bunny. (List subject to change per page.)

## Repro
- Search: `GET https://registry.npmjs.org/-/v1/search?text=keywords:pi-package&size=100[&from=100|200]`; `text=pi-coding-agent&size=100`; `text=pi+subagent&size=100`.
- Meta: `GET https://registry.npmjs.org/<name>` → `dist-tags.latest`, `time.modified`, `versions[latest].{description,keywords,dependencies,peerDependencies,dist.tarball,dist.unpackedSize,deprecated}`, `readme`.
- Docs: `GET https://pi.dev/docs/latest/packages`, `https://pi.dev/packages`, `https://pi.dev/docs/latest/models`, `GET https://opencode.ai/v2/docs/console/go`.
- Gate rule: modified>=2026-01-01 AND not deprecated/unpublished. Shortlist cap: 25 (this file) + also-ran notes.

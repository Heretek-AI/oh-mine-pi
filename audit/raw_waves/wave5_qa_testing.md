# WAVE 5 — QA / Static-Analysis & Tester/Verification Swarm Audit

Date (UTC): 2026-10-19 · Workdir: `C:\Users\derek\Desktop\Projects\oh-mine-pi`
Scope: Agent Skills (SKILL.md) + MCP servers for QA (static analysis / lint / review)
and Tester (unit/E2E harness generation, verification, container healthchecks) roles.
Polyglot: TS/JS, Python/Ruff, Semgrep/Sonar, Playwright. Pi-sandbox interplay included.

Method: `gh search repos` (adapted queries — literal "SKILL.md <x>" returns ∅, so
topic queries were used), repo-page fetches (vercel-labs/skills, vercel-labs/agent-skills,
anthropics/skills, trailofbits/skills, obra/superpowers, mattpocock/skills,
SonarSource/sonarqube-mcp-server, github/github-mcp-server, currents-dev/playwright-best-practices-skill,
earendil-works/pi), skills.sh leaderboard + /topic/testing, pi skills.md docs,
L337-org/docker-mcp README, semgrep MCP README via websearch.
Liveness gate: repo pushed ≥ 2026-01-01. gh API rate-limited mid-run (2026-10-19 05:42 UTC);
entries below that lack an explicit pushed date were verified active via pages fetched this run
or skills.sh install activity — flagged as [L2] (page-verified) vs [L1] (pushed-date verified).

Local baseline: skills-lock.json v1, only `find-skills` (vercel-labs/skills) installed;
project skills dir `.agents\skills\` contains only `find-skills\`; pi runs containerized
(docker-compose.yml: `pi-home` volume + `./workspace` bind, no ports — CLI not daemon).

---

## 1. SKILLS shortlist (max 12)

| # | Skill (source) | What it teaches the agent | Role | Install mechanism | Liveness | Score /10 |
|---|---|---|---|---|---|---|
| S1 | `test-driven-development` — obra/superpowers (302k★) | RED-GREEN-REFACTOR loop, one vertical slice at a time, testing anti-patterns ref | Tester (primary) | `pi install git:github.com/obra/superpowers`; or `npx skills add obra/superpowers --skill test-driven-development`; plugin marketplaces (Claude/Codex/Copilot/Gemini…) | [L2] page live, skills.sh #267 (~254k installs) | 10 |
| S2 | `verification-before-completion` — obra/superpowers | Forces a verification pass before ANY task is marked done — the Tester gate as a skill | Tester | same as S1 | [L2] skills.sh testing topic | 9 |
| S3 | `systematic-debugging` — obra/superpowers | 4-phase root-cause process (repro → minimise → hypothesise → instrument → fix → regression test) | Tester / QA triage | same as S1 | [L2] skills.sh #258 (~299k) | 9 |
| S4 | `tdd` — mattpocock/skills (296k★) | Red-green-refactor with guidance on good vs bad tests; pairs with `diagnosing-bugs` loop | Tester | `npx skills add mattpocock/skills --skill tdd` (plugin or editable copy); `/setup-matt-pocock-skills` per repo | [L2] skills.sh #6 (~1.1M installs) | 9 |
| S5 | `code-review` — mattpocock/skills | TWO-AXIS review as parallel subagents: Standards (repo norms + Fowler smells) vs Spec (faithfulness to originating issue) | QA | same as S4 | [L2] skills.sh #54 (~759k) | 9 |
| S6 | `playwright-best-practices` — currents-dev/playwright-best-practices-skill (402★, MIT) | 57 refs in 8 cats: locators, fixtures, POM, flaky-test fixing, a11y, API/visual/i18n/Electron, CI sharding, docker images | Tester (E2E) | `npx skills add https://github.com/currents-dev/playwright-best-practices-skill` | [L2] page live 2026, skills.sh testing topic | 9 |
| S7 | `webapp-testing` — anthropics/skills (182k★) | Python Playwright scripts + `scripts/with_server.py` server-lifecycle helper (multi-server), reconnaissance-then-action DOM pattern | Tester (E2E) | `/plugin marketplace add anthropics/skills` → `document-skills`/`example-skills`; or copy `skills/webapp-testing/` | [L2] SKILL.md fetched live | 8 |
| S8 | `static-analysis` — trailofbits/skills (7.6k★, CC-BY-SA-4.0) | CodeQL + Semgrep + SARIF parsing toolkit | QA | `/plugin marketplace add trailofbits/skills` (Claude) / `codex plugin marketplace add trailofbits/skills` | [L2] page live, plugins/ tree | 9 |
| S9 | `semgrep-rule-creator` + `semgrep-rule-variant-creator` — trailofbits/skills | Write custom Semgrep rules; port rules across languages with test-driven validation | QA (custom rules) | same as S8 | [L2] same | 8 |
| S10 | `modern-python` — trailofbits/skills | uv + ruff + pytest baseline (closest thing to a ruff skill in any major catalog) | Programmer / QA lint | same as S8 | [L2] same | 8 |
| S11 | `differential-review` — trailofbits/skills | Security-focused diff review with git-history analysis | QA | same as S8 | [L2] same | 8 |
| S12 | `react-best-practices` + `web-design-guidelines` — vercel-labs/agent-skills (32.6k★, MIT) | 40+ React perf rules; 100+ web UI rules (a11y, focus, forms, animation, i18n) — review checklists for QA pass | QA (perf/a11y) | `npx skills add vercel-labs/agent-skills --skill react-best-practices` | [L2] README fetched 2026 | 7 |

Install paths for pi: pi implements the Agent Skills spec; project skills discovered
recursively in `.agents/skills/` (cwd → ancestors, stops at repo root), plus global
`~/.agents/skills/`. superpowers ships `.pi/extensions/` + `pi install git:github.com/obra/superpowers`
(one-line pi-native install). `npx skills add` targets `pi` via `-a pi`
(`.agents/skills/` project, `~/.agents/skills/` global). `skills.sh` is the discovery index.

Not shortlisted (checked, rejected): `claude-skill-code-review-router` / `claude-skill-codex-review`
(0★, single-file, stale ≥ Mar 2026); `broomva/skills` (Tier-2 pack, QA content unverified);
`vercel-labs/skills` repo itself (only the `find-skills` CLI skill — already installed locally).

---

## 2. MCP table (QA/Tester)

| # | Server | Tools relevant to swarm | Transport | Docker-fit | Liveness | Score /10 |
|---|---|---|---|---|---|---|
| M1 | Official Semgrep MCP (`semgrep/semgrep` cli, `semgrep mcp`; PyPI `semgrep-mcp`; deprecated standalone `semgrep/mcp` repo) | `semgrep_scan`, `scan_directory`, `list_rules`, `create_rule`, `analyze/filter/export/compare_results`; Semgrep Guardian bundles MCP+hooks+skills | stdio (default) + streamable-http (`-t`, port 8000); hosted experimental `https://mcp.semgrep.ai/mcp` | First-class: `docker run -i --rm semgrep/semgrep semgrep mcp -t stdio`; GHCR `ghcr.io/semgrep/mcp`; token (`SEMGREP_APP_TOKEN`) optional | [L2] README on develop fetched via search 2026 | 10 |
| M2 | Official SonarQube MCP (`SonarSource/sonarqube-mcp-server`, 665★) | `analyze_code_snippet`/`analyze_file_list`/`run_advanced_code_analysis` (Vortex), issues, hotspots, quality gates, coverage (`search_files_by_coverage`, line-level), duplications, dependency-risks, rules | stdio (default, recommended local) + Streamable HTTP/HTTPS (`SONARQUBE_TRANSPORT`, `/mcp`, per-request `Authorization: Bearer`); `SONARQUBE_TOOLSETS` trims context, `READ_ONLY` mode | First-class: `sonarsource/sonarqube-mcp` image, `--pull=always`; workspace mount `/app/mcp-workspace` keeps file content out of context; `/health`, `/info` endpoints | [L1] pushed 2026-10-16 | 9 |
| M3 | Official GitHub MCP (`github/github-mcp-server`, 33.7k★) — `code_security` toolset | Code Scanning alerts, secret protection, Dependabot, `code_quality` toolset; read-only + lockdown modes (prompt-injection filter) | Remote hosted `https://api.githubcopilot.com/mcp/` (HTTP) + local `ghcr.io/github/github-mcp-server` over stdio (Docker) or `go build` binary; `GITHUB_TOOLSETS` allow-list | Good: docker one-liner, OAuth or PAT; fine for Tester fetching findings, not a scanner itself | [L2] README fetched (1,191 commits) | 8 |
| M4 | `L337-org/docker-mcp` (`docker-mcp-server`, PyPI + Docker Hub/GHCR) — Tester container control | 150+ typed tools: `container_run/exec/logs/stats`, `compose_*`, `system_wait` (wait-for-healthy/exit/log-line with timeout), log/stats MCP resources, `read-only` / `no-destructive` / per-host `(ro)` modes, provenance labels, self-termination guard | stdio via `uvx docker-mcp-server` or `docker run -i --rm -v /var/run/docker.sock:/var/run/docker.sock …` (multi-arch); `.mcpb` + Claude plugin variants | Excellent — IS the docker-fit answer for Tester healthchecks: mount daemon socket, gate destructive tools in code (not prompt), remote daemons over SSH/TLS; ships sibling `l337-docker` SKILL.md (CLI-only alternative) | [L1] pushed 2026-10-17 | 9 |
| M5 | `microsoft/playwright-mcp` (+ `microsoft/playwright-cli`) | Browser automation for E2E (already audited Wave 1C — reference only, NOT re-done) | stdio | n/a (reference) | Wave 1C | ref |

Also seen: `MekayelAnik/semgrep-mcp-docker` (unofficial wrapper, 0★, pushed 2026-10-19 — prefer M1);
`stefanskiasan/semgrep-mcp-server` (2★, original inspiration for official — superseded by M1);
SonarQube forks (`9506hqwy`, `flowgent-labs`, `BrainerVirus/sonarless-mcp` local-Sonar bundle) —
prefer official M2 unless offline-local is required (then `sonarless-mcp`).

---

## 3. pi-specific QA notes

- Pi skills = Agent Skills spec, natively: frontmatter (`name`, `description` ≤1024 chars drives
  routing, `disable-model-invocation`, `allowed-tools` experimental). Force-load via `/skill:name`.
  Discovery: project `.agents/skills/` + global `~/.agents/skills/` (+ `~/.agents/skills` shared
  with Cline/Codex/Cursor). Name collisions keep first + warn. (Source: pi `skills.md` doc.)
- superpowers is pi-first-class: `.pi/extensions/` bootstrap injected at session start AND after
  compaction; install `pi install git:github.com/obra/superpowers` or `pi -e <checkout>` for dev.
  Hermes note applies: no post-compaction hook there — prefer pi's extension model.
- Sandbox: **pi has NO built-in permission system** — runs with user/process permissions.
  Three sanctioned patterns (pi `containerization.md`): (1) Gondolin extension (pi + auth on host,
  tools + `!` routed into Linux micro-VM); (2) plain Docker whole-`pi` container (= oh-mine-pi's
  current setup); (3) OpenShell policy sandbox. QA implication: linters/tests/scanners run
  wherever pi runs — inside oh-mine-pi's container they are already sandboxed; on host runs they
  are NOT unless Gondolin/OpenShell is added.
- Extension interplay: a QA extension could gate `!`-commands (ruff/eslint/semgrep/playwright)
  or route them into the micro-VM; no such QA extension was found in the wild (see gap).
- `gh search repos "pi lint OR pi test-runner"` → ∅ (plus API rate-limit); pi ecosystem search is
  immature — skills.sh `find` + `npx skills find <kw>` is the working discovery path (and is the
  only skill currently installed in this repo's lockfile).

## 4. Role map

- QA (static analysis / review / gates): S5, S8, S9, S11, S12, M1, M2, M3; S10 (ruff baseline).
- Tester (harness generation / execution / verification): S1, S2, S3, S4, S6, S7, M4, M5(ref).
- Programmer (consumes QA output, owns lint-clean code): S10 + vercel `react-best-practices`.
- Suggested wiring: Programmer writes → QA scans (M1/M2, S8/S9 rules) → Tester generates + runs
  (S1/S4 TDD, S6/S7 Playwright, M4 healthchecks) → S2 verification gate → S5/S11 review.
  M3 surfaces findings as issues; `SONARQUBE_TOOLSETS`/`GITHUB_TOOLSETS` + docker-mcp read-only
  mode keep context small and production daemons safe.

## 5. Scores recap (swarm fit)

10: S1, M1 · 9: S2, S3, S4, S5, S6, S8, M2, M4 · 8: S7, S9, S10, S11, M3 · 7: S12.

## 6. Biggest gap

No polyglot lint-orchestrator skill (single routing skill across ESLint + Ruff + Semgrep +
SonarQube with pi-sandbox awareness) and no pi-native QA extension that gates/routes
linter/test/scanner tool calls into the sandbox (Gondolin/plain-Docker). Ruff appears only
buried inside trailofbits `modern-python`; there is no standalone ruff SKILL.md in any major
catalog, and no container-healthcheck skill (docker-mcp server fills it, but as a server, not
a skill). Recommend authoring `qa-lint-orchestrator` (skill) + a pi QA extension (tool gating)
as Wave-6 build items.

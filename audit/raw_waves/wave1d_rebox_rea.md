# WAVE 1D RAW FINDINGS — re-box + rea deep audit
Date: 2026-10-19 | Auditor: wave-1d | Workdir: C:\Users\derek\Desktop\Projects\oh-mine-pi
Clones: review/re-box (Heretek-AI, depth-1), review/rea (morluto, depth-1)

## 1. LIVENESS GATE (both ALIVE — verdict: USABLE, with drift caveats)

### Heretek-AI/re-box
- pushed_at: 2026-10-18T03:13:18Z (yesterday) | archived: false | stars: 0 | forks: 0
- language: Shell | license: NOASSERTION (LICENSE.md present, not SPDX-detected) | default_branch: main
- 2026 commits: 12, all 2026-10-17 → 2026-10-18 (brand-new repo, M4→M8 sprint in ~36h)
- VERDICT: ALIVE, but INFANT — 2 days old, 0 stars/forks, single-org (Heretek-AI) companion to opencode-rea.

### morluto/rea
- pushed_at: 2026-10-19T05:23:31Z (today) | archived: false | stars: 325536 | forks: 82444
- language: TypeScript | license: MIT | description: "Reverse engineer anything with agents, from app behavior down to native binaries."
- 2026 commits: 3000+ (paginated 100/page × 36 pages, back to 2026-04-14; ~daily cadence, still landing today)
- VERDICT: ALIVE and HYPERACTIVE. (Star/fork counts are anomalously large — treat as vanity-inflated, not a trust signal. What matters: MIT, real daily commits, npm package `rea-agents` v6.7.0.)

## 2. re-box COMPLETENESS (claim-by-claim)

### 2a. Dockerfile (412 lines, fully read) — COMPLETE, strongly pinned
- Base: `ubuntu:24.04` (2-stage: system → final). Non-root `re` user, WORKDIR /workspace.
- APT: ca-certificates, curl, gnupg, git, unzip, procps (ps), util-linux (prlimit), python3+pip+venv, openjdk-21-full-JDK (jdk.compiler checked), binutils (objdump), gdb+gdbserver, tshark+capinfos 4.x, sigrok-cli 0.7.2, adb (standalone pkg), radare2 (apt), gcc, python3-dev, pkg-config, libfontconfig1-dev, file, xz-utils, jq.
- Node 22.x via NodeSource setup_22.x (major-pinned). Bun via bun.sh/install → **UNPINNED (latest)** — gap #1.
- OpenCode CLI pinned `@opencode/cli@2.0.32` (acceptance-gated). REA CLI pinned `rea-agents@6.5.0` — **DRIFT: rea upstream is 6.7.0** — gap #2.
- M5 engines (all pinned + acceptance-gated INSIDE build, fail-closed):
  | Tool | Pin | Verify |
  | Ghidra | 12.1.4 NSA release, sha-verified | analyzeHeadless executable |
  | jadx-headless-mcp | 0.7.1, sha256 6e5eac…ff75 (matches rea JadxRelease.ts) | sha re-check in build |
  | rizin | 0.9.1 static tarball | version grep (NO published digest — admitted in comment) — gap #3 (minor) |
  | radare2 | apt (skills use only; REA calls rizin) | — |
  | WABT | 1.0.42, sha-verified | wasm2wat --version |
  | Wakaru | 1.14.0, binary-sha 664fa0…927c38 verified | --version |
  | Binwalk | 3.1.x (cargo install 3.1.0, toolchain removed after) | --version grep 3.1.x |
  | venv /opt/venvs/re-tools | pwntools 4.15.0, pyelftools 0.33, unicorn 2.1.2, mitmproxy 12.2.3, unblob 26.6.4 | import check + --version gates |
  | Apktool | 3.0.3 (≥3.0.2 CVE rule) | --version gate |
  | pwndbg | branch 2026.09.15 (date-branch = mutable ref) — gap #4 (minor) |
  | DIE (M7) | 3.21 .deb, opt-in REBOX_WITH_DIE | diec --version |
  | ReVa (M7) | commit a05a6b0 post-v7.3.1 (deliberate, documented: v7.3.1 tag has broken mcp import) | ext .jar + mcp-reva --help + import |
  | opencode-rea skills | @heretek-ai/opencode-rea@0.1.2 tarball, SKILL.md asserted | ls + file tests |
  | operator-helper | @aerovato/operator-helper@1.8.0 | --help grep |
- Tiny C sample built + REAL Ghidra headless decompile gate (evidence_id + sha256 asserted via node). Scoped `rea doctor` gates for ghidra+jadx; licensed providers (IDA/Hopper/JEB/Kuna) explicitly excluded.
- M6 wire-up runs at BUILD time as `re`: `rea setup --client opencode`, plugin add, skill copy (never overwrites reverse-engineer-anything), operator-memory, compact profile + watcher.ignore via jq.
- HEALTHCHECK: `node /opt/re-box/scripts/healthcheck.mjs` (interval 5m). ENTRYPOINT: entrypoint.sh.

### 2b. docker-compose / service files — MINIMAL but SUFFICIENT
- Full compose = 39 lines ONLY (no ports, no named volumes, no restart policy, no healthcheck override).
- services.re-box: build: ., image: re-box:m6 (STALE TAG vs README m7 — gap #5), container_name, working_dir /workspace, stdin_open+tty, volumes ./workspace:/workspace + ./targets:/workspace/targets:ro, cap_add SYS_PTRACE, 4 provider-key env passthroughs (host-only, never baked — good).
- No ports published: correct for stdio-MCP + interactive TUI design, but a pi-extension TCP/SSE bridge would need a compose delta (see §5).

### 2c. Entrypoints / volumes / healthchecks — COMPLETE
- entrypoint.sh (27 lines): gates ps + /usr/bin/prlimit + /workspace, then `exec opencode "$@"`. `--help` asserted in build.
- volumes: rw workspace + ro targets (correct RE hygiene). ports: none (by design). healthcheck: file + in-Dockerfile gate.
- setup-rea.sh: idempotent, fail-closed (`set -eu`), 6 steps incl. conditional mcp.reva registration (timeout 180s for ~90s cold boot). healthcheck.mjs: parses env.defaults, fails on any missing path; REVA/DIEC optional (lean-image aware); REA_MCP_INPUT_SCHEMA_PROFILE=compact exact-match.
- smoke.sh (M8): SKIP_BUILD-aware, 3 gates (healthcheck + rea analyze sample + report verification). build.yml: build + smoke on push/PR.

### 2d. Android RE coverage — NEAR-COMPLETE, 3 holes
- PRESENT: jadx-headless-mcp 0.7.1 (Java+smali-fallback via REA), apktool 3.0.3, adb, full JDK 21.
- MISSING from image: (a) **frida-tools / frida-server** — rea's frida provider uses the `frida` npm optional dep (17.23.2, ships inside rea-agents install, so node-side binding IS present via the global install) but no `frida-tools` CLI and no device-side frida-server staging (device-side is arguably out of scope); (b) **standalone smali/baksmali CLI** (REA covers smali via JADX fallback internally — acceptable, but a raw `smali` binary is absent); (c) **bundletool / apksigner / zipalign** (no AAB handling, no signing) — gap #6, the most material Android hole.
- Java/Python/Node: YES (JDK 21 full, python3+venv, Node 22). radare2: YES (apt). ghidra: YES.

## 3. rea COMPLETENESS (claim-by-claim)

### 3a. Language / deps / entrypoint
- Language: TypeScript (strict, ESM `type: module`), ~50 src/ domains. Engines: node ^22.19 || ^24.11 || >=26; packageManager npm@11.16.0; .nvmrc 24.18.0.
- Deps: ~40 runtime deps ALL EXACT-pinned (zod 4.4.3, MCP SDK 2.3.1 client+server, pino, playwright-core 1.58.2, evmole 0.9.3…); optionalDependencies: frida 17.23.2 (allowScripts). devDeps pinned (vitest 5.0.3, turbo, oxlint…).
- Entrypoints: bin `rea`/`rea-agents` → scripts/rea.mjs → dist/cli-runtime/cli.js (CLI) or dist/mcp/main.js (MCP stdio). `npm start` = `rea mcp`. NOTE: ships compiled `dist/` — requires `npm ci && npm run build:cached`; if dist is absent the launcher errors with the exact rebuild command (fail-clear, good).
- install.sh: bash, truncation-guarded (`{ … }` brace group), installs Node if needed, `REA_VERSION` overridable.

### 3b. README setup — RUNS STANDALONE, no re-box needed
- `npx rea-agents setup` → interactive multi-client registration + backups + approval gate. Manual MCP JSON also documented. Terminal path: `npx -y rea-agents@latest analyze-javascript-application … --json` / `npm i -g rea-agents; rea --help`.
- Prereqs stated: Node+npm, procps `ps` on Linux (owned-process checks), per-provider BYO engines (Hopper/Ghidra/IDA optional; setup can install Hopper with approval).
- Does NOT need re-box: rea runs on any host with Node; re-box is a convenience container that pre-bakes the BYO engines.

### 3c. API surface — CLI + MCP stdio (+ bridges), NO REST/TCP
- CLI: ~50 command modules (adb, android, apktool, frida, ghidra, firmware, pcap, wasm, evm, sqlite, electron, browser, managed/dotnet, cutter, jeb, hopper, ida, kuna…).
- MCP: stdio only (`npx rea-agents mcp`; server.json transport.stdio; mcpName io.github.morluto/rea v6.7.0). ~70 register*Tools files (sessions, evidence, investigation, comparison, runtime-observation…). Compact/full schema profiles. NO HTTP/SSE listener — any TCP bridge must be added outside rea.
- Agent clients supported (SupportedClients.ts, 25 entries): claude_code, claude_desktop, codex, cursor, gemini_cli, windsurf, devin, **opencode**, antigravity, copilot_cli, commandcode, qwen_code, kimi, vscode, trae, workbuddy, grok_build, **omp**, **pi** (~/.pi/agent/mcp.json), hermes, qoder, droid, zcode, dsh, (+grok_bot manual-only). **pi + omp + hermes are first-class setup targets** — directly relevant to oh-mine-pi.
- Bridges: ghidra (Java), jadx (ReaJadxBridge), hopper (python), cutter, mitmproxy (capture.py), pwndbg/pwntools (python), lldb tracer (swift), native windows (.node). Host-only/licensed tools (IDA/Hopper/JEB/Kuna/macOS ipatool) correctly stay OUT of the container.

## 4. INTEGRATION READINESS — can a pi-extension/MCP client drive rea inside re-box TODAY?
- ANSWER: MOSTLY YES for OpenCode-in-container; PARTIAL for pi-extension. The image boots wired for opencode (`mcp.rea` registered, compact profile, skills, memory). A pi agent is a supported rea client BUT setup-rea.sh only registers `--client opencode`; nothing writes ~/.pi/agent/mcp.json in-image, and the entrypoint `exec`s opencode (must be overridden to run anything else).
- PUNCHLIST (numbered gaps):
  1. re-box pins rea-agents@6.5.0, upstream is 6.7.0 — 2 minor versions drift; setup-rea.sh + Dockerfile ARG both hardcode 6.5.0.
  2. Bun installed via `bun.sh/install` unpinned (latest) — only unpinned toolchain in image; breaks reproducibility claim.
  3. rizin static tarball has no published digest (exact-version grep only, admitted in Dockerfile comment).
  4. pwndbg pinned to date-branch `2026.09.15` (mutable ref, no SHA).
  5. Compose image tag `re-box:m6` stale vs README `:m7`; compose lacks restart policy + named volumes (./workspace bind only — session state not crash-safe).
  6. No bundletool/apksigner/zipalign (AAB install/sign flow impossible in-container); no standalone smali/baksmali CLI (covered via JADX fallback, but no raw binary); no frida-tools CLI (node binding present via rea's optional dep; device frida-server staging undocumented).
  7. No TCP/SSE transport: rea is stdio-only; an out-of-container pi extension cannot attach without `socat`/stdio-bridge sidecar or `docker exec` shim — no compose delta provided.
  8. setup-rea.sh registers opencode only — no `--client pi/omp/hermes` pass; pi-in-container needs a manual `rea setup --client pi` (works, but unwired).
  9. re-box repo license is NOASSERTION (LICENSE.md undetected) + 0 stars/forks + 2 days old — supply-chain infancy risk; all 12 commits in 36h by one org.
  10. No published/pre-pulled image (GHCR/Docker Hub); every consumer pays the full multi-GB engines build (~Ghidra+ReVa Gradle build) with no build-cache guidance.
- SCORES: re-box 8/10 (complete Dockerfile+acceptance, deductions for drift/unpinned-Bun/Android-signing holes/infancy). rea 9/10 (mature CLI+MCP+25 clients+exact pins; deduction for dist-required + stdio-only + inflated social proof).

## 5. MINIMAL DELTA for re-box (≤15 lines: Dockerfile + compose)
```dockerfile
ARG REBOX_REA_VERSION=6.7.0
RUN npm install -g rea-agents@${REBOX_REA_VERSION} && rea --version   # close drift (gap 1)
RUN curl -fsSL https://github.com/smali/smali/releases/download/v3.0.9/smali-3.0.9.jar -o /opt/smali/smali.jar \
 && printf '#!/bin/sh\nexec java -jar /opt/smali/smali.jar "$@"\n' > /usr/local/bin/smali && chmod +x /usr/local/bin/smali  # raw smali (gap 6)
RUN curl -fL -o /opt/bundletool.jar https://github.com/google/bundletool/releases/download/1.18.1/bundletool-all-1.18.1.jar  # AAB (gap 6)
ENV BUN_VERSION=1.2.0
RUN curl -fsSL https://bun.sh/install | bash -s -- bun-v${BUN_VERSION}  # pin Bun (gap 2)
```
```yaml
# compose delta (gap 7/8): stdio bridge for external pi-extension
  command: ["sleep", "infinity"]          # keep container up; drive via docker exec
  # external client: docker exec -i re-box rea mcp   (stdio over exec, no TCP needed)
```

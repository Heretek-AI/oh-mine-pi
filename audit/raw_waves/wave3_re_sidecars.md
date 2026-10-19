# WAVE 3 RAW FINDINGS — Docker RE sidecars + sandboxing + re-box delta
Date: 2026-10-19 | Auditor: wave-3 | Workdir: C:\Users\derek\Desktop\Projects\oh-mine-pi
Preread: audit/raw_waves/wave1d_rebox_rea.md (re-box 412-line Dockerfile + 39-line compose verified there — NOT re-audited, only delta-validated).

## 1. DISCOVERY + LIVENESS GATE (pushed >= 2026-01-01, not archived)

Queries run (`gh search repos`, --sort updated): `jadx docker`, `apktool docker`,
`frida docker`, `ghidra docker`, `MobSF docker`, `objection docker`, `radare2 docker`,
`mobsf`, `bundletool`, `frida-server android`, `ghidra-mcp`, `jadx-mcp`,
`coding agent sandbox docker`, `agent sandbox`, `pi-coding-agent`, `pi agent sandbox extension`.
(~60 candidates scanned; shortlist = best 2026 activity, all PASS gate unless noted.)

### 1a. SHORTLIST (10, all alive + unarchived)

| # | Repo (pushed / stars) | Base / image | Tools + pins | Drive method |
|---|---|---|---|---|
| 1 | alexmi256/rea-agent-docker (2026-10-19 / 4) | ubuntu:24.04; 4 imgs: rea-agent, -ghidra, -hopper, -ida; GHCR `ghcr.io/alexmi256/*` published on every main push | Ghidra 12.1.4 (multi-arch, default), Hopper 6.6.0 demo headless via Xvfb, IDA BYOL; same aux toolchain all four; `scripts/verify.sh` fixtures x 8 arch/format families + real MCP handshake | REA MCP ~207 tools: stdio via `docker exec` (default) OR Streamable HTTP via optional bridge |
| 2 | psyb0t/docker-reverse-engineer-anything (2026-10-18 / 0, CI+release badges) | Debian 13 (OpenJDK 21 full); Docker Hub `psyb0t/reverse-engineer-anything` (pulls badge = published image) | rea-agents 6.4.0 (170 tools), jadx-headless-mcp 0.7.1 (SHA-checked vs REA pin), Apktool 3.0.3, adb 34.0.5, Node 24 | Token-guarded Streamable HTTP MCP endpoint + stdio MCP + CLI; `.agents/AGENTS.md`, glama.json |
| 3 | MobSF/Mobile-Security-Framework-MobSF (2026-10-18 / 21987, official) | Official image `opensecurity/mobile-security-framework-mobsf` (Docker Hub, versioned tags) | Full MobSF: static+dynamic+malware analysis, APK/IPA/APPX; REST API :8000 + web UI | REST (`/api/v1/...` with API key) + web UI; drive via curl/exec, wrap as MCP tools trivially |
| 4 | zinja-coder/jadx-ai-mcp (2026-10-19 / 2915) + zinja-coder/jadx-mcp-server (2026-10-19 / 805) | JADX plugin (runs inside jadx GUI 0.7.x line), MCP server companion | JADX decompile/search/generate-hooks as MCP tools | MCP (plugin stdio); containerize by layering onto any JDK image with jadx — same jar re-box already pins |
| 5 | wellingtonlee/ghidra-docker-mcp (2026-07-30 / 2) | Dockerized Ghidra MCP server | Ghidra headless + MCP shim | MCP stdio in container |
| 6 | raven-dev-io/ghidra-docker (2026-01-17 / 0) | Docker; "integrated MCP + collection of RE tools" | Ghidra + RE tool bundle | MCP + CLI exec |
| 7 | jumpeip/ghidrallm-mcp (2026-10-18 / 0) | Ghidra 12.1.4-embedded native MCP (== re-box's Ghidra 12.1.4: drop-in version match) | 70 LLM tools: decompile, xref, patch, vuln assess | In-Ghidra MCP server; sidecar = same container family as re-box Ghidra layer |
| 8 | boy-offi9-inc/hexforge-gateway (2026-10-17 / 8, MIT, Fastify+TS) | Node >= 20, Termux-or-PC; job & workflow engine | jadx/apktool/adb/frida/APKiD dispatched as jobs, exposed as native MCP tools for Claude | MCP tools + workspace REST API; self-hosted, no cloud |
| 9 | moshouhot/SOMCP-APKX (2026-10-17 / 0, AGPL-3.0) | APK full-chain MCP toolchain | jadx, smali, APKEditor, apksig, DexKit, root DEX unpack, frida-server | MCP (SOMCP 1.0.22 baseline) |
| 10 | iammohdzaki/bundletool-mcp (2026-09-29 / 2) | MCP wrapper over bundletool | AAB build/extract/device-spec | MCP; closes re-box AAB hole (wave1d gap 6) without a jar hack |

Near-misses (alive, not in top 10): Sarks0/binary-mcp (today / 10; Ghidra+x64dbg+WinDbg+ILSpyCmd MCP — Windows-side only, skip for linux sidecar); samudoria/revoid (2026-10-15 / 7; JADX Headless MCP server); Albasha0x0/Corvus (today; .NET/PE/ELF/Mach-O MCP, IDA+Ghidra optional); meenmachine1/revkit (2026-10-18; Ghidra-decompiler-as-C++-libs + MCP); zhuyansen/awesome-ai-reverse-engineering (2026-10-18 / 11; 122-repo graded RE-agent list, EN+CN — index for future waves).
STALE / fail-gate (record only): jadx docker imgs (all 2024, 0-2 stars); caprosoft/apktool-docker (2024-02); frida imgs (2023/2022); whoant/objection-docker (2023-03); radare/radare2-dockers (2016); chennqqi/ghidra-docker (pushed 2026-10-12 / 0, no desc — marginal pass, thin signal).

Docker Hub presence: psyb0t/reverse-engineer-anything (published, pulls badge); opensecurity/mobile-security-framework-mobsf (official, versioned); frida = NO maintained image (frida-tools via pip, frida-server = per-arch device binary — correctly out-of-container); objection = NO maintained image (pipx install, drives host frida); bundletool/apksigner/zipalign = NO standalone maintained images (Google ships jars; wrap in-house).

### 1b. MCP-WRAPPABILITY (could a pi RE-agent drive it via docker exec or an MCP shim?)

1. rea-agent-docker: YES native — `docker exec -i <c> rea mcp` stdio today; HTTP bridge optional for remote pi. Highest fidelity: same REA tool surface pi already targets (~207 tools, pi is a first-class rea client per wave1d §3b).
2. psyb0t image: YES native — token-guarded Streamable HTTP is the exact pattern re-box lacks (wave1d gap 7); pi MCP JSON points at URL, no exec needed.
3. MobSF: YES via 1-file shim — REST is stable (`/api/v1/upload`, `/api/v1/scan`, `/api/v1/report_json`); ~30 lines of python MCP wrapper; dynamic analysis needs emulator/device mount, static works headless.
4. jadx-ai-mcp: MAYBE — needs GUI jadx + plugin; better to reuse its MCP tool schema against re-box's headless jadx jar than containerize the GUI.
5. ghidra-docker-mcp / raven-dev-io: YES via exec — headless analyze + MCP stdio; overlap with rea's ghidra provider, use only if rea's Ghidra path is insufficient.
6. ghidrallm-mcp: YES — 70 Ghidra-native tools, version-matched to re-box; candidate to REPLACE rea-doctor-ghidra path for deep binary work, exec-driven.
7. hexforge-gateway: YES native — already MCP tools over a job engine incl. frida; use as the FRIDA sidecar (fills wave1d gap: no frida-tools in re-box) via its HTTP/MCP surface.
8. SOMCP-APKX: CAUTION — AGPL-3.0 + frida-server/root-unpack scope creep; borrow smali/apksig patterns only, don't adopt image.
9. bundletool-mcp: YES — single-purpose AAB shim; or 3-line jar exec (see delta §3), no image needed.
10. General rule confirmed: every shortlist item is drivable WITHOUT new protocol work — stdio-over-`docker exec` (pi `bash` tool) or Streamable HTTP/SSE (pi MCP URL client). No custom pi extension required for v1.

## 2. SANDBOXING PATTERNS (how pi-agent runners sandbox tool execution today)

Local evidence: review/awesome-pi-coding-agent README (extension catalog w/ download counts = adoption proxy).
- Dominant pattern = OS-level in-process sandbox, NOT containers: @anthropic-ai/sandbox-runtime + bwrap/landlock (linux) / seatbelt (macOS). Adopters: pi-sandbox 7.6k/mo, @erichll/pi-sandbox 3.9k/mo (fail-closed static fs policy + per-connection net approval), @yandy0725/@xzzpig/@oddsjam/@igormaka forks, pi-guard-sandbox, pi-os-guard, @nqbao/pi-sandbox, pi-permission-modes (bash AST gating via tree-sitter).
- Docker pattern = SECOND tier, two flavors: (a) whole-agent-in-container (@agimon-ai/doompi-sandbox 10.3k/mo, @kushalkhemka/pi-docker); (b) per-tool-call container: @christianmoesl/pi-sbx (Docker sbx), pi-container-sandbox (Apple `container` or Docker per-session), @stixxert/pi-docker-sandbox (private sbx microVM, host docker never exposed), pi-sandbox-docker (fresh offline Debian per run, RO mount + per-run net approval), docker/sbx-kits-contrib/pi (Docker's OFFICIAL kit, pushed 2026-10-16, 177 stars; fork: simonferquel-clanker/pi-agent-mcp-kit adds MCP-gateway self-registration).
- Remote/cloud sandboxes: @daytona/pi, pi-e2b/pi-extension-e2b, @upstash/box-pi, @cogbox/pi, pi-extension-opensandbox (all tool calls remote-ephemeral, agent local).
- MicroVM: pi-msb-sandbox (libkrun + 2-way sync), pi-gondolin-mount, pi-enclave (VM + secret protection).
- Meta: pi-context-mode sandboxes heavy tool OUTPUT to temp files (tool-output sandboxing, 98% ctx reduction claim via mksglu/context-mode).
- `earendil-works/pi-coding-agent`: owner string does NOT resolve via gh API (GraphQL "could not resolve"); string appears in @5dive/telegram-pi-bridge as pi's SDK host — treat as package-org reference, not a repo; pi upstream sandbox = the extension catalog above. No firejail-based pi pattern found; gVisor appears only in k8s agent-sandbox work (heyvaldemar/kubernetes-ai-agent-sandbox: gVisor + egress allowlist; kubernetes-sigs/agent-sandbox referenced by agentscale fork + sandbox-scheduler).
- RE-sidecar implication: RE tools are hostile-input processors — run them in the (b) flavor: disposable sidecar container(s), RO target mount (re-box already does `./targets:ro`), no provider keys inside (re-box already does env-passthrough), SYS_PTRACE only where ptrace needed (frida/gdb sidecars), egress-deny except adb/device.

## 3. re-box DELTA VALIDATION (review/re-box Dockerfile + compose re-read; wave1d §5 confirmed + extended)

Wave1d's ≤15-line delta CONFIRMED accurate against current review/re-box checkout (Dockerfile still 412 lines, rea 6.5.0, no smali/bundletool, Bun unpinned, compose still `re-box:m6` + no sleep/bridge). EXTENDED delta below: keeps wave1d's 5 Dockerfile lines, fixes compose properly, adds pi-client registration + HTTP-bridge option copied from shortlist items #1/#2 instead of raw socat.
```dockerfile
ARG REBOX_REA_VERSION=6.7.0
RUN npm install -g rea-agents@${REBOX_REA_VERSION} && rea --version
RUN curl -fsSL https://github.com/smali/smali/releases/download/v3.0.9/smali-3.0.9.jar -o /opt/smali/smali-3.0.9.jar \
 && printf '#!/bin/sh\nexec java -jar /opt/smali/smali-3.0.9.jar "$@"\n' > /usr/local/bin/smali && chmod +x /usr/local/bin/smali
RUN curl -fL -o /opt/bundletool.jar https://github.com/google/bundletool/releases/download/1.18.1/bundletool-all-1.18.1.jar
ENV BUN_VERSION=1.2.0
RUN curl -fsSL https://bun.sh/install | bash -s -- bun-v${BUN_VERSION}
```
```yaml
# compose.pi-re.yaml — sidecar profile for pi-driven use (./targets stays ro; no keys baked)
services:
  re-box:
    build: .
    image: re-box:pi
    container_name: re-box-pi
    working_dir: /workspace
    stdin_open: true
    tty: true
    command: ["sleep", "infinity"]          # keep up; drive via exec, entrypoint opencode bypassed
    volumes:
      - ./workspace:/workspace
      - ./targets:/workspace/targets:ro
    cap_add: [SYS_PTRACE]
    profiles: ["re"]
# MobSF sidecar (static-only headless): docker run -d -p 8000:8000 opensecurity/mobile-security-framework-mobsf:latest
```
```sh
# shim: register pi client once, then drive REA over exec-stdio (no TCP needed for local pi)
docker exec -i re-box-pi rea setup --client pi            # writes ~/.pi/agent/mcp.json in-container (wave1d gap 8 fix)
docker exec -i re-box-pi rea mcp                          # pi mcp.json: {"command":["docker","exec","-i","re-box-pi","rea","mcp"]}
# optional HTTP (borrow token-guard pattern from psyb0t/alexmi256 bridge when pi runs remote):
# docker exec -d re-box-pi rea-mcp-http --port 8099 --token "$RE_MCP_TOKEN"   # shim wraps stdio->Streamable HTTP
```
Remaining wave1d gaps status after delta: 1 closed (6.7.0), 2 closed (Bun pin), 6 closed (smali+bundletool; apksigner/zipalign still absent — pull via Android cmdline-tools or reuse bundletool-mcp #10), 7 closed (exec-shim, no compose TCP needed), 8 closed (setup --client pi), 3/4 accepted risks (rizin no-digest, pwndbg date-branch), 5 fixed (image tag re-box:pi), 9/10 out of scope (infancy + no published image — MITIGATED by shortlist #1/#2 which ARE published: prefer `ghcr.io/alexmi256/rea-agent` or `psyb0t/reverse-engineer-anything` if no-build matters more than re-box's acceptance gates).
Verdict: re-box works-as-sidecar AFTER delta (9 lines Dockerfile + compose profile + 2 exec commands); works-as-is TODAY only for interactive `docker run` REA-CLI use, NOT for pi-driven MCP use.

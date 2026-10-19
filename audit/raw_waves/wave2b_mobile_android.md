# WAVE 2B — Mobile interfaces for pi-coding-agent / OpenCode swarm driving (Android-first, ZeroTier-friendly)

Auditor: WAVE 2B. Date: 2026-10-19. Workdir: `C:\Users\derek\Desktop\Projects\oh-mine-pi`.
Method: README fetched via `gh api repos/{o}/{r}/readme` (base64-decoded) — no big clones; `gh search repos` discovery; repo metadata via `gh api repos/{o}/{r}`. All pushed-dates/stars as observed 2026-10-19.
Liveness gate: pushed >= 2026-01-01. Mission scoring = phone-based swarm monitoring/steering over ZeroTier.

## A. The named four — mobile story from their own READMEs/docs

### A1. happier-dev/happier — ★1992, pushed 2026-10-19 (today), TypeScript, MIT
- Tagline: "Web, Desktop & Mobile client and orchestrator for Codex, Claude Code, OpenCode, Pi, Cursor, Grok, Antigravity, Kimi … fully end-to-end encrypted".
- Platform: **native iOS (App Store `happier-claude-codex-opencode` id6758554297) + native Android (Google Play + direct APK via happier.dev/apk) + desktop + browser**. QR codes + TestFlight/dev-APK lanes in README.
- Backend: Pi is a **first-class bespoke RPC backend** (`apps/cli/src/backends/pi/…`, `PiRpcBackend`), NOT generic ACP. Evidence: `docs/pi-feature-matrix.md` (19.7 KB internal audit doc, audited against pi 0.73.1): normal sessions `supported`, transcript/event mapping `supported`, permissions/tool-allowlist `supported`, model/command introspection `partial`, vendor resume via `--session` artifact `supported`, fork/clone `partial` (RPC supports, UI hides), rollback `unconfirmed`. Sessions can spawn **subagents across agents** (Claude→Codex etc.), switch agents mid-session, approve/steer/review/commit from phone.
- Self-host / ZeroTier: **self-hostable relay, one command** (`happier relay host install --mode system`, `--ssh user@host`, Docker, Proxmox). Relay stores/forwards E2E-encrypted blobs; routing metadata only. Phone pairs to your relay — so hosting the relay on a ZeroTier-joined box (or LAN IP) keeps swarm steering fully private. No per-URL-field evidence in README (relay identity model, not raw URL), but self-host docs cover custom runtimes.
- Install: desktop app (sets up CLI+daemon) → `happier.dev/download`; mobile via stores/APK; `hdev` dev lane.
- Verdict: deepest Pi support of any mobile client found. Score 9/10.

### A2. getpaseo/paseo — ★21335, pushed 2026-10-19 (today), TypeScript
- Tagline: "One interface for Claude Code, Codex, Copilot, OpenCode, Pi, Antigravity, and Muse Code agents." / "Orchestrate multiple coding agents from desktop and mobile".
- Platform: desktop + **mobile is the FULL app, native on iOS and Android** (`packages/app`: Expo client for iOS/Android/web) + web + CLI.
- Backend: Pi listed as built-in provider; parallel agents each in own worktree; orchestration (agents spawn agents cross-provider); voice mode.
- Self-host / ZeroTier: **strongest explicit ZeroTier story of the big-4**: "Paseo starts, then asks whether to enable the end-to-end encrypted relay for device pairing. **If you decline, connect directly over TCP, Tailscale, or another VPN.**" Any-VPN-direct ⇒ ZeroTier IP works by construction. Daemon via `npm i -g @getpaseo/cli` or Docker (`http://localhost:6767` web UI); separate Elixir relay repo `getpaseo/paseo-relay`.
- Install: `paseo.sh/download` or GH releases; daemon auto-starts with desktop app.
- Verdict: full-app mobile + explicit no-relay VPN-direct mode = ideal ZeroTier fit. Score 9/10.

### A3. stablyai/orca — ★97039 (as displayed 2026-10-19; treat with mild caution, anomalously high), pushed 2026-10-19, TypeScript, MIT
- Tagline: "Run Codex, Claude Code, OpenCode or Pi side-by-side — each in its own worktree, tracked in one place."
- Platform: desktop (macOS/Win/Linux) + **Mobile Companion: iOS App Store (`orca-ide` id6766130217) + Android APK (onorca.dev/download/android)**, currently **beta**. Explicitly "read-mostly remote control, not a full editor".
- Backend: Chat UI (readable transcript+composer+permissions+attachments) supports **Claude, Codex, Grok, OpenCode, OMP, and Pi**; raw terminal view otherwise. Quick Commands synced with desktop, source-control commit from phone, account switching + rate-limit state, push notifications on agent finish.
- Self-host / ZeroTier: pairing via **Orca Relay (sign-in) OR local/LAN path**; paired-host **address is user-editable** (`IP, host:port, ws(s)://`, default port 6768) with docs example **"home LAN vs Tailscale"** — i.e. point the phone at a Tailscale/ZeroTier address and reconnect, same pairing token. Troubleshooting doc: "phone and desktop must share a network path (LAN, Tailscale, or the pairing path you used)". ZeroTier works wherever Tailscale does (any L3 path to port 6768).
- Install: desktop from onorca.dev/download; mobile App Store/APK; one-time pairing code.
- Verdict: best documented LAN↔VPN host-switching; mobile intentionally thin. Score 8/10.

### A4. spacering-net/codeg — ★4011, pushed 2026-10-18, Rust (+ TS UI), Apache-2.0
- Tagline: "Collaborative multi-agent AI coding workspace: aggregate sessions from Claude Code, Codex, OpenCode, Pi, Grok Build, etc. Desktop app, self-hosted server, or Docker."
- Platform: desktop (macOS/Win/Linux) + **native iOS (App Store `codeg-client` id6785199071, SwiftUI, iOS 26+) + native Android (APK via GH releases, Jetpack Compose + Material 3, Android 12+)**, both v1.0.1 test releases; + Telegram/Lark/WeChat channels; + web service in browser.
- Backend: 19 built-in agents incl. Pi + OpenCode, any ACP agent joinable; sessions travel/import/resume across agents; `codeg-mcp` companion bundled; `codeg-cli` since 0.38.0.
- Self-host / ZeroTier: **explicit custom-URL server profiles**: "add a server profile, enter its URL and token, Test Connection" — `http://192.168.1.10:3080` LAN example; "for remote access, use HTTPS through a trusted reverse proxy, **VPN, or tunnel**" ⇒ ZeroTier IP:port + token works. Token in Keychain/Keystore. Desktop `Settings → Web Service` exposes access-token + QR for phones; or headless `codeg-server`/Docker.
- Install: desktop dmg/exe/AppImage/deb/rpm; mobile App Store/APK (+SHA-256 page); point at Web Service URL.
- Verdict: cleanest URL+token BYO-backend model for ZeroTier. Score 8/10.

## B. Discovery sweeps (all pass liveness gate unless noted)

### B1. `gh search repos "opencode android" --sort updated` (30 hits, top relevant)
| Repo | Pushed | What it is |
|---|---|---|
| grapeot/opencode_android_client | 2026-10-19 | Native Kotlin/Compose client → `opencode serve`; **Tailscale MagicDNS explicit** (`*.ts.net` HTTP allowlisted), Basic Auth, SSE, usage dashboard; ravamichi iOS twin |
| Dajeovv/opencode-android | 2026-10-18 | Launcher APK: runs opencode **on-phone via Termux**, one-tap `http://127.0.0.1:4096`, wizard, update watchdog |
| xiufeigo/opencode-android-shell | 2026-10-17 | Thin fullscreen **WebView shell** for OpenCode web UI → any backend URL |
| Astreele/opencode-android | 2026-10-18 ★18 | **Native OpenCode v2 builds for Termux** (`opencode2`, `pkg` updates) |
| MeanderX/opencode-android | 2026-10-17 | Termux+proot-distro installer/launcher/home-screen widget |
| tixyq / nemoobc / XyrusCode / Theblackcat98 / Dukuu-Wild / Chakszzz(RN/Expo) / cinvymoe(Capacitor) / hjinlabs(Compose+Ktor+Hilt) / turanmertkaraca / GetterSethya `opencode-android*` | 2026-09-06…10-17 | Long tail of thin clients / Termux wrappers / RN shells — mostly 0–2 ★, single-maintainer, churn-heavy |
| Sakura-0311/opencode-android-remote | 2026-10-11 | Android App + desktop_agent + relay_server + cloud_server (CN docs) |
| wryan2986/opencode-android | 2026-10-02 | Client + SSH-terminal fallback |
| Zar-Manah/opencode-android-apk | 2026-10-08 | "APK + on-device agent factory + persistent memory" marketing; unverified |
| z15537006222/codeg-android | 2026-10-04 (no README) | "Codeg mobile app for Android" — likely binary mirror of codeg APK lane |

### B2. `gh search repos "opencode mobile client"` (15 hits)
| Repo | Pushed | What it is |
|---|---|---|
| cyrasafia/openbuilder | 2026-10-18 | Flutter Android+iOS, opencode-focused: **mDNS/Tailscale discovery**, SSE streaming, worktree mgmt, diff review, OAuth→Basic→none auth ladder, Authelia reference |
| grinev/opencode-telegram-bot | 2026-10-17 | Telegram bot client, **OpenCode V2**, no open ports (Bot API polling → works over any net incl. ZeroTier, needs internet), session/model/subagent tracking |
| apuyou/mobilecode | 2026-09-12 | TestFlight + Play beta, multi-server, projects/sessions/chat; **"same LAN or VPN like Tailscale"** |
| bmpenuelas/opencode-mobile-client | 2026-09-04 | **Play Store + App Store + VS Code sidebar**; wraps OpenCode Web UI; **LAN or VPN/Tailscale**, multi-profile, Basic Auth, narrow-screen fixes |
| junbaor/opencode-mobile | 2026-08-04 | SEO/landing repo for "KKCode" mobile client (iPhone/iPad/Android) |
| mittaus/opencode-mobile-client | 2026-03-15 | Kotlin KMP app + **Go gateway** (`:8080`, API-key auth, SSE fan-out, per-project process mgmt) — most self-hostable architecture, but oldest push |
| alchemist1234/oc-pocket, inxeoz, sawaizscan, luoyingwen(chat-bot), hanpham32(RN), barysiuk(relay svc), AYM1607 | 2025-08…2026-08 | Stale long tail; pre-V2 mostly |

### B3. `gh search repos "pi android"` — only 2 true pi-coding-agent hits in 30
- **heikeyangle-code/pi-android** (2026-10-18, Kotlin): "put the pi coding agent in your Android phone; extension ecosystem identical to desktop" — Ubuntu base + Node, **no root**, full extension/skill/theme install from phone, diff-view chat UI. CN docs w/ screenshots. On-device pi, not remote swarm steering.
- **minglu6/pi-android** (2026-10-16, Java, no desc/README): unassessable, likely stub/mirror. Treat as noise.
- Rest = Raspberry Pi / "pixel/ping" false positives (expected: "pi" is a stopword-grade query).

### B4. Termux pi workflows — ALIVE and current
| Repo | Pushed | What it is |
|---|---|---|
| wirawira941/pi-termux | 2026-10-19 | **Pi natively on Termux** (aarch64): `bun build --compile --target=bun-android-arm64` single binary; launcher works around Bun-on-Android `execPath` bug; zip releases + `install.sh`; custom OpenAI-compatible endpoints via `models.json` |
| Daxiongmao87/oh-my-pi-termux | 2026-10-17 | **oh-my-pi (omp) on Termux via glibc-runner**, unmodified upstream ARM64 ELF, atomic update/rollback, `omp doctor` smoke checks |
| jeamy/pi-termux-mobile | 2026-10-16 ★4 | pi-termux-mobile launcher (JS) |
| Marvin-z/pi-termux-notify, daltonxiong/pi-termux-notify | 2026-09 | Haptics/toast + completion notify shims for pi-on-Termux |
| robertclaw496-alt/pi-termux-setup | 2026-08-28 | Supervisor + auto-restart + session restore + safety gate for pi/Android |
| Phirisyyds/pi-termux-toolkit | 2026-08-11 | libffi-shim, safety gate, completion notify |
| Hariketsu/pi-termux-fixes | 2026-07-31 | TUI full-redraw storm patch, gh-CLI install fix |
| CommunityPokeOrg/antseed-pi-termux | 2026-10-01 | Launcher for pi on AntSeed network in Termux |

### B5. codeg-mobile satellite
- MoozLee/codeg-mobile (2026-05-12): iOS experiment fork — superseded by official App Store client (A4); passes gate but stale.
- xintaofei/codeg-android (★17, pushed 2026-07-27): official-ish Android distribution lane referenced by codeg docs releases page.

## C. Survivor comparison (ZeroTier lens)

| Client | Platform | Backend | Self-host URL config | 2026 activity | Install |
|---|---|---|---|---|---|
| happier | iOS+Android+web | Pi (RPC, deep) + OpenCode + 30 | Self-host relay (any L3; E2E) | today ★1992 | stores/APK + 1-cmd relay |
| paseo | iOS+Android+web (Expo, full app) | Pi + OpenCode + 5 | **Direct TCP/Tailscale/any-VPN, no relay needed** | today ★21335 | paseo.sh/download, npm CLI, Docker |
| orca | iOS+Android companion (beta) | Pi + OpenCode (Chat UI) | Editable host addr; LAN↔Tailscale documented | today ★97039* | App Store/APK + pairing code |
| codeg | iOS (App Store) + Android APK | Pi + OpenCode + 17 | URL+token profiles; VPN/tunnel documented | yesterday ★4011 | App Store/APK + Web Service |
| openbuilder | Flutter Android+iOS | opencode only | mDNS/Tailscale; OAuth/Basic | 10-18 | Flutter builds |
| bmpenuelas | Play+AppStore+VSCode | opencode only | LAN/VPN/Tailscale + Basic Auth | 09-04 | stores |
| apuyou/mobilecode | TestFlight+Play beta | opencode only | LAN/Tailscale | 09-12 | beta lanes |
| grapeot android client | Native Kotlin APK | opencode only | Tailscale MagicDNS explicit | today | gradle APK |
| xiufeigo shell | WebView APK | opencode web (any) | Any URL | 10-17 | APK |
| grinev telegram-bot | Telegram (any phone) | opencode V1+V2 | No ports (Bot API) | 10-17 | npm |
| heikeyangle pi-android | Native Android APK | **on-device pi** | N/A (local) | 10-18 | APK, no root |
| Termux path (wirawira941, Daxiongmao87, Dajeovv, Astreele, MeanderX) | Termux on-device | on-device pi/omp/opencode | N/A (local; ZeroTier via termux tailscale/zerotier pkg if remote needed) | today→10-16 | scripts/zips/APKs |

\* orca star count as displayed; anomalously high — flag, don't rely on it.

## D. Scores (mission: phone-based swarm monitoring/steering over ZeroTier)
1. happier 9 — deepest Pi support + E2E self-host relay + shipping stores.
2. paseo 9 — full native mobile app + explicit direct-TCP/VPN mode (ZeroTier by construction) + Docker daemon.
3. orca 8 — best LAN↔VPN host-switch UX, Pi Chat UI; mobile deliberately thin (beta).
4. codeg 8 — cleanest URL+token BYO backend; native mobile still in testing (iOS 26+/Android 12+).
5. openbuilder 7 — best opencode-only Flutter option w/ Tailscale+mDNS; no Pi.
6. bmpenuelas 7 — store-distributed opencode web wrapper; no Pi.
7. heikeyangle pi-android 7 (different job: on-device pi, not swarm steering).
8. grinev telegram-bot 6 — zero-port monitoring anywhere; chat UI limits.
9. grapeot/apuyou/xiufeigo 6 — competent opencode-only Android clients; single-maintainer risk.
10. mittaus gateway 5 — best self-host architecture, stalest (03-15).
Long tail (`tixyq/nemoobc/XyrusCode/…`, `minglu6/pi-android`) 2–4: churn, no README, unverifiable — exclude.

## E. Termux verdict
**YES — pi-on-Termux is real and 2026-active, not folklore.** Two independent current paths: (1) wirawira941/pi-termux — true native Bun-compiled `bun-android-arm64` pi binary with releases (pushed today); (2) Daxiongmao87/oh-my-pi-termux — upstream oh-my-pi ARM64 ELF under glibc-runner with atomic updates (pushed 10-17); plus jeamy launcher, notify/haptic shims, supervisor/safety-gate setups, and a parallel opencode-on-Termux track (Astreele native v2, MeanderX, Dajeovv launcher APK). Termux = agent runs ON the phone (great for field nodes); companion apps (happier/paseo/orca/codeg) = phone STEERS the home swarm. For this mission recommend both tracks: Termux-pi for on-device, Happier or Paseo pointed at a ZeroTier-joined relay/daemon for swarm command.

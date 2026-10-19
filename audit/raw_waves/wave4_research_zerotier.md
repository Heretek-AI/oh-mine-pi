# WAVE 4 — Deep Research agent wired to self-hosted ZeroTier stack
Date: 2026-10-19 | Auditor: wave-4 | Workdir: C:\Users\derek\Desktop\Projects\oh-mine-pi
Targets: SearXNG JSON at http://zt-ip:8888 | Firecrawl API at http://zt-ip:3002 | Crawl4AI REST at http://zt-ip:11235
Clones reused from review/ (no re-clone). Liveness gate: pushed >= 2026-01-01.

---

## A. ANCHOR REPO DEEP-AUDIT

### A1. czhiming-maker/pi-deep-research (v0.4.1, pushed 2026-10-18, SURVIVOR)

**Provider chain** (`src/config.ts`, `src/chain.ts`, `src/types.ts`, `extension.ts`):
- Registry = 3 native providers + hot-plugged `.ts` plugins from
  `~/.pi/agent/pi-deep-research/providers/` (jiti-loaded, re-scanned on every
  extension load; `/reload` picks up changes; project-level dirs deliberately NOT loaded).
- Order resolution: `SEARCH_PROVIDERS` env (comma-separated, session-scoped) →
  `~/.pi/agent/pi-deep-research/config.json` `{"providers": [...]}` (persistent) →
  default `tavily,brave,agent-reach`. Unknown name = hard startup error.
- Chain semantics (uniform): `isConfigured()` false → skip · ≥1 result after domain
  filter → win · empty → next · throw → next · exhausted → aggregated `ChainError`.
- `extract()` is optional per provider; first configured provider with `extract()`
  wins; blank content = failure → fall through to `extractWithFetch` basic-HTTP fallback.
- Contract (`SearchProvider`): `{name: /^[a-z0-9-]+$/, tier: "local"|"cloud" (display only),
  isConfigured(), search({query,maxResults,searchDepth?,signal?}), extract?(url,signal?)}`.
- Tools registered: `web_search` (single+batch ≤5), `web_extract`, `research_checkpoint`
  (code-enforced CONTINUE/PROCEED gate, depth thresholds quick/standard/deep/exhaustive).
- Checkpointing = in-tool verdict logic only (no disk state); air-gap safe (local-only chain possible).

**Can it hit self-hosted endpoints? YES — 2 of 3 ship as example plugins**
(`examples/providers/`, copy-paste opt-in, NOT loaded by default):

| Service | Shipped plugin | Env / config keys | Code change? |
|---|---|---|---|
| SearXNG | `examples/providers/searxng.ts` | `SEARXNG_BASE_URL=http://zt-ip:8888`; list `searxng` in `SEARCH_PROVIDERS` or config.json | NONE. GOTCHA (in file header): SearXNG JSON API is OFF by default → `settings.yml` must enable `search.formats: [html, json]`. Calls `GET {base}/search?q=…&format=json&language=en&categories=general`, maps `results[]:{title,url,content→snippet,publishedDate}`, slices to maxResults. |
| Firecrawl (self-host) | `examples/providers/firecrawl.ts` | `FIRECRAWL_BASE_URL=http://zt-ip:3002`; `FIRECRAWL_BASIC_AUTH=user:pass` ONLY if behind reverse proxy (becomes `Authorization: Basic …`); NO API key sent otherwise | NONE. search: `POST {base}/v1/search {query,limit,scrapeOptions:{formats:[]}}` → `data[]:{title,url,description→snippet}`. extract: `POST {base}/v1/scrape {url,formats:["markdown"]}` → `data.markdown`, title/author/date via `pickMeta` candidate keys; empty markdown throws → chain falls back. Speaks **v1** — pin server accordingly (firecrawl-simple = v1 only; upstream 2.x = /v2; see §D). |
| Crawl4AI | NONE shipped | Proposed: `CRAWL4AI_BASE_URL=http://zt-ip:11235` + `CRAWL4AI_API_TOKEN` | YES — one ~40-line plugin (snippet §C). `isConfigured()` = both set. search: reuse SearXNG-shaped passthrough is NOT possible (Crawl4AI has no search index) → implement `search()` as throw/`[]` (chain skips to extract role) OR omit `search` and register extract-only. extract: `POST {base}/md {url}` with `Authorization: Bearer $TOKEN` → `{markdown}` → truncate 8000 words. |

### A2. Curio-Data/pi-intelli-search (v0.19.0, pushed 2026-10-17, SURVIVOR)

**5-stage pipeline** (`src/core/operations/research.ts`, `fetch.ts`, `messages.ts`, `types.ts`):
1. Search — search-grounded model (default `perplexity/sonar` via OpenRouter) returns
   synthesis; prose links merged with harvested `url_citation` annotations; URL list clamped.
2. Fetch — EVERY page dual-fetched in parallel (HTML→Defuddle vs Markdown variant),
   quality-scored (code blocks/headings/tables +, nav chrome −), best kept. Direct
   `wreq-js` HTTP; honors only top-level `httpProxy` setting.
3. Extract — per-page LLM compression (≈50K→≈3–5K chars, default MiniMax M3).
4. Collate — dedupe + summary + cache write (default MiniMax M3).
5. Cache-suggest — LLM judge over `.search/.index.json` (supplementary, awaited).
- MCP server mode: `packages/mcp/` standalone stdio server (`packages/mcp/src/config.ts`:
  strict config `{providers:{openrouter:{apiKeyEnv}}, models:{search,extract,collate},
  tuning:{…}}`, workspace containment, cacheDir must be workspace-relative).
  Models locked to provider `"openrouter"` in MCP mode.

**Can it be pointed at custom endpoints? NO — code change required for all three:**

| Service | Config surface | Verdict |
|---|---|---|
| SearXNG | NONE. `searchModel` = `{provider,model}` id only; no base-URL/endpoint key in `NESTED_KEYS` (settings.ts) or MCP `ranges`/`tuning` (mcp config.ts). | Code change: new search-provider branch in `operations/search.ts` or pre-search hook. |
| Firecrawl | `searchWebSearch.engine: "firecrawl"` EXISTS — but it is **OpenRouter's hosted `openrouter:web_search` server-tool**, not a self-hosted base URL. Fetch stage (`core/fetch.ts`) has NO Firecrawl hook (no FIRECRAWL_* key anywhere in src/). | Code change: replace/extend `fetchSingle` with `/v1/scrape` call. |
| Crawl4AI | NONE (no key, no engine option). | Code change: same fetch-layer hook as Firecrawl. |
| LLMs (partial yes) | NATIVE mode only: `searchModel/extractModel/collateModel` accept ANY pi-registry provider → extract/collate CAN run on ZeroTier-local LLMs (Ollama/vLLM registered in pi). But search stage still needs Sonar or the OpenRouter web_search tool → search stays cloud-tied. MCP mode locks provider to `openrouter`. | No code change for local extract/collate (native); search uncapturable. |

---

## B. MCP SERVER HUNT (`gh search repos … --sort updated --limit 20`, 2026-10-19)

Liveness = updated/pushed >= 2026-01-01. Pi client (verified https://pi.dev/docs/latest/mcp):
stdio (`command/args/env`) + **streamable HTTP** (`url/headers/oauth`) supported;
**legacy SSE rejected**; `url` entry selects streamable HTTP; `${VAR}` substitution in env/headers.

### B1. SearXNG MCP servers

| Repo | ★ / pushed | Transport | Base-URL key | Auth | Verdict |
|---|---|---|---|---|---|
| **ihor-sokoliuk/mcp-searxng** | **1315 / 2026-10-19** | stdio (default) + streamable HTTP `POST /mcp` (`MCP_HTTP_PORT/HOST`, stateless `MCP_HTTP_STATELESS`, `GET /health`) | **`SEARXNG_URL` (REQUIRED)**; `;`-separated replica list w/ failover or `SEARXNG_FANOUT=true` parallel merge; per-replica `user:pass@` Basic Auth; `AUTH_USERNAME/PASSWORD` legacy fallback; `SEARXNG_HTML_FALLBACK=true` for JSON-less instances | Inbound: static bearer `MCP_HTTP_AUTH_TOKEN` (+`MCP_HTTP_HARDEN`) or full OAuth resource mode. No key needed for SearXNG itself (self-hosted). | **BEST PICK.** Docs: CONFIGURATION.md. Tools: `searxng_web_search`, `web_url_read` (+PDF ≤16MiB/500pp), suggestions, instance info. GOTCHAS: (1) SearXNG needs JSON format on (same as A1). (2) `web_url_read` **blocks private/internal URLs by default** → set `MCP_HTTP_ALLOW_PRIVATE_URLS=true` if ever reading ZT-local pages. (3) HTTP-mode rate limits + tool admission caps are always on (sane defaults). |
| TadMSTR/searxng-mcp | 25 / 2026-10-07 | stdio + http (`SEARXNG_MCP_TRANSPORT`, port 3001, `SEARXNG_MCP_AUTH_TOKEN`) | `SEARXNG_URL` (default :8081; `,`/`;` replica list w/ failover; Basic Auth embeddable) | Optional bearer on HTTP transport | **STRONGEST ALL-IN-ONE (fetch cascade).** Single server fronts ALL THREE self-hosted backends: `FIRECRAWL_URL` (default `http://localhost:3002`) + `FIRECRAWL_API_VERSION=v1\|v2` + `FIRECRAWL_ENABLED` + `FIRECRAWL_API_KEY` (default `placeholder-local`); `CRAWL4AI_URL` + `CRAWL4AI_API_TOKEN` tier-2 fallback + `CRAWL4AI_ENABLED`; `CACHE_URL` (redis/valkey), `RERANKER_URL`, `OLLAMA_URL`/`LLM_BASE_URL`. Tier cascade: Firecrawl → Crawl4AI → raw+Readability →(opt) Wayback; Kiwix/Reddit/YT fast paths. Caveat: Firecrawl/Crawl4AI are FETCH tiers behind SearXNG search — no Firecrawl-search or Crawl4AI-native tools exposed. v2 API boundary: no `actions`, `wait_for_selector` degrades to fixed `FIRECRAWL_WAIT_FOR_MS` delay; LLM formats need backend LLM endpoint. |
| fadenstack/mcp-server-searxng | 0 / 2026-10-13 | streamable HTTP (`MCP_SEARXNG_BASE_URL`, port 8101, `MCP_SEARXNG_AUTH_TOKEN`) | `MCP_SEARXNG_BASE_URL` (default :8080) | Optional bearer | **REJECT — re-containerizes SearXNG** (supervisord runs its own SearXNG in the same image). Violates mission constraint. |
| bumbaRasch/searxng-mcp-server | 2 / 2026-10-18 | stdio (npx) | self-hosted instance (key not verified) | keyless | Backup only; 13 tools + MCP Tasks + SSRF guarding; env key unverified — verify before use. |
| Others (STIFLEUR390, teran, pete-builds, shoutsid, Paulr13-lite, Ethos6/free-search-api, Knuckles-Team…) | ≤2★, Oct 2026 | mixed | own SearXNG | keyless | Not audited — ihor covers the need. |

### B2. Firecrawl MCP servers

| Repo | ★ / pushed | Transport | Base-URL key | Auth | Verdict |
|---|---|---|---|---|---|
| **firecrawl/firecrawl-mcp-server (OFFICIAL)** | **7634 / 2026-10-19** | stdio (default) + streamable HTTP (`HTTP_STREAMABLE_SERVER=true`, container `:3000/mcp`, `HOST`/`PORT`) + SSE | **`FIRECRAWL_API_URL` → self-hosted API; `FIRECRAWL_API_KEY` OPTIONAL with self-host** ("Optional when using self-hosted instance with FIRECRAWL_API_URL") | Cloud: `Bearer fc-…` (`FIRECRAWL_API_KEY`); self-host: none by default → key optional. HTTP transports also accept `Authorization: Bearer <fco_oauth>` / `x-firecrawl-api-key`. | **BEST PICK.** All tools work against self-host (search/scrape/map/crawl/interact/monitor); backend-gated features degrade (see §D). |
| cipher-rc5/firecrawl-mcp-effect | 5 / 2026-08-29 | self-hostable HTTP (Vercel/Bun) | self-host URL supported | key or self-host URL | Passes liveness; redundant given official support. Not needed. |
| pipeworx-io/mcp-firecrawl, FahadUrRehman07/…, etc. | ≤4★, Sep 2026 or older | — | hardcode cloud (unverified) | cloud keys | Skip: no verified self-host base-URL support. |

### B3. Crawl4AI MCP servers — BLOCKER LIVES HERE

- Crawl4AI docker server exposes MCP **natively** (official docs v0.9.x, verified):
  **SSE `http://host:11235/mcp/sse` + WebSocket `ws://host:11235/mcp/ws`**, tools
  `md/html/screenshot/pdf/execute_js/crawl/ask`, schemas at `/mcp/schema`.
  **Pi's MCP client REJECTS SSE** (`sse` entries refused; only stdio or streamable HTTP).
  No streamable-HTTP `/mcp` endpoint documented → **pi cannot consume the native
  endpoint directly. No extra MCP server needed OR usable — use REST.**
- `walksoda/crawl-mcp` (48★, pushed 2026-10-10, PASS): stdio + HTTP(:8000) — BUT wraps
  the **local crawl4ai Python lib** (needs Python 3.11 + Playwright + browsers in the pi
  host; Docker image bundles Chromium/Firefox/WebKit = duplicate browser stack); search
  tools need **cloud keys** (Google/Brave/Exa); NO `CRAWL4AI_URL` remote-server option
  found. **Mismatch: does not front the :11235 docker server. REJECT for this mission.**
- `azure-architect/crawl4ai-mcp-server` (2026-09-22) / `Kaoz625/crawl4ai-mcp` (2026-08-29):
  docs wrappers around the native SSE endpoint (`…/mcp/sse`) → pi-incompatible. REJECT.
- Crawl4AI 0.9.x secure-by-default (verified official docs): **`CRAWL4AI_API_TOKEN` REQUIRED**
  — without it the server binds container-loopback → published port = connection reset
  (looks healthy!). Every REST/MCP call: `Authorization: Bearer $TOKEN` (`/health` exempt).
  Deep crawl disabled by default (`CRAWL4AI_ALLOW_DEEP_CRAWL=true` to enable);
  `hooks.code` removed (declarative hooks only, behind `CRAWL4AI_HOOKS_ENABLED=true`);
  `output_path` removed → artifact flow (`artifact_id` + `GET /artifacts/{id}`).
  REST surface: `POST /crawl /crawl/stream /md /html /screenshot /pdf /execute_js`,
  `POST /crawl/job /llm/job`, `GET /job/{id}`, `/hooks/info`, `/playground`, `/dashboard`.

---

## C. WIRING DESIGN (ranked)

**🥇 WINNER — (3)-variant: pi-deep-research provider chain** (pi extension calling REST
directly, but ~zero custom code: 2 shipped plugins + 1 small new plugin; NO extra MCP
servers, NO containers, all-ZeroTier via env vars):

```bash
mkdir -p ~/.pi/agent/pi-deep-research/providers
cp <review>/pi-deep-research/examples/providers/{searxng,firecrawl}.ts \
   ~/.pi/agent/pi-deep-research/providers/
# + crawl4ai.ts (snippet below) into the same dir
export SEARXNG_BASE_URL=http://zt-ip:8888
export FIRECRAWL_BASE_URL=http://zt-ip:3002
export CRAWL4AI_BASE_URL=http://zt-ip:11235
export CRAWL4AI_API_TOKEN='<token>'   # required ≥0.9.0
export SEARCH_PROVIDERS=crawl4ai,searxng,firecrawl   # or config.json {"providers":[…]}
# SearXNG side: settings.yml → search.formats: [html, json]  (else 403)
```

`crawl4ai.ts` plugin sketch (conforms to `SearchProvider`; extract-only):
```ts
declare const process: { env: Record<string, string | undefined> };
export default {
  name: "crawl4ai", tier: "local" as const,
  isConfigured: () => Boolean(process.env.CRAWL4AI_BASE_URL && process.env.CRAWL4AI_API_TOKEN),
  async search() { return []; },                       // no index → chain moves on
  async extract(url: string, signal?: AbortSignal) {
    const base = process.env.CRAWL4AI_BASE_URL!.replace(/\/+$/, "");
    const resp = await fetch(`${base}/md`, {
      method: "POST", signal: signal ?? AbortSignal.timeout(30000),
      headers: { "Content-Type": "application/json",
                 "Authorization": `Bearer ${process.env.CRAWL4AI_API_TOKEN}` },
      body: JSON.stringify({ url }),
    });
    if (!resp.ok) throw new Error(`Crawl4AI md error ${resp.status}: ${await resp.text()}`);
    const data = (await resp.json()) as { markdown?: string; title?: string };
    const content = (data.markdown ?? "").trim();
    if (!content) throw new Error("Crawl4AI returned no content");
    return { title: data.title ?? "", url, content,
             wordCount: content.split(/\s+/).length, provider: "crawl4ai" };
  },
};
```
NOTE: chain tries providers in order; put `crawl4ai` where its JS-rendered extract
should win (extract walks the SAME order, first capable provider wins). Keep SearXNG first
for search breadth, Crawl4AI early for extract quality — order is one chain for both
roles, so `searxng,crawl4ai,firecrawl` is the balanced default; tune per task.

**🥈 RUNNER-UP — (2) three dedicated MCP servers** in `~/.pi/agent/mcp.json`
(works, but heavier + Crawl4AI gap forces a hybrid):
```json
{ "mcpServers": {
  "searxng":   { "command": "npx", "args": ["-y","mcp-searxng"],
                 "env": { "SEARXNG_URL": "http://zt-ip:8888",
                          "MCP_HTTP_ALLOW_PRIVATE_URLS": "true" } },
  "firecrawl": { "command": "npx", "args": ["-y","firecrawl-mcp"],
                 "env": { "FIRECRAWL_API_URL": "http://zt-ip:3002" } },
  "crawl4ai":  { "url": "http://zt-ip:11235/mcp/sse" }   // ← REJECTED by pi (SSE). Use TadMSTR tier-2 or REST instead
}}
```
Prefer streamable-HTTP form for Docker-proxied hosts: ihor (`MCP_HTTP_PORT` service +
`"url": "http://zt-ip:PORT/mcp"`) and official firecrawl (`HTTP_STREAMABLE_SERVER=true`
`:3000/mcp`). Crawl4AI slot stays empty → fill with TadMSTR/searxng-mcp
(`CRAWL4AI_URL=http://zt-ip:11235` + token) as fetch cascade, or REST via winner.

**🥉 (1) pi-intelli-search MCP + custom endpoints — NOT VIABLE without fork.**
No endpoint config surface (search=Sonar/OpenRouter tool; fetch=direct HTTP; MCP models
locked to `openrouter`). Requires source changes in `operations/search.ts` + `core/fetch.ts`.
Revisit only if its 5-stage evidence pipeline (Defuddle-vs-MD scoring, per-page extract,
collate, cache-suggest) is needed AND cloud Sonar search is acceptable — then run it
alongside the winner (intelli extract/collate CAN use local pi-registry models natively).

---

## D. FIRECRAWL SELF-HOSTED vs CLOUD (API differences that matter)

- **Auth/header:** cloud `Authorization: Bearer fc-…` REQUIRED. Self-host default
  **unauthenticated** (`USE_DB_AUTHENTICATION=false`); `FIRECRAWL_API_KEY` optional;
  add reverse-proxy Basic auth if exposed (pi-deep-research plugin: `FIRECRAWL_BASIC_AUTH`).
  Official MCP: `FIRECRAWL_API_URL` + optional `FIRECRAWL_API_KEY`.
- **Endpoints/versions:** OSS baseline speaks **`/v1`** (`/v1/search`, `/v1/scrape`,
  `/v1/crawl`; API published on `:3002`; self stack ≈ API+workers+Playwright+Redis/
  RabbitMQ/NuQ-Postgres). Upstream 2.x moved to **`/v2`** (`/v2/scrape|crawl|map`);
  never mix prefixes (404s). `firecrawl-simple` image = v1 only.
- **Missing without extra config:** Fire-engine (stealth proxy, `actions`, screenshots)
  is closed-source cloud-only — self-hosted engines (`fetch/playwright/pdf/document`)
  report `actions:false`; scrape carrying `actions` → HTTP 400 (no degrade). LLM-backed
  formats (`json/summary/highlights`, `/v1/extract`) need a model provider wired on the
  backend (OpenAI / OpenAI-compatible / Ollama) or they fail.
- **Ops you own:** persistence (Compose ships NO volumes for PG/Redis/RabbitMQ),
  TLS/auth/network policy, monitoring, rate limits (default API has none).
- **Safe client pattern (works on both):** search with `scrapeOptions:{formats:[]}`,
  scrape with `formats:["markdown"]`, treat blank markdown as failure (per example plugin).

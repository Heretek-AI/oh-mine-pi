# LOCKED ARCHITECTURE DECISIONS — grill phase 2026-10-19

Source: audit/FINAL_ECOSYSTEM_MATRIX.md §7, resolved via @grill-me interview.
All 10 trade-offs closed. Reopening any item requires new evidence.

1. Topology: SIDECARS — host-pi + disposable RE/QA sidecars, shared `./targets:ro` only.
2. IPC/bus: PI-FABRIC MESH (15.9MB accepted for cross-host headroom; exec-stdio shim as fallback).
3. Android: STEER VIA APP — companion app (happier) over ZeroTier; keys never on phone. Termux deferred.
4. OpenCode Go pooling: POOLED ROTATION — per-agent keys + pi-multi-account + pi-router + pi-bifrost.
5. RE images: ADOPT PUBLISHED — alexmi256/rea-agent + psyb0t image over building re-box. (re-box verdict: alive, 85%, needs shim; revisit if published images rot.)
6. ADE: HAPPIER (MIT, MCP external-drive, relay over ZeroTier). Paseo rejected on license; codeg kept as fallback.
7. Memory: FILE-BACKED LEDGER — server-memory/sqlite on named volumes, zero new deps.
8. Secrets: ENV-PASSTHROUGH at runtime + owner-only auth.json; never baked into images.
9. Research: PROVIDER CHAIN — pi-deep-research + SearXNG/Firecrawl plugins + custom crawl4ai.ts; 3 env vars; SearXNG needs `search.formats: [html, json]`; Firecrawl server pinned to v1 API.
10. QA enforcement: PERMISSION SYSTEM — pi-permission-system + docker-mcp read-only modes; convention skill as backstop only.

## Implied compose shape (to be drafted)
services: pi-coordinator (pi-subagents + pi-goal-x + fabric + pooled Go keys), pi-researcher (provider chain + ZT env),
pi-qa (semgrep/sonarqube MCP + permission system), pi-tester (playwright + docker-mcp), re-sidecar (adopted rea-agent image,
exec-stdio now, HTTP later), mobsf (REST via shim), memory volume, pi-home volume, ./targets:ro, ./workspace.
Net: ZeroTier adjacency assumed; no ZT container (existing infra, API/MCP only).

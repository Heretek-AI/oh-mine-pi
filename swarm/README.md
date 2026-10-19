# oh-mine-pi swarm

Docker Compose stack for a `pi-coding-agent` swarm. Evidence chain:
`audit/raw_waves/` → `audit/FINAL_ECOSYSTEM_MATRIX.md` → `audit/DECISIONS.md`.
This stack is the executable form of the 10 locked decisions.

## Services

| Service | Role | Home volume |
|---|---|---|
| `pi-coordinator` | decomposition, pi-subagents + goal-x + fabric mesh, pooled Go keys | `pi-home-coordinator` |
| `pi-researcher` | ZeroTier trio via provider chain (SearXNG/Firecrawl/Crawl4AI) | `pi-home-researcher` |
| `pi-qa` | Semgrep via socket, permission-system gates | `pi-home-qa` |
| `pi-tester` | E2E skills, healthchecks via docker CLI | `pi-home-tester` |
| `rea` (profile `re`) | RE sidecar, `ghcr.io/alexmi256/rea-agent` | — |
| `mobsf` (profile `re`) | Mobile SAST, loopback `:8000` | `mobsf-data` |

Shared: `swarm-memory` (file-backed ledger), `./targets:ro`, `../workspace:/workspace`.

## Run

```bash
cp swarm/env.example swarm/.env   # fill secrets; never commit .env
docker compose -f swarm/docker-compose.swarm.yml up -d --build
docker compose -f swarm/docker-compose.swarm.yml --profile re up -d
docker compose -f swarm/docker-compose.swarm.yml run --rm rea apropos dex
```

Phone steering: self-host happier relay on a ZeroTier-joined host, point the
app at it (see `HAPPIER_RELAY_URL`). Keys never leave the swarm host.

## Research wiring (decision #9)

`pi-researcher` seeds `~/.pi/agent/pi-deep-research/providers/` with
`searxng.ts` + `firecrawl.ts` (upstream examples, czhiming-maker/pi-deep-research)
plus our `crawl4ai.ts` extract plugin. Chain order: `SEARCH_PROVIDERS`
(default `searxng,crawl4ai,firecrawl`). Gotchas, all verified:
- SearXNG needs `search.formats: [html, json]` in `settings.yml` (else 403).
- Self-hosted Firecrawl speaks `/v1` — keep `FIRECRAWL_API_VERSION=v1`.
- Crawl4AI ≥ 0.9 requires `CRAWL4AI_API_TOKEN` (sender loopback otherwise);
  its native MCP is SSE-only, so REST is the only pi-compatible path.

## Trust notes (read before production)

- Socket mounts (`/var/run/docker.sock` in coordinator/qa/tester) are
  root-equivalent on the host. Acceptable on a single-operator box; do not
  expose these containers to untrusted input.
- `swarm/images/pi-swarm/mcp/*.json` uses the `{"name": {"command": [...]}}`
  shape from audit evidence — confirm with `pi mcp --help` on first run and
  adjust; the entrypoint never overwrites your edited `mcp.json`.
- Extension specs in `PI_EXTENSIONS` install best-effort (warn-and-continue);
  a renamed npm package degrades to a warning, not a dead container.
- `REA_IMAGE`/`MOBSF_IMAGE` default to published images (decision #5). To
  build from `Heretek-AI/re-box` instead, apply the §5 delta in
  `audit/raw_waves/wave3_re_sidecars.md`.

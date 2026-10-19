# oh-mine-pi

Lightweight packaging for vanilla Pi (`@earendil-works/pi-coding-agent`,
upstream: https://github.com/earendil-works/pi).

Persistence model is borrowed from
[getpaseo/paseo](https://github.com/getpaseo/paseo),
[happier-dev/happier](https://github.com/happier-dev/happier),
[spacering-net/codeg](https://github.com/spacering-net/codeg) and
[stablyai/orca](https://github.com/stablyai/orca), scoped down to what a CLI needs:

- `pi-home` named volume → `/home/pi` (auth, sessions, skills, config)
- `./workspace` bind mount → `/workspace` (your code, pi's cwd)

Unlike those four, vanilla pi is a CLI, not a daemon — so there are no ports,
no healthcheck, and no supervisor. The image just runs `pi` as non-root `pi`
(uid 1000) behind `tini` + `gosu`, like Paseo's base image.

## Use

```bash
docker compose run --rm pi pi              # interactive session
docker compose run --rm pi pi --version
PI_VERSION=1.3.0 docker compose build      # pin upstream version
```

State survives recreates in the `pi-home` volume (`docker volume rm oh-mine-pi_pi-home` to reset).

## CI

`.github/workflows/ci.yml` validates compose, builds `linux/amd64`, smoke-tests
(`pi --version`, non-root `whoami`, volume-mounted run), and pushes to
`ghcr.io/heretek-ai/oh-mine-pi` on `main` / `v*.*.*` tags. PRs build + test only.

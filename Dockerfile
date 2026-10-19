# syntax=docker/dockerfile:1
# Vanilla Pi packaging.
# Upstream: https://github.com/earendil-works/pi (`@earendil-works/pi-coding-agent`, bin `pi`)
# Persistence pattern borrowed from:
#   - getpaseo/paseo  (named/bind mount for $HOME + /workspace, tini+gosu entrypoint)
#   - spacering-net/codeg (single named volume, e.g. codeg-data:/data)
#   - happier-dev/happier (VOLUME ["/data"], chown /data to non-root user)

ARG NODE_IMAGE=node:22-bookworm-slim
FROM ${NODE_IMAGE}

# Pin with `--build-arg PI_VERSION=1.3.0`. `latest` tracks the npm dist-tag.
ARG PI_VERSION=latest

ENV HOME=/home/pi \
    XDG_CONFIG_HOME=/home/pi/.config \
    XDG_DATA_HOME=/home/pi/.local/share \
    XDG_STATE_HOME=/home/pi/.local/state \
    XDG_CACHE_HOME=/home/pi/.cache

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      git \
      gosu \
      openssh-client \
      procps \
      tini; \
    rm -rf /var/lib/apt/lists/*

# Upstream install method is `npm install -g --ignore-scripts` (no lifecycle
# scripts needed for a normal install). Pinned transitive deps come from the
# installer's lockfile, not from npm, so npm stays correct for vanilla use.
RUN set -eux; \
    if [ "${PI_VERSION}" = "latest" ]; then \
      npm install -g --ignore-scripts @earendil-works/pi-coding-agent; \
    else \
      npm install -g --ignore-scripts @earendil-works/pi-coding-agent@${PI_VERSION}; \
    fi; \
    npm cache clean --force; \
    pi --version

# Non-root `pi` user (uid 1000). The node base image already owns uid 1000
# as `node`, so rename in place like Paseo's base image does.
RUN set -eux; \
    existing_group="$(getent group 1000 | cut -d: -f1 || true)"; \
    if [ -n "$existing_group" ] && [ "$existing_group" != "pi" ]; then \
      groupmod --new-name pi "$existing_group"; \
    elif [ -z "$existing_group" ]; then \
      groupadd --gid 1000 pi; \
    fi; \
    existing_user="$(getent passwd 1000 | cut -d: -f1 || true)"; \
    if [ -n "$existing_user" ] && [ "$existing_user" != "pi" ]; then \
      usermod --login pi --gid pi --home /home/pi --shell /bin/bash "$existing_user"; \
    elif [ -z "$existing_user" ]; then \
      useradd --uid 1000 --gid pi --create-home --home-dir /home/pi --shell /bin/bash pi; \
    fi; \
    mkdir -p /workspace /home/pi/.pi "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"; \
    rm -rf /home/node; \
    chown -R pi:pi /home/pi /workspace

COPY docker/entrypoint.sh /usr/local/bin/pi-docker-entrypoint
RUN chmod +x /usr/local/bin/pi-docker-entrypoint

WORKDIR /workspace

# Persist auth, sessions, skills and config across container recreates.
# (Code lives in /workspace, mounted separately in compose.)
VOLUME ["/home/pi"]

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/pi-docker-entrypoint"]
CMD ["pi", "--help"]

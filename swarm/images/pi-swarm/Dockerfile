# Role image for every pi swarm agent. Lean by design: extensions install at
# first container start (persisted on the role's pi-home volume), so the image
# stays a thin, cache-friendly layer over the vanilla pi base.
ARG BASE_IMAGE=ghcr.io/heretek-ai/oh-mine-pi:latest
FROM ${BASE_IMAGE}

ARG PI_VERSION=latest
# ROLE is set per service (coordinator/researcher/qa/tester).
ENV ROLE=coordinator

USER root
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends docker-cli gettext-base; \
    rm -rf /var/lib/apt/lists/*
# docker-cli: exec-stdio shims + healthchecks via mounted socket (qa/tester/coordinator).
# gettext-base: envsubst for role mcp.json templating in the entrypoint.

COPY mcp/ /etc/pi-swarm/mcp/
COPY research/ /etc/pi-swarm/research/
COPY swarm-entrypoint.sh /usr/local/bin/swarm-entrypoint
RUN chmod +x /usr/local/bin/swarm-entrypoint

USER pi
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/swarm-entrypoint"]
CMD ["pi"]

#!/bin/bash
# Role entrypoint: seed MCP profile + research providers, best-effort install
# PI_EXTENSIONS once (marker in $HOME, survives on the role volume), then pi.
# Mirrors the base image contract: fix volume ownership as root, run as pi.
set -euo pipefail

ROLE="${ROLE:-coordinator}"
PI_HOME_DIR="${HOME:-/home/pi}"
MARKER="$PI_HOME_DIR/.pi-swarm-seeded"

seed_files() {
  local mcp_src="/etc/pi-swarm/mcp/${ROLE}.json"
  local mcp_dst="$PI_HOME_DIR/.pi/agent/mcp.json"
  if [ ! -f "$mcp_dst" ]; then
    mkdir -p "$(dirname "$mcp_dst")"
    if [ -f "$mcp_src" ]; then
      # Expand ${VAR} placeholders (container names, ZT hosts) at seed time only;
      # later user edits to mcp.json are never overwritten.
      envsubst < "$mcp_src" > "$mcp_dst"
    else
      echo '{}' > "$mcp_dst"
    fi
  fi
  if [ "$ROLE" = "researcher" ]; then
    local prov_dir="$PI_HOME_DIR/.pi/agent/pi-deep-research/providers"
    mkdir -p "$prov_dir"
    for f in /etc/pi-swarm/research/*.ts; do
      [ -e "$f" ] || continue
      cp -n "$f" "$prov_dir/" 2>/dev/null || true
    done
  fi
  mkdir -p /memory 2>/dev/null || true
}

install_extensions() {
  [ -f "$MARKER" ] && return 0
  # shellcheck disable=SC2086
  for spec in ${PI_EXTENSIONS:-}; do
    pi install "$spec" || echo "WARN: extension install failed: $spec (continuing)" >&2
  done
  touch "$MARKER"
}

if [ "$(id -u)" = "0" ]; then
  mkdir -p "$PI_HOME_DIR/.pi" /workspace /targets /memory 2>/dev/null || true
  chown -R pi:pi "$PI_HOME_DIR" /workspace /memory 2>/dev/null || true
  exec gosu pi "$0" "$@"
fi

seed_files
install_extensions
# Exec args raw (compose/CI pass `pi ...` explicitly). Wrapping in `pi` would
# turn `whoami`-style probes into agent prompts requiring an API key.
exec "$@"

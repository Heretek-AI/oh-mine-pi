#!/bin/bash
# Fixes ownership of the persisted $HOME volume, then drops to `pi`.
# Mirrors getpaseo/paseo's docker entrypoint (tini + gosu), minus the daemon bits:
# vanilla pi is a CLI, not a server, so there is no supervisor here.
set -euo pipefail

PI_HOME="${HOME:-/home/pi}"

mkdir -p "$PI_HOME/.pi" /workspace

# Mounted named volumes start out root-owned on first use; make them usable.
if [ "$(id -u)" = "0" ]; then
  chown -R pi:pi "$PI_HOME" /workspace 2>/dev/null || true
  exec gosu pi "$@"
fi

exec "$@"

#!/bin/bash
# Exec-stdio shim: drive the RE sidecar's MCP server from any host with a
# docker socket. Matches the pattern verified in audit §5 (`re-box` delta):
#   bin/rea-stdio-shim.sh [container] [args...]
# pi mcp.json equivalent: {"command":["docker","exec","-i","swarm-rea","rea","mcp"]}
set -euo pipefail
CONTAINER="${1:-swarm-rea}"
shift || true
exec docker exec -i "$CONTAINER" rea mcp "$@"

#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT"

if [ ! -d "src/frontend" ] || [ ! -d "src/game-service/Game.Application" ]; then
  echo "ERROR: Please run this script from the original maple-fighters repository root."
  echo "Expected directories:"
  echo "  src/frontend"
  echo "  src/game-service/Game.Application"
  exit 1
fi

if [ ! -f ".env.server" ]; then
  cp .env.server.example .env.server
  echo "Created .env.server from .env.server.example"
fi

if [ -f "src/frontend/nginx.conf" ] && [ ! -f "src/frontend/nginx.conf.original" ]; then
  cp src/frontend/nginx.conf src/frontend/nginx.conf.original
  echo "Backed up original src/frontend/nginx.conf -> src/frontend/nginx.conf.original"
fi

cp src/frontend/nginx.server.conf src/frontend/nginx.conf
echo "Applied server nginx config -> src/frontend/nginx.conf"

docker compose -f docker-compose.server.yml --env-file .env.server config >/tmp/maple-fighters-compose-config.yml
echo "Compose config check passed."

docker compose -f docker-compose.server.yml --env-file .env.server up -d --build

PORT="$(grep -E '^PUBLIC_HTTP_PORT=' .env.server | tail -n1 | cut -d= -f2)"
PORT="${PORT:-80}"

SERVER_IP="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
if [ -z "$SERVER_IP" ]; then
  SERVER_IP="<SERVER_IP>"
fi

echo
echo "Deployment started."
echo "Open:"
if [ "$PORT" = "80" ]; then
  echo "  http://${SERVER_IP}"
else
  echo "  http://${SERVER_IP}:${PORT}"
fi
echo
echo "Logs:"
echo "  docker compose -f docker-compose.server.yml --env-file .env.server logs -f"

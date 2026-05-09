#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

retry() {
  local name="$1"
  local attempts="$2"
  local delay="$3"
  shift 3

  local i
  for i in $(seq 1 "$attempts"); do
    echo "[deploy-prod] ${name}, attempt ${i}/${attempts}"
    if "$@"; then
      return 0
    fi
    sleep "$delay"
  done

  echo "[deploy-prod] ${name} failed after ${attempts} attempts" >&2
  return 1
}

check_websocket() {
  local ws_response
  ws_response="$(timeout 8s curl -i -N \
    -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Version: 13" \
    -H "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
    http://127.0.0.1/game || true)"

  printf '%s\n' "${ws_response}"
  printf '%s\n' "${ws_response}" | grep -q '101 Switching Protocols'
}

if [ ! -f docker-compose.server.yml ]; then
  echo "[deploy-prod] docker-compose.server.yml not found in ${PROJECT_ROOT}" >&2
  exit 1
fi

if [ ! -f .env.server ]; then
  echo "[deploy-prod] .env.server not found; copying .env.server.example"
  cp .env.server.example .env.server
fi

if grep -q '^REACT_APP_ENV=' .env.server; then
  sed -i 's/^REACT_APP_ENV=.*/REACT_APP_ENV=Production/' .env.server
else
  printf '\nREACT_APP_ENV=Production\n' >> .env.server
fi

echo "[deploy-prod] Validating Docker Compose configuration"
docker compose -f docker-compose.server.yml --env-file .env.server config

echo "[deploy-prod] Building and starting services"
docker compose -f docker-compose.server.yml --env-file .env.server up -d --build

retry "Checking HTTP health endpoint" 20 2 curl -f http://127.0.0.1/healthz

retry "Checking game provider endpoint" 20 2 curl -f http://127.0.0.1/gameprovider/games

retry "Checking /game WebSocket handshake" 20 2 check_websocket

echo "[deploy-prod] Deployment succeeded. Jianghu Chronicles is running."

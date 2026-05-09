#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_DIR="${APP_DIR:-${PROJECT_ROOT}}"
BRANCH="${BRANCH:-main}"

cd "${APP_DIR}"

if [ -d .git ]; then
  git fetch origin "${BRANCH}"
  git reset --hard "origin/${BRANCH}"
fi

if [ ! -f .env.server ]; then
  cp .env.server.example .env.server
  echo "Created .env.server from .env.server.example"
fi

if grep -q '^REACT_APP_ENV=' .env.server; then
  sed -i 's/^REACT_APP_ENV=.*/REACT_APP_ENV=Production/' .env.server
else
  echo 'REACT_APP_ENV=Production' >> .env.server
fi

docker compose -f docker-compose.server.yml --env-file .env.server up -d --build

docker compose -f docker-compose.server.yml --env-file .env.server ps
curl -f http://127.0.0.1/healthz
curl -f http://127.0.0.1/gameprovider/games

echo "Production deployment completed successfully."

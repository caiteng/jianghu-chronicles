$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

if (-not (Test-Path "src/frontend") -or -not (Test-Path "src/game-service/Game.Application")) {
    Write-Host "ERROR: Please run this script from the original maple-fighters repository root."
    Write-Host "Expected directories:"
    Write-Host "  src/frontend"
    Write-Host "  src/game-service/Game.Application"
    exit 1
}

if (-not (Test-Path ".env.server")) {
    Copy-Item ".env.server.example" ".env.server"
    Write-Host "Created .env.server from .env.server.example"
}

if ((Test-Path "src/frontend/nginx.conf") -and -not (Test-Path "src/frontend/nginx.conf.original")) {
    Copy-Item "src/frontend/nginx.conf" "src/frontend/nginx.conf.original"
    Write-Host "Backed up original src/frontend/nginx.conf -> src/frontend/nginx.conf.original"
}

Copy-Item "src/frontend/nginx.server.conf" "src/frontend/nginx.conf" -Force
Write-Host "Applied server nginx config -> src/frontend/nginx.conf"

docker compose -f docker-compose.server.yml --env-file .env.server config | Out-Null
Write-Host "Compose config check passed."

docker compose -f docker-compose.server.yml --env-file .env.server up -d --build

Write-Host ""
Write-Host "Deployment started."
Write-Host "Open http://SERVER_IP or http://SERVER_IP:PUBLIC_HTTP_PORT according to .env.server"
Write-Host ""
Write-Host "Logs:"
Write-Host "  docker compose -f docker-compose.server.yml --env-file .env.server logs -f"

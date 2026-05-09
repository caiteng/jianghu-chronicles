#!/usr/bin/env bash
set -euo pipefail

# Minimal Docker installation helper for Ubuntu servers.
# Run as root or with sudo:
#   sudo bash scripts/install-docker-ubuntu.sh

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This helper only supports Ubuntu/Debian apt-based systems."
  exit 1
fi

apt-get update
apt-get install -y ca-certificates curl gnupg git

install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

. /etc/os-release
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

docker --version
docker compose version

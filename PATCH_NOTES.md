# Patch Notes

## v0.1-server-ip-multiplayer

目标：让 `codingben/maple-fighters` 可以部署到云服务器，通过 IP 访问，并支持多人连接。

变更：

- 新增 `docker-compose.server.yml`
  - 前端端口使用 `${PUBLIC_HTTP_PORT:-80}:80`
  - `game-service` 不暴露公网端口，只在 Docker 网络内部可见
  - `MAX_CONNECTIONS` 可配置
  - 两个容器都使用 `restart: unless-stopped`

- 新增 `.env.server.example`
  - 配置公网 HTTP 端口
  - 配置最大连接数
  - 配置日志等级

- 新增 `src/frontend/nginx.server.conf`
  - `server_name _`
  - 支持直接通过 IP 访问
  - `/game` WebSocket 代理到 `game-service:50051`
  - 增加 `/healthz`
  - 增加长连接 timeout
  - 关闭 WebSocket buffer

- 新增部署脚本
  - `scripts/apply-server-deploy.sh`
  - `scripts/apply-server-deploy.ps1`
  - `scripts/install-docker-ubuntu.sh`

未改动：

- 不改 Unity 客户端资源
- 不改游戏玩法
- 不改服务端业务逻辑
- 不引入新依赖

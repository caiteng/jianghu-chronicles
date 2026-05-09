# 部署说明

## 服务器要求

- Linux 服务器。
- Docker。
- Docker Compose plugin（支持 `docker compose` 命令）。
- 开放 80 端口，或开放 `.env.server` 中配置的 `PUBLIC_HTTP_PORT`。

## 首次部署

```bash
git clone https://github.com/caiteng/jianghu-chronicles.git
cd jianghu-chronicles
cp .env.server.example .env.server
./scripts/deploy-prod.sh
```

## 更新部署

```bash
git pull
./scripts/deploy-prod.sh
```

## GitHub Actions 自动部署

如果仓库存在 `.github/workflows/deploy.yml`，则 `main` 分支 push 后会自动部署，也可以在 GitHub Actions 页面手动触发。

需要配置以下 GitHub Secrets：

- `DEPLOY_HOST`
- `DEPLOY_USER`
- `DEPLOY_PORT`
- `DEPLOY_PATH`
- `DEPLOY_SSH_KEY`

不要把 SSH 私钥或任何 Secret 写入仓库。

## 健康检查命令

```bash
curl http://127.0.0.1/healthz
curl http://127.0.0.1/gameprovider/games
docker compose -f docker-compose.server.yml --env-file .env.server ps
docker compose -f docker-compose.server.yml --env-file .env.server logs -f
```

## 常见问题

### `WebGL.framework.js Unexpected token '<'`

通常是 Unity WebGL gzip 配置损坏，浏览器拿到了 HTML fallback 而不是 gzip 后的 JavaScript。请检查 `src/frontend/nginx.conf` 中 `.framework.js`、`.wasm`、`.data` 的 `try_files` 与 `Content-Encoding gzip` 配置。

### 仍出现 localhost 或历史域名请求

请检查容器启动后 `local-runtime-patch.js` 是否已注入到 `index.html`，并在浏览器控制台确认出现 `[local-runtime-patch] enabled`。

### `/game` WebSocket 不通

请检查 `game-service` 容器是否运行，确认 Nginx `/game` 代理仍指向 `game-service:50051`，并查看：

```bash
docker compose -f docker-compose.server.yml --env-file .env.server logs -f
```

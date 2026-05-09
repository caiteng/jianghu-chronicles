# Jianghu Chronicles Deployment

本项目的 CI/CD 尽量与 `caiteng/Rune-Dice` 保持一致：GitHub Actions 推送到 `main` 后，通过 `appleboy/ssh-action` SSH 到同一台服务器，在服务器目录中执行部署脚本。

## GitHub Actions 配置

Workflow 使用 GitHub Actions environment：`武汉2C2G`。

需要在该 environment 中配置并复用以下 Secrets：

- `DEPLOY_HOST` - 服务器公网 IP 或域名。
- `DEPLOY_USER` - SSH 用户，例如 `root`。
- `DEPLOY_SSH_KEY` - SSH 私钥内容。
- `DEPLOY_PORT` - SSH 端口。

部署目录在 workflow 中固定为当前服务器目录：`/root/maple-fighters`。

## 服务器首次部署

1. 安装 Docker / Docker Compose。
2. clone 仓库到服务器部署目录：
   ```bash
   git clone https://github.com/caiteng/jianghu-chronicles.git /root/maple-fighters
   cd /root/maple-fighters
   ```
3. 创建服务器环境文件：
   ```bash
   cp .env.server.example .env.server
   ```
4. 设置生产环境：
   ```bash
   if grep -q '^REACT_APP_ENV=' .env.server; then
     sed -i 's/^REACT_APP_ENV=.*/REACT_APP_ENV=Production/' .env.server
   else
     echo 'REACT_APP_ENV=Production' >> .env.server
   fi
   ```
5. 手动执行部署脚本：
   ```bash
   scripts/deploy-prod.sh
   ```

## 后续部署

- push 到 `main` 分支会自动部署。
- 或在 GitHub Actions 页面手动执行 **Run workflow**。

Workflow 会 SSH 到服务器，进入 `/root/maple-fighters`，执行 `scripts/deploy-prod.sh`。脚本会拉取 `origin/main`，保留服务器上的 `.env.server`，强制 `REACT_APP_ENV=Production`，重新构建并启动 Docker Compose 服务，然后执行健康检查。

## 验证命令

在服务器上执行：

```bash
curl http://127.0.0.1/healthz
curl http://127.0.0.1/gameprovider/games
docker compose -f docker-compose.server.yml --env-file .env.server ps
docker compose -f docker-compose.server.yml --env-file .env.server logs -f
```

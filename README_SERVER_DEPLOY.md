# Maple Fighters 服务器部署版改造包

## 选择的基础源码

基础项目：`codingben/maple-fighters`

选择原因：

- 原项目已经是浏览器 Web 游戏。
- 原项目已经有多人 game-service。
- 原项目已经有 Docker Compose。
- 原项目前端通过 Nginx 代理 `/game` WebSocket 到 game-service。
- 第一阶段不需要重写客户端或服务端，只需要改造成“服务器 IP 可访问”的部署结构。

## 这个改造包做了什么

新增/替换：

```text
docker-compose.server.yml
.env.server.example
src/frontend/nginx.server.conf
scripts/apply-server-deploy.sh
scripts/apply-server-deploy.ps1
scripts/install-docker-ubuntu.sh
```

实际部署时，脚本会把：

```text
src/frontend/nginx.server.conf
```

复制覆盖为：

```text
src/frontend/nginx.conf
```

并自动备份原文件到：

```text
src/frontend/nginx.conf.original
```

## 服务器部署步骤

### 1. 准备服务器

推荐 Ubuntu 22.04 / 24.04。

如果服务器还没有 Docker：

```bash
sudo bash scripts/install-docker-ubuntu.sh
```

### 2. 拉取原项目

```bash
git clone https://github.com/codingben/maple-fighters.git
cd maple-fighters
```

### 3. 解压本改造包

把本压缩包内容复制/解压到 `maple-fighters` 根目录。

确认你能看到：

```text
docker-compose.server.yml
.env.server.example
src/frontend/nginx.server.conf
scripts/apply-server-deploy.sh
```

### 4. 修改端口配置

默认使用 80 端口：

```bash
cp .env.server.example .env.server
vi .env.server
```

默认内容：

```env
PUBLIC_HTTP_PORT=80
MAX_CONNECTIONS=100
```

如果你的云服务器 80 端口被占用，改成：

```env
PUBLIC_HTTP_PORT=8080
```

### 5. 启动

```bash
chmod +x scripts/apply-server-deploy.sh
./scripts/apply-server-deploy.sh
```

或者手动执行：

```bash
cp src/frontend/nginx.server.conf src/frontend/nginx.conf
docker compose -f docker-compose.server.yml --env-file .env.server up -d --build
```

### 6. 打开浏览器

如果 `PUBLIC_HTTP_PORT=80`：

```text
http://服务器公网IP
```

如果 `PUBLIC_HTTP_PORT=8080`：

```text
http://服务器公网IP:8080
```

## 云服务器安全组 / 防火墙

至少开放：

```text
TCP 80
```

如果你用了 8080：

```text
TCP 8080
```

不需要向公网开放 `50051`，它是容器内部 game-service 端口，由 Nginx 通过 `/game` 代理访问。

## 多人加入方式

所有玩家打开同一个地址即可：

```text
http://服务器公网IP
```

或：

```text
http://服务器公网IP:8080
```

多人连接数在 `.env.server` 中配置：

```env
MAX_CONNECTIONS=100
```

## 查看日志

```bash
docker compose -f docker-compose.server.yml --env-file .env.server logs -f
```

只看服务端：

```bash
docker compose -f docker-compose.server.yml --env-file .env.server logs -f game-service
```

只看前端/Nginx：

```bash
docker compose -f docker-compose.server.yml --env-file .env.server logs -f frontend
```

## 停止服务

```bash
docker compose -f docker-compose.server.yml --env-file .env.server down
```

## 更新代码后重新部署

```bash
git pull
./scripts/apply-server-deploy.sh
```

## 第一阶段验收标准

部署成功后确认：

- `docker compose ps` 两个容器都是 running。
- 浏览器能打开首页。
- 游戏资源能加载。
- 一个玩家能进入。
- 两个浏览器窗口能同时进入。
- 局域网或公网其他设备能通过服务器 IP 访问。
- `game-service` 日志能看到连接。

## 当前架构

```text
玩家浏览器
  ↓ HTTP / WebSocket
服务器公网 IP:80
  ↓
frontend 容器 / Nginx
  ├─ 静态文件：Unity WebGL + React
  └─ /game WebSocket 代理
       ↓
game-service 容器 :50051
```

## 后续改造建议

第一阶段只做部署闭环，不改玩法。后续建议按这个顺序改：

1. 改项目名、标题、Logo、Loading。
2. 找到 Unity 角色、怪物、地图资源。
3. 做一个自定义角色皮肤。
4. 做一个自定义怪物。
5. 把怪物数值、技能数值抽离成 JSON 或配置文件。
6. 做一个新手地图。
7. 再考虑账号系统、存档、装备、任务。

# 江湖异闻录 / Jianghu Chronicles

《江湖异闻录》是一个古代武侠横版多人 Web 游戏原型。当前阶段优先保持浏览器可玩、服务器可部署、多人连接可验证，并在此基础上逐步把历史工程整理成可持续开发的自有项目。

## 当前状态

- 浏览器可打开并试玩。
- Unity WebGL 客户端负责当前可玩游戏内容。
- React 外壳负责页面标题、加载状态、全屏入口和项目链接。
- Nginx 提供静态文件服务与 `/game` WebSocket 反向代理。
- .NET 5 `game-service` 负责多人连接和游戏消息处理。
- Docker Compose 作为当前唯一服务器部署入口。
- `/gameprovider/games` 本地接口为客户端提供当前服务器信息。
- 运行时 URL 重写补丁会把历史 WebGL 底座中可能写死的旧域名、本机地址请求改写到当前访问来源，用于脱离历史域名运行。

## 启动与部署

本地或服务器均使用同一套部署入口：

```bash
cp .env.server.example .env.server
./scripts/deploy-prod.sh
```

部署脚本会校验 Docker Compose 配置、构建并启动容器，然后检查 `/healthz`、`/gameprovider/games` 和 `/game` WebSocket 握手。

## 访问

部署完成后，在桌面浏览器访问：

```text
http://服务器IP
```

如果 `.env.server` 中修改了 `PUBLIC_HTTP_PORT`，请使用对应端口访问。

## 开发原则

- 始终保持项目可运行、可部署、可试玩。
- 每次只做小步改造，便于回滚和定位问题。
- 不破坏当前可玩版本依赖的 Unity WebGL 构建产物、Nginx 配置和 game-service 连接链路。
- 资源、玩法、角色、怪物、地图、技能和 UI 会逐步替换为自有武侠内容。

## 重要说明

当前版本仍使用历史 WebGL 底座来保证原型可玩。后续会在不破坏部署和试玩链路的前提下，逐步替换角色、怪物、地图、技能、UI 与工程命名，最终演进为完整的《江湖异闻录》项目。

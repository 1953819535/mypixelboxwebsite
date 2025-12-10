# Docker部署指南

本项目支持通过Docker进行部署，包含自动数据获取、定时构建和SSL支持。

## 目录结构

```
.
├── docker-compose.yml      # Docker编排文件
├── Dockerfile              # 应用容器构建文件
├── crontab.conf           # 定时任务配置
├── scripts/
│   ├── fetch-albums.js    # 数据获取脚本
│   └── scheduled-task.sh  # 定时任务执行脚本
├── certs/                 # SSL证书目录（需手动创建）
└── dist/                  # 构建产物目录（自动生成）
```

## 部署步骤

### 1. 准备SSL证书

在项目根目录下创建certs目录，并放入你的SSL证书：

```bash
mkdir certs
# 将你的 fullchain.pem 和 private.key 放入 certs 目录
```

### 2. 配置环境变量

编辑 `.env` 文件或直接在 docker-compose.yml 中设置环境变量：

```yaml
environment:
  - VITE_API_BASE_URL=https://your-api-domain.com
  - IMAGE_URL=https://your-image-domain.com
```

### 3. 启动服务

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

## 定时任务配置

定时任务配置在 `crontab.conf` 文件中：

```bash
# 每天凌晨2点执行一次数据获取和构建任务
0 2 * * * /app/scripts/scheduled-task.sh >> /var/log/scheduled-task.log 2>&1

# 每小时检查一次（可根据需要调整频率）
0 * * * * /app/scripts/scheduled-task.sh >> /var/log/scheduled-task.log 2>&1
```

可以根据需要调整执行频率。

## 访问网站

启动服务后，可以通过以下方式访问：

- 开发服务器: http://localhost:4321

## 日志查看

```bash
# 查看定时任务日志
docker-compose logs -f scheduler

# 查看应用日志
docker-compose logs -f website
```

## 更新和维护

```bash
# 重新构建服务
docker-compose build

# 重启服务
docker-compose restart

# 停止服务
docker-compose down
```
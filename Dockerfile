# 使用官方Node.js运行时作为基础镜像
FROM node:20-alpine

# 设置工作目录
WORKDIR /app

# 全局安装PNPM
RUN npm install -g pnpm

# 安装cron服务
RUN apk add --no-cache curl

# 复制package.json和pnpm-lock.yaml（如果存在）
COPY package.json pnpm-lock.yaml* ./

# 安装项目依赖
RUN pnpm install

# 复制项目的所有文件
COPY . .

# 暴露端口
EXPOSE 4321

# 创建必要的目录
RUN mkdir -p /app/dist /var/log

# 设置脚本执行权限
RUN chmod +x ./scripts/scheduled-task.sh

# 启动定时任务服务
CMD ["crond", "-f"]
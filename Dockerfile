# 使用官方Node.js运行时作为基础镜像
FROM node:20-alpine

# 设置工作目录
WORKDIR /app

# 解决TLS错误：更新CA证书并更换为阿里云镜像源
RUN apk update && \
    apk add --no-cache ca-certificates tzdata && \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# 全局安装PNPM和Docker CLI
RUN npm install -g pnpm

# 安装Docker CLI（用于在容器内操作宿主机Docker）
RUN apk add --no-cache docker-cli git

# 复制package.json和pnpm-lock.yaml（如果存在）
COPY package.json pnpm-lock.yaml* ./

# 安装项目依赖
RUN pnpm install

# 复制项目的所有文件
COPY . .

# 创建必要的目录
RUN mkdir -p /app/dist /app/logs

# 复制构建脚本并设置执行权限
COPY build-and-deploy.sh /app/build-and-deploy.sh
RUN chmod +x /app/build-and-deploy.sh

# 设置非root用户
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# 更改文件所有权
RUN chown -R nextjs:nodejs /app
USER nextjs

# 暴露端口
EXPOSE 4321

# 启动构建脚本
CMD ["/app/build-and-deploy.sh"]
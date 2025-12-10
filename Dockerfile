# 使用官方Node.js运行时作为基础镜像
FROM node:20-alpine

# 设置工作目录
WORKDIR /app

# 更换为阿里云镜像源并一次性安装所有系统依赖
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache docker-cli git && \
    npm install -g pnpm

# 复制package.json和pnpm-lock.yaml（如果存在）
COPY package.json pnpm-lock.yaml* ./

# 设置pnpm使用国内镜像源并安装项目依赖
RUN pnpm install

# 复制项目的所有文件
COPY . .

# 创建必要的目录
RUN mkdir -p /app/dist /app/logs && \
    addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 && \
    chown -R nextjs:nodejs /app && \
    chmod +x /app/build-and-deploy.sh

USER nextjs

# 暴露端口
EXPOSE 4321

# 启动构建脚本
CMD ["/app/build-and-deploy.sh"]
# 使用官方Node.js运行时作为基础镜像
FROM node:20-alpine

# 设置工作目录
WORKDIR /app

# 更换为阿里云镜像源并安装必要工具
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache docker-cli git && \
    npm install -g pnpm

# 复制依赖文件并安装依赖
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install

# 复制项目文件
COPY . .

# 创建必要的目录和文件，设置权限
RUN mkdir -p /app/dist /app/logs && \
    touch /app/.last_commit && \
    chmod +x /app/build-and-deploy.sh

# 暴露端口
EXPOSE 4321

# 启动构建脚本
CMD ["/app/build-and-deploy.sh"]
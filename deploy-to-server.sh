#!/bin/bash

# 部署脚本 - 将文件复制到服务器正确位置

echo "开始部署网站到服务器..."

# 创建必要的目录结构
echo "1. 创建目录结构..."
sudo mkdir -p /srv/apps/mypixelboxwebsite
sudo mkdir -p /srv/apps/mypixelboxwebsite/dist
sudo mkdir -p /srv/apps/mypixelboxwebsite/logs
sudo mkdir -p /srv/apps/mypixelboxwebsite/ssl

# 复制文件到服务器目录
echo "2. 复制文件到服务器..."
sudo cp -r ./* /srv/apps/mypixelboxwebsite/
sudo cp -r ./.* /srv/apps/mypixelboxwebsite/ 2>/dev/null || true

# 特别确保 SSL 证书在正确位置
echo "3. 确保 SSL 证书在正确位置..."
sudo cp ./ssl/* /srv/apps/mypixelboxwebsite/ssl/ 2>/dev/null || true

# 设置正确的权限
echo "4. 设置文件权限..."
sudo chown -R $(id -u):$(id -g) /srv/apps/mypixelboxwebsite
sudo chmod -R 755 /srv/apps/mypixelboxwebsite
sudo chmod 600 /srv/apps/mypixelboxwebsite/ssl/privkey.pem
sudo chmod 644 /srv/apps/mypixelboxwebsite/ssl/fullchain.pem

# 启动 Docker 服务
echo "5. 启动 Docker 服务..."
cd /srv/apps/mypixelboxwebsite
sudo docker-compose down
sudo docker-compose up --build -d

# 检查服务状态
echo "6. 检查服务状态..."
sudo docker-compose ps

echo "部署完成！"
echo ""
echo "您现在可以通过以下方式访问网站："
echo "  - HTTP访问:  http://your-server-ip:8081"
echo "  - HTTPS访问: https://your-server-ip:8443"
echo "  - 测试访问:  http://your-server-ip:8080"
echo ""
echo "注意：由于443端口被占用，我们使用了替代端口："
echo "  - 8081端口替代80端口"
echo "  - 8443端口替代443端口"
echo ""
echo "请确保防火墙已开放 8081、8443、8080 端口"
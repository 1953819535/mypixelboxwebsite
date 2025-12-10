#!/bin/bash

# 测试端口访问脚本
echo "测试端口访问..."
echo "=================="

# 获取服务器IP
SERVER_IP=$(hostname -I | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then
    SERVER_IP="your-server-ip"
fi

echo "服务器IP: $SERVER_IP"
echo ""

# 测试8081端口 (替代80端口)
echo "1. 测试HTTP访问 (端口8081)..."
curl -I -m 10 http://$SERVER_IP:8081 2>/dev/null | head -1
if [ $? -eq 0 ]; then
    echo "   ✓ HTTP访问正常"
else
    echo "   ✗ HTTP访问失败"
fi
echo ""

# 测试8080端口
echo "2. 测试端口访问测试 (端口8080)..."
curl -I -m 10 http://$SERVER_IP:8080 2>/dev/null | head -1
if [ $? -eq 0 ]; then
    echo "   ✓ 端口8080访问正常"
else
    echo "   ✗ 端口8080访问失败"
fi
echo ""

# 测试8443端口 (替代443端口)
echo "3. 测试HTTPS访问 (端口8443)..."
curl -I -k -m 10 https://$SERVER_IP:8443 2>/dev/null | head -1
if [ $? -eq 0 ]; then
    echo "   ✓ HTTPS访问正常"
else
    echo "   ✗ HTTPS访问失败（可能是因为SSL证书未配置）"
fi
echo ""

echo "测试完成。"
echo ""
echo "您可以使用以下URL访问网站："
echo "  - HTTP:  http://$SERVER_IP:8081"
echo "  - 测试:  http://$SERVER_IP:8080"
echo "  - HTTPS: https://$SERVER_IP:8443 （需要SSL证书）"
echo ""
echo "注意：由于原端口被占用，我们使用了替代端口："
echo "  - 8081端口替代80端口"
echo "  - 8443端口替代443端口"
echo ""
echo "请确保防火墙已开放 8081、8443、8080 端口"
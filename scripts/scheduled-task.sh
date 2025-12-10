#!/bin/sh

echo "开始执行定时任务: $(date)"

# 执行数据获取
echo "正在获取最新数据..."
cd /app
node scripts/fetch-albums.js

if [ $? -eq 0 ]; then
  echo "数据获取成功，开始构建项目..."
  
  # 使用pnpm构建项目
  pnpm build
  
  if [ $? -eq 0 ]; then
    echo "项目构建成功完成"
    
    # 可选：将构建产物复制到指定目录
    # cp -r dist/* /shared-dist/
  else
    echo "项目构建失败"
  fi
else
  echo "数据获取失败，取消构建"
fi

echo "定时任务执行完毕: $(date)"
echo "========================================"
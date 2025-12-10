#!/bin/sh

# 安装openssh-client（如果不存在）
if ! command -v ssh >/dev/null 2>&1; then
    echo "Installing openssh-client..."
    apk add --no-cache openssh-client
fi

# 主循环
while true; do
    # 初始化变量
    DATE=$(date '+%Y-%m-%d %H:%M:%S')
    LOG_FILE="/app/logs/build-deploy.log"
    LAST_COMMIT_FILE="/app/.last_commit"
    
    # 确保日志目录存在
    mkdir -p /app/logs
    
    # 记录开始时间
    echo "[$DATE] 开始执行网站构建任务" >> "$LOG_FILE"
    
    # 检查是否有新的提交
    CURRENT_COMMIT=$(git rev-parse HEAD 2>/dev/null)
    
    # 如果获取commit失败，可能是网络问题或git仓库问题
    if [ $? -ne 0 ]; then
        echo "[$DATE] 无法获取当前commit信息，跳过本次构建" >> "$LOG_FILE"
    else
        LAST_COMMIT=""
        
        if [ -f "$LAST_COMMIT_FILE" ]; then
            LAST_COMMIT=$(cat "$LAST_COMMIT_FILE")
        fi
        
        if [ "$CURRENT_COMMIT" = "$LAST_COMMIT" ]; then
            echo "[$DATE] 没有新的提交，跳过构建" >> "$LOG_FILE"
        else
            echo "[$DATE] 检测到新的提交，开始构建..." >> "$LOG_FILE"
            
            # 拉取最新代码
            echo "[$DATE] 正在拉取最新代码..." >> "$LOG_FILE"
            git pull origin main >> "$LOG_FILE" 2>&1
            
            # 检查git pull是否成功
            if [ $? -ne 0 ]; then
                echo "[$DATE] Git拉取失败" >> "$LOG_FILE"
            else
                # 使用pnpm安装依赖
                echo "[$DATE] 检查并使用pnpm安装依赖..." >> "$LOG_FILE"
                timeout 300 pnpm install --verbose >> "$LOG_FILE" 2>&1
                
                # 检查依赖安装是否成功
                if [ $? -ne 0 ]; then
                    echo "[$DATE] 依赖安装失败或超时" >> "$LOG_FILE"
                else
                    # 使用pnpm构建项目
                    echo "[$DATE] 开始使用pnpm构建项目..." >> "$LOG_FILE"
                    timeout 600 pnpm run build --verbose >> "$LOG_FILE" 2>&1
                    
                    # 检查构建是否成功
                    if [ $? -ne 0 ]; then
                        echo "[$DATE] 项目构建失败或超时" >> "$LOG_FILE"
                    else
                        echo "[$DATE] 项目构建成功" >> "$LOG_FILE"
                        
                        # 确保构建输出目录存在并复制文件（如果需要）
                        if [ -d "/app/dist" ] && [ "$(ls -A /app/dist)" ]; then
                            echo "[$DATE] 复制构建文件到共享目录..." >> "$LOG_FILE"
                            cp -r /app/dist/* /srv/apps/mypixelboxwebsite/dist/ 2>>"$LOG_FILE" || echo "[$DATE] 警告：复制文件时出错" >> "$LOG_FILE"
                        else
                            echo "[$DATE] 构建目录为空或不存在" >> "$LOG_FILE"
                        fi
                        
                        # 保存当前commit hash
                        echo "$CURRENT_COMMIT" > "$LAST_COMMIT_FILE"
                    fi
                fi
            fi
        fi
    fi
    
    # 获取构建间隔时间（默认24小时）
    BUILD_INTERVAL=${BUILD_INTERVAL:-86400}
    
    echo "[$DATE] 等待 $BUILD_INTERVAL 秒后再次执行..." >> "$LOG_FILE"
    
    # 等待指定的时间间隔
    sleep $BUILD_INTERVAL
done
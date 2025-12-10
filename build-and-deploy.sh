#!/bin/sh

# 设置变量
LOG_FILE="/srv/apps/mypixelboxwebsite/logs/build-deploy.log"
LAST_COMMIT_FILE="/srv/apps/mypixelboxwebsite/.last_commit"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# 创建日志目录
mkdir -p /srv/apps/mypixelboxwebsite/logs

# 记录开始时间
echo "[$DATE] 开始执行网站构建任务" >> $LOG_FILE

# 主循环
while true; do
    DATE=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 检查是否有新的提交
    CURRENT_COMMIT=$(git rev-parse HEAD 2>/dev/null)
    
    # 如果获取commit失败，可能是网络问题或git仓库问题
    if [ $? -ne 0 ]; then
        echo "[$DATE] 无法获取当前commit信息，跳过本次构建" >> $LOG_FILE
    else
        LAST_COMMIT=""
        
        if [ -f "$LAST_COMMIT_FILE" ]; then
            LAST_COMMIT=$(cat $LAST_COMMIT_FILE)
        fi
        
        if [ "$CURRENT_COMMIT" = "$LAST_COMMIT" ]; then
            echo "[$DATE] 没有新的提交，跳过构建" >> $LOG_FILE
        else
            echo "[$DATE] 检测到新的提交，开始构建..." >> $LOG_FILE
            
            # 拉取最新代码
            echo "[$DATE] 正在拉取最新代码..." >> $LOG_FILE
            git pull origin main >> $LOG_FILE 2>&1
            
            # 检查git pull是否成功
            if [ $? -ne 0 ]; then
                echo "[$DATE] Git拉取失败" >> $LOG_FILE
            else
                # 使用pnpm安装依赖
                echo "[$DATE] 检查并使用pnpm安装依赖..." >> $LOG_FILE
                # 添加超时设置和详细输出
                timeout 300 pnpm install --verbose >> $LOG_FILE 2>&1
                
                # 检查依赖安装是否成功
                if [ $? -ne 0 ]; then
                    echo "[$DATE] 依赖安装失败或超时" >> $LOG_FILE
                else
                    # 使用pnpm构建项目
                    echo "[$DATE] 开始使用pnpm构建项目..." >> $LOG_FILE
                    # 添加超时设置和详细输出
                    timeout 600 pnpm run build --verbose >> $LOG_FILE 2>&1
                
                # 检查构建是否成功
                if [ $? -ne 0 ]; then
                    echo "[$DATE] 项目构建失败" >> $LOG_FILE
                else
                    echo "[$DATE] 项目构建成功" >> $LOG_FILE
                    
                    # 保存当前commit hash
                    echo $CURRENT_COMMIT > $LAST_COMMIT_FILE
                    
                    # 可选：重启Nginx容器以应用更改
                    # echo "[$DATE] 重启Nginx容器..." >> $LOG_FILE
                    # docker restart pixelbox-nginx >> $LOG_FILE 2>&1
                fi
            fi
        fi
    fi
    
    # 获取构建间隔时间（默认1小时）
    BUILD_INTERVAL=${BUILD_INTERVAL:-3600}
    
    echo "[$DATE] 等待 $BUILD_INTERVAL 秒后再次执行..." >> $LOG_FILE
    
    # 等待指定的时间间隔
    sleep $BUILD_INTERVAL
done
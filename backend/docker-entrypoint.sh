#!/bin/bash
set -e

# 等待数据库启动
if [ "$DB_HOST" ]; then
    echo "Waiting for database at $DB_HOST:${DB_PORT:-3306}..."
    while ! nc -z "$DB_HOST" "${DB_PORT:-3306}"; do
        sleep 1
    done
    echo "Database is ready!"
fi

# 等待 Redis 启动（如果配置了）
if [ "$REDIS_HOST" ]; then
    echo "Waiting for Redis at $REDIS_HOST:${REDIS_PORT:-6379}..."
    while ! nc -z "$REDIS_HOST" "${REDIS_PORT:-6379}"; do
        sleep 1
    done
    echo "Redis is ready!"
fi

# 创建必要的目录
mkdir -p /app/data /app/cache /app/logs /app/temp

# 设置权限
chmod 755 /app/data /app/cache /app/logs /app/temp

# 输出启动信息
echo "Starting Manhua Reader Backend..."
echo "Profile: ${SPRING_PROFILES_ACTIVE:-default}"
echo "Port: ${SERVER_PORT:-8080}"
echo "Java Options: $JAVA_OPTS"

# 执行传入的命令
exec "$@"
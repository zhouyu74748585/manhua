# 多阶段构建 Dockerfile

# 构建阶段
FROM maven:3.9-openjdk-17-slim AS builder

# 设置工作目录
WORKDIR /app

# 复制 pom.xml 和源代码
COPY pom.xml .
COPY src ./src

# 下载依赖并构建应用
RUN mvn clean package -DskipTests -Dmaven.javadoc.skip=true

# 运行阶段
FROM openjdk:17-jre-slim

# 安装必要的系统工具
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    p7zip-full \
    && rm -rf /var/lib/apt/lists/*

# 创建应用用户
RUN groupadd -r manhua && useradd -r -g manhua manhua

# 设置工作目录
WORKDIR /app

# 创建必要的目录
RUN mkdir -p /app/data /app/cache /app/logs /app/temp /app/manga \
    && chown -R manhua:manhua /app

# 复制构建的 JAR 文件
COPY --from=builder /app/target/*.jar app.jar

# 复制启动脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 设置 JVM 参数
ENV JAVA_OPTS="-Xmx1g -Xms512m -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# 设置应用参数
ENV SPRING_PROFILES_ACTIVE=prod
ENV SERVER_PORT=8080

# 暴露端口
EXPOSE 8080

# 切换到应用用户
USER manhua

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# 启动应用
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["java", "-jar", "app.jar"]
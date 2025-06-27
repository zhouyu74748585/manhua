# 漫画阅读器 (Manhua Reader)

一个功能完整的漫画阅读器应用，支持多种漫画格式，提供优秀的阅读体验。

## 功能特性

### 📚 漫画管理
- 支持多种漫画格式：ZIP、CBZ、RAR、CBR、7Z、CB7、PDF、EPUB
- 多漫画库管理，支持本地和网络文件系统
- 自动扫描和元数据提取
- 漫画分类、标签和评分系统
- 智能搜索和过滤功能

### 📖 阅读体验
- 流畅的页面翻转和缩放
- 多种阅读模式（单页、双页、连续滚动）
- 阅读进度自动保存
- 书签和笔记功能
- 阅读统计和历史记录

### 🖼️ 图像处理
- 高质量图像缩放和优化
- 自动生成缩略图和封面
- 支持多种图像格式
- 智能缓存机制

### 🌐 网络支持
- SMB/CIFS 网络共享
- FTP 文件服务器
- WebDAV 协议支持
- 云存储集成

### 🔧 系统特性
- RESTful API 设计
- 响应式 Web 界面
- 多用户支持（可选）
- 数据备份和恢复
- 性能监控和日志

## 技术栈

### 后端
- **框架**: Spring Boot 3.2.0
- **数据库**: H2 (开发) / SQLite (生产) / MySQL (可选)
- **ORM**: Spring Data JPA + Hibernate
- **安全**: Spring Security
- **缓存**: Caffeine
- **文件处理**: Apache Commons Compress, Tika
- **图像处理**: imgscalr, TwelveMonkeys ImageIO

### 前端
- **框架**: React 18 + TypeScript
- **UI库**: Ant Design
- **状态管理**: Redux Toolkit
- **路由**: React Router
- **HTTP客户端**: Axios
- **构建工具**: Vite

## 快速开始

### 环境要求
- Java 17+
- Node.js 18+
- Maven 3.8+

### 后端启动

1. 克隆项目
```bash
git clone <repository-url>
cd manhua_jve
```

2. 编译和运行后端
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

后端服务将在 `http://localhost:8080` 启动

### 前端启动

1. 安装依赖
```bash
cd frontend
npm install
```

2. 启动开发服务器
```bash
npm run dev
```

前端应用将在 `http://localhost:5173` 启动

### 使用Docker

```bash
# 构建镜像
docker-compose build

# 启动服务
docker-compose up -d
```

## 配置说明

### 应用配置

主要配置文件：`backend/src/main/resources/application.yml`

```yaml
manhua:
  # 数据目录
  data-dir: ./data
  
  # 缓存配置
  cache:
    max-size: 1024  # MB
    expire-hours: 24
  
  # 扫描配置
  scan:
    thread-pool-size: 4
    interval: 300  # 秒
  
  # 安全配置
  security:
    enable-auth: false
    enable-cors: true
```

### 环境配置

支持多环境配置：
- `dev`: 开发环境（H2内存数据库）
- `prod`: 生产环境（SQLite/MySQL）
- `test`: 测试环境

```bash
# 指定环境
java -jar app.jar --spring.profiles.active=prod
```

## API 文档

### 漫画库管理
- `GET /api/libraries` - 获取漫画库列表
- `POST /api/libraries` - 创建漫画库
- `PUT /api/libraries/{id}` - 更新漫画库
- `DELETE /api/libraries/{id}` - 删除漫画库
- `POST /api/libraries/{id}/scan` - 扫描漫画库

### 漫画管理
- `GET /api/manga` - 获取漫画列表
- `GET /api/manga/{id}` - 获取漫画详情
- `PUT /api/manga/{id}` - 更新漫画信息
- `DELETE /api/manga/{id}` - 删除漫画
- `GET /api/manga/{id}/cover` - 获取漫画封面
- `GET /api/manga/{id}/pages/{page}` - 获取漫画页面

### 阅读进度
- `GET /api/progress` - 获取阅读进度列表
- `POST /api/progress` - 创建阅读进度
- `PUT /api/progress/{id}` - 更新阅读进度
- `POST /api/progress/{id}/session/start` - 开始阅读会话
- `POST /api/progress/{id}/session/end` - 结束阅读会话

### 标签管理
- `GET /api/tags` - 获取标签列表
- `POST /api/tags` - 创建标签
- `PUT /api/tags/{id}` - 更新标签
- `DELETE /api/tags/{id}` - 删除标签

## 部署指南

### 生产环境部署

1. 构建应用
```bash
# 后端
cd backend
mvn clean package -Pprod

# 前端
cd frontend
npm run build
```

2. 配置数据库
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/manhua_reader
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

3. 启动应用
```bash
java -jar backend/target/manhua-reader-backend-1.0.0.jar \
  --spring.profiles.active=prod \
  --server.port=8080
```

### Docker 部署

```dockerfile
# Dockerfile
FROM openjdk:17-jre-slim
COPY target/manhua-reader-backend-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### Nginx 配置

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        root /var/www/manhua-reader;
        try_files $uri $uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 开发指南

### 项目结构

```
manhua_jve/
├── backend/                 # 后端代码
│   ├── src/main/java/
│   │   └── com/manhua/
│   │       ├── controller/  # REST控制器
│   │       ├── service/     # 业务逻辑
│   │       ├── repository/  # 数据访问
│   │       ├── entity/      # 实体类
│   │       ├── dto/         # 数据传输对象
│   │       └── config/      # 配置类
│   └── src/main/resources/
│       ├── application.yml  # 应用配置
│       └── static/          # 静态资源
├── frontend/                # 前端代码
│   ├── src/
│   │   ├── components/      # React组件
│   │   ├── pages/           # 页面组件
│   │   ├── services/        # API服务
│   │   ├── store/           # Redux状态
│   │   └── utils/           # 工具函数
│   ├── public/              # 公共资源
│   └── package.json         # 依赖配置
├── docker-compose.yml       # Docker编排
└── README.md               # 项目说明
```

### 代码规范

- 后端遵循 Spring Boot 最佳实践
- 前端使用 ESLint + Prettier
- 提交信息遵循 Conventional Commits
- 单元测试覆盖率 > 80%

### 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 常见问题

### Q: 支持哪些漫画格式？
A: 支持 ZIP、CBZ、RAR、CBR、7Z、CB7、PDF、EPUB 等格式。

### Q: 如何添加网络漫画库？
A: 在漫画库管理页面选择网络类型，配置相应的连接参数。

### Q: 阅读进度会自动保存吗？
A: 是的，阅读进度会自动保存，包括当前页面和阅读时间。

### Q: 如何备份数据？
A: 可以备份 `data` 目录下的所有文件，包括数据库和配置。

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系方式

- 项目主页: [GitHub Repository]
- 问题反馈: [GitHub Issues]
- 邮箱: [your-email@example.com]

## 更新日志

### v1.0.0 (2024-01-01)
- 初始版本发布
- 基础漫画阅读功能
- 多格式支持
- 网络文件系统支持

---

感谢使用漫画阅读器！如果您觉得这个项目有用，请给我们一个 ⭐️
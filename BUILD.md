# 漫画阅读器 - 构建指南

本项目是一个集成了前端（Vue.js + Electron）和后端（Spring Boot）的完整漫画阅读器应用。

## 项目结构

```
manhua/
├── src/                    # Vue.js 前端源码
├── electron/               # Electron 主进程和预加载脚本
├── backend/                # Spring Boot 后端源码
├── dist/                   # 前端构建输出
├── dist-electron/          # Electron 构建输出
├── dist-app/               # 最终应用打包输出
└── build-electron.js       # 自动化构建脚本
```

## 环境要求

- Node.js 18+
- Java 17+
- Maven 3.6+
- npm 或 yarn

## 开发模式

### 启动后端服务器
```bash
cd backend
mvn spring-boot:run
```

### 启动前端开发服务器
```bash
npm run dev
```

### 启动 Electron 应用（开发模式）
```bash
npm run electron:dev
```

## 生产构建

### 方法一：使用自动化构建脚本（推荐）
```bash
npm run build:electron
```

这个命令会：
1. 构建 Vue.js 前端应用
2. 构建 Spring Boot 后端 JAR 文件
3. 验证构建产物
4. 使用 electron-builder 打包完整应用

### 方法二：手动分步构建
```bash
# 1. 构建前端
npm run build

# 2. 构建后端
npm run build:backend

# 3. 打包 Electron 应用
npm run electron:build
```

## 应用架构

### 运行时架构
1. **Electron 主进程**：启动时会自动启动内嵌的 Spring Boot 后端服务器
2. **后端服务器**：运行在 `http://localhost:8080`，提供 REST API
3. **前端界面**：Vue.js 应用，通过 HTTP 请求与后端通信
4. **进程管理**：应用退出时会自动清理后端进程

### 开发模式 vs 生产模式
- **开发模式**：前端连接到 Vite 开发服务器，后端需要单独启动
- **生产模式**：前端使用构建后的静态文件，后端 JAR 文件内嵌在应用中自动启动

## 构建产物

构建完成后，可执行文件位于：
- Windows: `dist-app/Manga Reader Setup 1.0.0.exe`
- macOS: `dist-app/Manga Reader-1.0.0.dmg`
- Linux: `dist-app/Manga Reader-1.0.0.AppImage`

## 故障排除

### 后端启动失败
- 检查 Java 17+ 是否正确安装
- 确认 `backend/target/*.jar` 文件存在
- 查看 Electron 控制台日志

### 前端无法连接后端
- 确认后端服务器在 8080 端口正常运行
- 检查防火墙设置
- 查看浏览器开发者工具的网络请求

### 构建失败
- 确认所有依赖已正确安装：`npm install`
- 检查 Maven 配置：`mvn --version`
- 清理缓存：`npm run clean` 和 `mvn clean`

## 自定义配置

### 修改后端端口
1. 修改 `electron/main.ts` 中的 `BACKEND_PORT` 常量
2. 修改 `src/services/api.ts` 中的 `API_BASE_URL`
3. 更新后端 `application.properties` 中的 `server.port`

### 修改应用信息
编辑 `package.json` 中的 `build` 配置节点。
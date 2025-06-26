# 漫画阅读软件

基于Electron+Vue前端和Java后端的现代化漫画阅读软件。

## 项目概述

本项目是一款桌面端漫画阅读软件，旨在为用户提供现代化、简约风格的漫画阅读体验。软件支持本地文件和常见远程网络文件协议，并具备强大的漫画库管理、书架功能和隐私保护模式。

## 主要功能

- 现代化与简约UI，提供沉浸式阅读体验
- 多种阅读模式（单页、双页、连续滚动等）
- 支持多种文件格式（本地文件夹、压缩包、PDF）
- 支持多种远程网络文件协议（SMB/CIFS、FTP/SFTP、WebDAV、NFS）
- 强大的漫画库管理和书架功能
- 隐私保护模式
- 多语言支持和主题切换

## 技术栈

- 前端：Vue.js + Element UI/Ant Design Vue
- 打包工具：Webpack/Vite
- 桌面应用框架：Electron
- 后端：Java
- 数据库：SQLite3

## 项目结构

```
├── frontend/            # 前端代码（Electron + Vue）
│   ├── src/             # 源代码
│   ├── public/          # 静态资源
│   └── package.json     # 前端依赖配置
├── backend/             # 后端代码（Java）
│   ├── src/             # 源代码
│   ├── pom.xml          # Maven配置
│   └── build.gradle     # Gradle配置
└── resources/           # 资源文件
    └── images/          # 图片资源
```

## 开发与构建

### 前端开发

```bash
cd frontend
npm install
npm run dev
```

### 后端开发

```bash
cd backend
./mvnw spring-boot:run  # 如果使用Maven
./gradlew bootRun       # 如果使用Gradle
```

### 构建应用

```bash
# 构建前端
cd frontend
npm run build

# 构建后端
cd ../backend
./mvnw package  # 如果使用Maven
./gradlew build  # 如果使用Gradle

# 打包Electron应用
cd ../frontend
npm run electron:build
```

## 许可证

[MIT](LICENSE)
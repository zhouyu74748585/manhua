# Flutter 漫画阅读器

一个现代化的漫画阅读应用，使用 Flutter 构建，支持多平台（Android、iOS、Windows、macOS、Linux、Web）。

## 功能特性

### 核心功能
- 📚 漫画库管理（本地、网络、云端）
- 📖 多种阅读模式（单页、双页、连续滚动）
- 🔍 智能搜索和分类
- ⭐ 收藏和书签管理
- 📊 阅读进度跟踪
- 🌙 深色/浅色主题切换
- 🌐 多语言支持

### 阅读体验
- 🖼️ 多种图片适应模式
- 📱 全屏阅读支持
- 🔆 亮度调节
- ⌨️ 音量键翻页
- 👆 触摸导航
- 🔄 预加载优化

### 平台适配
- 📱 移动端：底部导航栏
- 💻 桌面端：侧边栏导航
- 🎨 响应式布局
- 🪟 桌面端窗口管理

## 项目结构

```
lib/
├── app/                    # 应用配置
│   ├── routes/            # 路由配置
│   └── themes/            # 主题配置
├── core/                  # 核心功能
│   ├── constants/         # 常量定义
│   ├── services/          # 核心服务
│   └── utils/             # 工具类
├── data/                  # 数据层
│   ├── models/            # 数据模型
│   └── repositories/      # 数据仓库
└── presentation/          # 表现层
    ├── pages/             # 页面组件
    ├── providers/         # 状态管理
    └── widgets/           # UI组件
```

## 技术栈

### 核心框架
- **Flutter**: 跨平台UI框架
- **Dart**: 编程语言

### 状态管理
- **Riverpod**: 现代化状态管理
- **Riverpod Annotation**: 代码生成支持

### 数据存储
- **Hive**: 本地数据库
- **SharedPreferences**: 键值对存储
- **Path Provider**: 文件路径管理

### 网络和图片
- **Dio**: HTTP客户端
- **Retrofit**: API接口生成
- **Cached Network Image**: 图片缓存
- **Photo View**: 图片查看器

### UI和动画
- **Material Design 3**: 设计系统
- **Go Router**: 路由管理
- **Animations**: 动画支持

### 平台功能
- **Window Manager**: 桌面端窗口管理
- **Permission Handler**: 权限管理
- **File Picker**: 文件选择

## 快速开始

### 环境要求
- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0

### 安装依赖
```bash
flutter pub get
```

### 代码生成
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 运行应用
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Web
flutter run -d chrome
```

## 主要页面

### 首页 (HomePage)
- 最近阅读
- 最新更新
- 快速搜索

### 漫画库 (LibraryPage)
- 库管理
- 扫描和同步
- 分类浏览

### 书架 (BookshelfPage)
- 收藏管理
- 阅读历史
- 进度跟踪

### 搜索 (SearchPage)
- 智能搜索
- 高级筛选
- 搜索历史

### 设置 (SettingsPage)
- 外观设置
- 阅读设置
- 存储管理
- 关于信息

### 漫画详情 (MangaDetailPage)
- 漫画信息
- 章节列表
- 收藏和分享

### 阅读器 (ReaderPage)
- 全屏阅读
- 多种阅读模式
- 进度控制
- 设置面板

## 数据模型

### Manga (漫画)
- 基本信息（标题、作者、描述）
- 封面和标签
- 状态和评分
- 阅读进度

### Chapter (章节)
- 章节信息
- 页面列表
- 阅读状态
- 下载状态

### MangaLibrary (漫画库)
- 库配置
- 扫描设置
- 统计信息

### Settings (设置)
- 应用设置
- 阅读器设置
- 库视图设置
- 下载设置

## 开发说明

### 代码规范
- 使用 Dart 官方代码风格
- 遵循 Flutter 最佳实践
- 使用 Riverpod 进行状态管理
- 采用 Repository 模式管理数据

### 架构设计
- **表现层**: UI组件和状态管理
- **业务层**: 业务逻辑和数据处理
- **数据层**: 数据存储和网络请求

### 注意事项
1. 首次运行可能需要下载字体文件
2. 某些功能需要相应的系统权限
3. 桌面端需要额外的窗口管理配置
4. 代码生成文件需要运行 build_runner

## 待实现功能

- [ ] 完善数据存储逻辑
- [ ] 实现网络API接口
- [ ] 添加文件格式支持
- [ ] 完善阅读器功能
- [ ] 添加下载管理
- [ ] 实现云同步
- [ ] 添加插件系统
- [ ] 完善测试覆盖

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

---

**注意**: 这是一个基础框架项目，许多功能标记为 TODO 待实现。项目提供了完整的架构和UI框架，可以在此基础上继续开发具体功能。
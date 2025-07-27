# 漫画阅读器 Flutter

一个现代化的跨平台漫画阅读应用，使用 Flutter 构建，支持多种网络协议、隐私保护和多设备同步功能。

## ✨ 功能特性

### 📚 漫画库管理
- **多库支持**: 创建、编辑、删除多个漫画库，支持本地和网络路径
- **智能扫描**: 自动扫描漫画库，识别图片文件夹和压缩包作为漫画
- **封面模式**: 支持默认、左半、右半三种封面展示模式
- **隐私保护**: 漫画库隐私模式，支持密码和生物识别验证
- **实时同步**: 支持局域网内多设备漫画库同步

### 🌐 网络协议支持
- **HTTP/HTTPS**: 标准网页协议支持
- **SMB/CIFS**: Windows 网络共享协议
- **FTP/SFTP**: 文件传输协议
- **WebDAV**: 网络分布式创作和版本控制协议
- **NFS**: 网络文件系统协议
- **远程缓存**: 网络漫画本地缓存，支持离线阅读

### 📖 阅读体验
- **多种阅读模式**: 单页、双页阅读模式
- **全屏阅读**: 沉浸式阅读体验
- **进度记忆**: 自动保存阅读进度，支持跨设备同步
- **预加载优化**: 智能预加载，减少阅读卡顿
- **多种翻页方式**: 键盘、鼠标、触摸板支持
- **底部进度条**: 带预览的进度控制

### 🔒 隐私与安全
- **隐私模式**: 漫画库级别的隐私保护
- **多重认证**: 密码 + 生物识别（指纹/面部识别）
- **应用保护**: 应用进入后台时自动模糊屏幕
- **激活管理**: 隐私库激活状态管理，重启应用需重新验证

### 🔄 多设备共享
- **设备发现**: 局域网内自动发现其他设备
- **漫画库同步**: 支持整库或部分同步
- **进度同步**: 阅读进度跨设备同步
- **mDNS + UDP**: 双重设备发现机制

### 🎨 用户界面
- **现代化设计**: Material Design 3 设计语言
- **响应式布局**: 适配手机、平板、桌面端
- **主题切换**: 深色/浅色主题支持
- **多语言**: 中文、英文、日文等多语言支持

## 🏗️ 技术架构

### 核心框架
- **Flutter**: 3.10.0+ 跨平台UI框架
- **Dart**: 3.0.0+ 编程语言
- **Riverpod**: 现代化状态管理
- **Go Router**: 声明式路由管理

### 数据存储
- **Drift**: 跨平台SQLite数据库
- **SharedPreferences**: 配置存储
- **Path Provider**: 文件路径管理
- **Crypto**: 密码加密

### 网络与文件
- **Dio**: HTTP客户端
- **Multicast DNS**: 设备发现
- **Archive**: 压缩文件处理
- **PDFx**: PDF文件支持
- **各协议客户端**: SMB、FTP、WebDAV、NFS等

### UI组件
- **Cached Network Image**: 图片缓存
- **Photo View**: 图片查看器
- **Staggered Grid View**: 瀑布流布局
- **Local Auth**: 生物识别认证

## 📁 项目结构

```
lib/
├── app/                           # 应用配置
│   ├── routes/                   # 路由配置
│   └── themes/                   # 主题配置
├── core/                         # 核心功能
│   ├── constants/               # 常量定义
│   ├── services/                # 核心服务
│   │   ├── network/            # 网络协议实现
│   │   ├── app_lifecycle_manager.dart
│   │   ├── privacy_service.dart
│   │   └── task_tracker_service.dart
│   └── utils/                   # 工具类
├── data/                        # 数据层
│   ├── database/               # 数据库定义
│   ├── models/                 # 数据模型
│   ├── repositories/           # 数据仓库
│   └── services/               # 数据服务
│       ├── drift_database_service.dart
│       ├── library_service.dart
│       └── multi_device_sync_service.dart
└── presentation/               # 表现层
    ├── pages/                  # 页面组件
    │   ├── bookshelf/         # 书架页面
    │   ├── library/           # 漫画库管理
    │   ├── manga_detail/      # 漫画详情
    │   ├── reader/            # 阅读器
    │   ├── settings/          # 设置页面
    │   └── sync/              # 同步页面
    ├── providers/             # 状态管理
    └── widgets/               # UI组件
        ├── library/           # 漫画库组件
        ├── manga/             # 漫画组件
        ├── privacy/           # 隐私组件
        └── reader/            # 阅读器组件
```

## 🚀 快速开始

### 环境要求
- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- 支持的平台：Android、iOS、Windows、macOS、Linux

### 安装步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd manhua
```

2. **安装依赖**
```bash
flutter pub get
```

3. **代码生成**
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. **运行应用**
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
```

## 📱 主要页面

### 🏠 首页 (HomePage)
- 最近阅读漫画
- 快速访问功能
- 统计信息展示

### 📚 漫画库 (LibraryPage)
- 漫画库创建和管理
- 网络协议配置
- 扫描进度监控
- 隐私设置

### 📖 书架 (BookshelfPage)
- 统一展示所有激活库的漫画
- 多种布局模式（网格、列表）
- 智能搜索和筛选
- 排序功能（名称、最近阅读、添加时间）

### 🔍 搜索 (SearchPage)
- 全局漫画搜索
- 高级筛选选项
- 搜索历史记录

### ⚙️ 设置 (SettingsPage)
- 外观设置（主题、语言）
- 阅读器设置
- 隐私设置
- 存储管理
- 关于信息

### 📄 漫画详情 (MangaDetailPage)
- 漫画基本信息
- 阅读进度显示
- 页面预览（瀑布流）
- 收藏和分享功能

### 📖 阅读器 (ReaderPage)
- 全屏阅读模式
- 底部进度条和预览
- 阅读设置面板
- 快捷键支持

### 🔄 同步页面 (SyncPage)
- 设备发现和连接
- 漫画库同步管理
- 同步进度监控

## 🔧 核心功能详解

### 网络协议支持

项目实现了完整的网络文件系统抽象层，支持多种协议：

```dart
// 网络文件系统工厂
NetworkFileSystem fileSystem = NetworkFileSystemFactory.create(config);
await fileSystem.connect();
List<NetworkFileInfo> files = await fileSystem.listDirectory('/');
```

支持的协议：
- **HTTP/HTTPS**: 基于标准HTTP协议的文件访问
- **SMB/CIFS**: Windows网络共享，使用`smb_connect`包
- **FTP/SFTP**: 文件传输协议，支持加密传输
- **WebDAV**: 基于HTTP的分布式文件系统
- **NFS**: 网络文件系统，支持Linux/macOS挂载

### 隐私保护机制

```dart
// 设置漫画库为隐私模式
await PrivacyService.setLibraryPrivate(libraryId, true);

// 验证访问权限
bool hasAccess = await PrivacyService.verifyAccess(libraryId);
```

隐私功能特性：
- 漫画库级别的隐私保护
- 密码 + 生物识别双重认证
- 应用后台自动模糊保护
- 重启应用需重新验证

### 多设备同步

```dart
// 发现局域网设备
Stream<List<DeviceInfo>> devices = MultiDeviceSyncService.devicesStream;

// 同步漫画库
await MultiDeviceSyncService.syncLibrary(libraryId, targetDeviceId);
```

同步功能：
- mDNS + UDP双重设备发现
- 漫画库元数据同步
- 阅读进度同步
- 增量同步支持

## 🗄️ 数据模型

### 核心模型

```dart
// 漫画模型
class Manga {
  final String id;
  final String title;
  final String? author;
  final String? coverPath;
  final int totalPages;
  final ReadingProgress? progress;
  // ...
}

// 漫画库模型
class MangaLibrary {
  final String id;
  final String name;
  final String path;
  final NetworkConfig? networkConfig;
  final bool isPrivate;
  final CoverDisplayMode coverMode;
  // ...
}

// 网络配置模型
class NetworkConfig {
  final NetworkProtocol protocol;
  final String host;
  final int port;
  final String? username;
  final String? password;
  // ...
}
```

## 🔨 开发指南

### 代码规范
- 遵循 Dart 官方代码风格
- 使用 Riverpod 进行状态管理
- 采用 Repository 模式管理数据
- 使用 Drift 进行数据库操作

### 架构原则
- **分层架构**: 表现层、业务层、数据层清晰分离
- **依赖注入**: 使用 Riverpod 进行依赖管理
- **错误处理**: 统一的错误处理机制
- **日志记录**: 完善的日志系统

### 添加新的网络协议

1. 实现 `NetworkFileSystem` 接口
2. 在 `NetworkFileSystemFactory` 中注册
3. 添加协议枚举值
4. 实现连接测试逻辑

```dart
class CustomFileSystem extends NetworkFileSystem {
  @override
  Future<void> connect() async {
    // 实现连接逻辑
  }
  
  @override
  Future<List<NetworkFileInfo>> listDirectory([String path = '/']) async {
    // 实现目录列表逻辑
  }
}
```

## 🧪 测试

### 运行测试
```bash
# 单元测试
flutter test

# 集成测试
flutter test integration_test/
```

### 测试覆盖
- 核心服务单元测试
- 网络协议集成测试
- UI组件测试
- 隐私功能测试

## 📦 构建发布

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Desktop
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- Flutter 团队提供的优秀框架
- 所有开源包的贡献者
- 社区的反馈和建议

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue
- 发起 Discussion
- 邮件联系

---

**注意**: 首次运行可能需要下载字体文件和初始化数据库，某些功能需要相应的系统权限。
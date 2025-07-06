class AppConstants {
  // 应用信息
  static const String appName = '漫画阅读器';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A modern manga reader application';

  // API配置
  static const String apiBaseUrl = 'http://localhost:8080/api';
  static const Duration apiTimeout = Duration(seconds: 30);

  // 存储键名
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String readerSettingsKey = 'reader_settings';
  static const String librariesKey = 'libraries';
  static const String readingProgressKey = 'reading_progress';

  // 缓存配置
  static const int imageCacheMaxSize = 100 * 1024 * 1024; // 100MB
  static const int imageCacheMaxObjects = 1000;
  static const Duration imageCacheDuration = Duration(days: 7);

  // 阅读器配置
  static const double defaultZoomLevel = 1.0;
  static const double minZoomLevel = 0.5;
  static const double maxZoomLevel = 5.0;
  static const double zoomStep = 0.25;

  // 网格配置
  static const int mobileGridColumns = 2;
  static const int tabletGridColumns = 3;
  static const int desktopGridColumns = 4;
  static const double gridAspectRatio = 0.7;

  // 动画配置
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 文件类型
  static const List<String> supportedImageFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
  ];

  static const List<String> supportedArchiveFormats = [
    '.zip',
    '.rar',
    '.7z',
    '.cbz',
    '.cbr',
  ];

  // 错误消息
  static const String networkErrorMessage = '网络连接失败，请检查网络设置';
  static const String serverErrorMessage = '服务器错误，请稍后重试';
  static const String unknownErrorMessage = '未知错误，请稍后重试';
  static const String fileNotFoundMessage = '文件不存在或已被删除';
  static const String permissionDeniedMessage = '权限不足，无法访问文件';

  // 成功消息
  static const String saveSuccessMessage = '保存成功';
  static const String deleteSuccessMessage = '删除成功';
  static const String importSuccessMessage = '导入成功';
  static const String exportSuccessMessage = '导出成功';
}

// 阅读模式枚举
enum ReadingMode {
  single('单页'),
  double('双页');

  const ReadingMode(this.displayName);
  final String displayName;
}

// 阅读方向枚举
enum ReadingDirection {
  leftToRight('从左到右'),
  rightToLeft('从右到左'),
  topToBottom('从上到下');

  const ReadingDirection(this.displayName);
  final String displayName;
}

// 图片适应模式枚举
enum ImageFitMode {
  fitWidth('适应宽度'),
  fitHeight('适应高度'),
  fitScreen('适应屏幕'),
  originalSize('原始大小');

  const ImageFitMode(this.displayName);
  final String displayName;
}

// 漫画库类型枚举
enum LibraryType {
  local('本地文件夹'),
  smb('SMB/CIFS'),
  ftp('FTP/SFTP'),
  webdav('WEBDAV'),
  nfs('NFS');

  const LibraryType(this.displayName);
  final String displayName;
}

// 排序方式枚举
enum SortOrder {
  titleAsc('标题 A-Z'),
  titleDesc('标题 Z-A'),
  createdAtAsc('创建时间 ↑'),
  createdAtDesc('创建时间 ↓'),
  updatedAtAsc('更新时间 ↑'),
  updatedAtDesc('更新时间 ↓'),
  sizeAsc('大小 ↑'),
  sizeDesc('大小 ↓');

  const SortOrder(this.displayName);
  final String displayName;
}

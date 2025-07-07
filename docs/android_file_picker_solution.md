# Android文件选择器权限问题解决方案

## 问题描述

在Android 11+系统中，由于作用域存储(Scoped Storage)的限制，`FilePicker.platform.getDirectoryPath()` 方法经常返回根目录 "/" 而不是用户实际选择的路径，导致应用无法访问用户选择的文件夹。

## 问题原因

1. **作用域存储限制**：Android 11引入了作用域存储，限制了应用对外部存储的直接访问
2. **SAF限制**：Storage Access Framework在某些情况下无法正确返回实际路径
3. **权限模型变化**：Android 13+引入了细粒度媒体权限，传统的存储权限可能不足

## 解决方案

### 1. 平台特定处理

我们实现了平台特定的文件选择器处理：

- **Android平台**：使用增强的处理逻辑，包含多种备用方案
- **其他平台**：使用标准的文件选择器方法

### 2. Android备用方案

当检测到文件选择器返回根目录时，提供以下备用方案：

#### 方案1：选择常用目录
- 自动扫描并验证常用的Android目录
- 包括：Download、Pictures、Documents、DCIM等
- 只显示可访问的目录供用户选择

#### 方案2：使用应用目录
- 在应用的外部存储目录下创建manga文件夹
- 确保应用有完全的访问权限
- 适合不需要访问系统其他位置的用户

#### 方案3：手动输入路径
- 允许用户手动输入完整的文件夹路径
- 实时验证路径的可访问性
- 提供常用路径的提示信息

#### 方案4：重试文件选择器
- 再次尝试系统文件选择器
- 某些情况下重试可能成功

### 3. 权限验证增强

- **多层权限检查**：结合系统权限和实际文件访问验证
- **路径规范化**：统一处理路径格式，避免重复保存
- **权限持久化**：保存已验证的路径，避免重复验证

## 技术实现

### 核心类和方法

```dart
// 主要入口方法
static Future<String?> pickDirectoryWithPermission({
  required BuildContext context,
  String? dialogTitle,
  String? initialDirectory,
  bool lockParentWindow = false,
})

// Android特定处理
static Future<String?> _pickDirectoryAndroid({...})

// 备用方案处理
static Future<String?> _handleAndroidRootDirectoryIssue(BuildContext context)
```

### 备用方案枚举

```dart
enum AndroidDirectoryOption {
  useCommonPaths,  // 使用常用目录
  useAppDirectory, // 使用应用目录
  manualInput,     // 手动输入路径
  retryPicker,     // 重试文件选择器
}
```

## 用户体验改进

### 1. 友好的错误处理
- 详细的问题说明和解决方案指导
- 多种选择方案，适应不同用户需求
- 清晰的操作步骤提示

### 2. 智能路径建议
- 自动检测可用的常用目录
- 过滤不可访问的路径
- 提供路径访问状态反馈

### 3. 权限状态透明化
- 实时显示权限验证结果
- 保存成功授权的路径
- 提供权限管理界面

## 使用方法

### 基本用法

```dart
final result = await EnhancedFilePickerService.pickDirectoryWithPermission(
  context: context,
  dialogTitle: '选择漫画库文件夹',
);

if (result != null) {
  // 使用选择的路径
  print('选择的路径: $result');
}
```

### 权限检查

```dart
final hasPermission = await EnhancedFilePickerService.checkPathPermission(path);
if (!hasPermission) {
  final granted = await EnhancedFilePickerService.requestPathPermission(
    context: context,
    path: path,
  );
}
```

## 注意事项

1. **Android版本兼容性**：解决方案兼容Android 6.0+到最新版本
2. **权限申请时机**：在文件选择前主动申请必要权限
3. **用户引导**：提供清晰的权限说明和操作指导
4. **错误恢复**：多种备用方案确保用户总能找到可用的解决方法

## 测试建议

1. **多版本测试**：在不同Android版本上测试
2. **权限场景测试**：测试各种权限授予/拒绝场景
3. **路径访问测试**：验证不同路径的访问能力
4. **用户体验测试**：确保操作流程简单明了

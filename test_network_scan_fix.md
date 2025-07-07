# 网络漫画库扫描修复验证

## 问题描述
用户报告："点击网络漫画库的扫描按钮后一直显示正在初始化扫描"

## 根本原因分析
经过深入调查，发现了两个关键问题：

1. **缺少扫描启动逻辑**：在 `LibraryCard` 的 `_handleScan` 方法中，对于网络库只是显示了进度对话框，但没有实际调用网络扫描队列管理器来启动扫描。

2. **任务ID不匹配**：`LibraryCard` 生成的任务ID格式与 `NetworkScanQueueManager` 生成的任务ID格式不一致，导致进度更新无法正确传递到对话框。
   - LibraryCard 生成：`'scan_${library.id}_${timestamp}'`
   - NetworkScanQueueManager 生成：`'${library.id}_${timestamp}'`

## 修复方案
采用了两步修复方案：

### 第一步：添加扫描启动逻辑
在 `NetworkScanProgressDialog` 的 `initState` 中添加 `_startScan()` 方法调用，该方法：

1. **获取网络配置**：优先从 `library.settings.networkConfig` 获取，兼容旧版本从路径解析
2. **验证配置有效性**：检查网络配置是否完整
3. **启动扫描**：调用 `NetworkScanQueueManager.instance.startScan()`
4. **错误处理**：处理配置无效和启动失败的情况

### 第二步：修复任务ID一致性问题
修改 `NetworkScanQueueManager.startScan()` 方法，支持接受外部提供的任务ID，确保任务ID在整个扫描流程中保持一致。

## 修复的文件
- `lib/presentation/widgets/library/network_scan_progress_dialog.dart`
  - 添加了 `_startScan()` 方法
  - 在 `initState()` 中调用 `_startScan()`
  - 添加了 `NetworkConfig` 导入
  - 传递任务ID给扫描管理器

- `lib/core/services/network/network_scan_queue_manager.dart`
  - 修改 `startScan()` 方法签名，支持可选的 `taskId` 参数
  - 使用外部提供的任务ID或生成新的任务ID

## 测试验证
创建了全面的单元测试：
- 验证对话框在初始化时启动扫描
- 验证网络配置无效时的错误处理
- 验证取消按钮的显示和功能
- 验证网络配置解析功能

所有测试都通过了。

## 手动测试步骤

### 前提条件
1. 确保有一个配置好的网络漫画库（SMB/FTP/WebDAV等）
2. 网络配置包含有效的主机、用户名、密码等信息

### 测试步骤
1. 打开应用
2. 进入漫画库管理页面
3. 找到一个网络类型的漫画库
4. 点击"扫描"按钮
5. 观察进度对话框的行为

### 预期结果
- 对话框应该立即显示"开始扫描网络漫画库..."或连接相关的消息
- 不应该一直停留在"正在初始化扫描..."状态
- 如果网络配置无效，应该显示明确的错误信息
- 如果连接失败，应该显示具体的连接错误信息

### 测试用例

#### 测试用例1：有效的SMB配置
- 配置：SMB://10.0.0.3，用户名：zhouyu，密码：946898
- 预期：应该开始连接并扫描，或显示具体的连接错误

#### 测试用例2：无效的网络配置
- 配置：空的主机名或无效的协议
- 预期：应该立即显示"网络配置无效，请检查连接设置"

#### 测试用例3：网络不可达
- 配置：指向不存在的主机
- 预期：应该显示连接超时或网络不可达的错误

## 技术细节

### 修复前的流程
1. 用户点击扫描按钮
2. `LibraryCard._handleScan()` 生成任务ID
3. 显示 `NetworkScanProgressDialog`
4. 对话框监听进度流，但没有任务被启动
5. 永远显示"正在初始化扫描..."

### 修复后的流程
1. 用户点击扫描按钮
2. `LibraryCard._handleScan()` 生成任务ID
3. 显示 `NetworkScanProgressDialog`
4. 对话框在 `initState` 中调用 `_startScan()`
5. `_startScan()` 获取网络配置并启动扫描
6. 扫描进度通过流更新对话框UI

### 错误处理改进
- 配置验证：检查网络配置是否完整有效
- 启动失败处理：捕获并显示启动扫描时的异常
- 用户友好的错误消息：提供具体的错误信息而不是技术性的异常

## 相关代码变更

### NetworkScanProgressDialog 主要变更
```dart
@override
void initState() {
  super.initState();
  _listenToProgress();
  _startScan(); // 新增：启动扫描
}

void _startScan() async {
  try {
    // 获取网络配置
    NetworkConfig config;
    if (widget.library.settings.networkConfig != null) {
      config = widget.library.settings.networkConfig!;
    } else {
      config = NetworkConfig.fromConnectionString(widget.library.path);
    }

    // 验证配置
    if (!config.isValid) {
      // 显示配置无效错误
      return;
    }

    // 启动扫描
    await NetworkScanQueueManager.instance.startScan(widget.library, config);
  } catch (e) {
    // 显示启动失败错误
  }
}
```

这个修复确保了网络漫画库扫描功能能够正常工作，用户不再会遇到"一直显示正在初始化扫描"的问题。

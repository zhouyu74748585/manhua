import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final Widget? action;

  const AppErrorWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.retryText,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            if (title != null)
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                textAlign: TextAlign.center,
              ),
            if (title != null && message != null) const SizedBox(height: 8),
            if (message != null)
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            if (action != null)
              action!
            else if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? '重试'),
              ),
          ],
        ),
      ),
    );
  }
}

// 网络错误组件
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.wifi_off,
      title: '网络连接失败',
      message: '请检查网络连接后重试',
      onRetry: onRetry,
    );
  }
}

// 空数据组件
class EmptyDataWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final Widget? action;

  const EmptyDataWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: icon ?? Icons.inbox_outlined,
      title: title ?? '暂无数据',
      message: message ?? '这里还没有任何内容',
      action: action,
    );
  }
}

// 服务器错误组件
class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const ServerErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.cloud_off,
      title: '服务器错误',
      message: message ?? '服务器暂时无法响应，请稍后重试',
      onRetry: onRetry,
    );
  }
}

// 权限错误组件
class PermissionErrorWidget extends StatelessWidget {
  final VoidCallback? onRequestPermission;
  final String? message;

  const PermissionErrorWidget({
    super.key,
    this.onRequestPermission,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.lock_outline,
      title: '权限不足',
      message: message ?? '需要相关权限才能继续操作',
      onRetry: onRequestPermission,
      retryText: '授予权限',
    );
  }
}

// 页面错误组件
class PageErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  const PageErrorWidget({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? '错误'),
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
            : null,
      ),
      body: AppErrorWidget(
        message: message ?? '页面加载失败',
        onRetry: onRetry,
      ),
    );
  }
}

// 错误边界组件
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }

      return AppErrorWidget(
        title: '应用错误',
        message: '应用遇到了一个错误，请重启应用',
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
        retryText: '重新加载',
      );
    }

    return widget.child;
  }
}

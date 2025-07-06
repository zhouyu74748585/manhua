import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../presentation/providers/theme_provider.dart';
import '../presentation/widgets/privacy/privacy_app_wrapper.dart';
import 'routes/app_router.dart';
import 'themes/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // 路由配置
      routerConfig: router,

      // 本地化配置
      supportedLocales: const [
        Locale('zh', 'CN'), // 简体中文
        Locale('zh', 'TW'), // 繁体中文
        Locale('en', 'US'), // 英语
        Locale('ja', 'JP'), // 日语
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 构建器
      builder: (context, child) {
        return MediaQuery(
          // 限制文本缩放范围，防止UI破坏，但允许适度缩放
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              (MediaQuery.of(context).textScaler.scale(1.0)).clamp(0.8, 1.3),
            ),
          ),
          child: PrivacyAppWrapper(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

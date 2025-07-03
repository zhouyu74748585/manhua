import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/services/database_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Hive数据库服务（包含数据迁移）
  await DatabaseService.init();
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

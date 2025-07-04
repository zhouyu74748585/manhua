import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/app_lifecycle_manager.dart';
import 'core/services/privacy_service.dart';
import 'data/services/drift_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Drift database - no platform-specific setup needed
  // Drift handles cross-platform database initialization automatically
  final database = DriftDatabaseService.database;

  // Ensure database is ready
  await database.customStatement('SELECT 1');

  // Initialize privacy service - 清除激活状态缓存
  await PrivacyService.initialize();
  
  // Create provider container for dependency injection
  final container = ProviderContainer();
  
  // Initialize app lifecycle manager - 管理应用生命周期和隐私保护
  await AppLifecycleManager.instance.initialize(container);

  runApp(
    ProviderScope(
      parent: container,
      child: const App(),
    ),
  );
}

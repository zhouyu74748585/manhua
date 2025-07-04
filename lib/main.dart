import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/privacy_service.dart';
import 'data/services/drift_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Drift database - no platform-specific setup needed
  // Drift handles cross-platform database initialization automatically
  final database = DriftDatabaseService.database;

  // Ensure database is ready
  await database.customStatement('SELECT 1');

  // Initialize privacy service - 确保每次应用启动时隐私库都处于非激活状态
  await PrivacyService.initialize();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

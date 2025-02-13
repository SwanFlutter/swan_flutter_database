import 'package:swan_flutter_database/swan_flutter_database.dart';

import 'database_setup_service.dart';

class DatabaseInitializer {
  final DatabaseConfig config;
  final DatabaseSetupService _setupService;

  DatabaseInitializer({required this.config}) : _setupService = DatabaseSetupService(config: config);

  Future<bool> initialize() async {
    try {
      // ایجاد جدول کاربران
      final usersCreated = await _setupService.createUsersTable();
      if (!usersCreated) {
        print('Failed to create users table');
        return false;
      }

      // ایجاد جدول تسک‌ها
      final todosCreated = await _setupService.createTodosTable();
      if (!todosCreated) {
        print('Failed to create todos table');
        return false;
      }

      return true;
    } catch (e) {
      print('Error initializing database: $e');
      return false;
    }
  }
}

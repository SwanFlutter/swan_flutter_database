import 'package:swan_flutter_database/swan_flutter_database.dart';

class DatabaseSetupService {
  final DatabaseService _dbService;
  final String baseUrl;
  final String? _token;

  DatabaseSetupService({
    required DatabaseConfig config,
    String? token,
  })  : _dbService = DatabaseService(config),
        baseUrl = config.baseUrl,
        _token = token;

  Future<bool> createTodosTable() async {
    try {
      final response = await _dbService.createTable(
        'todos',
        {
          'id': 'INT AUTO_INCREMENT PRIMARY KEY',
          'user_id': 'INT NOT NULL',
          'title': 'VARCHAR(255) NOT NULL',
          'description': 'TEXT',
          'completed': 'BOOLEAN DEFAULT FALSE',
          'created_at': 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
          'updated_at': 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'
        },
        token: _token,
      );

      return response.success;
    } catch (e) {
      print('Error creating todos table: $e');
      return false;
    }
  }

  Future<bool> createUsersTable() async {
    try {
      final response = await _dbService.createTable(
        'users',
        {
          'id': 'INT AUTO_INCREMENT PRIMARY KEY',
          'name': 'VARCHAR(100) NOT NULL',
          'email': 'VARCHAR(255) NOT NULL UNIQUE',
          'password': 'VARCHAR(255) NOT NULL',
          'created_at': 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
          'updated_at': 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'
        },
        token: _token,
      );

      return response.success;
    } catch (e) {
      print('Error creating users table: $e');
      return false;
    }
  }
}

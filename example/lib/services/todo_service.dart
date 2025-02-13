import 'package:swan_flutter_database/swan_flutter_database.dart';

class TodoService {
  final DatabaseService _db;
  final String _tableName = 'todos';

  TodoService(DatabaseConfig config) : _db = DatabaseService(config);

  Future<void> createTodosTable(String token) async {
    await _db.createTable(
        _tableName,
        {
          'id': 'INTEGER PRIMARY KEY AUTOINCREMENT',
          'user_id': 'INTEGER NOT NULL',
          'title': 'TEXT NOT NULL',
          'completed': 'BOOLEAN DEFAULT 0',
          'created_at': 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
        },
        token: token);
  }

  Future<int> addTodo(String title, int userId, String token) async {
    final response = await _db.insert(
        _tableName,
        {
          'title': title,
          'user_id': userId,
        },
        token: token);

    if (response.success && response.data != null) {
      return response.data!.value;
    }
    throw Exception('Failed to add todo');
  }

  Future<List<Map<String, dynamic>>> getUserTodos(int userId, String token) async {
    final response = await _db.select(
      _tableName,
      where: 'user_id = $userId',
      orderBy: 'created_at DESC',
      token: token,
    );

    if (response.success && response.data != null) {
      return response.data!.data;
    }
    return [];
  }

  Future<void> toggleTodo(int todoId, bool completed, String token) async {
    await _db.update(
      _tableName,
      {'completed': completed ? 1 : 0},
      'id = $todoId',
      token: token,
    );
  }

  Future<void> deleteTodo(int todoId, String token) async {
    await _db.delete(
      _tableName,
      'id = $todoId',
      token: token,
    );
  }
}

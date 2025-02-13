import 'package:example/services/auth_manager.dart';
import 'package:example/services/todo_service.dart';
import 'package:flutter/material.dart';
import 'package:swan_flutter_database/swan_flutter_database.dart';

class TodoScreen extends StatefulWidget {
  final DatabaseConfig config;
  const TodoScreen({required this.config, super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late final _todoService = TodoService(widget.config);
  late final _authManager = AuthManager(config: widget.config);
  final _titleController = TextEditingController();
  List<Map<String, dynamic>> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final token = await _authManager.getToken();
      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final todos = await _todoService.getUserTodos(1, token); // userId should come from user data
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _addTodo() async {
    if (_titleController.text.isEmpty) return;

    try {
      final token = await _authManager.getToken();
      if (token == null) return;

      await _todoService.addTodo(_titleController.text, 1, token); // userId should come from user data
      _titleController.clear();
      _loadTodos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todos'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authManager.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return ListTile(
                  title: Text(todo['title']),
                  leading: Checkbox(
                    value: todo['completed'] == 1,
                    onChanged: (value) async {
                      final token = await _authManager.getToken();
                      if (token == null) return;

                      await _todoService.toggleTodo(
                        todo['id'],
                        value ?? false,
                        token,
                      );
                      _loadTodos();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('New Todo'),
              content: TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _addTodo();
                    Navigator.pop(context);
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

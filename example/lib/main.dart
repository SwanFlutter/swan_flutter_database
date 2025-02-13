import 'package:example/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:swan_flutter_database/swan_flutter_database.dart';

class ApiTestService {
  final HttpService _httpService;
  final String _baseUrl;

  ApiTestService(String baseUrl)
      : _baseUrl = baseUrl,
        _httpService = HttpService(baseUrl);

  Future<void> testConnection() async {
    try {
      print('Testing API connection...');
      print('Base URL: $_baseUrl');

      // درخواست به create_table.php
      final response = await _httpService.post(
        '/create_table.php',
        {}, // نیازی به ارسال داده نیست چون ساختار جدول در PHP تعریف شده
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('\nAPI Response:');
      print(response);

      if (response['success'] == true) {
        print('Success: ${response['message']}');
        print('SQL: ${response['sql']}');
      } else {
        print('Error: ${response['message']}');
      }
    } catch (e) {
      print('\nError during API test:');
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');
      rethrow;
    }
  }

  Future<void> testSimpleEndpoint() async {
    try {
      print('Testing simple endpoint...');
      final response = await _httpService.get(
        'test.php',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print('Simple test response:');
      print(response);
    } catch (e) {
      print('Error in simple test:');
      print(e);
      rethrow;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TestScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _status = 'Initializing...';
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      setState(() {
        _isLoading = true;
        _status = 'Testing connection...';
        _error = '';
      });

      final config = DatabaseConfig(
        host: '192.168.1.103',
        dbName: 'todo_app',
        username: 'root',
        password: '',
        baseUrl: 'http://192.168.1.103/todoapp',
      );

      final apiTester = ApiTestService(config.baseUrl);

      // Test simple endpoint
      setState(() => _status = 'Testing simple endpoint...');
      await apiTester.testSimpleEndpoint();

      // Test main connection
      setState(() => _status = 'Testing main connection...');
      await apiTester.testConnection();

      setState(() {
        _status = 'Connection successful!';
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error Stack Trace:');
      print(stackTrace);
      setState(() {
        _error = 'Error: ${e.toString()}\n\nStack Trace:\n${stackTrace.toString()}';
        _isLoading = false;
        _status = 'Connection failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: $_status',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (!_isLoading)
              ElevatedButton(
                onPressed: _testConnection,
                child: const Text('Retry Connection'),
              ),
          ],
        ),
      ),
    );
  }
}

/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = DatabaseConfig(
    host: '192.168.1.103',
    dbName: 'todo_app',
    username: 'root',
    password: '',
    baseUrl: 'http://192.168.1.103/todoapp',
  );

  final dbInitializer = DatabaseInitializer(config: config);

  try {
    final initialized = await dbInitializer.initialize();
    if (!initialized) {
      print('Failed to initialize database');
    } else {
      print('Database initialized successfully');
    }
  } catch (e) {
    print('Error during database initialization: $e');
  }

  runApp(TodoApp(config));
}
*/

class TodoApp extends StatelessWidget {
  final DatabaseConfig config;
  final DatabaseService db;
  final SecurityService security;

  TodoApp(this.config, {super.key})
      : db = DatabaseService(config),
        security = SecurityService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(
        config: config,
      ),
    );
  }
}

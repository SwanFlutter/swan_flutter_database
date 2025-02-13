# SwanFlutterDatabase

A powerful Flutter package for MySQL database integration via PHP backend with built-in image processing capabilities.

## Features

- 🔄 Complete CRUD database operations
- 🔒 Secure connection and data management
- 🎯 Flexible Query Builder
- 📸 Client-side image processing
- 🌐 UTF-8 support
- ⚡ Async/await operations
- 🎨 Automatic data type conversion

## Installation

```yaml
dependencies:
  swan_flutter_database: ^1.0.0
```

## Initial Configuration

```dart
final config = DatabaseConfig(
  host: 'your_host',
  dbName: 'your_database',
  username: 'your_username',
  password: 'your_password',
  baseUrl: 'https://your-api-url.com',
);

final db = DatabaseService(config);
```

## Core Features

### 1. Basic Database Operations

```dart
// Create table
await db.createTable('users', {
  'id': 'INT PRIMARY KEY AUTO_INCREMENT',
  'name': 'VARCHAR(255)',
  'email': 'VARCHAR(255)',
});

// Insert data
await db.insert('users', {
  'name': 'John Doe',
  'email': 'john@example.com',
});

// Read data
final users = await db.select('users', where: 'age > 18');

// Update
await db.update('users', 
  {'status': 'active'}, 
  where: 'id = 1'
);

// Delete
await db.delete('users', where: 'id = 1');
```

### 2. Advanced Query Builder

```dart
final query = AdvancedQueryBuilder()
  .table('users')
  .select(['id', 'name'])
  .leftJoin('orders', 'orders.user_id = users.id')
  .where('users.age > 18')
  .groupBy(['users.id'])
  .having('COUNT(orders.id) > 5')
  .orderBy('name')
  .limit(10)
  .build();

final results = await db.query(query);
```

### 3. Image Processing

```dart
final imageProcessor = ImageProcessingService();

// Resize image
final resizedImage = await imageProcessor.processImage(
  imageFile,
  operation: 'resize',
  params: {
    'width': 800,
    'height': 600,
    'quality': 80,
  },
);

// Convert to grayscale
final grayscaleImage = await imageProcessor.processImage(
  imageFile,
  operation: 'grayscale',
);
```

### 4. Security Management

```dart
final security = SecurityService();

// Encrypt data
final encrypted = security.encryptData(sensitiveData);

// Secure storage
await security.secureStore('api_key', apiKey);

// Secure retrieval
final storedKey = await security.secureRetrieve('api_key');
```

## Important Notes

1. **Error Handling**
```dart
try {
  final result = await db.query(query);
} catch (e) {
  print('Database error: $e');
}
```

2. **Performance Optimization**
- Use `where` to limit results
- Use `select` to choose specific fields
- Process images with appropriate quality

3. **Security**
- Use HTTPS
- Encrypt sensitive data
- Validate inputs

## Limitations

- Large image processing might be slow
- Complex SQL operations may require manual queries
- Requires proper CORS configuration on server

## Practical Examples

### User Management System
```dart
class UserManager {
  final DatabaseService db;
  final SecurityService security;
  
  Future<void> createUser(User user) async {
    final hashedPassword = security.encryptData(user.password);
    await db.insert('users', {
      ...user.toMap(),
      'password': hashedPassword,
    });
  }
  
  Future<User?> login(String email, String password) async {
    final result = await db.select('users', 
      where: 'email = "$email"'
    );
    // Validate and return user
  }
}
```

### Image Upload System
```dart
class ImageUploader {
  final ImageProcessingService imageProcessor;
  final DatabaseService db;
  
  Future<String> uploadProfileImage(File image) async {
    // Process image
    final processed = await imageProcessor.processImage(
      image,
      operation: 'resize',
      params: {'width': 200, 'height': 200}
    );
    
    // Upload and save path
    final path = await uploadToServer(processed);
    return path;
  }
}
```

## Support

For bug reports or feature requests:
- Create an issue on GitHub
- Submit a Pull Request
- Check the detailed documentation

## License
MIT

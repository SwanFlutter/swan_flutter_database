import 'package:swan_flutter_database/swan_flutter_database.dart';

class AuthManager {
  final AuthService _authService;
  final SecurityService _securityService;
  final CacheService _cacheService;

  AuthManager({
    required DatabaseConfig config,
  })  : _authService = AuthService(config),
        _securityService = SecurityService(),
        _cacheService = CacheService();

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    // اعتبارسنجی پسورد
    if (!_securityService.validateSensitiveData(password)) {
      throw Exception('Password is not strong enough');
    }

    final response = await _authService.register({
      'email': email,
      'password': password,
      'name': name,
    });

    if (response.success && response.token != null) {
      await _cacheService.set('auth_token', response.token);
      return true;
    }

    throw Exception(response.message ?? 'Registration failed');
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final response = await _authService.login({
      'email': email,
      'password': password,
    });

    if (response.success && response.token != null) {
      await _cacheService.set('auth_token', response.token);
      return true;
    }

    throw Exception(response.message ?? 'Login failed');
  }

  Future<bool> logout() async {
    return await _cacheService.delete('auth_token');
  }

  Future<String?> getToken() async {
    return await _cacheService.get('auth_token');
  }
}

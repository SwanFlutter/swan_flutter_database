import '../services/cache_service.dart';
import '../utils/logger.dart';

abstract class DatabaseMiddleware {
  Future<dynamic> beforeQuery(String query);
  Future<void> afterQuery(String query, dynamic result);
}

class LoggingMiddleware implements DatabaseMiddleware {
  final Logger _logger;

  LoggingMiddleware(this._logger);

  @override
  Future<dynamic> beforeQuery(String query) async {
    _logger.log(LogLevel.info, 'Executing query: $query');
  }

  @override
  Future<void> afterQuery(String query, dynamic result) async {
    _logger.log(LogLevel.info, 'Query result: $result');
  }
}

class ValidationMiddleware implements DatabaseMiddleware {
  @override
  Future<dynamic> beforeQuery(String query) async {
    // بررسی امنیت کوئری
    if (query.toLowerCase().contains('drop') || query.toLowerCase().contains('truncate')) {
      throw Exception('Dangerous query detected!');
    }
  }

  @override
  Future<void> afterQuery(String query, dynamic result) async {
    // می‌توانید اعتبارسنجی نتیجه را اینجا انجام دهید
  }
}

class CachingMiddleware implements DatabaseMiddleware {
  final CacheService _cache;

  CachingMiddleware(this._cache);

  @override
  Future<dynamic> beforeQuery(String query) async {
    // بررسی کش قبل از اجرای کوئری
    final cachedResult = await _cache.get(query);
    if (cachedResult != null) {
      return cachedResult;
    }
    return null;
  }

  @override
  Future<void> afterQuery(String query, dynamic result) async {
    // ذخیره نتیجه در کش
    await _cache.set(query, result);
  }
}

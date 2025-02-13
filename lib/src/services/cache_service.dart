class CacheService {
  final Map<String, dynamic> _cache = {};
  final Map<String, int> _ttls = {};

  Future<dynamic> get(String key) async {
    if (_ttls[key] != null && DateTime.now().millisecondsSinceEpoch > _ttls[key]!) {
      delete(key);
      return null;
    }
    return _cache[key];
  }

  Future<void> set(String key, dynamic value, {int ttl = 3600}) async {
    _cache[key] = value;
    _ttls[key] = DateTime.now().millisecondsSinceEpoch + (ttl * 1000);
  }

  Future<bool> delete(String key) async {
    _cache.remove(key);
    _ttls.remove(key);
    return true;
  }
}

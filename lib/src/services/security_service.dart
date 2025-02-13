import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  final _storage = const FlutterSecureStorage();
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;
  bool _isInitialized = false;

  SecurityService() {
    _initEncryption();
  }

  Future<void> _initEncryption() async {
    if (_isInitialized) return;

    // دریافت یا ایجاد کلید رمزنگاری
    String? key = await _storage.read(key: 'encryption_key');

    // اگر کلید وجود نداشت، یک کلید جدید بساز
    if (key == null) {
      final newKey = encrypt.Key.fromSecureRandom(32);
      key = base64.encode(newKey.bytes);
      await _storage.write(key: 'encryption_key', value: key);
    }

    // تنظیم رمزنگار
    final encryptionKey = encrypt.Key.fromBase64(key);
    _encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey));
    _iv = encrypt.IV.fromLength(16);
    _isInitialized = true;
  }

  // اطمینان از اینکه سرویس آماده است
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initEncryption();
    }
  }

  // رمزنگاری داده
  Future<String> encryptData(String data) async {
    await ensureInitialized();
    return _encrypter.encrypt(data, iv: _iv).base64;
  }

  // رمزگشایی داده
  Future<String> decryptData(String encryptedData) async {
    await ensureInitialized();
    return _encrypter.decrypt64(encryptedData, iv: _iv);
  }

  // ذخیره امن داده
  Future<void> secureStore(String key, String value) async {
    await ensureInitialized();
    final encrypted = await encryptData(value);
    await _storage.write(key: key, value: encrypted);
  }

  // بازیابی امن داده
  Future<String?> secureRetrieve(String key) async {
    await ensureInitialized();
    final encrypted = await _storage.read(key: key);
    if (encrypted == null) return null;
    return await decryptData(encrypted);
  }

  // حذف امن داده
  Future<void> secureDelete(String key) async {
    await ensureInitialized();
    await _storage.delete(key: key);
  }

  // تولید توکن امن
  Future<String> generateSecureToken() async {
    await ensureInitialized();
    final random = encrypt.Key.fromSecureRandom(32);
    return base64.encode(random.bytes);
  }

  // اعتبارسنجی داده‌های حساس
  bool validateSensitiveData(
    String data, {
    bool requireSpecialChars = true,
    bool requireNumbers = true,
    int minLength = 8,
  }) {
    if (data.length < minLength) return false;
    if (requireSpecialChars && !data.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    if (requireNumbers && !data.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  // پاکسازی داده‌های حساس
  String sanitizeSensitiveData(String data) {
    // حذف کاراکترهای خطرناک
    return data.replaceAll('<', '').replaceAll('>', '').replaceAll('"', '').replaceAll("'", '').replaceAll('\\', '');
  }
}

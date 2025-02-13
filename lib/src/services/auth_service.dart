import 'dart:convert';

import '../config/database_config.dart';
import '../models/auth_response.dart';
import 'http_service.dart';

class AuthService {
  final DatabaseConfig config;
  late final HttpService _httpService;

  AuthService(this.config) {
    _httpService = HttpService(config.baseUrl);
  }

  Future<AuthResponse> login(Map<String, dynamic> credentials) async {
    try {
      final response = await _httpService.post(
        'v1/login',
        credentials,
      );
      return AuthResponse.fromJson(json.encode(response));
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  Future<AuthResponse> register(Map<String, dynamic> userData) async {
    try {
      final response = await _httpService.post(
        'v1/register',
        userData,
      );
      return AuthResponse.fromJson(json.encode(response));
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  Future<AuthResponse> verify(String token) async {
    try {
      final response = await _httpService.post(
        'v1/verify',
        {},
        headers: {'token': token},
      );
      return AuthResponse.fromJson(json.encode(response));
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpException implements Exception {
  final String message;
  final int? statusCode;

  HttpException(this.message, {this.statusCode});

  @override
  String toString() => 'HttpException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
}

class HttpService {
  final String baseUrl;
  final int maxRetries;
  final Duration retryDelay;

  HttpService(
    this.baseUrl, {
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  Future<T> _retry<T>(Future<T> Function() operation) async {
    for (var i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(retryDelay * (i + 1));
      }
    }
    throw HttpException('Max retries exceeded');
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {Map<String, String>? headers}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json', ...?headers},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw HttpException(responseData['message'] ?? 'Unknown error', statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException(e.toString());
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers, Map<String, String>? params}) async {
    try {
      String queryString = Uri(queryParameters: params).query;
      final response = await http.get(Uri.parse('$baseUrl/$endpoint?$queryString'), headers: {'Content-Type': 'application/json', ...?headers});

      if (response.statusCode == 200)
        return json.decode(response.body);
      else
        return {'success': false, 'message': 'HTTP Error: ${response.statusCode}', 'data': null};
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'data': null};
    }
  }
}

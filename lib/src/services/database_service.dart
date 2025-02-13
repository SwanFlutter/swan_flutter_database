import 'dart:convert';

import 'package:swan_flutter_database/src/models/map_pableList.dart';
import 'package:swan_flutter_database/src/models/mappable.dart';
import 'package:swan_flutter_database/src/models/simple_mappable.dart';

import '../config/database_config.dart';
import '../models/database_response.dart';
import 'http_service.dart';

class DatabaseService {
  final DatabaseConfig config;
  late final HttpService _httpService;

  DatabaseService(this.config) {
    _httpService = HttpService(config.baseUrl);
  }

  // ایجاد جدول
  Future<DatabaseResponse<SimpleMappable<bool>>> createTable(String tableName, Map<String, String> columns, {String? token}) async {
    try {
      final response = await _httpService.post(
        'v1/database/create_table',
        {
          'table_name': tableName,
          'columns': columns,
        },
        headers: {'token': token ?? ''},
      );
      return DatabaseResponse<SimpleMappable<bool>>.fromJson(json.encode(response));
    } catch (e) {
      return DatabaseResponse<SimpleMappable<bool>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // درج اطلاعات
  Future<DatabaseResponse<SimpleMappable<int>>> insert(String tableName, Map<String, dynamic> data, {String? token}) async {
    try {
      final response = await _httpService.post(
        'v1/database/insert',
        {
          'table_name': tableName,
          'data': data,
        },
        headers: {'token': token ?? ''},
      );
      return DatabaseResponse<SimpleMappable<int>>.fromJson(json.encode(response));
    } catch (e) {
      return DatabaseResponse<SimpleMappable<int>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // به‌روزرسانی اطلاعات
  Future<DatabaseResponse<SimpleMappable<int>>> update(String tableName, Map<String, dynamic> data, String where, {String? token}) async {
    try {
      final response = await _httpService.post(
        'v1/database/update',
        {
          'table_name': tableName,
          'data': data,
          'where': where,
        },
        headers: {'token': token ?? ''},
      );
      return DatabaseResponse<SimpleMappable<int>>.fromJson(json.encode(response));
    } catch (e) {
      return DatabaseResponse<SimpleMappable<int>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // حذف اطلاعات
  Future<DatabaseResponse<SimpleMappable<int>>> delete(String tableName, String where, {String? token}) async {
    try {
      final response = await _httpService.post(
        'v1/database/delete',
        {
          'table_name': tableName,
          'where': where,
        },
        headers: {'token': token ?? ''},
      );
      return DatabaseResponse<SimpleMappable<int>>.fromJson(json.encode(response));
    } catch (e) {
      return DatabaseResponse<SimpleMappable<int>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // دریافت اطلاعات
  Future<DatabaseResponse<MappableList>> select(String tableName, {List<String>? columns, String? where, String? orderBy, int? limit, String? token}) async {
    try {
      final response = await _httpService.get(
        'v1/database/select',
        headers: {'token': token ?? ''},
        params: {
          'table_name': tableName,
          if (columns != null) 'columns': json.encode(columns),
          if (where != null) 'where': where,
          if (orderBy != null) 'order_by': orderBy,
          if (limit != null) 'limit': limit.toString(),
        },
      );

      return DatabaseResponse<MappableList>.fromJson(json.encode(response));
    } catch (e) {
      return DatabaseResponse<MappableList>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // اجرای کوئری دلخواه
  Future<DatabaseResponse<dynamic>> query(String sql, {String? token}) async {
    try {
      final response = await _httpService.post(
        'v1/database/query',
        {'sql': sql},
        headers: {'token': token ?? ''},
      );

      return DatabaseResponse<Mappable>.fromJson(json.encode(response));
    } catch (e) {
      return DatabaseResponse<Mappable>(
        success: false,
        message: e.toString(),
      );
    }
  }
}

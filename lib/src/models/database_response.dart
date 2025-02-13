// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:swan_flutter_database/src/models/mappable.dart';

class DatabaseResponse<T extends Mappable> {
  final bool success;
  final T? data;
  final String? message;

  DatabaseResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory DatabaseResponse.fromJsonMap(Map<String, dynamic> json) {
    return DatabaseResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? Mappable.fromMap(json['data']) as T : null,
      message: json['message'],
    );
  }

  DatabaseResponse<T> copyWith({
    bool? success,
    T? data,
    String? message,
  }) {
    return DatabaseResponse<T>(
      success: success ?? this.success,
      data: data ?? this.data,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'data': data?.toMap(),
      'message': message,
    };
  }

  factory DatabaseResponse.fromMap(Map<String, dynamic> map) {
    return DatabaseResponse<T>(
      success: map['success'] as bool,
      data: map['data'] != null ? Mappable.fromMap(map['data']) as T : null,
      message: map['message'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory DatabaseResponse.fromJson(String source) => DatabaseResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DatabaseResponse(success: $success, data: $data, message: $message)';

  @override
  bool operator ==(covariant DatabaseResponse<T> other) {
    if (identical(this, other)) return true;

    return other.success == success && other.data == data && other.message == message;
  }

  @override
  int get hashCode => success.hashCode ^ (data?.hashCode ?? 0) ^ (message?.hashCode ?? 0);
}

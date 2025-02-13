// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AuthResponse {
  final bool success;
  final String? message;
  final String? token;

  AuthResponse({
    required this.success,
    this.message,
    this.token,
  });

  factory AuthResponse.fromJsonMap(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      token: json['token'],
    );
  }

  AuthResponse copyWith({
    bool? success,
    String? message,
    String? token,
  }) {
    return AuthResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'token': token,
    };
  }

  factory AuthResponse.fromMap(Map<String, dynamic> map) {
    return AuthResponse(
      success: map['success'] as bool,
      message: map['message'] != null ? map['message'] as String : null,
      token: map['token'] != null ? map['token'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthResponse.fromJson(String source) => AuthResponse.fromJsonMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AuthResponse(success: $success, message: $message, token: $token)';

  @override
  bool operator ==(covariant AuthResponse other) {
    if (identical(this, other)) return true;

    return other.success == success && other.message == message && other.token == token;
  }

  @override
  int get hashCode => success.hashCode ^ message.hashCode ^ token.hashCode;
}

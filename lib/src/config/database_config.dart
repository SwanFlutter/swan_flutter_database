// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DatabaseConfig {
  final String host;
  final String dbName;
  final String username;
  final String password;
  final String baseUrl;

  const DatabaseConfig({
    required this.host,
    required this.dbName,
    required this.username,
    required this.password,
    required this.baseUrl,
  });

  Map<String, dynamic> toJsonMap() => {'host': host, 'dbname': dbName, 'username': username, 'password': password, 'base_url': baseUrl};

  DatabaseConfig copyWith({
    String? host,
    String? dbName,
    String? username,
    String? password,
    String? baseUrl,
  }) {
    return DatabaseConfig(
      host: host ?? this.host,
      dbName: dbName ?? this.dbName,
      username: username ?? this.username,
      password: password ?? this.password,
      baseUrl: baseUrl ?? this.baseUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'host': host,
      'dbName': dbName,
      'username': username,
      'password': password,
      'baseUrl': baseUrl,
    };
  }

  factory DatabaseConfig.fromMap(Map<String, dynamic> map) {
    return DatabaseConfig(
      host: map['host'] as String,
      dbName: map['dbName'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      baseUrl: map['baseUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DatabaseConfig.fromJson(String source) => DatabaseConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DatabaseConfig(host: $host, dbName: $dbName, username: $username, password: $password, baseUrl: $baseUrl)';
  }

  @override
  bool operator ==(covariant DatabaseConfig other) {
    if (identical(this, other)) return true;

    return other.host == host && other.dbName == dbName && other.username == username && other.password == password && other.baseUrl == baseUrl;
  }

  @override
  int get hashCode {
    return host.hashCode ^ dbName.hashCode ^ username.hashCode ^ password.hashCode ^ baseUrl.hashCode;
  }
}

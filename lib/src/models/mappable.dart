// ignore_for_file: file_names

abstract class Mappable {
  Map<String, dynamic> toMap();
  factory Mappable.fromMap(Map<String, dynamic> map) => throw UnimplementedError();
}

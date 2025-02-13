// ignore_for_file: file_names

import 'package:swan_flutter_database/src/models/mappable.dart';

class MappableList implements Mappable {
  final List<Map<String, dynamic>> data;

  MappableList(this.data);

  Map<String, dynamic> toJson() {
    return {'data': data};
  }

  @override
  Map<String, dynamic> toMap() {
    return {'data': data};
  }

  factory MappableList.fromJson(Map<String, dynamic> json) {
    return MappableList(List<Map<String, dynamic>>.from(json['data']));
  }
}

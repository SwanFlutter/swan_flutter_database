import 'package:swan_flutter_database/src/models/mappable.dart';

class SimpleMappable<T> implements Mappable {
  final T value;

  SimpleMappable(this.value);

  @override
  Map<String, dynamic> toMap() {
    return {'value': value};
  }

  factory SimpleMappable.fromMap(Map<String, dynamic> map) {
    return SimpleMappable(map['value']);
  }
}

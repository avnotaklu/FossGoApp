import 'package:hive/hive.dart';

extension SafeMap on Box<dynamic> {
  Map<String, dynamic>? getMap(String key) {
    return _hiveGetMap<dynamic>(get(key));
  }

  void putMap(String key, Map<String, dynamic> value) {
    put(key, value);
  }
}

Map<String, V>? _hiveGetMap<V>(dynamic data) {
  if (data == null) return null;

  return Map.castFrom<dynamic, dynamic, String, V>(data);
}

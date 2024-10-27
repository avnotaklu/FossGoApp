import 'dart:convert';

class MovePosition {
  final int? x;
  final int? y;
  MovePosition({
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'y': y,
    };
  }

  factory MovePosition.fromMap(Map<String, dynamic> map) {
    return MovePosition(
      x: map['x'] as int?,
      y: map['y'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory MovePosition.fromJson(String source) =>
      MovePosition.fromMap(json.decode(source) as Map<String, dynamic>);
}

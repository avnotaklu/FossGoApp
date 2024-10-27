import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GameMove {
  final DateTime time;
  final int? x;
  final int? y;
  GameMove({
    required this.time,
    this.x,
    this.y,
  });

  bool isPass() {
    return x == null && y == null;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'time': time.toString(),
      'x': x,
      'y': y,
    };
  }

  factory GameMove.fromMap(Map<String, dynamic> map) {
    return GameMove(
      time: DateTime.parse(map['time'] as String),
      x: map['x'] != null ? map['x'] as int : null,
      y: map['y'] != null ? map['y'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameMove.fromJson(String source) =>
      GameMove.fromMap(json.decode(source) as Map<String, dynamic>);
}

import 'dart:convert';

import 'package:go/models/game.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GameMove {
  final DateTime time;
  final int? x;
  final int? y;
  GameMove({
    required this.time,
    required this.x,
    required this.y,
  });

  bool isPass() {
    return x == null && y == null;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      GameFieldNames.Time: time.toIso8601String(),
      GameFieldNames.X: x,
      GameFieldNames.Y: y,
    };
  }

  factory GameMove.fromMap(Map<String, dynamic> map) {
    return GameMove(
      time: DateTime.parse(map[GameFieldNames.Time] as String),
      x: map[GameFieldNames.X] as int?,
      y: map[GameFieldNames.Y] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameMove.fromJson(String source) =>
      GameMove.fromMap(json.decode(source) as Map<String, dynamic>);
}

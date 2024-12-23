import 'dart:convert';

import 'package:go/models/game.dart';
import 'package:go/models/position.dart';

extension GameMoveExt on GameMove {
  Position? toPosition() {
    if (x == null || y == null) {
      return null;
    }
    return Position(x!, y!);
  }
}

class GameMove {
  final int secondsAfterStart;
  final int? x;
  final int? y;

  GameMove({
    required this.secondsAfterStart,
    required this.x,
    required this.y,
  });

  bool isPass() {
    return x == null && y == null;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      GameFieldNames.SecondsAfterStart: secondsAfterStart,
      GameFieldNames.X: x,
      GameFieldNames.Y: y,
    };
  }

  factory GameMove.fromMap(Map<String, dynamic> map) {
    return GameMove(
      secondsAfterStart: map[GameFieldNames.SecondsAfterStart] as int,
      x: map[GameFieldNames.X] as int?,
      y: map[GameFieldNames.Y] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameMove.fromJson(String source) =>
      GameMove.fromMap(json.decode(source) as Map<String, dynamic>);
}

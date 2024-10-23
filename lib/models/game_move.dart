import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GameMove {
  final String playerId;
  final DateTime playedAt;
  final int? x;
  final int? y;
  GameMove({
    required this.playerId,
    required this.playedAt,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'playerId': playerId,
      'playedAt': playedAt.toString(),
      'x': x,
      'y': y,
    };
  }

  factory GameMove.fromMap(Map<String, dynamic> map) {
    return GameMove(
      playerId: map['playerId'] as String,
      playedAt: DateTime.parse(map['playedAt'] as String),
      x: map['x'] as int?,
      y: map['y'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameMove.fromJson(String source) =>
      GameMove.fromMap(json.decode(source) as Map<String, dynamic>);

  bool isPass() {
    return x == null && y == null;
  }
}

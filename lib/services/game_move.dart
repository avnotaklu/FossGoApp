import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GameMove {
  final String playerId;
  final int x;
  final int y;
  GameMove({
    required this.playerId,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'playerId': playerId,
      'x': x,
      'y': y,
    };
  }

  factory GameMove.fromMap(Map<String, dynamic> map) {
    return GameMove(
      playerId: map['playerId'] as String,
      x: map['x'] as int,
      y: map['y'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameMove.fromJson(String source) => GameMove.fromMap(json.decode(source) as Map<String, dynamic>);
}

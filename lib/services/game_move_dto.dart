import 'dart:convert';

class GameMoveDto {
  final String playerId;
  final int? x;
  final int? y;
  GameMoveDto({
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

  factory GameMoveDto.fromMap(Map<String, dynamic> map) {
    return GameMoveDto(
      playerId: map['playerId'] as String,
      x: map['x'] as int?,
      y: map['y'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameMoveDto.fromJson(String source) =>
      GameMoveDto.fromMap(json.decode(source) as Map<String, dynamic>);
}

import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GameJoinDto {
final String gameId;
  GameJoinDto({
    required this.gameId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gameId': gameId,
    };
  }

  factory GameJoinDto.fromMap(Map<String, dynamic> map) {
    return GameJoinDto(
      gameId: map['gameId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameJoinDto.fromJson(String source) => GameJoinDto.fromMap(json.decode(source) as Map<String, dynamic>);
}

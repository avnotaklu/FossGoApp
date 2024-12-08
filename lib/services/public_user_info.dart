import 'dart:convert';
import 'package:go/services/player_rating.dart';

enum PlayerType { normal, guest }

class PublicUserInfo {
  final String? username;
  final PlayerType playerType;
  final String id;
  final PlayerRating? rating;

  PublicUserInfo({
    required this.username,
    required this.playerType,
    required this.id,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'id': id,
      'rating': rating?.toMap(),
      'playerType': playerType.index,
    };
  }

  factory PublicUserInfo.fromMap(Map<String, dynamic> map) {
    return PublicUserInfo(
      username: map['username'] as String?,
      id: map['id'] as String,
      rating: map['rating'] != null
          ? PlayerRating.fromMap(map['rating'] as Map<String, dynamic>)
          : null,
      playerType: PlayerType.values[map['playerType'] as int],
    );
  }

  String toJson() => json.encode(toMap());

  factory PublicUserInfo.fromJson(String source) =>
      PublicUserInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}

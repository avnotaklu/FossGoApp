import 'dart:convert';
import 'package:go/services/user_rating.dart';

enum PlayerType { normal, guest }

class PublicUserInfo {
  final String? email;
  final PlayerType playerType;
  final String id;
  final UserRating? rating;

  PublicUserInfo({
    required this.email,
    required this.playerType,
    required this.id,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'id': id,
      'rating': rating?.toMap(),
      'playerType': playerType.index,
    };
  }

  factory PublicUserInfo.fromMap(Map<String, dynamic> map) {
    return PublicUserInfo(
      email: map['email'] as String?,
      id: map['id'] as String,
      rating: map['rating'] != null
          ? UserRating.fromMap(map['rating'] as Map<String, dynamic>)
          : null,
      playerType: PlayerType.values[map['playerType'] as int],
    );
  }

  String toJson() => json.encode(toMap());

  factory PublicUserInfo.fromJson(String source) =>
      PublicUserInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}

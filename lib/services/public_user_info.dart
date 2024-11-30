import 'dart:convert';

import 'package:go/services/user_rating.dart';

class PublicUserInfo {
  final String email;
  final String id;
  final UserRating rating;

  PublicUserInfo(this.email, this.id, this.rating);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'id': id,
      'rating': rating.toMap(),
    };
  }

  factory PublicUserInfo.fromMap(Map<String, dynamic> map) {
    return PublicUserInfo(
      map['email'] as String,
      map['id'] as String,
      UserRating.fromMap(map['rating'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory PublicUserInfo.fromJson(String source) =>
      PublicUserInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/services/user_rating.dart';

class UserRatingResult {
  final String userId;
  final UserRating userRating;
  UserRatingResult({
    required this.userId,
    required this.userRating,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'userRating': userRating.toMap(),
    };
  }

  factory UserRatingResult.fromMap(Map<String, dynamic> map) {
    return UserRatingResult(
      userId: map['userId'] as String,
      userRating: UserRating.fromMap(map['userRating'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRatingResult.fromJson(String source) =>
      UserRatingResult.fromMap(json.decode(source) as Map<String, dynamic>);
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/services/guest_user.dart';

class GuestUserResult {
  final GuestUser user;
  final String token;
  GuestUserResult({
    required this.user,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user.toMap(),
      'token': token,
    };
  }

  factory GuestUserResult.fromMap(Map<String, dynamic> map) {
    return GuestUserResult(
      user: GuestUser.fromMap(map['user'] as Map<String, dynamic>),
      token: map['token'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GuestUserResult.fromJson(String source) =>
      GuestUserResult.fromMap(json.decode(source) as Map<String, dynamic>);
}

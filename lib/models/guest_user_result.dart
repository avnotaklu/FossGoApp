// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/auth_creds.dart';
import 'package:go/models/guest_user.dart';
import 'package:go/models/user_account.dart';

class GuestUserResult {
  final GuestUser user;
  final AuthCreds creds;
  GuestUserResult({
    required this.user,
    required this.creds,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user.toMap(),
      'creds': creds.toMap(),
    };
  }

  factory GuestUserResult.fromMap(Map<String, dynamic> map) {
    return GuestUserResult(
      user: GuestUser.fromMap(map['user'] as Map<String, dynamic>),
      creds: AuthCreds.fromMap(map['creds'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory GuestUserResult.fromJson(String source) =>
      GuestUserResult.fromMap(json.decode(source) as Map<String, dynamic>);
}

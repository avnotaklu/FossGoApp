// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/user_account.dart';

class UpdateProfileResult {
  final UserAccount user;

  UpdateProfileResult({
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user.toMap(),
    };
  }

  factory UpdateProfileResult.fromMap(Map<String, dynamic> map) {
    return UpdateProfileResult(
      user: UserAccount.fromMap(map['user'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdateProfileResult.fromJson(String source) =>
      UpdateProfileResult.fromMap(json.decode(source) as Map<String, dynamic>);
}

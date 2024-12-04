// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/services/app_user.dart';
import 'package:go/services/public_user_info.dart';

class RegisterUserResult {
  // final List<AppUser> otherActivePlayers;
  final PublicUserInfo currentUser;
  RegisterUserResult({
    required this.currentUser,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentUser': currentUser.toMap(),
    };
  }

  factory RegisterUserResult.fromMap(Map<String, dynamic> map) {
    return RegisterUserResult(
      currentUser:
          PublicUserInfo.fromMap(map['currentUser'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterUserResult.fromJson(String source) =>
      RegisterUserResult.fromMap(json.decode(source) as Map<String, dynamic>);
}

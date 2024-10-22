// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:go/services/app_user.dart';

class RegisterUserResult {
  final List<AppUser> otherActivePlayers;

  RegisterUserResult({required this.otherActivePlayers});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'otherActivePlayers': otherActivePlayers.map((x) => x.toMap()).toList(),
    };
  }

  factory RegisterUserResult.fromMap(Map<String, dynamic> map) {
    return RegisterUserResult(
      otherActivePlayers: List<AppUser>.from((map['otherActivePlayers'] as List).map<AppUser>((x) => AppUser.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterUserResult.fromJson(String source) => RegisterUserResult.fromMap(json.decode(source) as Map<String, dynamic>);
}

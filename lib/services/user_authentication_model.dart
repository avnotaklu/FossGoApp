// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';


import 'package:go/services/app_user.dart';

class UserAuthenticationModel {
  final AppUser user;
  final String token;

  UserAuthenticationModel(this.user, this.token);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user.toMap(),
      'token': token,
    };
  }

  factory UserAuthenticationModel.fromMap(Map<String, dynamic> map) {
    return UserAuthenticationModel(
      AppUser.fromMap(map['user'] as Map<String,dynamic>),
      map['token'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAuthenticationModel.fromJson(String source) => UserAuthenticationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/services/auth_creds.dart';
import 'package:go/services/user_account.dart';

class UserAuthenticationModel {
  final UserAccount user;
  final AuthCreds creds;

  UserAuthenticationModel(this.user, this.creds);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user.toMap(),
      'creds': creds.toMap(),
    };
  }

  factory UserAuthenticationModel.fromMap(Map<String, dynamic> map) {
    return UserAuthenticationModel(
      UserAccount.fromMap(map['user'] as Map<String, dynamic>),
      AuthCreds.fromMap(map['creds'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAuthenticationModel.fromJson(String source) =>
      UserAuthenticationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}

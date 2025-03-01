// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AuthCreds {
  final String token;
  final String? refreshToken;

  AuthCreds({required this.token, required this.refreshToken});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
      'refreshToken': refreshToken,
    };
  }

  factory AuthCreds.fromMap(Map<String, dynamic> map) {
    return AuthCreds(
      token: map['token'] as String,
      refreshToken: map['refreshToken'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthCreds.fromJson(String source) =>
      AuthCreds.fromMap(json.decode(source) as Map<String, dynamic>);
}

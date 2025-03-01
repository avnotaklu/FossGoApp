// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/user_authentication_model.dart';

class GoogleSignInBody {
  final String token;
  GoogleSignInBody({
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
    };
  }

  factory GoogleSignInBody.fromMap(Map<String, dynamic> map) {
    return GoogleSignInBody(
      token: map['token'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GoogleSignInBody.fromJson(String source) =>
      GoogleSignInBody.fromMap(json.decode(source) as Map<String, dynamic>);
}

class GoogleSignUpBody {
  final String username;
  GoogleSignUpBody({
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
    };
  }

  factory GoogleSignUpBody.fromMap(Map<String, dynamic> map) {
    return GoogleSignUpBody(
      username: map['username'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GoogleSignUpBody.fromJson(String source) =>
      GoogleSignUpBody.fromMap(json.decode(source) as Map<String, dynamic>);
}

class GoogleSignInResponse {
  final bool authenticated;
  final String? newOAuthToken;
  final UserAuthenticationModel? auth;
  GoogleSignInResponse({
    required this.authenticated,
    this.newOAuthToken,
    required this.auth,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'authenticated': authenticated,
      'newOAuthToken': newOAuthToken,
      'auth': auth?.toMap(),
    };
  }

  factory GoogleSignInResponse.fromMap(Map<String, dynamic> map) {
    return GoogleSignInResponse(
      authenticated: map['authenticated'] as bool,
      newOAuthToken:
          map['newOAuthToken'] != null ? map['newOAuthToken'] as String : null,
      auth: map['auth'] != null
          ? UserAuthenticationModel.fromMap(map['auth'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GoogleSignInResponse.fromJson(String source) =>
      GoogleSignInResponse.fromMap(json.decode(source) as Map<String, dynamic>);
}

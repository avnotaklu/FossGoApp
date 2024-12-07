import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SignInDto {
  final String? username;
  final String? email;
  final String? googleToken;
  final String? password;
  SignInDto({
    this.username,
    this.email,
    this.googleToken,
    this.password,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'email': email,
      'googleToken': googleToken,
      'password': password,
    };
  }

  factory SignInDto.fromMap(Map<String, dynamic> map) {
    return SignInDto(
      username: map['username'] != null ? map['username'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      googleToken:
          map['googleToken'] != null ? map['googleToken'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SignInDto.fromJson(String source) =>
      SignInDto.fromMap(json.decode(source) as Map<String, dynamic>);
}

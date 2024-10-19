// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserDetailsDto {
  final String email;
  final String? password;
  final bool googleSignIn;

  UserDetailsDto(this.email, this.googleSignIn, this.password);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      'googleSignIn': googleSignIn,
    };
  }

  factory UserDetailsDto.fromMap(Map<String, dynamic> map) {
    return UserDetailsDto(
      map['email'] as String,
      map['googleSignIn'] as bool,
      map['password'] != null ? map['password'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDetailsDto.fromJson(String source) => UserDetailsDto.fromMap(json.decode(source) as Map<String, dynamic>);
}

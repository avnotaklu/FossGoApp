// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserDetailsDto {
  final String? email;
  final String? password;
  final bool googleSignIn;
  final String username;
  final String? fullName;
  final String? bio;
  final String? avatar;
  final String? nationalilty;
  UserDetailsDto({
    this.email,
    this.password,
    required this.googleSignIn,
    required this.username,
    this.fullName,
    this.bio,
    this.avatar,
    this.nationalilty,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      'googleSignIn': googleSignIn,
      'username': username,
      'fullName': fullName,
      'bio': bio,
      'avatar': avatar,
      'nationalilty': nationalilty,
    };
  }

  factory UserDetailsDto.fromMap(Map<String, dynamic> map) {
    return UserDetailsDto(
      email: map['email'] != null ? map['email'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      googleSignIn: map['googleSignIn'] as bool,
      username: map['username'] as String,
      fullName: map['fullName'] != null ? map['fullName'] as String : null,
      bio: map['bio'] != null ? map['bio'] as String : null,
      avatar: map['avatar'] != null ? map['avatar'] as String : null,
      nationalilty:
          map['nationalilty'] != null ? map['nationalilty'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDetailsDto.fromJson(String source) =>
      UserDetailsDto.fromMap(json.decode(source) as Map<String, dynamic>);
}

import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserAccount {
  final String id;
  final String? email;
  final String? passwordHash;
  final bool googleSignIn;
  final String userName;
  final String? fullName;
  final String? bio;
  final String? avatar;
  final DateTime creationDate;
  final DateTime lastSeen;
  final String? nationality;

  UserAccount({
    required this.id,
    this.email,
    this.passwordHash,
    required this.googleSignIn,
    required this.userName,
    this.fullName,
    this.bio,
    this.avatar,
    required this.creationDate,
    required this.lastSeen,
    this.nationality,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'passwordHash': passwordHash,
      'googleSignIn': googleSignIn,
      'userName': userName,
      'fullName': fullName,
      'bio': bio,
      'avatar': avatar,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
      'nationality': nationality,
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] as String,
      email: map['email'] != null ? map['email'] as String : null,
      passwordHash:
          map['passwordHash'] != null ? map['passwordHash'] as String : null,
      googleSignIn: map['googleSignIn'] as bool,
      userName: map['userName'] as String,
      fullName: map['fullName'] != null ? map['fullName'] as String : null,
      bio: map['bio'] != null ? map['bio'] as String : null,
      avatar: map['avatar'] != null ? map['avatar'] as String : null,
      creationDate: DateTime.parse(map['creationDate'] as String),
      lastSeen: DateTime.parse(map['lastSeen'] as String),
      nationality:
          map['nationality'] != null ? map['nationality'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAccount.fromJson(String source) =>
      UserAccount.fromMap(json.decode(source) as Map<String, dynamic>);
}

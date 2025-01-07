import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/utils/intl/formatters.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/services/public_user_info.dart';

extension AbstractUserAccountExt on AbstractUserAccount {
  String get myId => switch (this) {
        GuestUser(id: var id) => id,
        UserAccount(id: var id) => id,
      };

  PlayerType get myType => switch (this) {
        GuestUser() => PlayerType.guest,
        UserAccount() => PlayerType.normal,
      };

  String get myUsername => switch (this) {
        GuestUser() => 'Guest',
        UserAccount(userName: var un) => un,
      };

  Either<AppError, UserAccount> get asUserAccount {
    return this is UserAccount
        ? right(this as UserAccount)
        : left(AppError(message: 'Not a user account'));
  }

  UserAccount get forceUserAccount {
    return this as UserAccount;
  }

  PublicUserInfo getPublicUserInfo(PlayerRating? ratings) {
    return switch (this) {
      GuestUser(id: var id) => PublicUserInfo(
          id: id,
          username: 'Guest',
          rating: null,
          playerType: myType,
        ),
      UserAccount(id: var id, userName: var un) => PublicUserInfo(
          username: un,
          playerType: myType,
          id: id,
          rating: ratings,
        )
    };
  }
}

sealed class AbstractUserAccount {}

class GuestUser implements AbstractUserAccount {
  final String id;

  GuestUser(this.id);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
    };
  }

  factory GuestUser.fromMap(Map<String, dynamic> map) {
    return GuestUser(
      map['id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GuestUser.fromJson(String source) =>
      GuestUser.fromMap(json.decode(source) as Map<String, dynamic>);
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserAccount implements AbstractUserAccount {
  final String id;
  final String? email;
  final String? passwordHash;
  final bool googleSignIn;
  final String userName;
  final String? fullName;
  final String? bio;
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
    required this.creationDate,
    required this.lastSeen,
    this.nationality,
  });

  Map<String, dynamic> toMap() {
    // = (() => null).call().

    return <String, dynamic>{
      'id': id,
      'email': email,
      'passwordHash': passwordHash,
      'googleSignIn': googleSignIn,
      'userName': userName,
      'fullName': fullName,
      'bio': bio,
      'creationDate': creationDate.toServerString(),
      'lastSeen': lastSeen.toServerString(),
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
      creationDate: DateTime.parse(map['creationDate'] as String).toLocal(),
      lastSeen: DateTime.parse(map['lastSeen'] as String).toLocal(),
      nationality:
          map['nationality'] != null ? map['nationality'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAccount.fromJson(String source) =>
      UserAccount.fromMap(json.decode(source) as Map<String, dynamic>);
}

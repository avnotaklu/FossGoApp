// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/signal_r_message.dart';

class FindMatchResult extends SignalRMessageType {
  final List<PublicUserInfo> joinedUsers;
  final Game game;

  FindMatchResult({
    required this.joinedUsers,
    required this.game,
  });

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'joinedUsers': joinedUsers.map((x) => x.toMap()).toList(),
      'game': game.toMap(),
    };
  }

  factory FindMatchResult.fromMap(Map<String, dynamic> map) {
    return FindMatchResult(
      joinedUsers: List<PublicUserInfo>.from(
        (map['joinedUsers'] as List).map<PublicUserInfo>(
          (x) => PublicUserInfo.fromMap(x as Map<String, dynamic>),
        ),
      ),
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory FindMatchResult.fromJson(String source) =>
      FindMatchResult.fromMap(json.decode(source) as Map<String, dynamic>);
}

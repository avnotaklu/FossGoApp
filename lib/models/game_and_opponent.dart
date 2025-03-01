// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game.dart';
import 'package:go/models/public_user_info.dart';

class GameAndOpponent {
  GameAndOpponent({
    required this.game,
    required this.opponent,
  });

  final Game game;
  final PublicUserInfo opponent;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'game': game.toMap(),
      'opponent': opponent.toMap(),
    };
  }

  factory GameAndOpponent.fromMap(Map<String, dynamic> map) {
    return GameAndOpponent(
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
      opponent: PublicUserInfo.fromMap(map['opponent'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory GameAndOpponent.fromJson(String source) =>
      GameAndOpponent.fromMap(json.decode(source) as Map<String, dynamic>);
}

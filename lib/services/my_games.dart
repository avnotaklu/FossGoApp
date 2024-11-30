// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/signal_r_message.dart';

class MyGame {
  final Game game;
  final PublicUserInfo? opposingPlayer;

  MyGame({
    required this.game,
    required this.opposingPlayer,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'game': game.toMap(),
      'opposingPlayer': opposingPlayer?.toMap(),
    };
  }

  factory MyGame.fromMap(Map<String, dynamic> map) {
    return MyGame(
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
      opposingPlayer: map['opposingPlayer'] == null
          ? null
          : PublicUserInfo.fromMap(
              map['opposingPlayer'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory MyGame.fromJson(String source) =>
      MyGame.fromMap(json.decode(source) as Map<String, dynamic>);
}

class MyGames {
  final List<MyGame> games;

  MyGames({required this.games});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'games': games.map((x) => x.toMap()).toList(),
    };
  }

  factory MyGames.fromMap(Map<String, dynamic> map) {
    return MyGames(
      games: List<MyGame>.from(
        (map['games'] as List).map<MyGame>(
          (x) => MyGame.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());
  factory MyGames.fromJson(String source) =>
      MyGames.fromMap(json.decode(source) as Map<String, dynamic>);
}

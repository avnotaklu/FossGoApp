// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game.dart';
import 'package:go/models/public_user_info.dart';

class OnGoingGame {
  final Game game;
  final PublicUserInfo? opposingPlayer;

  OnGoingGame({
    required this.game,
    required this.opposingPlayer,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'game': game.toMap(),
      'opposingPlayer': opposingPlayer?.toMap(),
    };
  }

  factory OnGoingGame.fromMap(Map<String, dynamic> map) {
    return OnGoingGame(
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
      opposingPlayer: map['opposingPlayer'] == null
          ? null
          : PublicUserInfo.fromMap(
              map['opposingPlayer'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory OnGoingGame.fromJson(String source) =>
      OnGoingGame.fromMap(json.decode(source) as Map<String, dynamic>);
}

class OngoingGames {
  final List<OnGoingGame> games;

  OngoingGames({required this.games});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'games': games.map((x) => x.toMap()).toList(),
    };
  }

  factory OngoingGames.fromMap(Map<String, dynamic> map) {
    return OngoingGames(
      games: List<OnGoingGame>.from(
        (map['games'] as List).map<OnGoingGame>(
          (x) => OnGoingGame.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());
  factory OngoingGames.fromJson(String source) =>
      OngoingGames.fromMap(json.decode(source) as Map<String, dynamic>);
}

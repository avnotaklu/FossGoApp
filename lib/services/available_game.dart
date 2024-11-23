// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game.dart';
import 'package:go/services/signal_r_message.dart';

class AvailableGame {
  final Game game;
  final PublicUserInfo creatorInfo;

  AvailableGame({
    required this.game,
    required this.creatorInfo,
  });


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'game': game.toMap(),
      'creatorInfo': creatorInfo.toMap(),
    };
  }

  factory AvailableGame.fromMap(Map<String, dynamic> map) {
    return AvailableGame(
      game: Game.fromMap(map['game'] as Map<String,dynamic>),
      creatorInfo: PublicUserInfo.fromMap(map['creatorInfo'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory AvailableGame.fromJson(String source) => AvailableGame.fromMap(json.decode(source) as Map<String, dynamic>);
}


class AvailableGames {
  final List<AvailableGame> games;

  AvailableGames({required this.games});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'games': games.map((x) => x.toMap()).toList(),
    };
  }

  factory AvailableGames.fromMap(Map<String, dynamic> map) {
    return AvailableGames(
      games: List<AvailableGame>.from(
        (map['games'] as List).map<AvailableGame>(
          (x) => AvailableGame.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());
  factory AvailableGames.fromJson(String source) =>
      AvailableGames.fromMap(json.decode(source) as Map<String, dynamic>);
}

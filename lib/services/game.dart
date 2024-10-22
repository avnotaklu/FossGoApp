// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/services/game_move.dart';

class Game {
  final String gameId;
  final int rows;
  final int columns;
  final int timeInSeconds;
  final Map<String, int> timeLeftForPlayers;
  final Map<String, String> playgroundMap;
  final List<GameMove> moves;
  final List<String> playersIds;

  Game({
    required this.gameId,
    required this.rows,
    required this.columns,
    required this.timeInSeconds,
    required this.timeLeftForPlayers,
    required this.playgroundMap,
    required this.moves,
    required this.playersIds,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gameId': gameId,
      'rows': rows,
      'columns': columns,
      'timeInSeconds': timeInSeconds,
      'timeLeftForPlayers': timeLeftForPlayers,
      'playgroundMap': playgroundMap,
      'moves': moves.map((x) => x.toMap()).toList(),
      'playersIds': playersIds,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
        gameId: map['gameId'] as String,
        rows: map['rows'] as int,
        columns: map['columns'] as int,
        timeInSeconds: map['timeInSeconds'] as int,
        timeLeftForPlayers: Map<String, int>.from(
            (map['timeLeftForPlayers'] as Map<String, int>)),
        playgroundMap: Map<String, String>.from(
            (map['playgroundMap'] as Map<String, String>)),
        moves: List<GameMove>.from(
          (map['moves'] as List<int>).map<GameMove>(
            (x) => GameMove.fromMap(x as Map<String, dynamic>),
          ),
        ),
        playersIds: List<String>.from(
          (map['playersIds'] as List<String>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory Game.fromJson(String source) =>
      Game.fromMap(json.decode(source) as Map<String, dynamic>);
}

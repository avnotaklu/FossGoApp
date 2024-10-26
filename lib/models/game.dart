// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/models/stone.dart';
import 'package:go/models/stone_representation.dart';

class Game {
  final String gameId;
  final int rows;
  final int columns;
  final int timeInSeconds;
  final Map<String, int> timeLeftForPlayers;
  final Map<String, int> playerScores;
  final Map<Position, StoneRepresentation> playgroundMap;
  final List<GameMove> moves;
  final Map<String, int> players;

  Game({
    required this.gameId,
    required this.rows,
    required this.columns,
    required this.timeInSeconds,
    required this.timeLeftForPlayers,
    required this.playgroundMap,
    required this.moves,
    required this.players,
    required this.playerScores,
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
      'players': players,
      'playerScores': playerScores,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
        gameId: map['gameId'] as String,
        rows: map['rows'] as int,
        columns: map['columns'] as int,
        timeInSeconds: map['timeInSeconds'] as int,
        timeLeftForPlayers: Map<String, int>.from((map['timeLeftForPlayers'])),
        playgroundMap: (map['playgroundMap'] as Map<String, dynamic>)
            .map<Position, StoneRepresentation>(
          (key, value) => MapEntry(
            Position.fromString(key),
            StoneRepresentation.fromString(value),
          ),
        ),
        moves: List<GameMove>.from(
          (map['moves'] as List).map<GameMove>(
            (x) => GameMove.fromMap(x as Map<String, dynamic>),
          ),
        ),
        players: Map<String, int>.from((map['players'])),
        playerScores:
            Map<String, int>.from((map['playerScores'])));
  }

  String toJson() => json.encode(toMap());

  factory Game.fromJson(String source) =>
      Game.fromMap(json.decode(source) as Map<String, dynamic>);
}

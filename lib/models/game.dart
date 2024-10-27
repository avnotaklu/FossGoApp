// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/models/stone.dart';
import 'package:go/models/stone_representation.dart';

enum StoneType { black, white }

enum GameState {
  waitingForStart,
  // Started,
  playing,
  scoreCalculation,
  ended
}

class Game {
  final String gameId;
  final int rows;
  final int columns;
  final int timeInSeconds;
  final Map<String, int> playerScores;
  final Map<Position, StoneType> playgroundMap;
  final List<GameMove> moves;
  final Map<String, StoneType> players;
  final DateTime startTime;
  final Position? koPositionInLastMove;
  final GameState gameState;

  Game({
    required this.gameId,
    required this.rows,
    required this.columns,
    required this.timeInSeconds,
    required this.playgroundMap,
    required this.moves,
    required this.players,
    required this.playerScores,
    required this.startTime,
    required this.koPositionInLastMove,
    required this.gameState,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gameId': gameId,
      'rows': rows,
      'columns': columns,
      'timeInSeconds': timeInSeconds,
      'playgroundMap': playgroundMap,
      'moves': moves.map((x) => x.toMap()).toList(),
      'players': players,
      'playerScores': playerScores,
      'startTime': startTime.toIso8601String(),
      'koPositionInLastMove': koPositionInLastMove?.toString(),
      'gameState': gameState.toString(),
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      gameId: map['gameId'] as String,
      rows: map['rows'] as int,
      columns: map['columns'] as int,
      timeInSeconds: map['timeInSeconds'] as int,
      playgroundMap:
          (map['playgroundMap'] as Map<String, int>).map<Position, StoneType>(
        (key, value) => MapEntry(
          Position.fromString(key),
          StoneType.values[value],
        ),
      ),
      moves: List<GameMove>.from(
        (map['moves'] as List).map<GameMove>(
          (x) => GameMove.fromMap(x as Map<String, dynamic>),
        ),
      ),
      players: Map<String, StoneType>.from(
        (map['players'] as Map<String, int> ?? {}).map((key, value) => MapEntry(
              key,
              StoneType.values[value],
            )),
      ),
      playerScores: Map<String, int>.from((map['playerScores'])),
      startTime: DateTime.parse(map['startTime'] as String),
      koPositionInLastMove: map['koPositionInLastMove'] != null
          ? Position.fromString(map['koPositionInLastMove'] as String)
          : null,
      gameState: GameState.values.firstWhere(
        (e) => e.toString() == map['gameState'] as String,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Game.fromJson(String source) =>
      Game.fromMap(json.decode(source) as Map<String, dynamic>);
}

class AvailableGames {
  final List<Game> games;

  AvailableGames({required this.games});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'games': games.map((x) => x.toMap()).toList(),
    };
  }

  factory AvailableGames.fromMap(Map<String, dynamic> map) {
    return AvailableGames(
      games: List<Game>.from(
        (map['games'] as List).map<Game>(
          (x) => Game.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());
  factory AvailableGames.fromJson(String source) =>
      AvailableGames.fromMap(json.decode(source) as Map<String, dynamic>);
}

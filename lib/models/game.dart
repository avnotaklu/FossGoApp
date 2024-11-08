// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/models/stone.dart';
import 'package:go/models/stone_representation.dart';
import 'package:go/providers/create_game_provider.dart';

enum StoneType { black, white }

enum GameState {
  waitingForStart,
  // Started,
  playing,
  scoreCalculation,
  paused,
  ended
}

class Game {
  final String gameId;
  final int rows;
  final int columns;
  final int timeInSeconds;
  final Map<String, int> prisoners;
  final Map<Position, StoneType> playgroundMap;
  final List<GameMove> moves;
  final Map<String, StoneType> players;
  final DateTime? startTime;
  final Position? koPositionInLastMove;
  final GameState gameState;
  final List<Position> deadStones;
  final String? winnerId;
  final double komi;
  final List<int> finalTerritoryScores;

  Game({
    required this.gameId,
    required this.rows,
    required this.columns,
    required this.timeInSeconds,
    required this.playgroundMap,
    required this.moves,
    required this.players,
    required this.prisoners,
    required this.startTime,
    required this.koPositionInLastMove,
    required this.gameState,
    required this.deadStones,
    required this.winnerId,
    required this.komi,
    required this.finalTerritoryScores,
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
      'prisoners': prisoners,
      'startTime': startTime?.toIso8601String(),
      'koPositionInLastMove': koPositionInLastMove?.toString(),
      'gameState': gameState.toString(),
      'deadStones': deadStones.map((e) => e.toString()).toList(),
      'winnerId': winnerId,
      'komi': komi,
      'finalTerritoryScores': finalTerritoryScores,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      gameId: map['gameId'] as String,
      rows: map['rows'] as int,
      columns: map['columns'] as int,
      timeInSeconds: map['timeInSeconds'] as int,
      playgroundMap:
          Map<String, int>.from(map['playgroundMap']).map<Position, StoneType>(
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
        Map<String, int>.from(map['players']).map(
          (key, value) => MapEntry(
            key,
            StoneType.values[value],
          ),
        ),
      ),
      prisoners: Map<String, int>.from((map['prisoners'])),
      startTime: map['startTime'] == null
          ? null
          : DateTime.parse(map['startTime'] as String),
      koPositionInLastMove: map['koPositionInLastMove'] != null
          ? Position.fromString(map['koPositionInLastMove'] as String)
          : null,
      gameState: GameState.values[map['gameState'] as int],
      deadStones: List<Position>.from(
        (map['deadStones'] as List).map<Position>(
          (e) => Position.fromString(e as String),
        ),
      ),
      winnerId: map['winnerId'] as String?,
      komi: map['komi'] as double,
      finalTerritoryScores: List<int>.from(map['finalTerritoryScores'] as List),
    );
  }

  String toJson() => json.encode(toMap());

  factory Game.fromJson(String source) =>
      Game.fromMap(json.decode(source) as Map<String, dynamic>);

  Game copyWith({
    String? gameId,
    int? rows,
    int? columns,
    int? timeInSeconds,
    Map<String, int>? prisoners,
    Map<Position, StoneType>? playgroundMap,
    List<GameMove>? moves,
    Map<String, StoneType>? players,
    DateTime? startTime,
    Position? koPositionInLastMove,
    GameState? gameState,
    List<Position>? deadStones,
    double? komi,
    List<int>? finalTerritoryScores,
    String? winnerId ,
    }) {
    return Game(
      gameId: gameId ?? this.gameId,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      timeInSeconds: timeInSeconds ?? this.timeInSeconds,
      prisoners: prisoners ?? this.prisoners,
      playgroundMap: playgroundMap ?? this.playgroundMap,
      moves: moves ?? this.moves,
      players: players ?? this.players,
      startTime: startTime ?? this.startTime,
      koPositionInLastMove: koPositionInLastMove ?? this.koPositionInLastMove,
      gameState: gameState ?? this.gameState,
      deadStones: deadStones ?? this.deadStones,
      winnerId: winnerId ?? this.winnerId,
      komi: komi ?? this.komi,
      finalTerritoryScores: finalTerritoryScores ?? this.finalTerritoryScores,
    );
  }

  List<String> get playerIdsSorted => players
      .toSortedList(
        Order.from(
          (a, b) => players[a]!.index.compareTo(players[b]!.index),
        ),
      )
      .map((e) => e.key)
      .toList();
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

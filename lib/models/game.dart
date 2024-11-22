// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:fpdart/fpdart.dart';

import 'package:go/gameplay/create/stone_selection_widget.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/models/stone.dart';
import 'package:go/models/stone_representation.dart';
import 'package:go/models/time_control.dart';
import 'package:go/providers/create_game_provider.dart';
import 'package:go/services/available_game.dart';
import 'package:go/services/game_over_message.dart';

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
  final TimeControl timeControl;
  final Map<String, int> prisoners;
  final Map<Position, StoneType> playgroundMap;
  final List<GameMove> moves;
  final List<PlayerTimeSnapshot> playerTimeSnapshots;
  final Map<String, StoneType> players;
  final DateTime? startTime;
  final Position? koPositionInLastMove;
  final GameState gameState;
  final List<Position> deadStones;
  final String? winnerId;
  final double komi;
  final GameOverMethod? gameOverMethod;
  final List<int> finalTerritoryScores;
  final DateTime? endTime;
  final StoneSelectionType stoneSelectionType;
  final String? gameCreator;

  Game({
    required this.gameId,
    required this.rows,
    required this.columns,
    required this.timeControl,
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
    required this.gameOverMethod,
    required this.endTime,
    required this.stoneSelectionType,
    required this.gameCreator,
    required this.playerTimeSnapshots,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gameId': gameId,
      'rows': rows,
      'columns': columns,
      'timeControl': timeControl.toMap(),
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
      'gameOverMethod': gameOverMethod?.index,
      'endTime': endTime?.toIso8601String(),
      'stoneSelectionType': stoneSelectionType.index,
      'gameCreator': gameCreator,
      'playerTimeSnapshots': playerTimeSnapshots.map((e) => e.toMap()).toList(),
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      gameId: map['gameId'] as String,
      rows: map['rows'] as int,
      columns: map['columns'] as int,
      timeControl:
          TimeControl.fromMap(map['timeControl'] as Map<String, dynamic>),
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
      gameOverMethod: map['gameOverMethod'] == null
          ? null
          : GameOverMethod.values[map['gameOverMethod'] as int],
      endTime: map['endTime'] == null
          ? null
          : DateTime.parse(map['endTime'] as String),
      stoneSelectionType:
          StoneSelectionType.values[map['stoneSelectionType'] as int],
      gameCreator: map['gameCreator'] as String?,
      playerTimeSnapshots: List<PlayerTimeSnapshot>.from(
        (map['playerTimeSnapshots'] as List).map<PlayerTimeSnapshot>(
          (e) => PlayerTimeSnapshot.fromMap(e as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Game.fromJson(String source) =>
      Game.fromMap(json.decode(source) as Map<String, dynamic>);

  Game copyWith({
    String? gameId,
    int? rows,
    int? columns,
    TimeControl? timeControl,
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
    String? winnerId,
    GameOverMethod? gameOverMethod,
    DateTime? endTime,
    StoneSelectionType? stoneSelectionType,
    String? gameCreator,
    List<PlayerTimeSnapshot>? playerTimeSnapshots,
  }) {
    return Game(
      gameId: gameId ?? this.gameId,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      timeControl: timeControl ?? this.timeControl,
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
      gameOverMethod: gameOverMethod ?? this.gameOverMethod,
      endTime: endTime ?? this.endTime,
      stoneSelectionType: stoneSelectionType ?? this.stoneSelectionType,
      gameCreator: gameCreator ?? this.gameCreator,
      playerTimeSnapshots: playerTimeSnapshots ?? this.playerTimeSnapshots,
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

class PlayerTimeSnapshot {
  final DateTime snapshotTimestamp;
  final int mainTimeMilliseconds;
  final int? byoYomisLeft;
  final bool byoYomiActive;
  final bool timeActive;

  PlayerTimeSnapshot({
    required this.snapshotTimestamp,
    required this.mainTimeMilliseconds,
    required this.byoYomisLeft,
    required this.byoYomiActive,
    required this.timeActive,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'snapshotTimestamp': snapshotTimestamp.toString(),
      'mainTimeMilliseconds': mainTimeMilliseconds,
      'byoYomisLeft': byoYomisLeft,
      'byoYomiActive': byoYomiActive,
      'timeActive': timeActive,
    };
  }

  factory PlayerTimeSnapshot.fromMap(Map<String, dynamic> map) {
    return PlayerTimeSnapshot(
      snapshotTimestamp: DateTime.parse(map['snapshotTimestamp']),
      mainTimeMilliseconds: map['mainTimeMilliseconds'] as int,
      byoYomisLeft:
          map['byoYomisLeft'] != null ? map['byoYomisLeft'] as int : null,
      byoYomiActive: map['byoYomiActive'] as bool,
      timeActive: map['timeActive'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerTimeSnapshot.fromJson(String source) =>
      PlayerTimeSnapshot.fromMap(json.decode(source) as Map<String, dynamic>);
}

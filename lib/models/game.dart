// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:fpdart/fpdart.dart';

import 'package:go/constants/constants.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/minimal_rating.dart';
import 'package:go/models/position.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:go/modules/homepage/stone_selection_widget.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/models/variant_type.dart';

extension StoneTypeExtension on StoneType {
  String get color => switch (this) {
        StoneType.black => "Black",
        StoneType.white => "White",
      };
  StoneType get other => switch (this) {
        StoneType.black => StoneType.white,
        StoneType.white => StoneType.black,
      };
  
  GameResult get resultForIWon => switch (this) {
        StoneType.black => GameResult.blackWon,
        StoneType.white => GameResult.whiteWon,
      };
  
  GameResult get resultForOtherWon => switch (this) {
        StoneType.black => GameResult.whiteWon,
        StoneType.white => GameResult.blackWon,
      };
}

enum StoneType { black, white }

enum GameState {
  waitingForStart,
  // Started,
  playing,
  scoreCalculation,
  paused,
  ended
}

enum GameType {
  anonymous,
  casual,
  rated,
}

class GameFieldNames {
  // Game
  static const String ID = "gameId";
  static const String Rows = "rows";
  static const String Columns = "columns";
  static const String TimeControl = "timeControl";
  static const String PlayerTimeSnapshots = "playerTimeSnapshots";
  static const String PlaygroundMap = "playgroundMap";
  static const String Moves = "moves";
  static const String Players = "players";
  static const String Prisoners = "prisoners";
  static const String StartTime = "startTime";
  static const String EndTime = "endTime";
  static const String KoPositionInLastMove = "koPositionInLastMove";
  static const String GameState = "gameState";
  static const String DeadStones = "deadStones";
  static const String Result = "result";
  static const String FinalTerritoryScores = "finalTerritoryScores";
  static const String Komi = "komi";
  static const String GameOverMethod = "gameOverMethod";
  static const String StoneSelectionType = "stoneSelectionType";
  static const String GameCreator = "gameCreator";
  static const String PlayersRatingsAfter = "playersRatingsAfter";
  static const String PlayersRatingsDiff = "playersRatingsDiff";
  static const String GameType = "gameType";

  // control Control
  static const String MainTimeSeconds =
      "mainTimeSeconds"; // time control only mainTimeSeconds seconds
  static const String IncrementSeconds = "incrementSeconds";
  static const String ByoYomiTime = "byoYomiTime";
  static const String TimeStandard = "timeStandard";
  static const String ByoYomiCount = "byoYomiCount";
  static const String ByoYomiSeconds = "byoYomiSeconds";

  // Player time Snapshot
  static const String SnapshotTimestamp = "snapshotTimestamp";
  static const String MainTimeMilliseconds = "mainTimeMilliseconds";
  static const String ByoYomisLeft = "byoYomisLeft";
  static const String ByoYomiActive = "byoYomiActive";
  static const String TimeActive = "timeActive";

  // move Move
  static const String Time = "time";
  static const String X = "x";
  static const String Y = "y";
}

// GameFieldNames {
//   // Game
//   static const String ID = "id";
//   static const String Rows = "r";
//   static const String Cols = "c";
//   static const String TimeControl = "tc";
//   static const String PlayerTimeSnapshots = "ts";
//   static const String PlaygroundMap = "map";
//   static const String Moves = "mv";
//   static const String Players = "p";
//   static const String Prisoners = "pr";
//   static const String StartTime = "st";
//   static const String EndTime = "et";
//   static const String KoPositionInLastMove = "ko";
//   static const String GameState = "gs";
//   static const String DeadStones = "ds";
//   static const String WinnerId = "wi";
//   static const String FinalTerritoryScores = "fts";
//   static const String Komi = "k";
//   static const String GameOverMethod = "gom";
//   static const String StoneSelectionType = "sst";
//   static const String GameCreator = "gc";
//   static const String PlayersRatings = "rts";
//   static const String PlayersRatingsDiff = "prd";

//   // Time Control
//   static const String MainTimeSeconds = "mts"; // time control only takes seconds
//   static const String IncrementSeconds = "is";
//   static const String ByoYomiTime = "byt";
//   static const String TimeStandard = "ts";
//   static const String ByoYomiCount = "byc";
//   static const String ByoYomiSeconds = "bys";

//   // Player Time Snapshot
//   static const String SnapshotTimestamp = "st";
//   static const String MainTimeMilliseconds = "mt";
//   static const String ByoYomisLeft = "byl";
//   static const String ByoYomiActive = "bya";
//   static const String TimeActive = "ta";

//   // Game Move
//   static const String Time = "t";
//   static const String X = "x";
//   static const String Y = "y";
// }

extension GameResultExt on GameResult {
  StoneType? etWinnerStone() {
    return switch (this) {
      GameResult.blackWon => StoneType.black,
      GameResult.whiteWon => StoneType.white,
      GameResult.draw => null,
    };
  }

  StoneType? getLoserStone() {
    return etWinnerStone()?.other;
  }
}

enum GameResult {
  blackWon,
  whiteWon,
  draw,
}

extension GameExts on Game {
  List<String> get playerIdsSorted => players
      .toSortedList(
        Order.from(
          (a, b) => players[a]!.index.compareTo(players[b]!.index),
        ),
      )
      .map((e) => e.key)
      .toList();

  String? getPlayerIdWithTurn() {
    if (startTime == null) return null;

    final turn = moves.length;
    for (var item in players.entries) {
      if (item.value.index == (turn % 2)) {
        return item.key;
      }
    }
    throw StateError(
        "This path shouldn't be reachable, as there always exists one user with supposed next turn");
  }

  StoneType? getStoneFromPlayerId(String id) {
    return players[id];
  }

  StoneType? getOtherStoneFromPlayerId(String id) {
    final myStone = getStoneFromPlayerId(id)?.index;
    if (myStone == null) return null;
    return StoneType.values[1 - myStone];
  }

  String? getPlayerIdFromStoneType(StoneType stone) {
    if (startTime == null) return null;
    for (var item in players.entries) {
      if (item.value == stone) {
        return item.key;
      }
    }
    throw StateError("Player: {stone} has not yet joined the game");
  }

  String? getOtherPlayerIdFromPlayerId(String id) {
    var getOtherPlayerStone = getOtherStoneFromPlayerId(id);
    if (getOtherPlayerStone == null) return null;
    return getPlayerIdFromStoneType(getOtherPlayerStone);
  }

  BoardSizeData get boardSizeData => BoardSizeData(rows, columns);
  TimeStandard get timeStandard => timeControl.timeStandard;

  bool didStart() {
    return gameState != GameState.waitingForStart;
  }

  Game buildWithNewBoardState(BoardState b) {
    return copyWith(
      playgroundMap:
          b.playgroundMap.mapValue((a) => StoneType.values[a.player]),
      koPositionInLastMove: b.koDelete,
      prisoners: b.prisoners,
    );
  }

  BoardSize getBoardSize() {
    if (rows == 9 && columns == 9) {
      return BoardSize.nine;
    } else if (rows == 13 && columns == 13) {
      return BoardSize.thirteen;
    } else if (rows == 19 && columns == 19) {
      return BoardSize.nineteen;
    } else {
      return BoardSize.other;
    }
  }

  // Variant data

  VariantType getTopLevelVariant() {
    return VariantType(getBoardSize(), timeControl.timeStandard);
  }

  VariantType getBoardVariant() {
    return VariantType(getBoardSize(), null);
  }

  VariantType getTimeStandardVariant() {
    return VariantType(null, timeControl.timeStandard);
  }

  List<VariantType> getRelevantVariants() {
    return [
      getTopLevelVariant(),
      getBoardVariant(),
      getTimeStandardVariant(),
    ];
  }
}

class Game {
  final String gameId;
  final int rows;
  final int columns;
  final TimeControl timeControl;
  final List<int> prisoners;
  final Map<Position, StoneType> playgroundMap;
  final List<GameMove> moves;
  final List<PlayerTimeSnapshot> playerTimeSnapshots;
  final Map<String, StoneType> players;
  final DateTime? startTime;
  final Position? koPositionInLastMove;
  final GameState gameState;
  final List<Position> deadStones;
  final GameResult? result;
  final double komi;
  final GameOverMethod? gameOverMethod;
  final List<int> finalTerritoryScores;
  final DateTime? endTime;
  final StoneSelectionType stoneSelectionType;
  final String? gameCreator;
  final List<MinimalRating> playersRatingsAfter;
  final List<int> playersRatingsDiff;
  final GameType gameType;

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
    required this.result,
    required this.komi,
    required this.finalTerritoryScores,
    required this.gameOverMethod,
    required this.endTime,
    required this.stoneSelectionType,
    required this.gameCreator,
    required this.playerTimeSnapshots,
    required this.playersRatingsAfter,
    required this.playersRatingsDiff,
    required this.gameType,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      GameFieldNames.Rows: rows,
      GameFieldNames.Columns: columns,
      GameFieldNames.TimeControl: timeControl.toMap(),
      GameFieldNames.PlaygroundMap: playgroundMap.map<String, int>(
        (key, value) => MapEntry(
          key.toString(),
          value.index,
        ),
      ),
      GameFieldNames.Moves: moves.map((x) => x.toMap()).toList(),
      GameFieldNames.Players: players.map<String, int>(
        (key, value) => MapEntry(
          key,
          value.index,
        ),
      ),
      GameFieldNames.Prisoners: prisoners,
      GameFieldNames.StartTime: startTime?.toIso8601String(),
      GameFieldNames.KoPositionInLastMove: koPositionInLastMove?.toString(),
      GameFieldNames.GameState: gameState.index,
      GameFieldNames.DeadStones: deadStones.map((e) => e.toString()).toList(),
      GameFieldNames.Result: result?.index,
      GameFieldNames.Komi: komi,
      GameFieldNames.FinalTerritoryScores: finalTerritoryScores,
      GameFieldNames.GameOverMethod: gameOverMethod?.index,
      GameFieldNames.EndTime: endTime?.toIso8601String(),
      GameFieldNames.StoneSelectionType: stoneSelectionType.index,
      GameFieldNames.GameCreator: gameCreator,
      GameFieldNames.PlayerTimeSnapshots:
          playerTimeSnapshots.map((e) => e.toMap()).toList(),
      GameFieldNames.PlayersRatingsAfter:
          playersRatingsAfter.map((e) => e.stringify()).toList(),
      GameFieldNames.PlayersRatingsDiff: playersRatingsDiff,
      GameFieldNames.GameType: gameType.index,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      gameId: map[GameFieldNames.ID] as String,
      rows: map[GameFieldNames.Rows] as int,
      columns: map[GameFieldNames.Columns] as int,
      timeControl: TimeControl.fromMap(
          map[GameFieldNames.TimeControl] as Map<String, dynamic>),
      playgroundMap: Map<String, int>.from(map[GameFieldNames.PlaygroundMap])
          .map<Position, StoneType>(
        (key, value) => MapEntry(
          Position.fromString(key),
          StoneType.values[value],
        ),
      ),
      moves: List<GameMove>.from(
        (map[GameFieldNames.Moves] as List).map<GameMove>(
          (x) => GameMove.fromMap(x as Map<String, dynamic>),
        ),
      ),
      players: Map<String, StoneType>.from(
        Map<String, int>.from(map[GameFieldNames.Players]).map(
          (key, value) => MapEntry(
            key,
            StoneType.values[value],
          ),
        ),
      ),
      prisoners: List<int>.from((map[GameFieldNames.Prisoners])),
      startTime: map[GameFieldNames.StartTime] == null
          ? null
          : DateTime.parse(map[GameFieldNames.StartTime] as String),
      koPositionInLastMove: map[GameFieldNames.KoPositionInLastMove] != null
          ? Position.fromString(
              map[GameFieldNames.KoPositionInLastMove] as String)
          : null,
      gameState: GameState.values[map[GameFieldNames.GameState] as int],
      deadStones: List<Position>.from(
        (map[GameFieldNames.DeadStones] as List).map<Position>(
          (e) => Position.fromString(e as String),
        ),
      ),
      result: (map[GameFieldNames.Result]) == null
          ? null
          : GameResult.values[(map[GameFieldNames.Result] as int)],
      komi: map[GameFieldNames.Komi] as double,
      finalTerritoryScores:
          List<int>.from(map[GameFieldNames.FinalTerritoryScores] as List),
      gameOverMethod: map[GameFieldNames.GameOverMethod] == null
          ? null
          : GameOverMethod.values[map[GameFieldNames.GameOverMethod] as int],
      endTime: map[GameFieldNames.EndTime] == null
          ? null
          : DateTime.parse(map[GameFieldNames.EndTime] as String),
      stoneSelectionType: StoneSelectionType
          .values[map[GameFieldNames.StoneSelectionType] as int],
      gameCreator: map[GameFieldNames.GameCreator] as String?,
      playerTimeSnapshots: List<PlayerTimeSnapshot>.from(
        (map[GameFieldNames.PlayerTimeSnapshots] as List)
            .map<PlayerTimeSnapshot>(
          (e) => PlayerTimeSnapshot.fromMap(e as Map<String, dynamic>),
        ),
      ),
      playersRatingsAfter: List<MinimalRating>.from(
        (map[GameFieldNames.PlayersRatingsAfter] as List).map(
          (a) => MinimalRating.fromString(a),
        ),
      ),
      playersRatingsDiff:
          List<int>.from(map[GameFieldNames.PlayersRatingsDiff] as List),
      gameType: GameType.values[map[GameFieldNames.GameType] as int],
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
    List<int>? prisoners,
    Map<Position, StoneType>? playgroundMap,
    List<GameMove>? moves,
    Map<String, StoneType>? players,
    DateTime? startTime,
    Position? koPositionInLastMove,
    GameState? gameState,
    List<Position>? deadStones,
    double? komi,
    List<int>? finalTerritoryScores,
    GameResult? result,
    GameOverMethod? gameOverMethod,
    DateTime? endTime,
    StoneSelectionType? stoneSelectionType,
    String? gameCreator,
    List<PlayerTimeSnapshot>? playerTimeSnapshots,
    List<MinimalRating>? playersRatingsAfter,
    List<int>? playersRatingsDiff,
    GameType? gameType,
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
      result: result ?? this.result,
      komi: komi ?? this.komi,
      finalTerritoryScores: finalTerritoryScores ?? this.finalTerritoryScores,
      gameOverMethod: gameOverMethod ?? this.gameOverMethod,
      endTime: endTime ?? this.endTime,
      stoneSelectionType: stoneSelectionType ?? this.stoneSelectionType,
      gameCreator: gameCreator ?? this.gameCreator,
      playerTimeSnapshots: playerTimeSnapshots ?? this.playerTimeSnapshots,
      playersRatingsAfter: playersRatingsAfter ?? this.playersRatingsAfter,
      playersRatingsDiff: playersRatingsDiff ?? this.playersRatingsDiff,
      gameType: gameType ?? this.gameType,
    );
  }
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
      GameFieldNames.SnapshotTimestamp: snapshotTimestamp.toIso8601String(),
      GameFieldNames.MainTimeMilliseconds: mainTimeMilliseconds,
      GameFieldNames.ByoYomisLeft: byoYomisLeft,
      GameFieldNames.ByoYomiActive: byoYomiActive,
      GameFieldNames.TimeActive: timeActive,
    };
  }

  factory PlayerTimeSnapshot.fromMap(Map<String, dynamic> map) {
    return PlayerTimeSnapshot(
      snapshotTimestamp:
          DateTime.parse(map[GameFieldNames.SnapshotTimestamp] as String),
      mainTimeMilliseconds: map[GameFieldNames.MainTimeMilliseconds] as int,
      byoYomisLeft: map[GameFieldNames.ByoYomisLeft] as int?,
      byoYomiActive: map[GameFieldNames.ByoYomiActive] as bool,
      timeActive: map[GameFieldNames.TimeActive] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerTimeSnapshot.fromJson(String source) =>
      PlayerTimeSnapshot.fromMap(json.decode(source) as Map<String, dynamic>);

  PlayerTimeSnapshot copyWith({
    DateTime? snapshotTimestamp,
    int? mainTimeMilliseconds,
    int? byoYomisLeft,
    bool? byoYomiActive,
    bool? timeActive,
  }) {
    return PlayerTimeSnapshot(
      snapshotTimestamp: snapshotTimestamp ?? this.snapshotTimestamp,
      mainTimeMilliseconds: mainTimeMilliseconds ?? this.mainTimeMilliseconds,
      byoYomisLeft: byoYomisLeft ?? this.byoYomisLeft,
      byoYomiActive: byoYomiActive ?? this.byoYomiActive,
      timeActive: timeActive ?? this.timeActive,
    );
  }
}

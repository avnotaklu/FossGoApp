// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/modules/gameplay/middleware/score_calculator.dart';
import 'package:go/modules/gameplay/middleware/time_calculator.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:signalr_netcore/errors.dart';

import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/modules/homepage/stone_selection_widget.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/services/move_position.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/services/user_rating.dart';

// HACK: `GameUpdate` object is a hack as signalR messages don't always give the full game state
extension GameExt on Game {
  GameUpdate toGameUpdate() {
    return GameUpdate(
      game: this,
      curPlayerTimeSnapshot: didStart()
          ? playerTimeSnapshots[
              getStoneFromPlayerId(getPlayerIdWithTurn()!)!.index]
          : null,
      playerWithTurn:
          didStart() ? getStoneFromPlayerId(getPlayerIdWithTurn()!) : null,
    );
  }
}

extension GameUpdateExt on GameUpdate {
  Game makeCopyFromOldGame(Game game) {
    // REVIEW: this works for now,
    // but it might have some nullability issues down the line.
    // e.g. if the new game updated some value to a null value, it would be ignored by `??` operator.
    // In this case the update won't be communicated.
    var newGame = Game(
      gameId: this.game?.gameId ?? game.gameId,
      rows: this.game?.rows ?? game.rows,
      columns: this.game?.columns ?? game.columns,
      timeControl: this.game?.timeControl ?? game.timeControl,
      playgroundMap: this.game?.playgroundMap ?? game.playgroundMap,
      moves: this.game?.moves ?? game.moves,
      players: this.game?.players ?? game.players,
      prisoners: this.game?.prisoners ?? game.prisoners,
      startTime: this.game?.startTime ?? game.startTime,
      koPositionInLastMove:
          this.game?.koPositionInLastMove ?? game.koPositionInLastMove,
      gameState: this.game?.gameState ?? game.gameState,
      deadStones: this.game?.deadStones ?? game.deadStones,
      winnerId: this.game?.winnerId ?? game.winnerId,
      komi: this.game?.komi ?? game.komi,
      finalTerritoryScores:
          this.game?.finalTerritoryScores ?? game.finalTerritoryScores,
      gameOverMethod: this.game?.gameOverMethod ?? game.gameOverMethod,
      endTime: this.game?.endTime ?? game.endTime,
      stoneSelectionType:
          this.game?.stoneSelectionType ?? game.stoneSelectionType,
      gameCreator: this.game?.gameCreator ?? game.gameCreator,
      playerTimeSnapshots:
          this.game?.playerTimeSnapshots ?? game.playerTimeSnapshots,
      playersRatings: this.game?.playersRatings ?? game.playersRatings,
      playersRatingsDiff:
          this.game?.playersRatingsDiff ?? game.playersRatingsDiff,
    );

    var tmpTimes = [...newGame.playerTimeSnapshots];

    if (playerWithTurn != null && curPlayerTimeSnapshot != null) {
      var idx = playerWithTurn!.index;
      tmpTimes[idx] = curPlayerTimeSnapshot!;
    }

    return newGame.copyWith(playerTimeSnapshots: tmpTimes);
  }
}

class GameUpdate {
  final Game? game;
  final PlayerTimeSnapshot? curPlayerTimeSnapshot;
  final StoneType? playerWithTurn;
  final Position? deadStonePosition;
  final DeadStoneState? deadStoneState;

  GameUpdate({
    this.game,
    this.curPlayerTimeSnapshot,
    this.playerWithTurn,
    this.deadStonePosition,
    this.deadStoneState,
  });

  get state => null;
}

abstract class GameStateOracle {
  final StreamController<GameUpdate> gameUpdateC = StreamController.broadcast();
  Stream<GameUpdate> get gameUpdate => gameUpdateC.stream;

  DisplayablePlayerData myPlayerData(Game game);
  DisplayablePlayerData otherPlayerData(Game game);

  Future<Either<AppError, Game>> resignGame(Game game);
  Future<Either<AppError, Game>> acceptScores(Game game);
  Future<Either<AppError, Game>> continueGame(Game game);
  Future<Either<AppError, Game>> playMove(Game game, MovePosition move);
  Future<Either<AppError, Game>> editDeadStoneCluster(
      Game game, Position pos, DeadStoneState state);

  bool isThisAccountsTurn(Game game);
  StoneType thisAccountStone(Game game);
}

class LiveGameOracle extends GameStateOracle {
  final Api api;
  final AuthProvider authBloc;
  final SignalRProvider signalRbloc;
  late final List<StreamSubscription> subscriptions;
  late final Stream<GameJoinMessage> listenForGameJoin;
  late final Stream<EditDeadStoneMessage> listenForEditDeadStone;
  late final Stream<NewMoveMessage> listenFromMove;
  late final Stream<GameOverMessage> listenFromGameOver;
  late final Stream<GameTimerUpdateMessage> listenFromGameTimerUpdate;
  late final Stream<Null> listenFromAcceptScores;
  late final Stream<ContinueGameMessage> listenFromContinueGame;

  void setupStreams() {
    var gameMessageStream = signalRbloc.gameMessageStream;
    listenForGameJoin = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.gameJoin) {
        yield message.data as GameJoinMessage;
      }
    });

    listenForEditDeadStone = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.editDeadStone) {
        yield message.data as EditDeadStoneMessage;
      }
    });
    listenFromMove = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.newMove) {
        yield message.data as NewMoveMessage;
      }
    });

    listenFromContinueGame = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.continueGame) {
        yield message.data as ContinueGameMessage;
      }
    });

    listenFromAcceptScores = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.acceptedScores) {
        yield message.data as Null;
      }
    });

    listenFromGameOver = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.gameOver) {
        yield message.data as GameOverMessage;
      }
    });

    listenFromGameTimerUpdate = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.gameTimerUpdate) {
        yield message.data as GameTimerUpdateMessage;
      }
    });
  }

  LiveGameOracle({
    required this.api,
    required this.authBloc,
    required this.signalRbloc,
    GameJoinMessage? joiningData,
  }) {
    if (joiningData != null) {
      otherPlayerInfo = joiningData.otherPlayerData;
    }
    setupStreams();

    subscriptions = [
      listenFromGameJoin(),
      listenForMove(),
      listenForContinueGame(),
      listenForAcceptScore(),
      listenForGameOver(),
      listenForGameTimerUpdate()
    ];
  }

  StreamSubscription listenFromGameJoin() {
    return listenForGameJoin.listen((message) {
      otherPlayerInfo = message.otherPlayerData;
      gameUpdateC.add(message.game.toGameUpdate());
    });
  }

  StreamSubscription listenForContinueGame() {
    return listenFromContinueGame.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.continueGame}::\n\t\t${message.toMap()}");
      gameUpdateC.add(message.game.toGameUpdate());
    });
    // signalRbloc.hubConnection.on('gameMove', (data) {});
  }

  StreamSubscription listenForMove() {
    return listenFromMove.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.newMove}::\n\t\t${message.toMap()}");
      // assert(data != null, "Game move data can't be null");
      gameUpdateC.add(message.game.toGameUpdate());
    });
    // signalRbloc.hubConnection.on('gameMove', (data) {});
  }

  StreamSubscription listenForAcceptScore() {
    return listenFromAcceptScores.listen((message) {
      debugPrint("Signal R said, ::${SignalRMessageTypes.acceptedScores}::");
      // TODO: this event isn't transferred over to game state bloc as that does nothing with it
    });
  }

  StreamSubscription listenForGameOver() {
    return listenFromGameOver.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.gameOver}::\n\t\t${message.toMap()}");
      gameUpdateC.add(message.game.toGameUpdate());
    });
  }

  StreamSubscription listenForGameTimerUpdate() {
    return listenFromGameTimerUpdate.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.gameTimerUpdate}::\n\t\t${message.toMap()}");

      gameUpdateC.add(GameUpdate(
        curPlayerTimeSnapshot: message.currentPlayerTime,
        playerWithTurn: message.player,
      ));
    });
  }

  // TODO: listenForGameJoin + update otherPlayerInfo there

  late final PublicUserInfo? otherPlayerInfo;

  PublicUserInfo get myPlayerUserInfo => PublicUserInfo(
      id: authBloc.currentUserRaw.id,
      email: authBloc.currentUserRaw.email,
      rating: authBloc.currentUserRating);

  @override
  DisplayablePlayerData myPlayerData(Game game) {
    var publicInfo = myPlayerUserInfo;
    var rating = publicInfo.rating.getRatingForGame(game);
    StoneType? stone;

    if (game.didStart()) {
      stone = game.getStoneFromPlayerId(publicInfo.id);
    } else if (game.gameCreator == publicInfo.id) {
      stone = game.stoneSelectionType.type;
    }

    return DisplayablePlayerData(
      displayName: publicInfo.email,
      stoneType: stone,
      rating: rating,
    );
  }

  @override
  DisplayablePlayerData otherPlayerData(Game game) {
    var publicInfo = otherPlayerInfo;
    var rating = publicInfo?.rating.getRatingForGame(game);
    StoneType? stone;

    if (game.didStart()) {
      stone = game.getStoneFromPlayerId(publicInfo!.id);
    } else if (game.gameCreator == publicInfo?.id) {
      stone = game.stoneSelectionType.type;
    }

    return DisplayablePlayerData(
      displayName: publicInfo?.email,
      stoneType: stone,
      rating: rating,
    );
  }

  @override
  Future<Either<AppError, Game>> resignGame(Game game) async {
    return (await api.resignGame(authBloc.token!, game.gameId));
  }

  @override
  Future<Either<AppError, Game>> acceptScores(Game game) async {
    return (await api.acceptScores(authBloc.token!, game.gameId));
  }

  @override
  Future<Either<AppError, Game>> continueGame(Game game) async {
    return (await api.continueGame(authBloc.token!, game.gameId));
  }

  @override
  Future<Either<AppError, Game>> playMove(Game game, MovePosition move) async {
    // final sl = StoneLogic(game);

    // if (!move.isPass()) {
    //   sl.handleStoneUpdate(Position(move.x!, move.y!), thisAccountStone(game));
    // }

    return (await api.makeMove(move, authBloc.token!, game.gameId))
        .map((a) => a.game);
  }

  @override
  Future<Either<AppError, Game>> editDeadStoneCluster(
      Game game, Position pos, DeadStoneState state) async {
    final res = await api.editDeadStoneCluster(
      EditDeadStoneClusterDto(position: pos, state: DeadStoneState.Alive),
      authBloc.token!,
      game.gameId,
    );
    return res;
  }

  @override
  bool isThisAccountsTurn(Game game) {
    return game.getPlayerIdWithTurn() == authBloc.currentUserRaw.id;
  }

  @override
  StoneType thisAccountStone(Game game) {
    return game.getStoneFromPlayerId(authBloc.currentUserRaw.id)!;
  }
}

// This assumes the game is already started at time of creation
// This assumes the two player's ids are "bottom" and "top"

class FaceToFaceGameOracle extends GameStateOracle {
  final LocalGameplayServer gp;

  FaceToFaceGameOracle(this.gp);

  String get myPlayerId => "bottom";
  String get otherPlayerId => "top";

  @override
  DisplayablePlayerData myPlayerData(Game game) {
    StoneType stone = game.getStoneFromPlayerId(myPlayerId)!;

    return DisplayablePlayerData(
      displayName: stone.color,
      stoneType: stone,
      rating: null, // No rating for face to face games
    );
  }

  @override
  DisplayablePlayerData otherPlayerData(Game game) {
    StoneType stone = game.getStoneFromPlayerId(otherPlayerId)!;

    return DisplayablePlayerData(
      displayName: stone.color,
      stoneType: stone,
      rating: null, // No rating for face to face games
    );
  }

  @override
  Future<Either<AppError, Game>> resignGame(Game game) async {
    return gp.resignGame(thisAccountStone(game));
  }

  @override
  Future<Either<AppError, Game>> acceptScores(Game game) async {
    return gp.acceptScores(thisAccountStone(game));
  }

  @override
  Future<Either<AppError, Game>> continueGame(Game game) async {
    return gp.continueGame();
  }

  @override
  Future<Either<AppError, Game>> playMove(Game game, MovePosition move) async {
    var newGame = gp.makeMove(move, thisAccountStone(game));
    return newGame;
  }

  Future<Either<AppError, Game>> editDeadStoneCluster(
      Game game, Position pos, DeadStoneState state) async {
    return gp.editDeadStone(thisAccountStone(game), pos, state);
  }

  @override
  bool isThisAccountsTurn(Game game) {
    return true;
  }

  @override
  StoneType thisAccountStone(Game game) {
    return game.getStoneFromPlayerId(game.getPlayerIdWithTurn()!)!;
  }
}

class LocalGameplayServer {
  final TimeCalculator timeCalculator;

  BoardStateUtilities get boardUtils => BoardStateUtilities(_rows, _columns);

  SystemUtilities systemUtilities;
  DateTime get now => systemUtilities.currentTime;

  int _rows;
  int _columns;
  TimeControl _timeControl;
  late List<int> _prisoners;
  late Map<Position, StoneType> _playgroundMap;
  late List<GameMove> _moves;
  late List<PlayerTimeSnapshot> _playerTimeSnapshots;
  late Map<String, StoneType> _players;
  late DateTime _startTime;
  Position? _koPositionInLastMove;
  late GameState _gameState;
  late Map<Position, DeadStoneState> _stoneStates;

  List<Position> get deadStones => _stoneStates.entries
      .where((e) => e.value == DeadStoneState.Dead)
      .map((e) => e.key)
      .toList();

  String? _winnerId;
  late double _komi;
  GameOverMethod? _gameOverMethod;
  late List<int> _finalTerritoryScores;
  DateTime? _endTime;

  int get turn => _moves.length;
  int get turnPlayer => turn % 2;

  final List<StoneType> _scoresAcceptedBy = [];

  LocalGameplayServer(this._rows, this._columns, this._timeControl)
      : systemUtilities = systemUtils,
        timeCalculator = TimeCalculator() {
    initializeFields();
  }

  void initializeFields() {
    _startTime = now;

    _prisoners = [0, 0];
    _playgroundMap = {};
    _moves = [];
    _playerTimeSnapshots = [
      _timeControl.getStartingSnapshot(_startTime, true),
      _timeControl.getStartingSnapshot(_startTime, false),
    ];
    _players = {"bottom": StoneType.black, "top": StoneType.white};
    _koPositionInLastMove = null;
    _gameState = GameState.playing;
    _stoneStates = {};
    _winnerId = null;
    _komi = 6.5;
    _gameOverMethod = null;
    _finalTerritoryScores = [];
    _endTime = null;
  }

  Game getGame() {
    return Game(
      gameId: "LocalGame",
      rows: _rows,
      columns: _columns,
      timeControl: _timeControl,
      playgroundMap: _playgroundMap,
      moves: _moves,
      players: _players,
      prisoners: _prisoners,
      startTime: _startTime,
      koPositionInLastMove: _koPositionInLastMove,
      gameState: _gameState,
      deadStones: deadStones,
      winnerId: _winnerId,
      komi: _komi,
      finalTerritoryScores: _finalTerritoryScores,
      endTime: _endTime,
      gameOverMethod: _gameOverMethod,
      playerTimeSnapshots: _playerTimeSnapshots,
      gameCreator: null,
      stoneSelectionType: StoneSelectionType.auto,
      playersRatings: [],
      playersRatingsDiff: [],
    );
  }

  log(String m) {
    debugPrint(m);
  }

  Either<AppError, Game> makeMove(MovePosition move, StoneType stone) {
    assert(turnPlayer == stone.index, "It's not this player's turn");
    final stoneLogic = StoneLogic(getGame());
    try {
      if (!move.isPass()) {
        var res =
            stoneLogic.handleStoneUpdate(Position(move.x!, move.y!), stone);
        if (res.result) {
          _playgroundMap = boardUtils
              .makeHighLevelBoardRepresentationFromBoardState(res.board);
          _prisoners = res.board.prisoners
              .zip(_prisoners)
              .map((a) => a.$1 + a.$2)
              .toList();
          _koPositionInLastMove = res.board.koDelete;
        } else {
          log("Couldn't play at position");
          return left(AppError(message: "Couldn't play at position"));
        }
      }

      var moveTime = now;

      _moves.add(GameMove(time: moveTime, x: move.x, y: move.y));

      _setTimes(moveTime);

      log("Move played ${_moves.last.toJson()}");

      if (hasPassedTwice()) {
        log("Setting score calc");
        _setScoreCalculationStage();
      }

      return right(getGame());
    } on Exception catch (e) {
      return left(AppError(message: e.toString()));
    }
  }

  void _setScoreCalculationStage() {
    assert(_gameState == GameState.playing, "Game is not in playing state");
    assert(hasPassedTwice(), "Both players haven't passed twice");

    _gameState = GameState.scoreCalculation;
  }

  void _setTimes(DateTime time) {
    var times = timeCalculator.recalculateTurnPlayerTimeSnapshots(
      StoneType.values[turnPlayer],
      _playerTimeSnapshots,
      _timeControl,
      time,
    );

    _playerTimeSnapshots = times;

    // TODO: Send an event after this
    log("Reset clock to ${_playerTimeSnapshots[turnPlayer].mainTimeMilliseconds / 1000} seconds");
  }

  Either<AppError, Game> resignGame(StoneType playerStone) {
    if (_gameState == GameState.ended) {
      return left(AppError(message: "Game is already ended"));
    }

    _endGame(GameOverMethod.Resign, playerStone.other);

    return right(getGame());
  }

  Either<AppError, Game> acceptScores(StoneType stone) {
    if (_gameState != GameState.scoreCalculation) {
      return left(AppError(message: "Game is not in score calculation stage"));
    }

    _scoresAcceptedBy.add(stone);

    if (_scoresAcceptedBy.length == 2) {
      _endGame(GameOverMethod.Score, null);
    }

    return right(getGame());
  }

  Either<AppError, Game> continueGame() {
    _gameState = GameState.playing;
    _stoneStates.clear();
    _scoresAcceptedBy.clear();

    return right(getGame());
  }

  Either<AppError, Game> editDeadStone(
      StoneType stone, Position pos, DeadStoneState state) {
    if (_gameState != GameState.scoreCalculation) {
      throw Exception("Game is not in score calculation stage");
    }

    _scoresAcceptedBy.clear();

    if (_stoneStates[pos] != state) {
      final newBoard = boardUtils.boardStateFromGame(getGame());

      for (var pos in (newBoard.playgroundMap[pos]?.cluster.data ?? {})) {
        _stoneStates[pos] = state;
      }
    }

    return right(getGame());
  }

  void _endGame(
    GameOverMethod method,
    StoneType? winner,
  ) {
    final List<int> scores = [];
    final stoneLogic = StoneLogic(getGame());

    if (method == GameOverMethod.Score) {
      final calc = ScoreCalculator(
        rows: _rows,
        cols: _columns,
        komi: _komi,
        deadStones: deadStones,
        prisoners: _prisoners,
        playground: stoneLogic.board.playgroundMap,
      );

      scores.addAll(calc.territoryScores);
      winner = StoneType.values[calc.getWinner()];
    }

    _gameState = GameState.ended;
    _playerTimeSnapshots = [
      _playerTimeSnapshots[0].copyWith(timeActive: false),
      _playerTimeSnapshots[1].copyWith(timeActive: false),
    ];
    _finalTerritoryScores = scores;
    _winnerId = _players.keys.firstWhere((k) => _players[k] == winner);
    _gameOverMethod = method;
    _endTime = now;
  }

  // Helpers
  bool hasPassedTwice() {
    GameMove? prev;
    bool hasPassedTwice = false;
    for (var i in (_moves).reversed) {
      if (prev == null) {
        prev = i;
        continue;
      }
      if (i.isPass() && prev.isPass()) {
        hasPassedTwice = !hasPassedTwice;
      } else {
        break;
      }
    }
    return hasPassedTwice;
  }
}

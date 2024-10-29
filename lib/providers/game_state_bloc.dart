import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/system_utilities.dart';
import 'package:go/gameplay/stages/score_calculation_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/move_position.dart';
import 'package:go/services/join_message.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/utils/player.dart';
import 'package:ntp/ntp.dart';
import 'package:signalr_netcore/errors.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:timer_count_down/timer_controller.dart';

class GameStateBloc extends ChangeNotifier {
  final Api api;
  final AuthProvider authBloc;
  final SignalRProvider signalRbloc;
  final SystemUtilities systemUtilities;
  Game game;
  // Stage curStage;

  GameStateBloc(
    this.api,
    this.signalRbloc,
    this.authBloc,
    this.game,
    this.systemUtilities,
    // this.curStage,
    StageType curStageType,
    GameJoinMessage? joiningData,
  )   : times = [
          ValueNotifier(Duration(seconds: game.timeInSeconds)),
          ValueNotifier(Duration(seconds: game.timeInSeconds))
        ],
        curStageTypeNotifier = ValueNotifier(curStageType),
        myPlayerUserInfo = PublicUserInfo(
          authBloc.currentUserRaw!.email,
          authBloc.currentUserRaw!.id,
        ) {
    setupGame(game, joiningData);
    setupStreams();
    subscriptions = [listenFromGameJoin(), listenForMove()];
  }

  late final List<Player> _players;
  List<Player> get players => List.unmodifiable(_players);

  StoneType get myStone => game.players[authBloc.currentUserRaw!.id]!;
  StoneType get otherStone => StoneType.values[1 - myStone.index];

  int get turn => game.moves.length;

  int get gametime => game.timeInSeconds;

  Player get getPlayerWithTurn => _players[turn % 2];
  Player get getPlayerWithoutTurn => _players[turn % 2 == 0 ? 1 : 0];

  // Join Data

  PublicUserInfo myPlayerUserInfo;
  PublicUserInfo? otherPlayerUserInfo;

  List<ValueNotifier<Duration>> times;

  Set<Position> finalRemovedCluster = {};

  final List<CountdownController> _controller = [
    CountdownController(autoStart: false),
    CountdownController(autoStart: false)
  ];

  List<CountdownController> get timerController => _controller;

  ValueNotifier<StageType> curStageTypeNotifier;
  StageType get curStageType => curStageTypeNotifier.value;
  set curStageType(StageType stage) {
    // cur_stage.disposeStage();
    curStageTypeNotifier.value = stage;
  }

  void setupGame(Game game, GameJoinMessage? joiningData) {
    _players = [Player(0), Player(1)];

    if (joiningData != null) {
      joinGame(joiningData);
    }
  }

  // Stream<bool> listenForGameEndRequest() {
  //   return signalRbloc.gameMessageController.stream
  //       .where((message) => message.placeholder is bool)
  //       .cast();
  // }

  late final List<StreamSubscription> subscriptions;
  late final Stream<GameJoinMessage> listenForGameJoin;
  late final Stream<bool> listenFromOpponentConfirmation;
  late final Stream<(bool, Position)> listenFromRemovedCluster;
  late final Stream<NewMoveMessage> listenFromMove;

  void setupStreams() {
    var gameMessageStream = signalRbloc.gameMessageStream;
    listenForGameJoin = gameMessageStream.asyncExpand((message) async* {
      if (message.data is GameJoinMessage) {
        yield message.data as GameJoinMessage;
      }
    });
    listenFromOpponentConfirmation =
        gameMessageStream.asyncExpand((message) async* {
      if (message.data is bool) {
        yield message.data as bool;
      }
    });

    listenFromRemovedCluster = gameMessageStream.asyncExpand((message) async* {
      if (message.data is (bool, Position)) {
        yield message.data as (bool, Position);
      }
    });
    listenFromMove = gameMessageStream.asyncExpand((message) async* {
      if (message.data is NewMoveMessage) {
        yield message.data as NewMoveMessage;
      }
    });
  }

  StreamSubscription listenFromGameJoin() {
    return listenForGameJoin.listen((message) {
      joinGame(message);
      debugPrint("Joined game BAHAHA");
      notifyListeners();
    });
  }

  void joinGame(GameJoinMessage joinMessage) {
    // _startTime = DateTime.parse((joinMessage.time));
    game = joinMessage.game;

    var myPlayerInfoIndex = joinMessage.players
        .indexWhere((element) => element.id == authBloc.currentUserRaw!.id);

    myPlayerUserInfo = joinMessage.players[myPlayerInfoIndex];
    otherPlayerUserInfo = joinMessage.players[myPlayerInfoIndex == 0 ? 1 : 0];

    var now = systemUtilities.currentTime;
    times[getPlayerWithTurn.turn].value =
        times[getPlayerWithTurn.turn].value - now.difference(joinMessage.time);

    startPausedTimerOfActivePlayer();

    curStageType = StageType.Gameplay;
  }

  StreamSubscription listenForMove() {
    return listenFromMove.listen((message) {
      final game = message.game;
      debugPrint("Got move ${authBloc.token}");
      // assert(data != null, "Game move data can't be null");
      applyMoveResult(game);
    });
    // signalRbloc.hubConnection.on('gameMove', (data) {});
  }

  Future<Either<AppError, GameMove>> playMove(MovePosition moveDto) async {
    var token = authBloc.token!;

    var updatedGame = await api.makeMove(
      moveDto,
      token,
      game.gameId,
    );

    return updatedGame.fold((l) {
      debugPrint("Move failure ${l.message}");
      return left(AppError(message: l.message));
    }, (r) {
      if (r.result) {
        applyMoveResult(r.game);
        return right(game.moves.last);
      } else {
        return left(AppError(message: "Invalid move"));
      }
    });

    // var tmpMove = GameMove(time: DateTime.now(), x: moveDto.x, y: moveDto.y);
    // var tmpGame = game.copyWith(moves: [...game.moves, tmpMove]);

    // applyMoveResult(tmpGame);
  }

  void applyMoveResult(Game game) {
    this.game = game;

    setTurnTimerAfterMoveWasAdded();

    if (game.gameState == GameState.scoreCalculation) {
      curStageType = StageType.ScoreCalculation;
    }

    notifyListeners();
  }

  void setTurnTimerAfterMoveWasAdded() {
    int turn = this.turn;
    var times = [game.startTime!, ...game.moves.map((e) => e.time)];

    var turnPlayerTimer = timerController[turn % 2];
    turnPlayerTimer.start();

    var nonTurnPlayerTimer = timerController[1 - turn % 2];
    nonTurnPlayerTimer.pause();

    var firstPlayerDuration = times
        .mapWithIndex((e, i) => (e, i))
        .filterWithIndex((e, i) => i % 2 == 1)
        .fold(const Duration(), (d, r) => d + r.$1.difference(times[r.$2 - 1]));

    this.times[0].value =
        Duration(seconds: game.timeInSeconds) - firstPlayerDuration;

    var secondPlayerTimes = times
        .mapWithIndex((e, i) => (e, i))
        .skip(1)
        .filterWithIndex((e, i) => i % 2 == 1);

    var secondPlayerDuration = times
        .mapWithIndex((e, i) => (e, i))
        .skip(1)
        .filterWithIndex((e, i) => i % 2 == 1)
        .fold(const Duration(), (d, r) => d + r.$1.difference(times[r.$2 - 1]));

    debugPrint("times: ${times.fold("", (s, d) => "$s$d ,")}");
    debugPrint(
        "secondPlayerTimes: ${secondPlayerTimes.fold("", (s, d) => "$s$d ,")}");

    debugPrint("Second Player time: ${secondPlayerDuration.inSeconds}");
    this.times[1].value =
        Duration(seconds: game.timeInSeconds) - secondPlayerDuration;

    // Also calculate the lag time and incorporate that for player with turn
    this.times[getPlayerWithTurn.turn].value -=
        systemUtilities.currentTime.difference(game.moves.last.time);
  }

  String getPlayerIdFromTurn(int turn) {
    for (var e in game.players.entries) {
      if (e.value.index == turn) {
        return e.key;
      }
    }
    throw NotImplementedException();
  }

  void endGame() {
    // TODO: call api here
  }

  bool isMyTurn() {
    return game.players[authBloc.currentUserRaw!.id]!.index == turn % 2;
  }

  bool hasPassedTwice() {
    var prev;
    bool hasPassedTwice = false;
    for (var i in (game.moves).reversed) {
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

  void unsetFinalRemovedCluster() {
    finalRemovedCluster = {};

    // TODO: call api to reset final removed cluster??
    // MultiplayerData.of(context)?.curGameReferences?.gameEndData.remove();
  }

  void continueGame() {
    // TODO: call api to continue game
  }

  void confirmGameEnd() {
    // TODO: call api to end game
  }

  void startPausedTimerOfActivePlayer() {
    timerController[getPlayerWithTurn.turn].start();
  }

  void removeClusterFromRemovedClusters(Cluster cluster) {
    // TODO: call api
  }

  void addClusterToRemovedClusters(Cluster cluster) {
    // TODO: call api
  }

  Set<Cluster> getRemovedClusters() {
    return {};
    // TODO: call api
  }

  int getRemotePlayerIndex() {
    final stone = game.players[(authBloc.currentUserRaw)!.id];
    // game.players.indexWhere((k) => k != (authBloc.currentUserRaw)!.id);
    if (stone == null) {
      throw ("remote player not found");
    }
    return 1 - stone.index;
  }

  int getClientPlayerIndex() {
    final stone = game.players[(authBloc.currentUserRaw)!.id];
    // final index =
    //     game.players.indexWhere((k) => k == (authBloc.currentUserRaw)!.id);
    if (stone == null) {
      throw ("client player not found");
    }
    return stone.index;
  }
}

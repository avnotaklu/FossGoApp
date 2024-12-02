import 'dart:async';
import 'dart:math';
import 'package:barebones_timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/score_calculation_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/models/stone.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/app_user.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/services/move_position.dart';
import 'package:go/services/join_message.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/ui/gameui/game_timer.dart';
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

  // late final List<Player> _players;
  // List<Player> get players => List.unmodifiable(_players);

  StoneType get myStone => game.players[authBloc.currentUserRaw.id]!;
  StoneType get otherStone => StoneType.values[1 - myStone.index];

  int get turn => game.moves.length;
  int get playerTurn => game.moves.length % 2;

  int get gametime => game.timeControl.mainTimeSeconds;

  // Player get getPlayerWithTurn => _players[turn % 2];
  // Player get getPlayerWithoutTurn => _players[turn % 2 == 0 ? 1 : 0];

  StoneType? get getWinnerStone => game.players[game.winnerId];
  StoneType? get getLoserStone => game.players[game.winnerId] == null
      ? null
      : StoneType.values[1 - game.players[game.winnerId]!.index];

  GameOverMethod? get getGameOverMethod => game.gameOverMethod;

  List<double> get getSummedPlayerScores => [
        game.finalTerritoryScores[0].toDouble() + game.prisoners[0],
        game.finalTerritoryScores[1].toDouble() + game.prisoners[1] + game.komi,
      ];

  String getPlayerIdFromStoneType(StoneType stone) {
    return game.players.entries
        .firstWhere((element) => element.value == stone)
        .key;
  }

  bool iAccepted = false;

  // Join Data

  PublicUserInfo myPlayerUserInfo;
  PublicUserInfo? otherPlayerUserInfo;

  // List<Duration> times;
  final List<TimerController> _controller;

  List<TimerController> get timerController => _controller;

  StageType curStageTypeNotifier;
  StageType get curStageType => curStageTypeNotifier;

  set curStageType(StageType stage) {
    // cur_stage.disposeStage();
    curStageTypeNotifier = stage;
  }
  // Stream<bool> listenForGameEndRequest() {
  //   return signalRbloc.gameMessageController.stream
  //       .where((message) => message.placeholder is bool)
  //       .cast();
  // }

  late final List<StreamSubscription> subscriptions;
  late final Stream<GameJoinMessage> listenForGameJoin;
  late final Stream<EditDeadStoneMessage> listenForEditDeadStone;
  late final Stream<NewMoveMessage> listenFromMove;
  late final Stream<GameOverMessage> listenFromGameOver;
  late final Stream<GameTimerUpdateMessage> listenFromGameTimerUpdate;
  late final Stream<Null> listenFromAcceptScores;
  late final Stream<ContinueGameMessage> listenFromContinueGame;

  GameStateBloc(
    this.api,
    this.signalRbloc,
    this.authBloc,
    this.game,
    this.systemUtilities,
    // this.curStage,
    StageType curStageType,
    GameJoinMessage? joiningData,
  )   : _controller = [
          TimerController(
            autoStart: false,
            updateInterval: const Duration(milliseconds: 100),
            duration: Duration(seconds: game.timeControl.mainTimeSeconds),
          ),
          TimerController(
            autoStart: false,
            updateInterval: const Duration(milliseconds: 100),
            duration: Duration(seconds: game.timeControl.mainTimeSeconds),
          )
        ],
        curStageTypeNotifier = curStageType,
        myPlayerUserInfo = PublicUserInfo(
          authBloc.currentUserRaw.email,
          authBloc.currentUserRaw.id,
          authBloc.currentUserRating,
        ) {
    setupGame(game, joiningData);
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

  void setupGame(Game game, GameJoinMessage? joiningData) {
    // _players = [Player(0), Player(1)];

    if (joiningData != null) {
      applyJoinMessage(joiningData);
    }
  }

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

  StreamSubscription listenFromGameJoin() {
    return listenForGameJoin.listen((message) {
      applyJoinMessage(message);
      debugPrint("Joined game BAHAHA");
      notifyListeners();
    });
  }

  void applyJoinMessage(GameJoinMessage joinMessage) {
    game = joinMessage.game;
    otherPlayerUserInfo = joinMessage.otherPlayerData;

    if (game.startTime != null && game.gameState == GameState.playing) {
      setPlayerTimes();
      recalculatePlayerLagTime();

      // NOTE: the below hack seems to be fixed now, test it and remove the hack
      // HACK: This is a hack to make sure that the timer starts after the ui is rendered
      // The reason is that the timer controller is not started even when called start() function
      // The controller checks for presense of onStart method, which is supplied via ui
      // check `CountdownController.start() in timer_controller.dart`

      // Future.delayed(const Duration(milliseconds: 300), () {
      //   startPausedTimerOfActivePlayer();
      // });

      startPausedTimerOfActivePlayer();

      curStageType = StageType.Gameplay;
      notifyListeners();
    }
    if (GameState.scoreCalculation == game.gameState) {
      curStageType = StageType.ScoreCalculation;
      notifyListeners();
    }
    if (game.gameState == GameState.ended) {
      applyEndGame();
    }
  }

  StreamSubscription listenForContinueGame() {
    return listenFromContinueGame.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.continueGame}::\n\t\t${message.toMap()}");
      applyContinue();
    });
    // signalRbloc.hubConnection.on('gameMove', (data) {});
  }

  StreamSubscription listenForMove() {
    return listenFromMove.listen((message) {
      final game = message.game;
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.newMove}::\n\t\t${message.toMap()}");
      // assert(data != null, "Game move data can't be null");
      applyMoveResult(game);
    });
    // signalRbloc.hubConnection.on('gameMove', (data) {});
  }

  StreamSubscription listenForAcceptScore() {
    return listenFromAcceptScores.listen((message) {
      debugPrint("Signal R said, ::${SignalRMessageTypes.acceptedScores}::");
    });
  }

  StreamSubscription listenForGameOver() {
    return listenFromGameOver.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.gameOver}::\n\t\t${message.toMap()}");
      game = message.game;
      applyEndGame();
    });
  }

  StreamSubscription listenForGameTimerUpdate() {
    return listenFromGameTimerUpdate.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.gameTimerUpdate}::\n\t\t${message.toMap()}");
      final newPlayerTimeSnapshots = game.playerTimeSnapshots;
      newPlayerTimeSnapshots[message.player.index] = message.currentPlayerTime;
      game.copyWith(playerTimeSnapshots: newPlayerTimeSnapshots);

      setPlayerTimes();
      recalculatePlayerLagTime();

      notifyListeners();

      setTurnTimer();
    });
  }

  Future<Either<AppError, GameMove>> playMove(
      Position? position, StoneLogic stoneLogic) async {
    bool canPlayMove = isMyTurn();
    if (position == null && canPlayMove) {
      canPlayMove = true;
    } else if (position != null && canPlayMove) {
      canPlayMove = (stoneLogic.stoneAt(position) == null) &&
          stoneLogic.checkInsertable(position, myStone);
    }

    if (!canPlayMove) {
      return left(AppError(message: "You can't play here"));
    }

    // If there is no stone at this position and this is users turn, place stone
    final move = MovePosition(
      // playedAt: value,
      x: position?.x,
      y: position?.y,
    );

    var token = authBloc.token!;

    if (!move.isPass()) {
      stoneLogic.handleStoneUpdate(position);
    }

    var updatedGame = await api.makeMove(
      move,
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
  }

  void applyMoveResult(Game game) {
    this.game = game;

    setPlayerTimes();
    recalculatePlayerLagTime();

    if (game.gameState == GameState.scoreCalculation) {
      curStageType = StageType.ScoreCalculation;
    }

    notifyListeners();

    setTurnTimer();
  }

  void setPlayerTimes() {
    _controller[playerTurn].updateDuration(Duration(
        milliseconds:
            game.playerTimeSnapshots[playerTurn].mainTimeMilliseconds));

    _controller[1 - playerTurn].updateDuration(Duration(
        milliseconds:
            game.playerTimeSnapshots[1 - playerTurn].mainTimeMilliseconds));
  }

  void recalculatePlayerLagTime() {
    // Also calculate the lag time and incorporate that for player with turn
    _controller[playerTurn].updateDuration(_controller[playerTurn].duration -
        systemUtilities.currentTime.difference(
          game.playerTimeSnapshots[playerTurn].snapshotTimestamp,
        ));
  }

  void setTurnTimer() {
    var turnPlayerTimer = timerController[playerTurn];
    turnPlayerTimer.start();

    // applyTimesOfDiscreteSections();

    var nonTurnPlayerTimer = timerController[1 - playerTurn];
    nonTurnPlayerTimer.pause();
  }

  String getPlayerIdFromTurn(int turn) {
    for (var e in game.players.entries) {
      if (e.value.index == turn) {
        return e.key;
      }
    }
    throw NotImplementedException();
  }

  void applyEndGame() {
    setPlayerTimes();

    curStageType = StageType.GameEnd;
    timerController[0].pause();
    timerController[1].pause();
    notifyListeners();
  }

  bool isMyTurn() {
    return game.players[authBloc.currentUserRaw.id]!.index == turn % 2;
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

  Future<Either<AppError, Game>> continueGame() async {
    return (await api.continueGame(authBloc.token!, game.gameId))
        .fold((l) => left(l), (r) {
      game = r;
      applyContinue();
      return right(r);
    });
  }

  void applyContinue() {
    curStageType = StageType.Gameplay;
    startPausedTimerOfActivePlayer();
  }

  Future<void> acceptScores() async {
    if (iAccepted) return;
    final token = authBloc.token!;
    final gameId = game.gameId;
    final res = await api.acceptScores(token, gameId);

    res.fold((l) {
      debugPrint("Accept scores failed ${l.message}");
    }, (r) {
      game = r;
      if (game.gameOverMethod != null) {
        applyEndGame();
      }
    });
  }

  Future<Either<AppError, Game>> resignGame() async {
    return (await api.resignGame(authBloc.token!, game.gameId))
        .fold((l) => left(l), (r) {
      game = r;
      applyEndGame();
      return right(r);
    });
  }

  void startPausedTimerOfActivePlayer() {
    timerController[playerTurn].start();
  }

  StoneType? getRemoteStone() {
    if (!game.didStart()) return null;
    return game.players.entries
        .firstWhere((element) => element.key != authBloc.currentUserRaw.id)
        .value;
  }

  StoneType? getMyStone() {
    if (!game.didStart()) return null;
    return game.players[authBloc.currentUserRaw.id];
  }
}
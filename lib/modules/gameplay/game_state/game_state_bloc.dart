import 'dart:async';
import 'package:barebones_timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/models/minimal_rating.dart';
import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:go/models/edit_dead_stone_dto.dart';
import 'package:go/models/game_over_message.dart';
import 'package:go/models/move_position.dart';
import 'package:go/models/player_rating.dart';
import 'package:go/models/signal_r_message.dart';

import 'package:signalr_netcore/errors.dart';

class DisplayablePlayerData {
  final String displayName;
  final StoneType? stoneType;
  final MinimalRating? rating;
  final int? ratingDiffOnEnd;
  final double? komi;
  final int? prisoners;
  final int? score;
  final bool waiting;

  DisplayablePlayerData({
    required this.waiting,
    required this.displayName,
    required this.stoneType,
    required this.rating,
    required this.ratingDiffOnEnd,
    required this.komi,
    required this.prisoners,
    required this.score,
  });
}

class GameStateBloc extends ChangeNotifier {
  Game game;

  final StoneLogic stoneLogic;

  int get turn => game.moves.length;
  int get playerTurn => game.moves.length % 2;

  int get gametime => game.timeControl.mainTimeSeconds;

  StoneType? get getWinnerStone => game.result?.getWinnerStone();
  StoneType? get getLoserStone => game.result?.getLoserStone();

  GameOverMethod? get getGameOverMethod => game.gameOverMethod;

  List<double> get getSummedPlayerScores => [
        game.finalScore[0].toDouble(),
        game.finalScore[1].toDouble() + game.komi,
      ];

  Map<StoneType, bool> acceptedBy = {
    StoneType.black: false,
    StoneType.white: false
  };

  // Oracle getters
  GamePlatform getPlatform() {
    return gameOracle.getPlatform();
  }

  DisplayablePlayerData? get blackPlayer => [
        bottomPlayerUserInfo,
        topPlayerUserInfo
      ].firstWhere((a) => a?.stoneType == StoneType.black);

  DisplayablePlayerData? get whitePlayer => [
        bottomPlayerUserInfo,
        topPlayerUserInfo
      ].firstWhere((a) => a?.stoneType == StoneType.white);

  DisplayablePlayerData get bottomPlayerUserInfo =>
      gameOracle.myPlayerData(game);
  DisplayablePlayerData get topPlayerUserInfo =>
      gameOracle.otherPlayerData(game);

  late final List<Duration> prevTimes;
  final List<TimerController> _controller;

  List<TimerController> get timerController => _controller;

  late StageType curStageType;

  final GameStateOracle gameOracle;
  final SystemUtilities systemUtilities;
  final SettingsProvider settingsProvider;

  late final TimerController headsUpTimeController;

  late final StreamSubscription<GameUpdate> gameUpdateListener;
  final StreamController<GameState> _gameStateUpdate =
      StreamController.broadcast();

  Stream<Null> get gameEndStream => gameOracle.gameEndStream;
  Stream<(GameMove, int)> get gameMoveStream => gameOracle.moveUpdate;
  Stream<ConnectionStrength>? get opponentConnection =>
      gameOracle.opponentConnection;
  Stream<GameState> get gameStateStream => _gameStateUpdate.stream;

  GameStateBloc(
    this.game,
    this.gameOracle,
    this.systemUtilities,
    this.settingsProvider,
  )   : stoneLogic = StoneLogic(game),
        _controller = [
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
        ] {
    prevTimes = [
      timerController[0].duration,
      timerController[1].duration,
    ];
    updateStateFromGame(game);

    gameUpdateListener = gameOracle.gameUpdate.listen((event) {
      updateStateFromGame(event.makeCopyFromOldGame(game));
    });

    gameMoveStream.listen((move) {
      if (!move.$1.isPass()) {
        var res = stoneLogic.handleStoneUpdate(
            move.$1.toPosition(), StoneTypeExt.fromMoveNumber(move.$2));

        if (settingsProvider.sound) {
          systemUtilities.playSound(SoundAsset.placeStone);
        }

        assert(res.result);
      }
    });

    for (var i = 0; i < timerController.length; i++) {
      timerController[i].durationUpdateStream.listen((d) {
        if (d.inSeconds < 10 &&
            prevTimes[i].inSeconds >= 10 &&
            settingsProvider.sound) {
          systemUtils.playSound(SoundAsset.message);
        }
        prevTimes[i] = d;
      });
    }
  }

  void resetBoard(BoardStateBloc board) {
    board.intermediate = null;
    board.updateBoard(stoneLogic.board);
  }

  Either<AppError, MovePosition> placeStone(
    Position position,
    BoardStateBloc bloc,
  ) {
    if (bloc.intermediateIsPlayed) {
      return right(bloc.intermediate!);
    }

    final tmpStoneLogic = stoneLogic.deepCopy();

    bool canPlayMove = gameOracle.isThisAccountsTurn(game);
    var updateStone = gameOracle.thisAccountStone(game);

    if (canPlayMove) {
      return bloc.placeStone(position, stoneLogic, updateStone);
    } else {
      return left(AppError(message: "It's not your turn"));
    }
  }

  Future<Either<AppError, Game>> makeMove(
    MovePosition move,
    BoardStateBloc bloc,
  ) async {
    bloc.intermediateIsPlayed = true;
    return (await gameOracle.playMove(game, move)).map((g) {
      bloc.intermediate = null;
      return updateStateFromGame(g);
    }).mapLeft((l) {
      bloc.intermediate = null;
      return l;
    });
  }

  void updateNewPlayerTimes(Game game) {
    _controller[playerTurn].updateDuration(Duration(
        milliseconds:
            game.playerTimeSnapshots[playerTurn].mainTimeMilliseconds));

    _controller[1 - playerTurn].updateDuration(Duration(
        milliseconds:
            game.playerTimeSnapshots[1 - playerTurn].mainTimeMilliseconds));
  }

  void recalculatePlayerLagTime() {
    _controller[playerTurn].updateDuration(_controller[playerTurn].duration -
        systemUtilities.currentTime.difference(
          game.playerTimeSnapshots[playerTurn].snapshotTimestamp,
        ));
  }

  Future<Either<AppError, Game>> continueGame() async {
    return (await gameOracle.continueGame(game)).map((g) {
      return updateStateFromGame(g);
    });
  }

  Future<Either<AppError, Game>> acceptScores() async {
    return (await gameOracle.acceptScores(game)).map((g) {
      return updateStateFromGame(g);
    });
  }

  Future<Either<AppError, Game>> resignGame() async {
    return (await gameOracle.resignGame(game)).map((g) {
      return updateStateFromGame(g);
    });
  }

  Future<Either<AppError, Game>> editDeadStone(
      Position pos, DeadStoneState state) async {
    return gameOracle.editDeadStoneCluster(game, pos, state);
  }

  void startPausedTimerOfActivePlayer() {
    timerController[playerTurn].start();
    timerController[1 - playerTurn].pause();
  }

  Game updateStateFromGame(Game game) {
    if (game.gameState != this.game.gameState) {
      _gameStateUpdate.add(game.gameState);
    }

    this.game = game;
    _updateStageType(game.gameState);

    if (game.didStart()) {
      updateNewPlayerTimes(game);
    }

    if (game.gameState == GameState.playing) {
      recalculatePlayerLagTime();
      startPausedTimerOfActivePlayer();
    } else {
      timerController[0].pause();
      timerController[1].pause();
    }

    if (game.bothPlayersIn() && game.gameState == GameState.waitingForStart) {
      headsUpTimeController = TimerController(
        autoStart: true,
        updateInterval: const Duration(milliseconds: 200),
        duration: gameOracle.headsUpTime,
      );
    }

    notifyListeners();
    return game;
  }

  void _updateStageType(GameState state) {
    if (state == GameState.playing) {
      curStageType = StageType.gameplay;
    } else if (state == GameState.scoreCalculation) {
      curStageType = StageType.scoreCalculation;
    } else if (state == GameState.ended) {
      curStageType = StageType.gameEnd;
    } else if (state == GameState.waitingForStart) {
      curStageType = StageType.beforeStart;
    }
  }

  void enterAnalysisMode() {
    curStageType = StageType.analysis;
    notifyListeners();
  }

  void exitAnalysisMode() {
    var curState = game.gameState;
    _updateStageType(curState);
    notifyListeners();
  }
}
